import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

/**
 * 可选鉴权守卫——优先用 JWT token，无 token 时尝试从 x-user-id 头获取用户
 * 适配自用模式：前端 localStorage 存 userId，通过 x-user-id 传过来
 */
@Injectable()
export class OptionalAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    // 先尝试 JWT
    if (authHeader) {
      try {
        const token = authHeader.replace('Bearer ', '');
        request['user'] = this.jwtService.verify(token);
        return true;
      } catch {}
    }

    // 无 token 时从 x-user-id 读取，存入 request.user.sub
    const userId = parseInt(request.headers['x-user-id']);
    if (userId && !isNaN(userId)) {
      request['user'] = { sub: userId, nickname: '用户' };
      return true;
    }

    request['user'] = { sub: 0, nickname: '匿名' };
    return true;
  }
}
