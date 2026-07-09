import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn,
} from 'typeorm';

@Entity('user')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true, nullable: true, length: 20 })
  phone: string;

  @Column({ unique: true, nullable: true, length: 100 })
  email: string;

  @Column({ unique: true, nullable: true, length: 64 })
  wechatOpenid: string;

  @Column({ length: 100 })
  passwordHash: string;

  @Column({ length: 50 })
  nickname: string;

  @Column({ nullable: true, length: 500 })
  avatarUrl: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
