import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Habit, HabitLog } from '../../database/entities/habit.entity';
import { RoomModule } from '../room/room.module';
import { HabitService } from './habit.service';
import { HabitController } from './habit.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Habit, HabitLog]), RoomModule],
  controllers: [HabitController],
  providers: [HabitService],
})
export class HabitModule {}
