import {
  WebSocketGateway, WebSocketServer, SubscribeMessage,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ namespace: 'greeting', cors: true })
export class GreetingGateway {
  @WebSocketServer() server: Server;

  /** 通知对方情话已更新 */
  notifyGreetingUpdated(roomId: number, data: any) {
    this.server.to(`couple_${roomId}`).emit('greeting:updated', data);
  }

  @SubscribeMessage('greeting:join')
  handleJoin(client: Socket, roomId: number) {
    client.join(`couple_${roomId}`);
  }
}
