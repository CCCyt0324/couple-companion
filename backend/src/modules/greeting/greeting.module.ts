import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DailyGreeting } from '../../database/entities/daily-greeting.entity';
import { GreetingService } from './greeting.service';
import { GreetingController } from './greeting.controller';
import { GreetingGateway } from './greeting.gateway';
import { RoomModule } from '../room/room.module';

@Module({
  imports: [TypeOrmModule.forFeature([DailyGreeting]), RoomModule],
  controllers: [GreetingController],
  providers: [GreetingService, GreetingGateway],
})
export class GreetingModule {}
