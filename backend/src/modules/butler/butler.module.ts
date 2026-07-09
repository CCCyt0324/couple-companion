import { Module } from '@nestjs/common';
import { AiProvider } from '../../providers/ai/ai.provider';
import { RoomModule } from '../room/room.module';
import { ButlerService } from './butler.service';
import { ButlerController } from './butler.controller';
import { Redis } from 'ioredis';
import { ConfigService } from '@nestjs/config';

@Module({
  imports: [RoomModule],
  controllers: [ButlerController],
  providers: [
    ButlerService, AiProvider,
    { provide: 'REDIS', useFactory: (config: ConfigService) => new Redis({ host: config.get('redis.host') || '127.0.0.1', port: config.get('redis.port') || 6379, password: config.get('redis.password') || undefined, lazyConnect: true, retryStrategy: () => null }), inject: [ConfigService] },
  ],
})
export class ButlerModule {}
