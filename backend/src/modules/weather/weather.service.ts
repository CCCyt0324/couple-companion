import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WeatherCache } from '../../database/entities/weather-cache.entity';
import { AiProvider } from '../../providers/ai/ai.provider';
import axios from 'axios';

@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);

  constructor(
    private config: ConfigService,
    @InjectRepository(WeatherCache) private cacheRepo: Repository<WeatherCache>,
    private aiProvider: AiProvider,
  ) {}

  async getWeather(roomId: number, city: string, lat?: number, lng?: number): Promise<any> {
    const cacheKey = city;
    const cached = await this.cacheRepo.findOne({ where: { roomId, city: cacheKey } });
    if (cached && Date.now() - cached.cachedAt.getTime() < 30 * 60 * 1000) {
      return cached.data;
    }

    let data: any;
    const amapKey = this.config.get('weather.apiKey');

    try {
      if (amapKey && amapKey !== 'your_weather_api_key') {
        data = await this.fetchAMapWeather(city, amapKey);
      } else {
        // fallback: Open-Meteo
        const coords = getCityCoords(city);
        data = await this.fetchOpenMeteo(lat ?? coords?.lat ?? 39.9, lng ?? coords?.lng ?? 116.4);
      }
    } catch (err: any) {
      this.logger.warn(`天气API调用失败: ${err.message}`);
      const coords = getCityCoords(city);
      // 再次尝试 Open-Meteo
      try {
        data = await this.fetchOpenMeteo(coords?.lat ?? 39.9, coords?.lng ?? 116.4);
      } catch (_) {
        data = this.buildMockWeather(city, lat ?? 39.9, lng ?? 116.4);
      }
    }

    // 保存缓存
    try {
      if (cached) {
        cached.data = data; cached.cachedAt = new Date();
        await this.cacheRepo.save(cached);
      } else {
        await this.cacheRepo.save(this.cacheRepo.create({ roomId, city: cacheKey, data, cachedAt: new Date() } as any));
      }
    } catch (_) {}

    return data;
  }

  // 高德天气 API
  private async fetchAMapWeather(city: string, key: string): Promise<any> {
    const adcode = getCityAdcode(city);
    // 同时获取实时天气(base)和预报(all)，因为 extensions=all 不返回 lives
    const [baseRes, allRes] = await Promise.allSettled([
      axios.get('https://restapi.amap.com/v3/weather/weatherInfo', { params: { key, city: adcode }, timeout: 8000 }),
      axios.get('https://restapi.amap.com/v3/weather/weatherInfo', { params: { key, city: adcode, extensions: 'all' }, timeout: 8000 }),
    ]);

    const live = baseRes.status === 'fulfilled' ? baseRes.value.data?.lives?.[0] : null;
    const forecasts = allRes.status === 'fulfilled' ? allRes.value.data?.forecasts?.[0]?.casts || [] : [];
    return this.normalizeAMap(live, forecasts);
  }

  // 高德格式 → 统一格式
  private normalizeAMap(live: any, forecasts: any[]): any {
    return {
      code: '200',
      now: {
        temp: live?.temperature || '--',
        text: live?.weather || '晴',
        feelsLike: live?.temperature || '--',
        humidity: live?.humidity || '--',
        windDir: live?.winddirection || '--',
        windScale: live?.windpower || '1',
      },
      daily: forecasts.slice(0, 3).map((f: any) => ({
        fxDate: f.date,
        tempMax: f.daytemp,
        tempMin: f.nighttemp,
        textDay: f.dayweather,
      })),
    };
  }

  // Open-Meteo fallback
  private async fetchOpenMeteo(lat: number, lng: number): Promise<any> {
    const res = await axios.get('https://api.open-meteo.com/v1/forecast', {
      params: {
        latitude: lat, longitude: lng,
        current: 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m',
        daily: 'temperature_2m_max,temperature_2m_min,weather_code',
        timezone: 'Asia/Shanghai', forecast_days: 3,
      },
      timeout: 8000,
    });
    return this.normalizeOpenMeteo(res.data);
  }

  private normalizeOpenMeteo(raw: any): any {
    const wmo: Record<number, string> = {
      0: '晴', 1: '晴', 2: '多云', 3: '阴', 45: '霾', 48: '霾',
      51: '小雨', 53: '小雨', 55: '中雨', 61: '小雨', 63: '中雨', 65: '大雨',
      71: '小雪', 73: '中雪', 75: '大雪', 80: '阵雨', 81: '阵雨', 82: '暴雨',
      95: '雷阵雨', 96: '雷阵雨', 99: '雷阵雨',
    };
    const c = raw.current, d = raw.daily;
    return {
      code: '200',
      now: {
        temp: Math.round(c.temperature_2m).toString(),
        text: wmo[c.weather_code] || '多云',
        feelsLike: Math.round(c.apparent_temperature).toString(),
        humidity: c.relative_humidity_2m.toString(),
        windDir: degToDir(c.wind_direction_10m),
        windScale: c.wind_speed_10m?.toString() || '1',
      },
      daily: d.time.map((t: string, i: number) => ({
        fxDate: t,
        tempMax: Math.round(d.temperature_2m_max[i]).toString(),
        tempMin: Math.round(d.temperature_2m_min[i]).toString(),
        textDay: wmo[d.weather_code[i]] || '多云',
      })),
    };
  }

  private buildMockWeather(city: string, lat: number, lng: number): any {
    const now = new Date();
    const baseTemp = lat > 35 ? 30 : lat > 30 ? 33 : 28;
    return {
      code: '200',
      now: { temp: baseTemp.toString(), text: '晴', feelsLike: (baseTemp + 2).toString(), humidity: '55', windDir: '东南风', windScale: '2' },
      daily: [
        { fxDate: now.toISOString().substring(0, 10), tempMax: (baseTemp + 2).toString(), tempMin: (baseTemp - 6).toString(), textDay: '晴' },
        { fxDate: new Date(+now + 86400000).toISOString().substring(0, 10), tempMax: (baseTemp + 1).toString(), tempMin: (baseTemp - 5).toString(), textDay: '多云' },
        { fxDate: new Date(+now + 172800000).toISOString().substring(0, 10), tempMax: (baseTemp - 1).toString(), tempMin: (baseTemp - 7).toString(), textDay: '小雨' },
      ],
    };
  }

  async generateReminder(weather: any): Promise<string> {
    const today = weather?.daily?.[0] || weather?.now;
    if (!today) return '今天天气不错，适合约会哦💝';

    const temp = parseInt(today.tempMax || today.temp || '25');
    const text = today.textDay || today.text || '';
    const wind = weather?.now?.windDir || '';
    const humidity = weather?.now?.humidity || '';
    const feelsLike = weather?.now?.feelsLike || temp.toString();

    // 拼装天气上下文给 AI
    const weatherDesc = `${text}，气温${temp}°C，体感${feelsLike}°C，湿度${humidity}%，${wind}风`;

    try {
      const reply = await this.aiProvider.chat([
        { role: 'user', content: `今日天气预报：${weatherDesc}\n\n你是一只叫小柒的蠢萌小猫咪，很会保护人。请用猫的口吻给一句20字以内的天气提醒，带1个emoji+喵结尾。比如"带伞🌂不然淋湿喵"、"防晒☀️本喵提醒你喵"这种。只说提醒本身。` },
      ]);
      return reply?.trim() || this.buildFallbackReminder(temp, text);
    } catch (_) {
      return this.buildFallbackReminder(temp, text);
    }
  }

  private buildFallbackReminder(temp: number, text: string): string {
    const r: string[] = [];
    if (text.includes('雨')) r.push('记得带伞🌂');
    if (temp < 10) r.push('穿厚外套🧥');
    if (temp > 30) r.push('注意防晒☀️');
    if (temp >= 20 && temp <= 28 && !text.includes('雨')) r.push('适合出门约会💕');
    return r.length > 0 ? r.join('，') : '今天天气不错，适合约会哦💝';
  }
}

// 城市 → 高德 adcode
function getCityAdcode(city: string): string {
  const map: Record<string, string> = {
    '北京': '110000', 'beijing': '110000',
    '上海': '310000', 'shanghai': '310000',
    '广州': '440100', 'guangzhou': '440100',
    '深圳': '440300', 'shenzhen': '440300',
    '杭州': '330100', 'hangzhou': '330100',
    '成都': '510100', 'chengdu': '510100',
    '重庆': '500000', 'chongqing': '500000',
    '武汉': '420100', 'wuhan': '420100',
    '南京': '320100', 'nanjing': '320100',
    '西安': '610100', 'xian': '610100',
    '天津': '120000', 'tianjin': '120000',
    '长沙': '430100', 'changsha': '430100',
    '郑州': '410100', 'zhengzhou': '410100',
    '昆明': '530100', 'kunming': '530100',
    '厦门': '350200', 'xiamen': '350200',
    '青岛': '370200', 'qingdao': '370200',
    '大连': '210200', 'dalian': '210200',
    '苏州': '320500', 'suzhou': '320500',
    '沈阳': '210100', 'shenyang': '210100',
  };
  return map[city.toLowerCase()] || map[city] || '110000';
}

// 城市 → 经纬度
function getCityCoords(city: string): { lat: number; lng: number } | null {
  const map: Record<string, { lat: number; lng: number }> = {
    '北京': { lat: 39.9, lng: 116.4 }, 'beijing': { lat: 39.9, lng: 116.4 },
    '上海': { lat: 31.2, lng: 121.5 }, 'shanghai': { lat: 31.2, lng: 121.5 },
    '广州': { lat: 23.1, lng: 113.3 }, 'guangzhou': { lat: 23.1, lng: 113.3 },
    '深圳': { lat: 22.5, lng: 114.1 }, 'shenzhen': { lat: 22.5, lng: 114.1 },
    '杭州': { lat: 30.3, lng: 120.2 }, 'hangzhou': { lat: 30.3, lng: 120.2 },
    '成都': { lat: 30.6, lng: 104.1 }, 'chengdu': { lat: 30.6, lng: 104.1 },
    '重庆': { lat: 29.6, lng: 106.5 }, 'chongqing': { lat: 29.6, lng: 106.5 },
    '武汉': { lat: 30.6, lng: 114.3 }, 'wuhan': { lat: 30.6, lng: 114.3 },
    '南京': { lat: 32.1, lng: 118.8 }, 'nanjing': { lat: 32.1, lng: 118.8 },
    '西安': { lat: 34.3, lng: 108.9 }, 'xian': { lat: 34.3, lng: 108.9 },
    '天津': { lat: 39.1, lng: 117.2 }, 'tianjin': { lat: 39.1, lng: 117.2 },
    '长沙': { lat: 28.2, lng: 113.0 }, 'changsha': { lat: 28.2, lng: 113.0 },
    '郑州': { lat: 34.8, lng: 113.6 }, 'zhengzhou': { lat: 34.8, lng: 113.6 },
    '昆明': { lat: 25.0, lng: 102.7 }, 'kunming': { lat: 25.0, lng: 102.7 },
    '厦门': { lat: 24.5, lng: 118.1 }, 'xiamen': { lat: 24.5, lng: 118.1 },
    '青岛': { lat: 36.1, lng: 120.4 }, 'qingdao': { lat: 36.1, lng: 120.4 },
    '大连': { lat: 38.9, lng: 121.6 }, 'dalian': { lat: 38.9, lng: 121.6 },
    '苏州': { lat: 31.3, lng: 120.6 }, 'suzhou': { lat: 31.3, lng: 120.6 },
    '沈阳': { lat: 41.8, lng: 123.4 }, 'shenyang': { lat: 41.8, lng: 123.4 },
  };
  return map[city.toLowerCase()] || map[city] || null;
}

function degToDir(d: number): string {
  const dirs = ['北', '东北', '东', '东南', '南', '西南', '西', '西北'];
  return dirs[Math.round(d / 45) % 8] + '风';
}
