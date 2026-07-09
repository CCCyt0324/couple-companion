import { Injectable, Inject } from '@nestjs/common';
import { Redis } from 'ioredis';
import { AiProvider } from '../../providers/ai/ai.provider';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

@Injectable()
export class ButlerService {
  private readonly systemPrompt = `你是"暹暹"，一只可爱的暹罗猫，也是情侣陪伴小助手的AI管家。你的特点：
- 说话温柔可爱，带一点喵的语气
- 擅长给恋爱建议、情感安慰、约会点子
- 可以用emoji，但不要过度
- 回答简洁温暖，2-5句话为宜
- 记住对话历史，保持上下文连贯`;

  constructor(
    private aiProvider: AiProvider,
    @Inject('REDIS') private redis: Redis,
  ) {}

  /** 随问随答 —— 流式 / 非流式均支持 */
  async chat(messages: ChatMessage[]): Promise<string> {
    return this.aiProvider.chat(messages, this.systemPrompt);
  }

  /** 保留旧接口兼容 */
  async getAdvice(roomId: number): Promise<{ suggestions: string[]; warning: string; templates: string[]; cached: boolean }> {
    const cacheKey = `butler:advice:${roomId}:${new Date().toISOString().slice(0, 10)}`;
    try {
      const cached = await this.redis.get(cacheKey);
      if (cached) return { ...JSON.parse(cached), cached: true };
    } catch (_) {}

    const result = await this.aiProvider.generateButlerAdvice({});
    try { await this.redis.setex(cacheKey, 86400, JSON.stringify(result)); } catch (_) {}
    return { ...result, cached: false };
  }
}
