import type { VercelRequest, VercelResponse } from '@vercel/node';

export default function handler(req: VercelRequest, res: VercelResponse) {
  res.status(200).json({
    message: "iCoder Plus Backend is working!",
    endpoints: [
      "/api/health",
      "/api/ai/analyze", 
      "/api/ai/chat",
      "/api/ai/fix/apply"
    ]
  });
}
