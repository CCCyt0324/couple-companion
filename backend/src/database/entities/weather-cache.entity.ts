import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('weather_cache')
export class WeatherCache {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  roomId: number;

  @Column({ length: 50 })
  city: string;

  @Column({ type: 'simple-json' })
  data: any;

  @Column({ type: 'datetime' })
  cachedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
