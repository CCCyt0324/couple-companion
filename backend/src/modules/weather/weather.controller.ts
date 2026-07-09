import { Controller, Get, Query } from '@nestjs/common';
import { WeatherService } from './weather.service';

@Controller('weather')
export class WeatherController {
  constructor(private weatherService: WeatherService) {}

  @Get()
  async get(
    @Query('city') city?: string,
    @Query('lat') lat?: number,
    @Query('lng') lng?: number,
  ) {
    const hasCoords = lat != null && lng != null;
    const weather = await this.weatherService.getWeather(
      0,
      city || 'beijing',
      hasCoords ? +lat! : undefined,
      hasCoords ? +lng! : undefined,
    );
    const reminder = await this.weatherService.generateReminder(weather);
    // 附加城市名到响应中
    return {
      weather: { ...weather, _city: weather.now?.city || city || '当前位置' },
      reminder,
    };
  }
}
