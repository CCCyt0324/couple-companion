import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { WishService } from './wish.service';
import { RoomService } from '../room/room.service';

@Controller('wish')
@UseGuards(OptionalAuthGuard)
export class WishController {
  constructor(
    private wishService: WishService,
    private roomService: RoomService,
  ) {}

  @Post()
  async send(
    @CurrentUser() user: any,
    @Body() body: { content: string; type: string },
  ) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.wishService.send(roomId!, user.sub, body.content, body.type);
  }

  @Get()
  async list(@CurrentUser() user: any, @Query('type') type?: string) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.wishService.list(roomId!, type);
  }

  @Put(':id/read')
  async markRead(@Param('id') id: number) {
    return this.wishService.markRead(id);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    return this.wishService.delete(id);
  }
}
