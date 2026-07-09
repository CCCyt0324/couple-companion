import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('user_status')
export class UserStatus {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column({ length: 20 })
  type: string;

  @Column({ length: 50 })
  content: string;

  @Column({ nullable: true, length: 10 })
  emoji: string;

  @Column({ nullable: true, length: 20 })
  bgColor: string;

  @Column({ type: 'datetime' })
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('status_interaction')
export class StatusInteraction {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  statusId: number;

  @Column()
  fromUserId: number;

  @Column({ length: 20 })
  type: string;

  @Column({ nullable: true, length: 200 })
  content: string;

  @CreateDateColumn()
  createdAt: Date;
}
