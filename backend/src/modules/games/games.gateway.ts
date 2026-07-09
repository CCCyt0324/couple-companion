import {
  WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ namespace: 'games', cors: true, pingInterval: 10000, pingTimeout: 5000 })
export class GamesGateway {
  @WebSocketServer() server: Server;

  @SubscribeMessage('game:join')
  handleJoin(@ConnectedSocket() client: Socket, @MessageBody() data: { gameRoomId: number }) {
    client.join(`room_${data.gameRoomId}`);
    client.data.gameRoomId = data.gameRoomId;
  }

  @SubscribeMessage('game:leave')
  handleLeave(@ConnectedSocket() client: Socket) {
    if (client.data.gameRoomId) {
      client.leave(`room_${client.data.gameRoomId}`);
    }
  }

  notifyRoom(roomId: number, event: string, data: any) {
    this.server.to(`room_${roomId}`).emit(event, data);
  }

  notifyAnswerSubmitted(roomId: number, userId: number) {
    this.server.to(`room_${roomId}`).emit('game:answer_submitted', { userId });
  }

  notifyMatchResult(roomId: number, result: { score: number; grade: string }) {
    this.server.to(`room_${roomId}`).emit('game:match_result', result);
  }
}
