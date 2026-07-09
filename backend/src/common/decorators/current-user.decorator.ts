import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/** 从 JWT 中提取当前用户信息 */
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
