import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { StatusService } from './status.service';

@Controller('status')
@UseGuards(OptionalAuthGuard)
export class StatusController {
  constructor(private statusService: StatusService) {}

  @Get('mine') getMine(@CurrentUser() u: any) { return this.statusService.getStatus(u.sub); }
  @Get('partner') getPartner(@CurrentUser() u: any) { return this.statusService.getPartnerStatus(u.sub); }
  @Get('interactions') getInteractions(@CurrentUser() u: any) { return this.statusService.getMyInteractions(u.sub); }
  @Post() setStatus(@CurrentUser() u: any, @Body() b: any) { return this.statusService.setStatus(u.sub, b); }
  @Post(':id/interact') interact(@Param('id') id: number, @CurrentUser() u: any, @Body() b: { type: string; content?: string }) { return this.statusService.interact(id, u.sub, b.type, b.content); }
}
