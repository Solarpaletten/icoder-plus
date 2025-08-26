import type { VercelRequest, VercelResponse } from '@vercel/node';
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

type AnalysisType = 'review' | 'commit' | 'optimize';
interface Body {
  code?: string;
  oldCode?: string;
  fileName?: string;
  analysisType: AnalysisType;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });

  try {
    const { code = '', oldCode = '', fileName = 'untitled', analysisType } = (req.body || {}) as Body;

    if (!process.env.OPENAI_API_KEY) {
      return res.status(200).json({ success: true, data: ['⚠️ OPENAI_API_KEY не задан — возвращаю заглушку'] });
    }
    if (!analysisType) return res.status(400).json({ error: 'analysisType is required' });

    let prompt = '';
    if (analysisType === 'review') {
      prompt = `Ты — лаконичный code reviewer. Дай 2–4 короткие рекомендации (80c max, с эмодзи).
Файл: ${fileName}
Код:
\`\`\`
${code.slice(0, 12000)}
\`\`\`
Верни JSON-массив строк (["...", "..."]).`;
    } else if (analysisType === 'commit') {
      prompt = `Сравни изменения и дай ОДНО короткое описание, начиная с эмодзи (например "✨ Добавлено …").
Файл: ${fileName}
OLD:
\`\`\`
${oldCode.slice(0, 6000)}
\`\`\`
NEW:
\`\`\`
${code.slice(0, 6000)}
\`\`\``;
    } else if (analysisType === 'optimize') {
      prompt = `Проанализируй код и предложи 2–3 оптимизации (производительность/память/алгоритмы).
Верни JSON-массив строк с эмодзи.
Код:
\`\`\`
${code.slice(0, 12000)}
\`\`\``;
    } else {
      return res.status(400).json({ error: 'Unsupported analysisType' });
    }

    const ai = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.2,
      max_tokens: 400,
      messages: [{ role: 'user', content: prompt }],
    });

    const content = ai.choices?.[0]?.message?.content?.trim() ?? '';
    let data: unknown = content;

    // Пытаемся распарсить JSON-массив, если прислали
    if (analysisType !== 'commit') {
      try {
        const parsed = JSON.parse(content);
        if (Array.isArray(parsed)) data = parsed;
      } catch {
        /* ignore, вернём как есть */
      }
    }

    return res.status(200).json({
      success: true,
      analysisType,
      fileName,
      data,
      timestamp: new Date().toISOString(),
    });
  } catch (err: any) {
    return res.status(500).json({ error: 'AI analyze failed', details: err?.message ?? String(err) });
  }
}
