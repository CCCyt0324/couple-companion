import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Anniversary } from '../../database/entities/anniversary.entity';
import { RoomModule } from '../room/room.module';
import { PushProvider } from '../../providers/push/push.provider';
import { AnniversaryService } from './anniversary.service';
import { AnniversaryController } from './anniversary.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Anniversary]), RoomModule],
  controllers: [AnniversaryController],
  providers: [AnniversaryService, PushProvider],
})
export class AnniversaryModule {}
