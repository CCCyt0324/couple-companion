import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WishNote } from '../../database/entities/wish-note.entity';
import { PushProvider } from '../../providers/push/push.provider';

@Injectable()
export class WishService {
  constructor(
    @InjectRepository(WishNote) private repo: Repository<WishNote>,
    private pushProvider: PushProvider,
  ) {}

  async send(roomId: number, fromUserId: number, content: string, type: string): Promise<WishNote> {
    const note = this.repo.create({ roomId, fromUserId, content, type });
    await this.repo.save(note);

    const couple = await this.repo.manager
      .getRepository('couple').findOne({ where: { id: roomId } }) as any;
    if (couple) {
      const partnerId = couple.userAId === fromUserId ? couple.userBId : couple.userAId;
      const typeLabel = type === 'whisper' ? '悄悄话' : '小心愿';
      this.pushProvider.push(
        [partnerId],
        `收到${typeLabel}`,
        content.slice(0, 30) + (content.length > 30 ? '...' : ''),
        { type: 'wish_note', noteType: type },
      );
    }
    return note;
  }

  async list(roomId: number, type?: string): Promise<WishNote[]> {
    const where: any = { roomId };
    if (type) where.type = type;
    return this.repo.find({ where, order: { createdAt: 'DESC' } });
  }

  async markRead(id: number): Promise<void> {
    await this.repo.update(id, { isRead: true });
  }

  async delete(id: number): Promise<void> {
    await this.repo.delete(id);
  }
}
