import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('album')
export class Album {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ length: 100 })
  name: string;

  @Column({ nullable: true, length: 500 })
  coverUrl: string;

  @Column({ default: 0 })
  sortOrder: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('photo')
export class Photo {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  albumId: number;

  @Column()
  uploadUserId: number;

  @Column({ length: 500 })
  url: string;

  @Column({ nullable: true, length: 500 })
  thumbnailUrl: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('photo_like')
export class PhotoLike {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  photoId: number;

  @Column()
  userId: number;
}

@Entity('photo_comment')
export class PhotoComment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  photoId: number;

  @Column()
  userId: number;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  parentId: number;

  @CreateDateColumn()
  createdAt: Date;
}
