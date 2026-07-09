import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

export interface LocationResult {
  city: string;
  province: string;
  adcode: string;
  lat: number;
  lng: number;
}

@Injectable()
export class LocationProvider {
  private readonly logger = new Logger(LocationProvider.name);

  constructor(private config: ConfigService) {}

  /** IP 定位获取当前城市 */
  async ipLocation(ip?: string): Promise<LocationResult | null> {
    const amapKey = this.config.get('weather.apiKey');
    if (!amapKey || amapKey === 'your_weather_api_key') {
      return this.fallbackIpLocation();
    }

    try {
      const params: any = { key: amapKey };
      if (ip) params.ip = ip;
      const res = await axios.get('https://restapi.amap.com/v3/ip', { params, timeout: 5000 });

      if (res.data?.status === '1') {
        const province = Array.isArray(res.data.province) ? '' : (res.data.province || '');
        const city = Array.isArray(res.data.city) ? '' : (res.data.city || '');
        const adcode = Array.isArray(res.data.adcode) ? '' : (res.data.adcode || '');
        if (city) {
          return await this.geocode(`${province}${city}`, amapKey);
        }
      }
    } catch (err: any) {
      this.logger.warn(`高德IP定位失败: ${err.message}`);
    }
    return this.fallbackIpLocation();
  }

  /** 城市名 → 坐标 */
  async geocode(address: string, amapKey?: string): Promise<LocationResult | null> {
    const key = amapKey || this.config.get('weather.apiKey');
    if (!key || key === 'your_weather_api_key') {
      return this.cityToCoords(address);
    }

    try {
      const res = await axios.get('https://restapi.amap.com/v3/geocode/geo', {
        params: { key, address },
        timeout: 5000,
      });
      if (res.data?.status === '1' && res.data.geocodes?.length > 0) {
        const g = res.data.geocodes[0];
        const [lng, lat] = g.location.split(',').map(Number);
        return { city: g.city || address, province: g.province || '', adcode: g.adcode || '', lat, lng };
      }
    } catch (err: any) {
      this.logger.warn(`高德地理编码失败: ${err.message}`);
    }
    return this.cityToCoords(address);
  }

  /** 纯本地城市坐标映射 */
  private cityToCoords(address: string): LocationResult | null {
    const map: Record<string, { lat: number; lng: number; province: string }> = {
      '北京': { lat: 39.9, lng: 116.4, province: '北京' },
      '上海': { lat: 31.2, lng: 121.5, province: '上海' },
      '广州': { lat: 23.1, lng: 113.3, province: '广东' },
      '深圳': { lat: 22.5, lng: 114.1, province: '广东' },
      '杭州': { lat: 30.3, lng: 120.2, province: '浙江' },
      '成都': { lat: 30.6, lng: 104.1, province: '四川' },
      '重庆': { lat: 29.6, lng: 106.5, province: '重庆' },
      '武汉': { lat: 30.6, lng: 114.3, province: '湖北' },
      '南京': { lat: 32.1, lng: 118.8, province: '江苏' },
      '西安': { lat: 34.3, lng: 108.9, province: '陕西' },
      '天津': { lat: 39.1, lng: 117.2, province: '天津' },
      '长沙': { lat: 28.2, lng: 113.0, province: '湖南' },
      '郑州': { lat: 34.8, lng: 113.6, province: '河南' },
      '昆明': { lat: 25.0, lng: 102.7, province: '云南' },
      '厦门': { lat: 24.5, lng: 118.1, province: '福建' },
      '青岛': { lat: 36.1, lng: 120.4, province: '山东' },
      '大连': { lat: 38.9, lng: 121.6, province: '辽宁' },
      '苏州': { lat: 31.3, lng: 120.6, province: '江苏' },
      '沈阳': { lat: 41.8, lng: 123.4, province: '辽宁' },
      '福州': { lat: 26.1, lng: 119.3, province: '福建' },
      '合肥': { lat: 31.8, lng: 117.2, province: '安徽' },
    };
    const match = Object.keys(map).find((k) => address.includes(k));
    if (match) {
      const c = map[match];
      return { city: match, province: c.province, adcode: '', lat: c.lat, lng: c.lng };
    }
    // 默认北京
    return { city: '北京', province: '北京', adcode: '110000', lat: 39.9, lng: 116.4 };
  }

  /** IP API fallback */
  private async fallbackIpLocation(): Promise<LocationResult | null> {
    try {
      const res = await axios.get('https://ipapi.co/json/', { timeout: 5000 });
      const d = res.data;
      if (d?.city) {
        return this.cityToCoords(d.city);
      }
    } catch (_) {}
    return this.cityToCoords('北京');
  }
}
