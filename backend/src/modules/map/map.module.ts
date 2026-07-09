import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RoomModule } from '../room/room.module';
import { MapService } from './map.service';
import { MapController } from './map.controller';
import { LocationController } from './location.controller';
import { MapGateway } from './map.gateway';
import { LocationProvider } from '../../providers/location/location.provider';
import { Redis } from 'ioredis';

@Module({
  imports: [RoomModule],
  controllers: [MapController, LocationController],
  providers: [
    MapService,
    MapGateway,
    LocationProvider,
    {
      provide: 'REDIS',
      useFactory: (config: ConfigService) => {
        return new Redis({
          host: config.get('redis.host') || '127.0.0.1',
          port: config.get('redis.port') || 6379,
          password: config.get('redis.password') || undefined,
          lazyConnect: true,
          retryStrategy: () => null,
        });
      },
      inject: [ConfigService],
    },
  ],
})
export class MapModule {}
