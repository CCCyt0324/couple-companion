import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { OptionalAuthGuard } from '../../common/guards/optional-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserService } from './user.service';

@Controller('user')
@UseGuards(OptionalAuthGuard)
export class UserController {
  constructor(private userService: UserService) {}

  @Get('profile')
  async profile(@CurrentUser() user: any) {
    return this.userService.findById(user.sub);
  }

  @Put('profile')
  async updateProfile(
    @CurrentUser() user: any,
    @Body() body: { nickname?: string; avatarUrl?: string },
  ) {
    return this.userService.update(user.sub, body);
  }
}
