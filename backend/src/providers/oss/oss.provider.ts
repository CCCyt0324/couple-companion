import { Injectable, Logger, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class OssProvider {
  private readonly logger = new Logger(OssProvider.name);
  private client: any = null;

  constructor(private config: ConfigService) {
    try {
      const OSS = require('ali-oss');
      this.client = new OSS({
        region: this.config.get('oss.region') || 'oss-cn-hangzhou',
        accessKeyId: this.config.get('oss.accessKeyId') || 'dev-key',
        accessKeySecret: this.config.get('oss.accessKeySecret') || 'dev-secret',
        bucket: this.config.get('oss.bucket') || 'couple-companion',
      });
      this.logger.log('阿里云 OSS 已初始化');
    } catch (e) {
      this.logger.warn('OSS 初始化失败，文件上传功能暂不可用');
    }
  }

  async upload(file: Buffer, key: string, mimeType = 'image/jpeg'): Promise<string> {
    if (!this.client) {
      this.logger.warn(`[OSS模拟上传] ${key}`);
      return `https://dev-oss.example.com/${key}`;
    }
    const result = await this.client.put(key, file, {
      mime: mimeType,
      headers: { 'Cache-Control': 'public, max-age=31536000' },
    });
    this.logger.log(`上传成功: ${key}`);
    return result.url;
  }

  getThumbnailUrl(url: string, width = 400): string {
    return `${url}?x-oss-process=image/resize,w_${width}`;
  }
}
