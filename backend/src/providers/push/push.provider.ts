import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PushProvider {
  private readonly logger = new Logger(PushProvider.name);
  private jpushClient: any = null;

  constructor(private config: ConfigService) {
    try {
      const JPush = require('jpush-async');
      if (JPush && JPush.buildClient) {
        this.jpushClient = JPush.buildClient(
          this.config.get('jpush.appKey') || '',
          this.config.get('jpush.masterSecret') || '',
        );
        this.logger.log('极光推送已连接');
      }
    } catch (e) {
      this.logger.warn('极光推送初始化失败，使用开发模式日志推送');
    }
  }

  async push(userIds: number[], title: string, content: string, extras?: Record<string, string>) {
    if (!userIds.length) return;

    // 开发模式或无 JPush 客户端时输出日志
    if (!this.jpushClient) {
      this.logger.log(`[推送] 用户:${userIds.join(',')} → ${title}: ${content}`);
      return;
    }

    const aliases = userIds.map((id) => `user_${id}`);
    try {
      this.jpushClient
        .push()
        .setPlatform('ios', 'android')
        .setAudience(this.jpushClient.alias(aliases))
        .setNotification(
          this.jpushClient.ios(content, title),
          this.jpushClient.android(content, title),
        )
        .setMessage(content)
        .setOptions({ apns_production: false })
        .setExtras(extras)
        .send((err: any) => {
          if (err) this.logger.error(`推送失败: ${err.message}`);
          else this.logger.log(`推送成功 → ${userIds.length} 人`);
        });
    } catch (e) {
      this.logger.warn(`[推送] ${title}: ${content}`);
    }
  }
}
