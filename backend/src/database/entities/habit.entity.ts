import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('habit')
export class Habit {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ length: 50 })
  name: string;

  @Column({ length: 10 })
  icon: string;

  @Column({ default: 0 })
  sortOrder: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('habit_log')
export class HabitLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  habitId: number;

  @Column()
  userId: number;

  @Column({ type: 'date' })
  date: string;

  @Column({ default: true })
  completed: boolean;
}
