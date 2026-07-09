import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class AiProvider {
  private readonly logger = new Logger(AiProvider.name);

  constructor(private config: ConfigService) {}

  /** 自由对话 */
  async chat(
    messages: Array<{ role: 'user' | 'assistant' | 'system'; content: string }>,
    systemPrompt?: string,
  ): Promise<string> {
    const fullMessages = systemPrompt
      ? [{ role: 'system' as const, content: systemPrompt }, ...messages]
      : messages;

    try {
      const res = await axios.post(
        `${this.config.get('ai.apiUrl')}/chat/completions`,
        { model: this.config.get('ai.model'), messages: fullMessages, temperature: 0.8, max_tokens: 500 },
        { headers: { Authorization: `Bearer ${this.config.get('ai.apiKey')}`, 'Content-Type': 'application/json' }, timeout: 30000 },
      );
      return res.data.choices[0].message.content;
    } catch (err: any) {
      this.logger.error(`AI 对话失败: ${err.message}`);
      return '喵～暹暹刚才走神了，能再说一遍吗？😺';
    }
  }

  /** 生成管家建议（旧接口） */
  async generateButlerAdvice(context: any): Promise<{ suggestions: string[]; warning: string; templates: string[] }> {
    const prompt = this.buildPrompt(context);
    try {
      const res = await axios.post(
        `${this.config.get('ai.apiUrl')}/chat/completions`,
        {
          model: this.config.get('ai.model'),
          messages: [
            { role: 'system', content: '你是一位贴心的恋爱管家。给出3条今日行动建议、1条避坑提醒、2条高情商话术模板。回答必须是严格JSON格式：{"suggestions":["建议1","建议2","建议3"],"warning":"避坑提醒","templates":["话术1","话术2"]}' },
            { role: 'user', content: prompt },
          ],
          temperature: 0.8,
        },
        { headers: { Authorization: `Bearer ${this.config.get('ai.apiKey')}`, 'Content-Type': 'application/json' } },
      );
      const text = res.data.choices[0].message.content;
      return JSON.parse(text.replace(/```json\s*|```\s*/g, '').trim());
    } catch (err: any) {
      this.logger.error(`AI 调用失败: ${err.message}`);
      return {
        suggestions: ['今天多关心对方', '给TA发一句早安', '询问TA今天过得怎么样'],
        warning: '今天尽量避免说让对方不开心的话',
        templates: ['宝贝今天想我了吗？', '辛苦啦，记得好好休息~'],
      };
    }
  }

  private buildPrompt(ctx: any): string {
    const parts: string[] = [];
    if (ctx.partnerMood !== undefined) {
      const d = ctx.partnerMood > 80 ? '非常开心' : ctx.partnerMood > 60 ? '心情不错' : ctx.partnerMood > 40 ? '平静一般' : ctx.partnerMood > 20 ? '有点低落' : '非常低落';
      parts.push(`对方今日心情值：${ctx.partnerMood}（${d}）`);
    }
    if (ctx.periodPhase) parts.push(`对方经期阶段：${ctx.periodPhase}`);
    if (ctx.weather) parts.push(`今日天气：${ctx.weather}`);
    if (ctx.todayHabits) parts.push(`对方今日打卡：${ctx.todayHabits}`);
    if (ctx.upcomingAnniversary) parts.push(`即将到来的纪念日：${ctx.upcomingAnniversary}`);
    return parts.join('\n');
  }
}
