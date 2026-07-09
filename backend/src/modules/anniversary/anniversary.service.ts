import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Anniversary } from '../../database/entities/anniversary.entity';

@Injectable()
export class AnniversaryService {
  constructor(
    @InjectRepository(Anniversary) private repo: Repository<Anniversary>,
  ) {}

  async list(roomId: number): Promise<Anniversary[]> {
    return this.repo.find({ where: { roomId }, order: { date: 'ASC' } });
  }

  async create(roomId: number, data: Partial<Anniversary>): Promise<Anniversary> {
    const ann = this.repo.create({ roomId, ...data });
    return this.repo.save(ann);
  }

  async update(id: number, data: Partial<Anniversary>): Promise<Anniversary> {
    await this.repo.update(id, data);
    const ann = await this.repo.findOne({ where: { id } });
    if (!ann) throw new NotFoundException('纪念日不存在');
    return ann;
  }

  async delete(id: number): Promise<void> {
    await this.repo.delete(id);
  }

  async getUpcomingAnniversaries(roomId: number): Promise<Array<{ ann: Anniversary; daysLeft: number }>> {
    const anns = await this.list(roomId);
    const today = new Date().toISOString().slice(5, 10);
    const results: Array<{ ann: Anniversary; daysLeft: number }> = [];

    for (const ann of anns) {
      const annDate = ann.date.slice(5); // MM-DD
      let targetDate = new Date(`${new Date().getFullYear()}-${annDate}`);
      if (targetDate <= new Date()) {
        targetDate = new Date(`${new Date().getFullYear() + 1}-${annDate}`);
      }
      const daysLeft = Math.ceil((targetDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
      results.push({ ann, daysLeft });
    }

    return results.sort((a, b) => a.daysLeft - b.daysLeft);
  }

  /** 定时任务：检查并推送纪念日提醒 */
  async checkAndPushReminders(pushProvider: any, coupleRepo: any, userRepo: any): Promise<void> {
    const today = new Date().toISOString().slice(5, 10);
    const anns = await this.repo.find({ where: { date: today } } as any);

    for (const ann of anns) {
      const couple = await coupleRepo.findOne({ where: { id: ann.roomId } });
      if (!couple) continue;
      const users = await userRepo.findByIds([couple.userAId, couple.userBId]);
      const userIds = users.map((u: any) => u.id);
      pushProvider.push(userIds, `纪念日提醒`, `${ann.title} 到了！`, { type: 'anniversary' });
    }
  }
}
