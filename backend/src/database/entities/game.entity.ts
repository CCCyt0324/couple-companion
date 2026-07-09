import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('game_room')
export class GameRoom {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 30 })
  gameType: string;

  @Column()
  roomId: number;

  @Column({ length: 20, default: 'waiting' })
  status: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('game_question')
export class GameQuestion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 30 })
  gameType: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'simple-json', nullable: true })
  options: string[];
}

@Entity('game_answer')
export class GameAnswer {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column()
  userId: number;

  @Column()
  questionId: number;

  @Column({ type: 'text' })
  answer: string;

  @Column({ default: 0 })
  score: number;
}
