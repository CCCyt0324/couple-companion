import { Controller, Get, Post, Delete, Put, Body, Param, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { TodoService } from './todo.service';
import { RoomService } from '../room/room.service';

@Controller('todo')
@UseGuards(OptionalAuthGuard)
export class TodoController {
  constructor(
    private todoService: TodoService,
    private roomService: RoomService,
  ) {}

  @Get()
  async list(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.todoService.list(roomId!);
  }

  @Post()
  async create(
    @CurrentUser() user: any,
    @Body() body: { content: string; deadline?: string },
  ) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.todoService.create(
      roomId!, user.sub, body.content,
      body.deadline ? new Date(body.deadline) : undefined,
    );
  }

  @Put(':id/toggle')
  async toggle(@Param('id') id: number) {
    return this.todoService.toggle(id);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    return this.todoService.delete(id);
  }
}
