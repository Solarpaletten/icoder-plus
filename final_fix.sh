#!/bin/bash

echo "🔥 Исправляем все 4 ошибки TypeScript в backend..."

# 1. ИСПРАВЛЯЕМ IMPORT ТИПОВ
cat > backend/src/types/ai.ts << 'EOF'
// Типы для AI сервисов
export interface AIAnalysisRequest {
  code: string;
  filename: string;
  language?: string;
}

export interface AIAnalysisResponse {
  commitNote: string;
  aiReview: string[];
  suggestions: string[];
  aiFixed?: string;
}

export interface AIChatRequest {
  message: string;
  code?: string;
  context?: string;
}

export interface AIChatResponse {
  response: string;
}

export interface AIConfig {
  openaiApiKey: string;
  anthropicApiKey?: string;
  model: string;
  temperature: number;
  maxTokens: number;
}
EOF

# 2. УБИРАЕМ rate-limiter-flexible (создаем простой middleware)
cat > backend/src/middleware/rateLimiter.ts << 'EOF'
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
EOF

# 3. ИСПРАВЛЯЕМ ROUTES/AI.TS
cat > backend/src/routes/ai.ts << 'EOF'
import { Router, Request, Response, NextFunction } from 'express';
import { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse } from '../types/ai.js';
import { generateCommitNote, generateAIReview, generateAIFix, generateChatResponse } from '../services/aiService.js';

const router = Router();

// POST /api/ai/analyze - Анализ кода
router.post('/analyze', async (req: Request<{}, AIAnalysisResponse, AIAnalysisRequest>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { code, filename, language } = req.body;

    if (!code || !filename) {
      res.status(400).json({
        commitNote: '',
        aiReview: ['Error: Missing required fields'],
        suggestions: []
      });
      return;
    }

    const commitNote = await generateCommitNote(code, filename);
    const aiReview = await generateAIReview(code, language || 'javascript');
    const suggestions = aiReview;

    res.json({
      commitNote,
      aiReview,
      suggestions
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/ai/fix - Автоматическое исправление кода
router.post('/fix', async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { code, filename } = req.body;

    if (!code) {
      res.status(400).json({ error: 'Code is required' });
      return;
    }

    const fixedCode = await generateAIFix(code);
    
    res.json({
      original: code,
      fixed: fixedCode,
      changes: ['Applied AI fixes']
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/ai/chat - Чат с AI о коде
router.post('/chat', async (req: Request<{}, AIChatResponse, AIChatRequest>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { message, code, context } = req.body;

    if (!message) {
      res.status(400).json({ response: 'Message is required' });
      return;
    }

    const response = await generateChatResponse(message, code, context);
    
    res.json({ response });
  } catch (error) {
    next(error);
  }
});

export default router;
EOF

# 4. ИСПРАВЛЯЕМ SERVICES/AISERVICE.TS
cat > backend/src/services/aiService.ts << 'EOF'
import OpenAI from 'openai';
import { AIConfig } from '../types/ai.js';

// Настройка OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || 'demo-key'
});

const config: AIConfig = {
  openaiApiKey: process.env.OPENAI_API_KEY || 'demo-key',
  anthropicApiKey: process.env.ANTHROPIC_API_KEY,
  model: 'gpt-3.5-turbo',
  temperature: 0.7,
  maxTokens: 1000
};

// Генерация commit note
export async function generateCommitNote(code: string, filename: string): Promise<string> {
  try {
    if (!config.openaiApiKey || config.openaiApiKey === 'demo-key') {
      return `📝 Update ${filename} - Added new functionality`;
    }

    const response = await openai.chat.completions.create({
      model: config.model,
      messages: [
        {
          role: 'system',
          content: 'Generate a concise commit message for this code change. Use emojis and be specific.'
        },
        {
          role: 'user',
          content: `File: ${filename}\nCode:\n${code}`
        }
      ],
      max_tokens: config.maxTokens,
      temperature: config.temperature
    });

    return response.choices[0]?.message?.content || `📝 Update ${filename}`;
  } catch (error) {
    console.error('AI Commit Note Error:', error);
    return `📝 Update ${filename} - AI service unavailable`;
  }
}

// Генерация AI review
export async function generateAIReview(code: string, language: string = 'javascript'): Promise<string[]> {
  try {
    if (!config.openaiApiKey || config.openaiApiKey === 'demo-key') {
      return [
        '✅ Code structure looks good',
        '💡 Consider adding error handling',
        '🔧 Variable names could be more descriptive'
      ];
    }

    const response = await openai.chat.completions.create({
      model: config.model,
      messages: [
        {
          role: 'system',
          content: `Review this ${language} code and provide 3-5 specific suggestions for improvement. Focus on best practices, security, and maintainability.`
        },
        {
          role: 'user',
          content: code
        }
      ],
      max_tokens: config.maxTokens,
      temperature: config.temperature
    });

    const review = response.choices[0]?.message?.content || '';
    return review.split('\n').filter(line => line.trim().length > 0).slice(0, 5);
  } catch (error) {
    console.error('AI Review Error:', error);
    return ['🤖 AI review service temporarily unavailable'];
  }
}

// Генерация исправленного кода
export async function generateAIFix(code: string): Promise<string> {
  try {
    // Простые автофиксы без API
    let fixedCode = code
      .replace(/var\s+/g, 'const ')
      .replace(/console\.log\([^)]*\);\?/g, '')
      .replace(/===/g, '===')
      .trim();

    if (!config.openaiApiKey || config.openaiApiKey === 'demo-key') {
      return fixedCode;
    }

    const response = await openai.chat.completions.create({
      model: config.model,
      messages: [
        {
          role: 'system',
          content: 'Fix code issues and improve it. Return only the corrected code, no explanations.'
        },
        {
          role: 'user',
          content: code
        }
      ],
      max_tokens: config.maxTokens,
      temperature: 0.3
    });

    return response.choices[0]?.message?.content || fixedCode;
  } catch (error) {
    console.error('AI Fix Error:', error);
    return code; // Возвращаем оригинальный код при ошибке
  }
}

// Генерация ответа в чате
export async function generateChatResponse(message: string, code?: string, context?: string): Promise<string> {
  try {
    if (!config.openaiApiKey || config.openaiApiKey === 'demo-key') {
      return `🤖 Hi! I would help you analyze your code, but I need an OpenAI API key to be configured. Your question: "${message}"`;
    }

    const systemPrompt = `You are a helpful coding assistant. Help with code analysis, debugging, and improvements.
    ${context ? `Context: ${context}` : ''}
    ${code ? `\nCurrent code:\n${code}` : ''}`;

    const response = await openai.chat.completions.create({
      model: config.model,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: message }
      ],
      max_tokens: config.maxTokens,
      temperature: config.temperature
    });

    return response.choices[0]?.message?.content || 'Sorry, I could not generate a response.';
  } catch (error) {
    console.error('AI Chat Error:', error);
    return '🤖 Sorry, the AI chat service is currently unavailable.';
  }
}
EOF

# 5. ОБНОВЛЯЕМ PACKAGE.JSON (убираем rate-limiter-flexible)
cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend - AI-powered code analysis API",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon --watch src --ext ts --exec ts-node -r tsconfig-paths/register src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.9.1",
    "compression": "^1.7.4",
    "cors": "^2.8.5",
    "diff": "^5.1.0",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "helmet": "^7.0.0",
    "joi": "^17.10.0",
    "morgan": "^1.10.0",
    "openai": "^4.20.1",
    "winston": "^3.10.0"
  },
  "devDependencies": {
    "@types/compression": "^1.7.3",
    "@types/cors": "^2.8.14",
    "@types/express": "^4.17.17",
    "@types/morgan": "^1.9.5",
    "@types/node": "^20.5.9",
    "@typescript-eslint/eslint-plugin": "^6.5.0",
    "@typescript-eslint/parser": "^6.5.0",
    "nodemon": "^3.0.1",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.2.2"
  },
  "keywords": [
    "express",
    "typescript",
    "ai",
    "openai",
    "claude",
    "code-analysis",
    "diff",
    "api"
  ],
  "author": "Solar IT Team",
  "license": "MIT",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

# 6. ОБНОВЛЯЕМ TSCONFIG.JSON (убираем "type": "module")
cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "CommonJS",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src",
    "paths": {
      "@types/*": ["types/*"],
      "@services/*": ["services/*"],
      "@routes/*": ["routes/*"],
      "@middleware/*": ["middleware/*"],
      "@utils/*": ["utils/*"]
    }
  },
  "include": [
    "src/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ],
  "ts-node": {
    "require": ["tsconfig-paths/register"]
  }
}
EOF

cd backend

# 7. ПЕРЕУСТАНАВЛИВАЕМ ЗАВИСИМОСТИ
echo "🔄 Переустанавливаем зависимости (без rate-limiter-flexible)..."
rm -rf node_modules package-lock.json
npm install

# 8. ПРОВЕРЯЕМ СБОРКУ
echo "🔨 Проверяем сборку..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Сборка успешна!"
    
    echo "🚀 Запускаем dev server..."
    echo "После запуска проверьте http://localhost:3000/health"
    
    # Запускаем сервер в фоне на 10 секунд для проверки
    timeout 10s npm run dev || true
    
    echo ""
    echo "✅ Все исправления применены!"
    echo "🎯 Теперь можете запустить:"
    echo "   npm run dev   # Разработка"
    echo "   npm run build # Сборка"  
    echo "   npm start     # Продакшн"
else
    echo "❌ Ошибки при сборке. Проверьте логи выше."
fi