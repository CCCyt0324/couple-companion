import { Controller, Get, Post, Delete, Put, Body, Param, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { HabitService } from './habit.service';
import { RoomService } from '../room/room.service';

@Controller('habit')
@UseGuards(OptionalAuthGuard)
export class HabitController {
  constructor(
    private habitService: HabitService,
    private roomService: RoomService,
  ) {}

  @Get()
  async list(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.habitService.list(roomId!);
  }

  @Post()
  async create(@CurrentUser() user: any, @Body() body: { name: string; icon: string }) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.habitService.create(roomId!, body.name, body.icon);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    return this.habitService.delete(id);
  }

  @Put(':id/toggle')
  async toggle(@Param('id') id: number, @CurrentUser() user: any) {
    return this.habitService.toggle(id, user.sub);
  }

  @Get('today-stats')
  async todayStats(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.habitService.getTodayStats(roomId!);
  }
}
