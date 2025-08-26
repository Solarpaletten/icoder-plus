import type { VercelRequest, VercelResponse } from '@vercel/node';
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

interface Body {
  code: string;
  fileName?: string;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });

  try {
    const { code = '', fileName = 'untitled' } = (req.body || {}) as Body;
    if (!code) return res.status(400).json({ error: 'code is required' });

    // Fallback без ключа — базовые фиксы
    const basicFix = (src: string) =>
      src
        .replace(/\bvar\s+(\w+)/g, 'let $1')
        .replace(/console\.log\(.*?\);?/g, '')
        .split('\n')
        .map((l) => l.trimEnd())
        .join('\n')
        .trim();

    if (!process.env.OPENAI_API_KEY) {
      return res.status(200).json({
        success: true,
        data: {
          originalCode: code,
          fixedCode: basicFix(code),
          fileName,
          appliedAt: new Date().toISOString(),
          note: '⚠️ OPENAI_API_KEY не задан — применены базовые фиксы',
        },
      });
    }

    const prompt = `Отформатируй и модернизируй код. 
Правила:
1) Замени var на let/const корректно
2) Удали console.log
3) Исправь частые синтакс. огрехи
4) Модернизируй JS (arrow/деструктуризация где уместно)
5) Удали неиспользуемые импорты
Верни ТОЛЬКО готовый код (без пояснений).

Файл: ${fileName}
Код:
\`\`\`
${code}
\`\`\``;

    const ai = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.1,
      max_tokens: Math.min(2000, code.length + 600),
      messages: [{ role: 'user', content: prompt }],
    });

    const raw = ai.choices?.[0]?.message?.content ?? '';
    const fixed = raw.replace(/^```[\w-]*\s*/i, '').replace(/```$/i, '').trim();

    return res.status(200).json({
      success: true,
      data: {
        originalCode: code,
        fixedCode: fixed || basicFix(code),
        fileName,
        appliedAt: new Date().toISOString(),
      },
    });
  } catch (err: any) {
    return res.status(500).json({ error: 'AI fix failed', details: err?.message ?? String(err) });
  }
}
