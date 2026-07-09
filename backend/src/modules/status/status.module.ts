import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserStatus, StatusInteraction } from '../../database/entities/user-status.entity';
import { RoomModule } from '../room/room.module';
import { PushProvider } from '../../providers/push/push.provider';
import { StatusService } from './status.service';
import { StatusController } from './status.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserStatus, StatusInteraction]), RoomModule],
  controllers: [StatusController],
  providers: [StatusService, PushProvider],
})
export class StatusModule {}
