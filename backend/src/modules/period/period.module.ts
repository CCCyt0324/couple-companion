import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PeriodRecord, PeriodSetting } from '../../database/entities/period.entity';
import { PeriodService } from './period.service';
import { PeriodController } from './period.controller';

@Module({
  imports: [TypeOrmModule.forFeature([PeriodRecord, PeriodSetting])],
  controllers: [PeriodController],
  providers: [PeriodService],
})
export class PeriodModule {}
