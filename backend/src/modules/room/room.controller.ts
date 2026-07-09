import { Controller, Get, Post, Body, Headers } from '@nestjs/common';
import { RoomService } from './room.service';

@Controller('room')
export class RoomController {
  constructor(private roomService: RoomService) {}

  /** 创建匿名用户并初始化房间。返回 userId + 房间码，前端存 localStorage 后续用 */
  @Post('start')
  async start() {
    return this.roomService.createAnonymousUserWithRoom();
  }

  /** 通过房间码加入房间 */
  @Post('join')
  async join(@Headers('x-user-id') userId: string, @Body() body: { roomCode: string }) {
    if (!userId) return { error: '缺少用户标识，请先调用 /room/start' };
    const room = await this.roomService.joinRoom(parseInt(userId), body.roomCode);
    const members = await this.roomService.getMembers(room.id);
    return { room, memberCount: members.length };
  }

  /** 退出房间——创建新房间并自动加入 */
  @Post('leave')
  async leave(@Headers('x-user-id') userId: string) {
    if (!userId) return { error: '缺少用户标识' };
    return this.roomService.leaveAndNewRoom(parseInt(userId));
  }

  /** 获取当前用户的房间信息 */
  @Get()
  async getRoom(@Headers('x-user-id') userId: string) {
    if (!userId) return null;
    const room = await this.roomService.getUserRoom(parseInt(userId));
    if (!room) return null;
    const members = await this.roomService.getMembers(room.id);
    return { room, memberCount: members.length };
  }
}
