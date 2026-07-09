import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AnniversaryService } from './anniversary.service';
import { RoomService } from '../room/room.service';

@Controller('anniversary')
@UseGuards(JwtAuthGuard)
export class AnniversaryController {
  constructor(
    private anniversaryService: AnniversaryService,
    private roomService: RoomService,
  ) {}

  @Get()
  async list(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.anniversaryService.list(roomId!);
  }

  @Post()
  async create(@CurrentUser() user: any, @Body() body: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.anniversaryService.create(roomId!, body);
  }

  @Put(':id')
  async update(@Param('id') id: number, @Body() body: any) {
    return this.anniversaryService.update(id, body);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    return this.anniversaryService.delete(id);
  }

  @Get('upcoming')
  async upcoming(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.anniversaryService.getUpcomingAnniversaries(roomId!);
  }
}
