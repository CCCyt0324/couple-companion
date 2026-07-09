import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('anniversary')
export class Anniversary {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ length: 100 })
  title: string;

  @Column({ type: 'date' })
  date: string;

  @Column({ length: 20, default: 'recurring' })
  type: string;

  @Column({ type: 'simple-json', nullable: true })
  remindConfig: { onDay: boolean; threeDaysBefore: boolean; sevenDaysBefore: boolean };

  @Column({ nullable: true, length: 500 })
  bgImageUrl: string;

  @CreateDateColumn()
  createdAt: Date;
}
