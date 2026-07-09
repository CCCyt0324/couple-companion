import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Album, Photo, PhotoLike, PhotoComment } from '../../database/entities/album.entity';
import { RoomModule } from '../room/room.module';
import { OssProvider } from '../../providers/oss/oss.provider';
import { PushProvider } from '../../providers/push/push.provider';
import { AlbumService } from './album.service';
import { AlbumController } from './album.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Album, Photo, PhotoLike, PhotoComment]), RoomModule],
  controllers: [AlbumController],
  providers: [AlbumService, OssProvider, PushProvider],
})
export class AlbumModule {}
