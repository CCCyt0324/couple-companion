import {
  WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ namespace: 'map', cors: true })
export class MapGateway {
  @WebSocketServer() server: Server;

  @SubscribeMessage('map:join')
  handleJoin(@ConnectedSocket() client: Socket, @MessageBody() roomId: number) {
    client.join(`couple_${roomId}`);
  }

  /** 推送对方最新位置 */
  notifyLocationUpdate(roomId: number, userId: number, data: { lat: number; lng: number }) {
    this.server.to(`couple_${roomId}`).emit('map:location_changed', { userId, ...data });
  }
}
