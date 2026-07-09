import {
  Controller, Get, Post, Delete, Body, Param, UseGuards,
  UploadedFile, UseInterceptors, Query,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AlbumService } from './album.service';
import { RoomService } from '../room/room.service';

@Controller('album')
@UseGuards(JwtAuthGuard)
export class AlbumController {
  constructor(
    private albumService: AlbumService,
    private roomService: RoomService,
  ) {}

  @Get()
  async list(@CurrentUser() user: any) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.albumService.listAlbums(roomId!);
  }

  @Post()
  async create(@CurrentUser() user: any, @Body() body: { name: string }) {
    const roomId = await this.roomService.getUserRoomId(user.sub);
    return this.albumService.createAlbum(roomId!, body.name);
  }

  @Delete(':id')
  async delete(@Param('id') id: number) {
    return this.albumService.deleteAlbum(id);
  }

  @Get(':id/photos')
  async getPhotos(@Param('id') id: number) {
    return this.albumService.getPhotos(id);
  }

  @Post(':id/photos')
  @UseInterceptors(FileInterceptor('file'))
  async upload(
    @Param('id') id: number,
    @UploadedFile() file: any,
    @CurrentUser() user: any,
  ) {
    const room = await this.roomService.getUserRoomId(user.sub);
    return this.albumService.uploadPhoto(
      id, user.sub, file.buffer, file.originalname, 0,
    );
  }

  @Post('photos/:photoId/like')
  async like(@Param('photoId') photoId: number, @CurrentUser() user: any) {
    return this.albumService.likePhoto(photoId, user.sub);
  }

  @Delete('photos/:photoId/like')
  async unlike(@Param('photoId') photoId: number, @CurrentUser() user: any) {
    return this.albumService.unlikePhoto(photoId, user.sub);
  }

  @Post('photos/:photoId/comments')
  async comment(
    @Param('photoId') photoId: number,
    @CurrentUser() user: any,
    @Body() body: { content: string; parentId?: number },
  ) {
    return this.albumService.addComment(photoId, user.sub, body.content, body.parentId);
  }

  @Get('photos/:photoId/comments')
  async getComments(@Param('photoId') photoId: number) {
    return this.albumService.getComments(photoId);
  }
}
