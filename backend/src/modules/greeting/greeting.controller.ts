import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GreetingService } from './greeting.service';
import { RoomService } from '../room/room.service';

@Controller('greeting')
@UseGuards(JwtAuthGuard)
export class GreetingController {
  constructor(
    private greetingService: GreetingService,
    private roomService: RoomService,
  ) {}

  @Get('today')
  async getToday(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.greetingService.getToday(roomId!);
  }

  @Put('content')
  async update(@CurrentUser() user: any, @Body() body: { content: string; isUserA: boolean }) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.greetingService.update(roomId!, user.sub, body.content, body.isUserA);
  }

  @Put('bg-image')
  async updateBgImage(@CurrentUser() user: any, @Body() body: { bgImageUrl: string }) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.greetingService.updateBgImage(roomId!, body.bgImageUrl);
  }
}
