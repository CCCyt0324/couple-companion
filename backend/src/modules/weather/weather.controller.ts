import { Controller, Get, Query } from '@nestjs/common';
import { WeatherService } from './weather.service';

@Controller('weather')
export class WeatherController {
  constructor(private weatherService: WeatherService) {}

  @Get()
  async get(
    @Query('city') city: string,
    @Query('lat') lat?: number,
    @Query('lng') lng?: number,
  ) {
    const key = city || 'beijing';
    const weather = await this.weatherService.getWeather(0, key, lat != null ? +lat : undefined, lng != null ? +lng : undefined);
    const reminder = await this.weatherService.generateReminder(weather);
    return { weather, reminder };
  }

  @Get('reminder')
  async reminder(
    @Query('city') city: string,
    @Query('lat') lat?: number,
    @Query('lng') lng?: number,
  ) {
    const key = city || 'beijing';
    const weather = await this.weatherService.getWeather(0, key, lat != null ? +lat : undefined, lng != null ? +lng : undefined);
    return { reminder: await this.weatherService.generateReminder(weather) };
  }
}
