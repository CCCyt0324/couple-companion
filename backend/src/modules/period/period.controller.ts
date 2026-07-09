import { Controller, Get, Post, Put, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PeriodService } from './period.service';

@Controller('period')
@UseGuards(JwtAuthGuard)
export class PeriodController {
  constructor(private periodService: PeriodService) {}

  @Get('today')
  getToday(@CurrentUser() user: any) {
    return this.periodService.getToday(user.sub);
  }

  @Post('record')
  save(@CurrentUser() user: any, @Body() body: any) {
    return this.periodService.save(user.sub, body);
  }

  @Get('setting')
  getSetting(@CurrentUser() user: any) {
    return this.periodService.getSetting(user.sub);
  }

  @Put('setting')
  updateSetting(@CurrentUser() user: any, @Body() body: { cycleDays: number; periodDays: number }) {
    return this.periodService.updateSetting(user.sub, body.cycleDays, body.periodDays);
  }

  @Get('predict')
  predict(@CurrentUser() user: any) {
    return this.periodService.predict(user.sub);
  }

  @Get('countdown')
  countdown(@CurrentUser() user: any) {
    return this.periodService.getCountdown(user.sub);
  }
}
