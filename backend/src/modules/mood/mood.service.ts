import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MoodRecord } from '../../database/entities/mood-record.entity';
import { RoomMember } from '../../database/entities/room.entity';

@Injectable()
export class MoodService {
  constructor(
    @InjectRepository(MoodRecord) private moodRepo: Repository<MoodRecord>,
    @InjectRepository(RoomMember) private memberRepo: Repository<RoomMember>,
  ) {}

  async getToday(userId: number): Promise<MoodRecord | null> {
    const today = new Date().toISOString().slice(0, 10);
    return this.moodRepo.findOne({ where: { userId, date: today } });
  }

  async set(userId: number, moodValue: number, note?: string): Promise<MoodRecord> {
    const today = new Date().toISOString().slice(0, 10);
    let record = await this.moodRepo.findOne({ where: { userId, date: today } });
    if (record) {
      record.moodValue = moodValue;
      record.note = note ?? record.note;
    } else {
      record = this.moodRepo.create({ userId, date: today, moodValue, note });
    }
    return this.moodRepo.save(record);
  }

  async getHistory(userId: number, year: number, month: number): Promise<MoodRecord[]> {
    const start = `${year}-${String(month).padStart(2, '0')}-01`;
    const end = `${year}-${String(month).padStart(2, '0')}-31`;
    return this.moodRepo.find({ where: { userId }, order: { date: 'ASC' } })
      .then((records) => records.filter((r) => r.date >= start && r.date <= end));
  }

  /** 获取同房间内双方的心情对比 */
  async getPartnerMood(userId: number): Promise<{ myMood: MoodRecord | null; partnerMood: MoodRecord | null }> {
    const myMember = await this.memberRepo.findOne({ where: { userId } });
    if (!myMember) return { myMood: null, partnerMood: null };

    const members = await this.memberRepo.find({ where: { roomId: myMember.roomId } });
    const partnerMember = members.find((m) => m.userId !== userId);
    if (!partnerMember) return { myMood: await this.getToday(userId), partnerMood: null };

    const [myMood, partnerMood] = await Promise.all([
      this.getToday(userId),
      this.getToday(partnerMember.userId),
    ]);
    return { myMood, partnerMood };
  }
}
