import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WishNote } from '../../database/entities/wish-note.entity';
import { RoomModule } from '../room/room.module';
import { PushProvider } from '../../providers/push/push.provider';
import { WishService } from './wish.service';
import { WishController } from './wish.controller';

@Module({
  imports: [TypeOrmModule.forFeature([WishNote]), RoomModule],
  controllers: [WishController],
  providers: [WishService, PushProvider],
})
export class WishModule {}
