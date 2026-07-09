import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('period_record')
export class PeriodRecord {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column({ type: 'date' })
  date: string;

  @Column({ length: 10 })
  flowLevel: string;

  @Column({ type: 'simple-json', nullable: true })
  symptoms: string[];

  @Column({ type: 'simple-json', nullable: true })
  emotions: string[];

  @Column({ nullable: true, type: 'text' })
  note: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('period_setting')
export class PeriodSetting {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column({ default: 28 })
  cycleDays: number;

  @Column({ default: 7 })
  periodDays: number;

  @CreateDateColumn()
  createdAt: Date;
}
