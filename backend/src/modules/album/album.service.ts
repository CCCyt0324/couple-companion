import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import { Album, Photo, PhotoLike, PhotoComment } from '../../database/entities/album.entity';

@Injectable()
export class AlbumService {
  private readonly uploadDir = path.join(process.cwd(), 'uploads', 'photos');

  constructor(
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Photo) private photoRepo: Repository<Photo>,
    @InjectRepository(PhotoLike) private likeRepo: Repository<PhotoLike>,
    @InjectRepository(PhotoComment) private commentRepo: Repository<PhotoComment>,
  ) {
    if (!fs.existsSync(this.uploadDir)) { fs.mkdirSync(this.uploadDir, { recursive: true }); }
  }

  // ========== 相册 ==========

  async listAlbums(roomId: number): Promise<Album[]> {
    return this.albumRepo.find({ where: { roomId }, order: { sortOrder: 'ASC' } });
  }

  async createAlbum(roomId: number, name: string, userId: number): Promise<Album> {
    const album = this.albumRepo.create({ roomId, name });
    return this.albumRepo.save(album);
  }

  async updateAlbum(id: number, name: string): Promise<Album> {
    await this.albumRepo.update(id, { name });
    return (await this.albumRepo.findOne({ where: { id } }))!;
  }

  async deleteAlbum(id: number): Promise<void> {
    const photos = await this.photoRepo.find({ where: { albumId: id } });
    for (const p of photos) { this.deleteFile(p.url); }
    await this.photoRepo.delete({ albumId: id });
    await this.albumRepo.delete(id);
  }

  // ========== 照片 ==========

  async getPhotos(albumId: number): Promise<any[]> {
    const photos = await this.photoRepo.find({ where: { albumId }, order: { createdAt: 'DESC' } });
    return Promise.all(photos.map(async (p) => {
      const [likes, comments] = await Promise.all([
        this.likeRepo.find({ where: { photoId: p.id } }),
        this.commentRepo.find({ where: { photoId: p.id }, order: { createdAt: 'ASC' }, take: 20 }),
      ]);
      return { ...p, likeCount: likes.length, likes, comments };
    }));
  }

  /** 通过 multipart 文件上传（推荐） */
  async uploadPhotoFile(albumId: number, userId: number, file: Express.Multer.File): Promise<Photo> {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedMimes.includes(file.mimetype)) throw new BadRequestException('仅支持 JPG/PNG/GIF/WebP 格式');

    const ext = file.mimetype === 'image/jpeg' ? 'jpg' : file.mimetype.replace('image/', '');
    const hash = crypto.createHash('md5').update(file.buffer).digest('hex').substring(0, 12);
    const fileName = `${Date.now()}_${hash}.${ext}`;
    const filePath = path.join(this.uploadDir, fileName);
    fs.writeFileSync(filePath, file.buffer);

    const photo = this.photoRepo.create({ albumId, uploadUserId: userId, url: `/uploads/photos/${fileName}` });
    await this.photoRepo.save(photo);

    const album = await this.albumRepo.findOne({ where: { id: albumId } });
    if (album && !album.coverUrl) { album.coverUrl = `/uploads/photos/${fileName}`; await this.albumRepo.save(album); }
    return photo;
  }

  /** 通过 base64 上传（备用，如粘贴截图） */
  async uploadPhotoBase64(albumId: number, userId: number, base64: string, filename?: string): Promise<Photo> {
    const matches = base64.match(/^data:image\/(png|jpeg|gif|webp);base64,(.+)$/);
    if (!matches) throw new BadRequestException('无效的图片格式');

    const ext = matches[1] === 'jpeg' ? 'jpg' : matches[1];
    const hash = crypto.createHash('md5').update(base64).digest('hex').substring(0, 12);
    const fileName = `${Date.now()}_${hash}.${ext}`;
    const filePath = path.join(this.uploadDir, fileName);
    fs.writeFileSync(filePath, Buffer.from(matches[2], 'base64'));

    const photo = this.photoRepo.create({ albumId, uploadUserId: userId, url: `/uploads/photos/${fileName}` });
    await this.photoRepo.save(photo);

    const album = await this.albumRepo.findOne({ where: { id: albumId } });
    if (album && !album.coverUrl) { album.coverUrl = `/uploads/photos/${fileName}`; await this.albumRepo.save(album); }
    return photo;
  }

  async deletePhoto(id: number): Promise<void> {
    const photo = await this.photoRepo.findOne({ where: { id } });
    if (!photo) throw new NotFoundException('照片不存在');
    this.deleteFile(photo.url);
    await this.commentRepo.delete({ photoId: id });
    await this.likeRepo.delete({ photoId: id });
    await this.photoRepo.delete(id);
  }

  // ========== 点赞 ==========

  async toggleLike(photoId: number, userId: number): Promise<{ liked: boolean; count: number }> {
    const existing = await this.likeRepo.findOne({ where: { photoId, userId } });
    if (existing) { await this.likeRepo.remove(existing); }
    else { await this.likeRepo.save(this.likeRepo.create({ photoId, userId })); }
    const count = await this.likeRepo.count({ where: { photoId } });
    return { liked: !existing, count };
  }

  // ========== 评论 ==========

  async addComment(photoId: number, userId: number, content: string, parentId?: number): Promise<PhotoComment> {
    if (!content?.trim()) throw new BadRequestException('评论不能为空');
    const comment = this.commentRepo.create({ photoId, userId, content: content.trim(), parentId });
    return this.commentRepo.save(comment);
  }

  async deleteComment(id: number): Promise<void> {
    await this.commentRepo.delete(id);
  }

  async getComments(photoId: number): Promise<PhotoComment[]> {
    return this.commentRepo.find({ where: { photoId }, order: { createdAt: 'ASC' } });
  }

  private deleteFile(url: string) {
    if (!url?.startsWith('/uploads/')) return;
    try { fs.unlinkSync(path.join(process.cwd(), url)); } catch (_) {}
  }
}
