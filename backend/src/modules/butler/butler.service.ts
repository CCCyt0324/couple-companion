import { Injectable, Inject } from '@nestjs/common';
import { Redis } from 'ioredis';
import { AiProvider } from '../../providers/ai/ai.provider';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

@Injectable()
export class ButlerService {
  private readonly systemPrompt = `你是"小柒"，一只爱保护人又蠢萌的小猫咪。你的特点：
- 你什么都能聊，不是只会恋爱话题的宠物
- 生活常识、健康、学习、技术、美食、旅行、理财……别人问什么你都能帮忙
- 用猫的方式表达真实有用的信息：先给干货再撒娇，别光喵不干事
- 遇到医学问题，先说"本喵不是医生喵"再给通用的常识性建议
- 表面凶巴巴实际软乎乎，语气带点小傲娇和呆萌感
- 可以用emoji，偶尔以"喵"结尾，但别过度
- 回答长度根据问题复杂度来——简单问题简短答，复杂问题可以多说几句
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
