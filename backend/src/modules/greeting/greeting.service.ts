import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyGreeting } from '../../database/entities/daily-greeting.entity';

@Injectable()
export class GreetingService {
  constructor(
    @InjectRepository(DailyGreeting) private greetingRepo: Repository<DailyGreeting>,
  ) {}

  async getToday(roomId: number): Promise<DailyGreeting> {
    const today = new Date().toISOString().slice(0, 10);
    let greeting = await this.greetingRepo.findOne({
      where: { roomId, date: today },
    });
    if (!greeting) {
      greeting = this.greetingRepo.create({ roomId, date: today });
      await this.greetingRepo.save(greeting);
    }
    return greeting;
  }

  async update(
    roomId: number, userId: number, content: string, isUserA: boolean,
  ): Promise<DailyGreeting> {
    const greeting = await this.getToday(roomId);
    if (isUserA) {
      greeting.contentA = content;
    } else {
      greeting.contentB = content;
    }
    return this.greetingRepo.save(greeting);
  }

  async updateBgImage(roomId: number, bgImageUrl: string): Promise<DailyGreeting> {
    const greeting = await this.getToday(roomId);
    greeting.bgImageUrl = bgImageUrl;
    return this.greetingRepo.save(greeting);
  }
}
