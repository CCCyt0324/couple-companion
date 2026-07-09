import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GameRoom, GameQuestion, GameAnswer } from '../../database/entities/game.entity';
import { RoomModule } from '../room/room.module';
import { PushProvider } from '../../providers/push/push.provider';
import { GamesService } from './games.service';
import { GamesController } from './games.controller';
import { GamesGateway } from './games.gateway';

@Module({
  imports: [TypeOrmModule.forFeature([GameRoom, GameQuestion, GameAnswer]), RoomModule],
  controllers: [GamesController],
  providers: [GamesService, GamesGateway, PushProvider],
})
export class GamesModule {}
