import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { RoomService } from './room.service';

@Controller('room')
@UseGuards(JwtAuthGuard)
export class RoomController {
  constructor(private roomService: RoomService) {}

  @Get()
  async getMyRoom(@CurrentUser() user: any) {
    const room = await this.roomService.getUserRoom(user.sub);
    if (!room) return null;
    const members = await this.roomService.getMembers(room.id);
    return { room, memberCount: members.length };
  }

  @Post('join')
  async join(@CurrentUser() user: any, @Body() body: { roomCode: string }) {
    const room = await this.roomService.joinRoom(user.sub, body.roomCode);
    const members = await this.roomService.getMembers(room.id);
    return { room, memberCount: members.length };
  }
}
