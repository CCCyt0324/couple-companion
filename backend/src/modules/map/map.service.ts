import { Injectable, Inject } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class MapService {
  constructor(@Inject('REDIS') private redis: Redis) {}

  async updateLocation(userId: number, lat: number, lng: number): Promise<void> {
    await this.redis.setex(
      `location:${userId}`,
      600, // 10分钟过期
      JSON.stringify({ lat, lng, updatedAt: Date.now() }),
    );
  }

  async getLocation(userId: number): Promise<{ lat: number; lng: number; updatedAt: number } | null> {
    const data = await this.redis.get(`location:${userId}`);
    return data ? JSON.parse(data) : null;
  }

  async getSharedStatus(userId: number): Promise<boolean> {
    const status = await this.redis.get(`location:share:${userId}`);
    return status !== '0';
  }

  async setSharedStatus(userId: number, sharing: boolean): Promise<void> {
    await this.redis.set(`location:share:${userId}`, sharing ? '1' : '0');
  }

  /** 计算两点间距离（Haversine） */
  calculateDistance(
    lat1: number, lng1: number, lat2: number, lng2: number,
  ): number {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLng = ((lng2 - lng1) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }
}
