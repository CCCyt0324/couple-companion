import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { GamesService } from './games.service';
import { RoomService } from '../room/room.service';

@Controller('games')
@UseGuards(JwtAuthGuard)
export class GamesController {
  constructor(private gamesService: GamesService, private roomService: RoomService) {}

  @Post('room')
  async createRoom(@CurrentUser() user: any, @Body() body: { gameType: string }) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.gamesService.createRoom(roomId!, body.gameType);
  }

  @Get('room/:id') getRoom(@Param('id') id: number) { return this.gamesService.getRoom(id); }
  @Post('room/:id/start') startGame(@Param('id') id: number) { return this.gamesService.startGame(id); }
  @Get('question/:gameType') getQuestion(@Param('gameType') gameType: string) { return this.gamesService.getQuestion(gameType); }

  @Post('answer')
  submitAnswer(@Body() body: { roomId: number; questionId: number; answer: string }, @CurrentUser() user: any) {
    return this.gamesService.submitAnswer(body.roomId, user.sub, body.questionId, body.answer);
  }

  @Get('match/:roomId') calculateMatch(@Param('roomId') roomId: number) { return this.gamesService.calculateMatch(roomId); }

  @Get('history')
  async history(@CurrentUser() user: any, @Query('type') type?: string) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.gamesService.getHistory(roomId!, type);
  }
}
