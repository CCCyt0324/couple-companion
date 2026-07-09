import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PhoneRegisterDto, EmailRegisterDto, PhoneLoginDto, EmailLoginDto, SendSmsDto } from './auth.dto';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('sms/send') sendSms(@Body() dto: SendSmsDto) { return this.authService.sendSmsCode(dto.phone); }
  @Post('register/phone') phoneRegister(@Body() dto: PhoneRegisterDto) { return this.authService.phoneRegister(dto); }
  @Post('register/email') emailRegister(@Body() dto: EmailRegisterDto) { return this.authService.emailRegister(dto); }
  @Post('login/phone') phoneLogin(@Body() dto: PhoneLoginDto) { return this.authService.phoneLogin(dto); }
  @Post('login/email') emailLogin(@Body() dto: EmailLoginDto) { return this.authService.emailLogin(dto.email, dto.password); }
}
