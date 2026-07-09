import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import appConfig from './config/app.config';
import { SnakeNamingStrategy } from './config/snake-naming.strategy';
import { AuthModule } from './modules/auth/auth.module';
import { UserModule } from './modules/user/user.module';
import { RoomModule } from './modules/room/room.module';
import { GreetingModule } from './modules/greeting/greeting.module';
import { WeatherModule } from './modules/weather/weather.module';
import { PeriodModule } from './modules/period/period.module';
import { ButlerModule } from './modules/butler/butler.module';
import { HabitModule } from './modules/habit/habit.module';
import { TodoModule } from './modules/todo/todo.module';
import { StatusModule } from './modules/status/status.module';
import { AnniversaryModule } from './modules/anniversary/anniversary.module';
import { AlbumModule } from './modules/album/album.module';
import { WishModule } from './modules/wish/wish.module';
import { GamesModule } from './modules/games/games.module';
import { MapModule } from './modules/map/map.module';
import { MoodModule } from './modules/mood/mood.module';
import { OssProvider } from './providers/oss/oss.provider';
import { PushProvider } from './providers/push/push.provider';
import { AiProvider } from './providers/ai/ai.provider';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [appConfig] }),
    JwtModule.registerAsync({ global: true, imports: [ConfigModule], inject: [ConfigService],
      useFactory: (config: ConfigService) => ({ secret: config.get('jwt.secret'), signOptions: { expiresIn: config.get('jwt.expiresIn') } }),
    }),
    TypeOrmModule.forRootAsync({ imports: [ConfigModule], inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'mysql', host: config.get('DB_HOST', '127.0.0.1'), port: config.get<number>('DB_PORT', 3306),
        username: config.get('DB_USERNAME', 'root'), password: config.get('DB_PASSWORD'),
        database: config.get('DB_DATABASE', 'couple_companion'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'], migrations: [__dirname + '/database/migrations/*{.ts,.js}'],
        namingStrategy: new SnakeNamingStrategy(), synchronize: false, logging: false, timezone: '+08:00',
      }),
    }),
    AuthModule, UserModule, RoomModule, GreetingModule, WeatherModule, PeriodModule, ButlerModule,
    HabitModule, TodoModule, StatusModule, AnniversaryModule, AlbumModule, WishModule, GamesModule, MapModule, MoodModule,
  ],
  providers: [OssProvider, PushProvider, AiProvider],
  exports: [OssProvider, PushProvider, AiProvider],
})
export class AppModule {}
