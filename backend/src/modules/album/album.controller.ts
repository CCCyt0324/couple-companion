import { Controller, Get, Post, Delete, Put, Body, Param, UseGuards, UseInterceptors, UploadedFile, Req } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AlbumService } from './album.service';

@Controller('album')
@UseGuards(OptionalAuthGuard)
export class AlbumController {
  constructor(private albumService: AlbumService) {}

  @Get() async list(@CurrentUser() u: any) { return this.albumService.listAlbums(u.sub || 1); }
  @Post() create(@CurrentUser() u: any, @Body() b: { name: string }) { return this.albumService.createAlbum(u.sub || 1, b.name, u.sub); }
  @Put(':id') update(@Param('id') id: number, @Body() b: { name: string }) { return this.albumService.updateAlbum(id, b.name); }
  @Delete(':id') deleteAlbum(@Param('id') id: number) { return this.albumService.deleteAlbum(id); }

  @Get(':id/photos') getPhotos(@Param('id') id: number) { return this.albumService.getPhotos(id); }

  /** Multipart 文件上传 */
  @Post(':id/photos/upload')
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: 10 * 1024 * 1024 } }))
  async uploadFile(@CurrentUser() u: any, @Param('id') id: number, @UploadedFile() file: Express.Multer.File) {
    if (!file) return { error: '请选择文件' };
    return this.albumService.uploadPhotoFile(id, u.sub, file);
  }

  /** Base64 上传（备用） */
  @Post(':id/photos')
  uploadBase64(@CurrentUser() u: any, @Param('id') id: number, @Body() b: { base64: string; filename?: string }) {
    return this.albumService.uploadPhotoBase64(id, u.sub, b.base64, b.filename);
  }

  @Delete('photos/:photoId') deletePhoto(@Param('photoId') id: number) { return this.albumService.deletePhoto(id); }
  @Post('photos/:photoId/like') like(@CurrentUser() u: any, @Param('photoId') id: number) { return this.albumService.toggleLike(id, u.sub); }
  @Get('photos/:photoId/comments') getComments(@Param('photoId') id: number) { return this.albumService.getComments(id); }
  @Post('photos/:photoId/comments') addComment(@CurrentUser() u: any, @Param('photoId') id: number, @Body() b: { content: string }) { return this.albumService.addComment(id, u.sub, b.content); }
  @Delete('comments/:id') deleteComment(@Param('id') id: number) { return this.albumService.deleteComment(id); }
}
