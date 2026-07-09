import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { MoodService } from './mood.service';

@Controller('mood')
@UseGuards(OptionalAuthGuard)
export class MoodController {
  constructor(private moodService: MoodService) {}

  @Get('today') getToday(@CurrentUser() u: any) { return this.moodService.getToday(u.sub); }
  @Post() set(@CurrentUser() u: any, @Body() b: { moodValue: number; note?: string }) { return this.moodService.set(u.sub, b.moodValue, b.note); }
  @Get('history') getHistory(@CurrentUser() u: any, @Query('year') y: number, @Query('month') m: number) { return this.moodService.getHistory(u.sub, y, m); }
  @Get('compare') compare(@CurrentUser() u: any) { return this.moodService.getPartnerMood(u.sub); }
}
