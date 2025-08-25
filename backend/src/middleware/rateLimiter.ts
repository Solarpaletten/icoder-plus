import { Request, Response, NextFunction } from 'express';

// Простой in-memory rate limiter без внешних зависимостей
const requests = new Map<string, number[]>();

export const rateLimiterMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const clientIp = req.ip || req.socket.remoteAddress || 'unknown';
  const now = Date.now();
  const windowMs = 60 * 1000; // 1 минута
  const maxRequests = 60; // 60 запросов в минуту

  if (!requests.has(clientIp)) {
    requests.set(clientIp, []);
  }

  const clientRequests = requests.get(clientIp)!;
  
  // Очищаем старые запросы
  const recentRequests = clientRequests.filter(time => now - time < windowMs);
  requests.set(clientIp, recentRequests);

  if (recentRequests.length >= maxRequests) {
    res.status(429).json({ 
      error: 'Too Many Requests',
      message: `Rate limit exceeded. Max ${maxRequests} requests per minute.`
    });
    return;
  }

  // Добавляем текущий запрос
  recentRequests.push(now);
  requests.set(clientIp, recentRequests);
  
  next();
};
