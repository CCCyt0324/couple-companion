import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { StatusService } from './status.service';

@Controller('status')
@UseGuards(JwtAuthGuard)
export class StatusController {
  constructor(private statusService: StatusService) {}

  @Get('mine')
  getMine(@CurrentUser() user: any) {
    return this.statusService.getStatus(user.sub);
  }

  @Post()
  setStatus(@CurrentUser() user: any, @Body() body: any) {
    return this.statusService.setStatus(user.sub, body);
  }

  @Post(':id/interact')
  interact(
    @Param('id') id: number,
    @CurrentUser() user: any,
    @Body() body: { type: string; content?: string },
  ) {
    return this.statusService.interact(id, user.sub, body.type, body.content);
  }
}
