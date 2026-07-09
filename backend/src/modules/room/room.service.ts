import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Room, RoomMember } from '../../database/entities/room.entity';
import { Habit } from '../../database/entities/habit.entity';
import * as crypto from 'crypto';

@Injectable()
export class RoomService {
  constructor(
    @InjectRepository(Room) private roomRepo: Repository<Room>,
    @InjectRepository(RoomMember) private memberRepo: Repository<RoomMember>,
    @InjectRepository(Habit) private habitRepo: Repository<Habit>,
    private dataSource: DataSource,
  ) {}

  /** 用户注册时自动分配房间：生成了房码则返回，未提供则创建新房间 */
  async setupRoom(userId: number, roomCode?: string, creatorName?: string): Promise<Room> {
    if (roomCode) {
      // 加入已有房间
      const room = await this.roomRepo.findOne({ where: { code: roomCode } });
      if (!room) throw new BadRequestException('房间码无效，请检查后重试');
      await this.memberRepo.save(this.memberRepo.create({ roomId: room.id, userId }));
      await this.initDefaultHabits(room.id);
      return room;
    }
    // 创建新房间
    const code = await this.generateUniqueCode();
    const room = await this.roomRepo.save(this.roomRepo.create({
      code, name: creatorName ? `${creatorName}的小窝` : '温馨小窝', creatorId: userId,
    }));
    await this.memberRepo.save(this.memberRepo.create({ roomId: room.id, userId }));
    await this.initDefaultHabits(room.id);
    return room;
  }

  /** 获取用户当前房间 */
  async getUserRoom(userId: number): Promise<Room | null> {
    const member = await this.memberRepo.findOne({ where: { userId } });
    if (!member) return null;
    return this.roomRepo.findOne({ where: { id: member.roomId } });
  }

  async getUserRoomId(userId: number): Promise<number | null> {
    const member = await this.memberRepo.findOne({ where: { userId } });
    return member?.roomId ?? null;
  }

  /** 获取房间内所有成员 */
  async getMembers(roomId: number): Promise<RoomMember[]> {
    return this.memberRepo.find({ where: { roomId } });
  }

  /** 换房间 */
  async joinRoom(userId: number, roomCode: string): Promise<Room> {
    const room = await this.roomRepo.findOne({ where: { code: roomCode } });
    if (!room) throw new BadRequestException('房间码无效');
    // 先退出现有房间
    await this.memberRepo.delete({ userId });
    await this.memberRepo.save(this.memberRepo.create({ roomId: room.id, userId }));
    await this.initDefaultHabits(room.id);
    return room;
  }

  private async initDefaultHabits(roomId: number) {
    const existing = await this.habitRepo.find({ where: { roomId } });
    if (existing.length > 0) return;
    const defaults = [
      { name: '喝水', icon: '💧' }, { name: '吃水果', icon: '🍎' },
      { name: '睡觉时间', icon: '😴' }, { name: '认真护肤', icon: '🧴' }, { name: '做家务', icon: '🏠' },
    ];
    for (let i = 0; i < defaults.length; i++) {
      await this.habitRepo.save(this.habitRepo.create({
        roomId, name: defaults[i].name, icon: defaults[i].icon, sortOrder: i,
      } as any));
    }
  }

  private async generateUniqueCode(): Promise<string> {
    const CHARS = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    for (let attempt = 0; attempt < 50; attempt++) {
      const bytes = crypto.randomBytes(6);
      let code = '';
      for (let i = 0; i < 6; i++) code += CHARS[bytes[i] % CHARS.length];
      const exists = await this.roomRepo.findOne({ where: { code } });
      if (!exists) return code;
    }
    throw new BadRequestException('生成房间码失败，请重试');
  }
}
