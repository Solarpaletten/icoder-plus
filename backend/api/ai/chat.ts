import type { VercelRequest, VercelResponse } from '@vercel/node';
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

interface Body {
  message: string;
  code?: string;
  fileName?: string;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });

  try {
    const { message, code = '', fileName = 'untitled' } = (req.body || {}) as Body;

    if (!message) return res.status(400).json({ error: 'message is required' });
    if (!process.env.OPENAI_API_KEY) {
      return res.status(200).json({ success: true, data: { message: '⚠️ OPENAI_API_KEY не задан — заглушка ответа' } });
    }

    const prompt = `Ты — эксперт-помощник IDE iCoder Plus. Ответь кратко (<=150 слов).
Файл: ${fileName}
Вопрос: ${message}
Контекст кода:
\`\`\`
${code.slice(0, 12000)}
\`\`\``;

    const ai = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.4,
      max_tokens: 300,
      messages: [{ role: 'user', content: prompt }],
    });

    const reply = ai.choices?.[0]?.message?.content?.trim() ?? 'Ответ не получен.';
    return res.status(200).json({
      success: true,
      data: {
        message: reply,
        conversationId: `conv_${Date.now()}`,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err: any) {
    return res.status(500).json({ error: 'AI chat failed', details: err?.message ?? String(err) });
  }
}
