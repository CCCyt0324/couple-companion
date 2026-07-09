import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { MoodService } from './mood.service';
import { RoomService } from '../room/room.service';

@Controller('mood')
@UseGuards(JwtAuthGuard)
export class MoodController {
  constructor(
    private moodService: MoodService,
    private roomService: RoomService,
  ) {}

  @Get('today')
  getToday(@CurrentUser() user: any) {
    return this.moodService.getToday(user.sub);
  }

  @Post()
  set(@CurrentUser() user: any, @Body() body: { moodValue: number; note?: string }) {
    return this.moodService.set(user.sub, body.moodValue, body.note);
  }

  @Get('history')
  getHistory(
    @CurrentUser() user: any,
    @Query('year') year: number,
    @Query('month') month: number,
  ) {
    return this.moodService.getHistory(user.sub, year, month);
  }

  @Get('compare')
  async compare(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    if (!roomId) return { myMood: null, partnerMood: null };
    return this.moodService.getPartnerMood(roomId, user.sub);
  }
}
