import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('wish_note')
export class WishNote {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column()
  fromUserId: number;

  @Column({ type: 'text' })
  content: string;

  @Column({ length: 20 })
  type: string;

  @Column({ default: false })
  isRead: boolean;

  @Column({ default: 'active', length: 20 })
  status: string;

  @CreateDateColumn()
  createdAt: Date;
}
