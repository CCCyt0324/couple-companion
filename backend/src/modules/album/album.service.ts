import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Album, Photo, PhotoLike, PhotoComment } from '../../database/entities/album.entity';
import { OssProvider } from '../../providers/oss/oss.provider';
import { PushProvider } from '../../providers/push/push.provider';

@Injectable()
export class AlbumService {
  constructor(
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Photo) private photoRepo: Repository<Photo>,
    @InjectRepository(PhotoLike) private likeRepo: Repository<PhotoLike>,
    @InjectRepository(PhotoComment) private commentRepo: Repository<PhotoComment>,
    private ossProvider: OssProvider,
    private pushProvider: PushProvider,
  ) {}

  // ---- 相册 ----

  async listAlbums(roomId: number): Promise<Album[]> {
    return this.albumRepo.find({ where: { roomId }, order: { sortOrder: 'ASC' } });
  }

  async createAlbum(roomId: number, name: string): Promise<Album> {
    const album = this.albumRepo.create({ roomId, name });
    return this.albumRepo.save(album);
  }

  async deleteAlbum(id: number): Promise<void> {
    await this.albumRepo.delete(id);
  }

  // ---- 照片 ----

  async getPhotos(albumId: number): Promise<Photo[]> {
    return this.photoRepo.find({
      where: { albumId }, order: { createdAt: 'DESC' },
    });
  }

  async uploadPhoto(
    albumId: number, uploadUserId: number, fileBuffer: Buffer, filename: string, partnerId: number,
  ): Promise<Photo> {
    const key = `albums/${albumId}/${Date.now()}_${filename}`;
    const url = await this.ossProvider.upload(fileBuffer, key);
    const thumbnailUrl = this.ossProvider.getThumbnailUrl(url);
    const photo = this.photoRepo.create({ albumId, uploadUserId, url, thumbnailUrl });
    await this.photoRepo.save(photo);

    this.pushProvider.push(
      [partnerId],
      '相册更新',
      'TA 上传了新的照片',
      { type: 'album_photo', albumId: String(albumId), photoId: String(photo.id) },
    );
    return photo;
  }

  // ---- 点赞 ----

  async likePhoto(photoId: number, userId: number): Promise<number> {
    const existing = await this.likeRepo.findOne({ where: { photoId, userId } });
    if (existing) throw new BadRequestException('已经赞过啦');

    const like = this.likeRepo.create({ photoId, userId });
    await this.likeRepo.save(like);
    const count = await this.likeRepo.count({ where: { photoId } });
    return count;
  }

  async unlikePhoto(photoId: number, userId: number): Promise<number> {
    await this.likeRepo.delete({ photoId, userId });
    return this.likeRepo.count({ where: { photoId } });
  }

  // ---- 评论 ----

  async addComment(photoId: number, userId: number, content: string, parentId?: number): Promise<PhotoComment> {
    const comment = this.commentRepo.create({ photoId, userId, content, parentId });
    return this.commentRepo.save(comment);
  }

  async getComments(photoId: number): Promise<PhotoComment[]> {
    return this.commentRepo.find({
      where: { photoId }, order: { createdAt: 'ASC' },
    });
  }
}
