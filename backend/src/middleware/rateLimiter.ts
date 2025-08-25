import { RateLimiterMemory } from "rate-limiter-flexible";
import { Request, Response, NextFunction } from "express";

const rateLimiter = new RateLimiterMemory({
  points: 10, // 10 запросов
  duration: 1 // за 1 секунду
});

export const rateLimiterMiddleware = (req: Request, res: Response, next: NextFunction) => {
  rateLimiter.consume(req.ip || "unknown")
    .then(() => next())
    .catch(() => res.status(429).json({ error: "Too Many Requests" }));
};
