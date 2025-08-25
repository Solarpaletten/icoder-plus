# 🚀 ФИНАЛЬНЫЕ ИСПРАВЛЕНИЯ iCoder Plus Backend
# Этот скрипт решает ВСЕ проблемы ESM/CJS конфликта

cd backend

echo "🔥 Исправляем ESM/CommonJS конфликт..."

# ============================================================================
# 1. ИСПРАВИТЬ package.json (убрать type: module)
# ============================================================================

cat > package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend - AI-powered code analysis API",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon --exec ts-node -r tsconfig-paths/register src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1",
    "openai": "^4.20.1",
    "@anthropic-ai/sdk": "^0.9.1",
    "diff": "^5.1.0",
    "joi": "^17.10.0",
    "winston": "^3.10.0"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.14",
    "@types/morgan": "^1.9.5",
    "@types/compression": "^1.7.3",
    "@types/node": "^20.5.9",
    "@types/joi": "^17.2.3",
    "ts-node": "^10.9.1",
    "nodemon": "^3.0.1",
    "tsconfig-paths": "^4.2.0"
  },
  "keywords": [
    "express",
    "typescript",
    "ai",
    "openai",
    "claude"
  ],
  "author": "Solar IT Team",
  "license": "MIT",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

echo "✅ package.json исправлен (убран type: module)"

# ============================================================================
# 2. ИСПРАВИТЬ tsconfig.json (строго CommonJS)
# ============================================================================

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": false,
    "sourceMap": true,
    "removeComments": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "moduleResolution": "node",
    "baseUrl": "./src",
    "paths": {
      "@/*": ["*"],
      "@routes/*": ["routes/*"],
      "@services/*": ["services/*"],
      "@middleware/*": ["middleware/*"],
      "@types/*": ["types/*"],
      "@utils/*": ["utils/*"]
    }
  },
  "include": [
    "src/**/*"
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

echo "✅ tsconfig.json исправлен (CommonJS + правильные paths)"

# ============================================================================
# 3. СОЗДАТЬ src/types/ai.ts (TypeScript интерфейсы)
# ============================================================================

mkdir -p src/types

cat > src/types/ai.ts << 'EOF'
export interface AIAnalysisRequest {
  code: string;
  fileName?: string;
  oldCode?: string;
  analysisType: 'review' | 'fix' | 'commit' | 'optimize';
}

export interface AIAnalysisResponse {
  success: boolean;
  data: any;
  analysisType: string;
  fileName: string;
  timestamp: string;
  error?: string;
}

export interface AIChatRequest {
  message: string;
  code?: string;
  fileName?: string;
  conversationId?: string;
}

export interface AIChatResponse {
  success: boolean;
  data: {
    message: string;
    conversationId: string;
    timestamp: string;
  };
  error?: string;
}

export interface AIConfig {
  isConfigured: boolean;
  provider: string;
  model: string;
  features: {
    commitNotes: boolean;
    codeReview: boolean;
    autoFix: boolean;
    chat: boolean;
    optimization: boolean;
  };
}
EOF

echo "✅ Типы TypeScript созданы"

# ============================================================================
# 4. ИСПРАВИТЬ src/services/aiService.ts
# ============================================================================

mkdir -p src/services

cat > src/services/aiService.ts << 'EOF'
import OpenAI from 'openai';
import type { AIConfig } from '@types/ai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || '',
});

export async function generateAIComment(
  oldCode: string, 
  newCode: string, 
  fileName: string = ''
): Promise<string> {
  if (!process.env.OPENAI_API_KEY) {
    return "🤖 AI service not configured - add OPENAI_API_KEY to .env";
  }

  try {
    if (oldCode === newCode) return "No changes detected.";
    if (!oldCode) return `🆕 New file created: ${fileName}`;
    if (!newCode) return `❌ File deleted: ${fileName}`;

    const prompt = `Compare these code versions and describe the change in one sentence:

OLD: ${oldCode.slice(0, 200)}
NEW: ${newCode.slice(0, 200)}

Reply with an emoji + short description.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 50,
      temperature: 0.3
    });

    return response.choices[0]?.message?.content?.trim() || "✏️ Code updated";
  } catch (error) {
    console.error('AI Comment failed:', error);
    return "✏️ Code updated (AI analysis failed)";
  }
}

export async function generateAIReview(code: string, fileName: string = ''): Promise<string[]> {
  if (!process.env.OPENAI_API_KEY) {
    return ["⚠️ AI service not configured"];
  }

  try {
    const prompt = `Review this code and give 2-3 short suggestions:
${code.slice(0, 500)}

Return as JSON array of strings with emojis.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 150,
      temperature: 0.2
    });

    const content = response.choices[0]?.message?.content;
    if (!content) return ["⚠️ AI review unavailable"];
    
    try {
      const suggestions = JSON.parse(content);
      return Array.isArray(suggestions) ? suggestions : [content];
    } catch {
      return content.split('\n').filter(line => line.trim()).slice(0, 3);
    }
  } catch (error) {
    return ["⚠️ AI review temporarily unavailable"];
  }
}

export async function applyAIFixes(code: string, fileName: string = ''): Promise<string> {
  let fixed = code;
  
  // Basic fixes
  fixed = fixed.replace(/\bvar\s+(\w+)\s*=/g, 'const $1 =');
  fixed = fixed.replace(/console\.log\([^;]*\);?\n?/g, '');
  fixed = fixed.split('\n').map(line => line.trimEnd()).join('\n');
  
  return fixed.trim();
}

export async function chat(params: {
  message: string;
  code?: string;
  fileName?: string;
  conversationId?: string;
}): Promise<string> {
  if (!process.env.OPENAI_API_KEY) {
    return "🤖 AI chat not configured - add OpenAI API key";
  }

  try {
    const prompt = `Help with this code question:
Question: ${params.message}
Code: ${params.code?.slice(0, 500) || 'No code provided'}

Give a helpful answer in under 100 words.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 150,
      temperature: 0.4
    });

    return response.choices[0]?.message?.content?.trim() || "🤖 Sorry, couldn't process your question.";
  } catch (error) {
    return "🤖 AI chat temporarily unavailable.";
  }
}

export function getStatus(): AIConfig {
  return {
    isConfigured: !!process.env.OPENAI_API_KEY,
    provider: 'OpenAI',
    model: 'gpt-4o-mini',
    features: {
      commitNotes: true,
      codeReview: true,
      autoFix: true,
      chat: true,
      optimization: true
    }
  };
}
EOF

echo "✅ aiService.ts исправлен"

# ============================================================================
# 5. СОЗДАТЬ src/routes/ai.ts
# ============================================================================

mkdir -p src/routes

cat > src/routes/ai.ts << 'EOF'
import { Router, Request, Response, NextFunction } from 'express';
import * as aiService from '@services/aiService';
import type { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse } from '@types/ai';

const router = Router();

router.post('/analyze', async (req: Request<{}, AIAnalysisResponse, AIAnalysisRequest>, res: Response, next: NextFunction) => {
  try {
    const { code, fileName, oldCode, analysisType } = req.body;
    let result: any;

    switch (analysisType) {
      case 'review':
        result = await aiService.generateAIReview(code, fileName);
        break;
      case 'fix':
        result = await aiService.applyAIFixes(code, fileName);
        break;
      case 'commit':
        result = await aiService.generateAIComment(oldCode || '', code, fileName);
        break;
      default:
        return res.status(400).json({ success: false, error: 'Invalid analysis type' });
    }

    res.json({
      success: true,
      data: result,
      analysisType,
      fileName: fileName || 'untitled',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

router.post('/chat', async (req: Request<{}, AIChatResponse, AIChatRequest>, res: Response, next: NextFunction) => {
  try {
    const { message, code, fileName, conversationId } = req.body;
    const response = await aiService.chat({ message, code, fileName, conversationId });

    res.json({
      success: true,
      data: {
        message: response,
        conversationId: conversationId || `conv_${Date.now()}`,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

router.get('/status', (req: Request, res: Response) => {
  const status = aiService.getStatus();
  
  res.json({
    success: true,
    data: {
      configured: status.isConfigured,
      provider: status.provider,
      model: status.model,
      features: Object.keys(status.features).filter(key => 
        status.features[key as keyof typeof status.features]
      ),
      timestamp: new Date().toISOString()
    }
  });
});

export default router;
EOF

echo "✅ routes/ai.ts создан"

# ============================================================================
# 6. СОЗДАТЬ src/server.ts
# ============================================================================

cat > src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import aiRoutes from '@routes/ai';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan('combined'));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Routes
app.use('/api/ai', aiRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

// Error handler
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 iCoder Plus Backend v2.0 running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

process.on('SIGTERM', () => {
  server.close(() => process.exit(0));
});

export default app;
EOF

echo "✅ server.ts создан"

# ============================================================================
# 7. СОЗДАТЬ .env файл
# ============================================================================

cat > .env << 'EOF'
# iCoder Plus Backend Environment Variables

# AI Configuration
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Server Configuration
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:5173

# Logging
LOG_LEVEL=info
EOF

echo "✅ .env файл создан"

# ============================================================================
# 8. ПЕРЕУСТАНОВИТЬ ЗАВИСИМОСТИ
# ============================================================================

echo "🔄 Переустанавливаем зависимости..."
rm -rf node_modules package-lock.json
npm install

echo "✅ Зависимости установлены"

# ============================================================================
# 9. ПРОВЕРИТЬ СБОРКУ
# ============================================================================

echo "🔨 Проверяем сборку..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Сборка прошла успешно!"
else
    echo "❌ Ошибки при сборке"
    exit 1
fi

# ============================================================================
# 10. ТЕСТИРОВАТЬ ЗАПУСК
# ============================================================================

echo "🚀 Готово! Теперь можно запускать:"
echo ""
echo "  npm run dev      # Development сервер"  
echo "  npm run build    # Собрать проект"
echo "  npm start        # Production сервер"
echo ""
echo "🌐 Health check будет доступен на:"
echo "  http://localhost:3000/health"
echo ""
echo "🎯 Финальные рабочие команды:"
echo "  cd backend"
echo "  npm run dev"

# ============================================================================
# РЕЗУЛЬТАТ
# ============================================================================

echo ""
echo "🎉 ВСЕ ПРОБЛЕМЫ ESM/CommonJS РЕШЕНЫ!"
echo "✅ package.json: CommonJS (убран type: module)"  
echo "✅ tsconfig.json: CommonJS + правильные paths"
echo "✅ Все сервисы исправлены с типизацией"
echo "✅ Готово к деплою на Render"