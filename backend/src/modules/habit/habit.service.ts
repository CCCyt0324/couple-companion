import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Habit, HabitLog } from '../../database/entities/habit.entity';

@Injectable()
export class HabitService {
  constructor(
    @InjectRepository(Habit) private habitRepo: Repository<Habit>,
    @InjectRepository(HabitLog) private logRepo: Repository<HabitLog>,
  ) {}

  async list(roomId: number): Promise<Habit[]> {
    return this.habitRepo.find({ where: { roomId }, order: { sortOrder: 'ASC' } });
  }

  async create(roomId: number, name: string, icon: string): Promise<Habit> {
    const max = await this.habitRepo.findOne({
      where: { roomId }, order: { sortOrder: 'DESC' },
    });
    const habit = this.habitRepo.create({
      roomId, name, icon, sortOrder: (max?.sortOrder ?? 0) + 1,
    });
    return this.habitRepo.save(habit);
  }

  async delete(id: number): Promise<void> {
    await this.habitRepo.delete(id);
  }

  async toggle(habitId: number, userId: number): Promise<HabitLog> {
    const today = new Date().toISOString().slice(0, 10);
    const existing = await this.logRepo.findOne({
      where: { habitId, userId, date: today },
    });

    if (existing) {
      existing.completed = !existing.completed;
      return this.logRepo.save(existing);
    }

    const log = this.logRepo.create({ habitId, userId, date: today, completed: true });
    return this.logRepo.save(log);
  }

  async getTodayStats(roomId: number): Promise<{ total: number; completed: number }> {
    const habits = await this.list(roomId);
    const today = new Date().toISOString().slice(0, 10);
    const logs = await this.logRepo.find({
      where: habits.map((h) => ({ habitId: h.id, date: today })),
    });
    const completed = logs.filter((l) => l.completed).length;
    return { total: habits.length, completed };
  }
}
