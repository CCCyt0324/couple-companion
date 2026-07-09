import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Room, RoomMember } from '../../database/entities/room.entity';
import { User } from '../../database/entities/user.entity';
import { Habit } from '../../database/entities/habit.entity';
import { RoomService } from './room.service';
import { RoomController } from './room.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Room, RoomMember, Habit, User])],
  controllers: [RoomController],
  providers: [RoomService],
  exports: [RoomService],
})
export class RoomModule {}
