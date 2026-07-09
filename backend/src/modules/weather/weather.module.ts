import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WeatherCache } from '../../database/entities/weather-cache.entity';
import { RoomModule } from '../room/room.module';
import { WeatherService } from './weather.service';
import { WeatherController } from './weather.controller';

@Module({
  imports: [TypeOrmModule.forFeature([WeatherCache]), RoomModule],
  controllers: [WeatherController],
  providers: [WeatherService],
})
export class WeatherModule {}
