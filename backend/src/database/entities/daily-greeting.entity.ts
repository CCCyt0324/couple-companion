import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('daily_greeting')
export class DailyGreeting {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ type: 'date' })
  date: string;

  @Column({ nullable: true, type: 'text' })
  contentA: string;

  @Column({ nullable: true, type: 'text' })
  contentB: string;

  @Column({ nullable: true, length: 500 })
  bgImageUrl: string;

  @CreateDateColumn()
  createdAt: Date;
}
