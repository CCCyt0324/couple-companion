import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from '../../database/entities/user.entity';
import { Room } from '../../database/entities/room.entity';
import { generateSmsCode } from '../../common/utils/helpers';
import { RoomService } from '../room/room.service';
import {
  PhoneRegisterDto, EmailRegisterDto, RegisterResultDto,
  PhoneLoginDto,
} from './auth.dto';

@Injectable()
export class AuthService {
  private smsCodes = new Map<string, { code: string; expires: number }>();

  constructor(
    @InjectRepository(User) private userRepo: Repository<User>,
    private jwtService: JwtService,
    private roomService: RoomService,
  ) {}

  async sendSmsCode(phone: string): Promise<void> {
    const code = generateSmsCode();
    this.smsCodes.set(phone, { code, expires: Date.now() + 5 * 60 * 1000 });
    console.log(`[短信验证码] ${phone} → ${code}`);
  }

  async phoneRegister(dto: PhoneRegisterDto): Promise<RegisterResultDto> {
    const record = this.smsCodes.get(dto.phone);
    if (!record || record.expires < Date.now()) throw new BadRequestException('验证码已过期');
    if (record.code !== dto.smsCode) throw new BadRequestException('验证码错误');

    const existing = await this.userRepo.findOne({ where: { phone: dto.phone } });
    if (existing) throw new BadRequestException('该手机号已注册');

    return this.createUser(dto.nickname, dto.phone, undefined, undefined, dto.password, dto.roomCode);
  }

  async emailRegister(dto: EmailRegisterDto): Promise<RegisterResultDto> {
    const existing = await this.userRepo.findOne({ where: { email: dto.email } });
    if (existing) throw new BadRequestException('该邮箱已注册');
    return this.createUser(dto.nickname, undefined, dto.email, undefined, dto.password, dto.roomCode);
  }

  private async createUser(
    nickname: string, phone?: string, email?: string, wechatOpenid?: string,
    password?: string, roomCode?: string,
  ): Promise<RegisterResultDto> {
    const passwordHash = password
      ? await bcrypt.hash(password, 10)
      : await bcrypt.hash(Math.random().toString(36), 10);

    const user = this.userRepo.create({ phone, email, wechatOpenid, nickname, passwordHash });
    await this.userRepo.save(user);

    // 创建或加入房间
    let room: Room | null = null;
    try {
      room = await this.roomService.setupRoom(user.id, roomCode, nickname);
    } catch (e) {
      // 房间码无效时仍正常注册，后续可再加入
    }

    const token = this.jwtService.sign({ sub: user.id, nickname: user.nickname });
    return { token, user, room };
  }

  async phoneLogin(dto: PhoneLoginDto): Promise<RegisterResultDto> {
    const user = await this.userRepo.findOne({ where: { phone: dto.phone } });
    if (!user) throw new UnauthorizedException('手机号未注册');
    const valid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!valid) throw new UnauthorizedException('密码错误');
    const token = this.jwtService.sign({ sub: user.id, nickname: user.nickname });
    const room = await this.roomService.getUserRoom(user.id);
    return { token, user, room };
  }

  async emailLogin(email: string, password: string): Promise<RegisterResultDto> {
    const user = await this.userRepo.findOne({ where: { email } });
    if (!user) throw new UnauthorizedException('邮箱未注册');
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new UnauthorizedException('密码错误');
    const token = this.jwtService.sign({ sub: user.id, nickname: user.nickname });
    const room = await this.roomService.getUserRoom(user.id);
    return { token, user, room };
  }
}
