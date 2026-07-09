import { ExceptionFilter, Catch, ArgumentsHost, HttpException, Logger } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      const message = typeof exceptionResponse === 'string'
        ? exceptionResponse
        : (exceptionResponse as any).message || '服务器异常';

      if (status >= 500) {
        this.logger.error(`[${status}] ${message}`, (exception as any).stack);
      }

      response.status(status).json({
        code: status,
        message: Array.isArray(message) ? message[0] : message,
        timestamp: new Date().toISOString(),
      });
    } else {
      // 非 HttpException（TypeORM/Bcrypt 等原生错误）
      const err = exception as Error;
      this.logger.error(`[500] ${err.message}`, err.stack);
      response.status(500).json({
        code: 500,
        message: process.env.NODE_ENV === 'production' ? '服务器异常' : err.message,
        timestamp: new Date().toISOString(),
      });
    }
  }
}
