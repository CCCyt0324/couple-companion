import * as crypto from 'crypto';

/** 生成 6 位短信验证码 */
export function generateSmsCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/** 计算下次经期预测日期（最近N次平均周期） */
export function predictNextPeriod(
  lastPeriodDate: Date,
  cycleDaysList: number[],
  defaultCycleDays = 28,
): { predictedDate: Date; confidence: number } {
  const validDays = cycleDaysList.slice(0, 6).filter((d) => d > 20 && d < 40);
  const avg = validDays.length > 0
    ? Math.round(validDays.reduce((a, b) => a + b, 0) / validDays.length)
    : defaultCycleDays;
  const predictedDate = new Date(lastPeriodDate);
  predictedDate.setDate(predictedDate.getDate() + avg);
  return {
    predictedDate,
    confidence: Math.min(validDays.length / 6, 1),
  };
}
