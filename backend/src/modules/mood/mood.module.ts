import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MoodRecord } from '../../database/entities/mood-record.entity';
import { RoomMember } from '../../database/entities/room.entity';
import { RoomModule } from '../room/room.module';
import { MoodService } from './mood.service';
import { MoodController } from './mood.controller';

@Module({
  imports: [TypeOrmModule.forFeature([MoodRecord, RoomMember]), RoomModule],
  controllers: [MoodController],
  providers: [MoodService],
})
export class MoodModule {}
