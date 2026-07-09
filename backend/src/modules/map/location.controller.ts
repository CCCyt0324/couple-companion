import { Controller, Get, Query, Req } from '@nestjs/common';
import { Request } from 'express';
import { LocationProvider } from '../../providers/location/location.provider';

/** 公开定位 API——无需登录 */
@Controller('location')
export class LocationController {
  constructor(private locationProvider: LocationProvider) {}

  /** IP 定位获取当前城市和坐标 */
  @Get()
  async locate(@Req() req: Request) {
    const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip;
    const result = await this.locationProvider.ipLocation(ip);
    return {
      city: result?.city || '北京',
      province: result?.province || '北京',
      adcode: result?.adcode || '110000',
      lat: result?.lat || 39.9,
      lng: result?.lng || 116.4,
    };
  }

  /** 城市名 → 坐标 */
  @Get('geocode')
  async geocode(@Query('address') address: string) {
    const result = await this.locationProvider.geocode(address || '北京');
    return result;
  }
}
