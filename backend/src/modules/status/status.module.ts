import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserStatus, StatusInteraction } from '../../database/entities/user-status.entity';
import { RoomMember } from '../../database/entities/room.entity';
import { RoomModule } from '../room/room.module';
import { StatusService } from './status.service';
import { StatusController } from './status.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserStatus, StatusInteraction, RoomMember]), RoomModule],
  controllers: [StatusController],
  providers: [StatusService],
})
export class StatusModule {}
