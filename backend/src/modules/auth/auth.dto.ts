import { IsString, Length, IsEmail, IsOptional } from 'class-validator';
import { User } from '../../database/entities/user.entity';
import { Room } from '../../database/entities/room.entity';

export class PhoneRegisterDto {
  @IsString() @Length(11, 11) phone: string;
  @IsString() @Length(6, 6) smsCode: string;
  @IsString() @Length(2, 20) nickname: string;
  @IsString() @Length(6, 32) password: string;
  @IsOptional() @IsString() @Length(6, 6) roomCode?: string;
}

export class EmailRegisterDto {
  @IsEmail() email: string;
  @IsString() @Length(2, 20) nickname: string;
  @IsString() @Length(6, 32) password: string;
  @IsOptional() @IsString() @Length(6, 6) roomCode?: string;
}

export class PhoneLoginDto {
  @IsString() @Length(11, 11) phone: string;
  @IsString() @Length(6, 32) password: string;
}

export class EmailLoginDto {
  @IsEmail() email: string;
  @IsString() @Length(6, 32) password: string;
}

export class SendSmsDto {
  @IsString() @Length(11, 11) phone: string;
}

export class RegisterResultDto {
  token: string;
  user: User;
  room?: Room | null;
}
