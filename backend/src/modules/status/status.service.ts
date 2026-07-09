import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { UserStatus, StatusInteraction } from '../../database/entities/user-status.entity';
import { RoomMember } from '../../database/entities/room.entity';

@Injectable()
export class StatusService {
  constructor(
    @InjectRepository(UserStatus) private statusRepo: Repository<UserStatus>,
    @InjectRepository(StatusInteraction) private interactionRepo: Repository<StatusInteraction>,
    @InjectRepository(RoomMember) private memberRepo: Repository<RoomMember>,
  ) {}

  async setStatus(userId: number, data: { type: string; content: string; emoji?: string; bgColor?: string }): Promise<UserStatus> {
    await this.statusRepo.delete({ userId });
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    const status = this.statusRepo.create({ userId, ...data, expiresAt });
    return this.statusRepo.save(status);
  }

  async getStatus(userId: number): Promise<UserStatus | null> {
    return this.statusRepo.findOne({ where: { userId } });
  }

  /** 获取同房间伴侣的状态 */
  async getPartnerStatus(userId: number): Promise<UserStatus | null> {
    const myMember = await this.memberRepo.findOne({ where: { userId } });
    if (!myMember) return null;
    const members = await this.memberRepo.find({ where: { roomId: myMember.roomId } });
    const partner = members.find((m) => m.userId !== userId);
    if (!partner) return null;
    return this.getStatus(partner.userId);
  }

  /** 获取针对我的互动通知 */
  async getMyInteractions(userId: number): Promise<{ interaction: StatusInteraction; status: UserStatus | null }[]> {
    const myStatuses = await this.statusRepo.find({ where: { userId }, select: ['id'] });
    if (!myStatuses.length) return [];
    const interactions = await this.interactionRepo.find({
      where: myStatuses.map((s) => ({ statusId: s.id })),
      order: { createdAt: 'DESC' },
      take: 20,
    });
    return Promise.all(interactions.map(async (i) => {
      const fromStatus = await this.statusRepo.findOne({ where: { userId: i.fromUserId } });
      return { interaction: i, status: fromStatus };
    }));
  }

  async interact(statusId: number, fromUserId: number, type: string, content?: string): Promise<StatusInteraction> {
    const interaction = this.interactionRepo.create({ statusId, fromUserId, type, content });
    return this.interactionRepo.save(interaction);
  }

  async cleanExpired(): Promise<void> {
    await this.statusRepo.delete({ expiresAt: LessThan(new Date()) } as any);
  }
}
