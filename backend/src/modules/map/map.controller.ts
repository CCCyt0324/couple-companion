import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { MapService } from './map.service';
import { RoomService } from '../room/room.service';

@Controller('map')
@UseGuards(JwtAuthGuard)
export class MapController {
  constructor(private mapService: MapService, private roomService: RoomService) {}

  @Post('location')
  updateLocation(@CurrentUser() user: any, @Body() body: { lat: number; lng: number }) {
    return this.mapService.updateLocation(user.sub, body.lat, body.lng);
  }

  @Get('locations')
  async getLocations(@CurrentUser() user: any) {
    const room = await this.roomService.getUserRoom(user.sub);
    if (!room) return { myLocation: null, partnerLocation: null, distance: null, partnerSharing: false };
    const members = await this.roomService.getMembers(room.id);
    const partner = members.find((m) => m.userId !== user.sub);
    const [myLoc, ptLoc, ptSharing] = await Promise.all([
      this.mapService.getLocation(user.sub),
      partner ? this.mapService.getLocation(partner.userId) : null,
      partner ? this.mapService.getSharedStatus(partner.userId) : false,
    ]);
    let distance: number | null = null;
    if (myLoc && ptLoc && ptSharing) {
      distance = this.mapService.calculateDistance(myLoc.lat, myLoc.lng, ptLoc.lat, ptLoc.lng);
    }
    return { myLocation: myLoc, partnerLocation: ptSharing ? ptLoc : null, distance: distance ? `${distance.toFixed(1)} 公里` : null, partnerSharing: ptSharing };
  }

  @Post('share-status')
  setSharedStatus(@CurrentUser() user: any, @Body() body: { sharing: boolean }) {
    return this.mapService.setSharedStatus(user.sub, body.sharing);
  }
}
