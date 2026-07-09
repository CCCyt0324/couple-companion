export default () => ({
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  redis: {
    host: process.env.REDIS_HOST || '127.0.0.1',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    password: process.env.REDIS_PASSWORD || undefined,
  },
  oss: {
    region: process.env.OSS_REGION || 'oss-cn-hangzhou',
    accessKeyId: process.env.OSS_ACCESS_KEY_ID,
    accessKeySecret: process.env.OSS_ACCESS_KEY_SECRET,
    bucket: process.env.OSS_BUCKET || 'couple-companion',
  },
  jpush: {
    appKey: process.env.JPUSH_APP_KEY,
    masterSecret: process.env.JPUSH_MASTER_SECRET,
  },
  weather: {
    apiKey: process.env.WEATHER_API_KEY,
  },
  ai: {
    apiUrl: process.env.AI_API_URL || 'https://api.openai.com/v1',
    apiKey: process.env.AI_API_KEY,
    model: process.env.AI_MODEL || 'gpt-4o',
  },
  sms: {
    apiKey: process.env.SMS_API_KEY,
    apiSecret: process.env.SMS_API_SECRET,
  },
  wechat: {
    appId: process.env.WECHAT_APP_ID,
    appSecret: process.env.WECHAT_APP_SECRET,
  },
});
