import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('room')
export class Room {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true, length: 6 })
  code: string;

  @Column({ length: 50 })
  name: string;

  @Column()
  creatorId: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('room_member')
export class RoomMember {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column()
  userId: number;

  @CreateDateColumn()
  joinedAt: Date;
}
