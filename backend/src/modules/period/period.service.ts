import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PeriodRecord, PeriodSetting } from '../../database/entities/period.entity';
import { predictNextPeriod } from '../../common/utils/helpers';

@Injectable()
export class PeriodService {
  constructor(
    @InjectRepository(PeriodRecord) private recordRepo: Repository<PeriodRecord>,
    @InjectRepository(PeriodSetting) private settingRepo: Repository<PeriodSetting>,
  ) {}

  async getToday(userId: number): Promise<PeriodRecord | null> {
    const today = new Date().toISOString().slice(0, 10);
    return this.recordRepo.findOne({ where: { userId, date: today } });
  }

  async save(userId: number, data: Partial<PeriodRecord>): Promise<PeriodRecord> {
    const date = data.date || new Date().toISOString().slice(0, 10);
    let record = await this.recordRepo.findOne({ where: { userId, date } });
    if (record) {
      Object.assign(record, data);
    } else {
      record = this.recordRepo.create({ userId, date, ...data });
    }
    return this.recordRepo.save(record);
  }

  async getSetting(userId: number): Promise<PeriodSetting> {
    let setting = await this.settingRepo.findOne({ where: { userId } });
    if (!setting) {
      setting = this.settingRepo.create({ userId });
      await this.settingRepo.save(setting);
    }
    return setting;
  }

  async updateSetting(userId: number, cycleDays: number, periodDays: number): Promise<PeriodSetting> {
    let setting = await this.settingRepo.findOne({ where: { userId } });
    if (!setting) {
      setting = this.settingRepo.create({ userId, cycleDays, periodDays });
    } else {
      setting.cycleDays = cycleDays;
      setting.periodDays = periodDays;
    }
    return this.settingRepo.save(setting);
  }

  async predict(userId: number): Promise<{ predictedDate: string; confidence: number } | null> {
    const records = await this.recordRepo.find({
      where: { userId }, order: { date: 'DESC' }, take: 6,
    });
    if (records.length === 0) return null;

    const lastRecord = records[0];
    const cycleDaysList: number[] = [];
    for (let i = 1; i < records.length; i++) {
      const diff = Math.round(
        (new Date(records[i - 1].date).getTime() - new Date(records[i].date).getTime())
        / (1000 * 60 * 60 * 24),
      );
      if (diff > 0) cycleDaysList.push(diff);
    }

    const { predictedDate, confidence } = predictNextPeriod(
      new Date(lastRecord.date), cycleDaysList,
    );
    return { predictedDate: predictedDate.toISOString().slice(0, 10), confidence };
  }

  async getCountdown(userId: number): Promise<string | null> {
    const prediction = await this.predict(userId);
    if (!prediction) return null;
    const today = new Date().toISOString().slice(0, 10);
    const days = Math.round(
      (new Date(prediction.predictedDate).getTime() - new Date(today).getTime())
      / (1000 * 60 * 60 * 24),
    );
    return days > 0 ? `${days} 天` : days === 0 ? '今天' : null;
  }
}
