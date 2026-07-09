import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { UserStatus, StatusInteraction } from '../../database/entities/user-status.entity';
import { PushProvider } from '../../providers/push/push.provider';

@Injectable()
export class StatusService {
  constructor(
    @InjectRepository(UserStatus) private statusRepo: Repository<UserStatus>,
    @InjectRepository(StatusInteraction) private interactionRepo: Repository<StatusInteraction>,
    private pushProvider: PushProvider,
  ) {}

  async setStatus(userId: number, data: { type: string; content: string; emoji?: string; bgColor?: string }): Promise<UserStatus> {
    // 清除之前状态
    await this.statusRepo.delete({ userId });

    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    const status = this.statusRepo.create({ userId, ...data, expiresAt });
    return this.statusRepo.save(status);
  }

  async getStatus(userId: number): Promise<UserStatus | null> {
    return this.statusRepo.findOne({ where: { userId } });
  }

  async interact(statusId: number, fromUserId: number, type: string, content?: string): Promise<StatusInteraction> {
    const interaction = this.interactionRepo.create({ statusId, fromUserId, type, content });
    await this.interactionRepo.save(interaction);

    // 通知状态发起方
    const status = await this.statusRepo.findOne({ where: { id: statusId } });
    if (status) {
      const actionMap = { poke: '戳了戳你', hug: '给了你一个拥抱', comment: '留言了', copy: '设置了同款状态' };
      this.pushProvider.push(
        [status.userId],
        '状态互动',
        `有人${actionMap[type] || '互动了你的状态'}`,
        { type: 'status_interact', action: type },
      );
    }
    return interaction;
  }

  /** 定时任务：清理过期状态 */
  async cleanExpired(): Promise<void> {
    await this.statusRepo.delete({ expiresAt: LessThan(new Date()) } as any);
  }
}
