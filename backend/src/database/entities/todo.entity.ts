import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('todo')
export class Todo {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ length: 500 })
  content: string;

  @Column({ default: 'pending', length: 20 })
  status: string;

  @Column()
  createdBy: number;

  @Column({ type: 'datetime', nullable: true })
  deadline: Date;

  @CreateDateColumn()
  createdAt: Date;
}
