Космическая скорость сохраняется! 🚀 Структура уже правильная для serverless на Vercel. Давай финализируем минимальный рабочий бэкенд (TS-функции в /api) — добавлю недостающий эндпоинт fix/apply.ts, а также дам полные версии всех файлов, чтобы можно было просто вставить и деплоить.

📁 Итоговая структура (serverless, Vercel)
backend/
├─ api/
│  ├─ health.ts
│  ├─ ai/
│  │  ├─ analyze.ts
│  │  ├─ chat.ts
│  │  └─ fix/
│  │     └─ apply.ts
├─ package.json
└─ vercel.json

🧩 Файлы (скопируй «как есть»)
api/health.ts
import type { VercelRequest, VercelResponse } from '@vercel/node';

export default function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).json({
    status: 'OK',
    service: 'iCoder Plus Backend (serverless)',
    timestamp: new Date().toISOString(),
  });
}

api/ai/analyze.ts
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

api/ai/chat.ts
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

api/ai/fix/apply.ts
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

package.json
{
  "name": "icoder-plus-backend-serverless",
  "version": "2.0.0",
  "private": true,
  "description": "iCoder Plus — serverless backend for Vercel",
  "scripts": {
    "dev": "vercel dev",
    "deploy": "vercel --prod"
  },
  "dependencies": {
    "openai": "^4.58.1"
  },
  "devDependencies": {
    "@vercel/node": "^3.2.12",
    "typescript": "^5.4.0"
  }
}

vercel.json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "functions": {
    "api/**/*.{ts,js}": {
      "runtime": "nodejs20.x",
      "memory": 512,
      "maxDuration": 15
    }
  },
  "routes": [
    { "src": "/api/(.*)", "dest": "/api/$1" }
  ]
}

🔑 Переменные окружения (Vercel → Settings → Environment Variables)

Для проекта icoder-plus-backend (этого serverless):

OPENAI_API_KEY — ваш ключ OpenAI

(по желанию) NODE_ENV=production

(Антропик можно добавить позже, в этом минимуме он не используется.)

▶️ Локальный запуск и деплой
cd backend
# локально (через vercel dev)
npm run dev

# затем деплой
npm run deploy


Проверка после деплоя:

GET /api/health

POST /api/ai/analyze { analysisType, code, oldCode?, fileName? }

POST /api/ai/chat { message, code?, fileName? }

POST /api/ai/fix/apply { code, fileName? }