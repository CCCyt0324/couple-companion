import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GameRoom, GameQuestion, GameAnswer } from '../../database/entities/game.entity';
import { PushProvider } from '../../providers/push/push.provider';

/** 默契度评级 */
function getMatchGrade(score: number): string {
  if (score >= 90) return '灵魂伴侣';
  if (score >= 70) return '心有灵犀';
  if (score >= 50) return '渐入佳境';
  return '还需磨合';
}

@Injectable()
export class GamesService {
  constructor(
    @InjectRepository(GameRoom) private roomRepo: Repository<GameRoom>,
    @InjectRepository(GameQuestion) private questionRepo: Repository<GameQuestion>,
    @InjectRepository(GameAnswer) private answerRepo: Repository<GameAnswer>,
    private pushProvider: PushProvider,
  ) {}

  async createRoom(roomId: number, gameType: string): Promise<GameRoom> {
    const gameRoom = this.roomRepo.create({ roomId, gameType, status: 'waiting' });
    return this.roomRepo.save(gameRoom);
  }

  async startGame(roomId: number): Promise<GameRoom> {
    await this.roomRepo.update(roomId, { status: 'playing' });
    const room = await this.roomRepo.findOne({ where: { id: roomId } });
    return room!;
  }

  async getRoom(roomId: number): Promise<GameRoom | null> {
    return this.roomRepo.findOne({ where: { id: roomId } });
  }

  async getQuestion(gameType: string, excludeIds: number[] = []): Promise<GameQuestion | null> {
    const qb = this.questionRepo.createQueryBuilder('q').where('q.gameType = :gameType', { gameType });
    if (excludeIds.length > 0) {
      qb.andWhere('q.id NOT IN (:...ids)', { ids: excludeIds });
    }
    return qb.orderBy('RAND()').getOne();
  }

  async submitAnswer(roomId: number, userId: number, questionId: number, answer: string): Promise<GameAnswer> {
    const ans = this.answerRepo.create({ roomId, userId, questionId, answer });
    return this.answerRepo.save(ans);
  }

  async calculateMatch(roomId: number): Promise<{ score: number; grade: string }> {
    const answers = await this.answerRepo.find({ where: { roomId } });
    if (answers.length < 2) return { score: 0, grade: '未完成' };

    // 按问题分组计算匹配度
    const byQuestion = new Map<number, GameAnswer[]>();
    for (const a of answers) {
      if (!byQuestion.has(a.questionId)) byQuestion.set(a.questionId, []);
      byQuestion.get(a.questionId)!.push(a);
    }

    let totalScore = 0;
    let count = 0;
    for (const [, ansList] of byQuestion) {
      if (ansList.length >= 2) {
        const match = ansList[0].answer === ansList[1].answer ? 100 : 0;
        totalScore += match;
        count++;
      }
    }

    const score = count > 0 ? Math.round(totalScore / count) : 0;
    return { score, grade: getMatchGrade(score) };
  }

  async getHistory(roomId: number, gameType?: string): Promise<GameRoom[]> {
    const where: any = { roomId };
    if (gameType) where.gameType = gameType;
    return this.roomRepo.find({ where, order: { createdAt: 'DESC' }, take: 20 });
  }

  private getGameName(type: string): string {
    const map: Record<string, string> = {
      heart_qa: '心动问答',
      two_choice: '甜蜜二选一',
      love_task: '爱的任务',
      match_test: '默契大考验',
    };
    return map[type] || '游戏';
  }
}
