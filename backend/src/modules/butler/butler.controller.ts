import { Controller, Post, Body } from '@nestjs/common';
import { ButlerService } from './butler.service';

@Controller('butler')
export class ButlerController {
  constructor(private butlerService: ButlerService) {}

  /** 自由对话 —— 无需登录 */
  @Post('chat')
  async chat(@Body() body: { messages: Array<{ role: 'user' | 'assistant'; content: string }> }) {
    const reply = await this.butlerService.chat(body.messages || []);
    return { role: 'assistant', content: reply };
  }
}
