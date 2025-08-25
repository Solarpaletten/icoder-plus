#!/bin/bash

cd backend

echo "🔧 Исправляем CommonJS импорты..."

# 1. ИСПРАВЛЯЕМ src/routes/ai.ts (убираем .js из импортов)
cat > src/routes/ai.ts << 'EOF'
import { Router, Request, Response, NextFunction } from 'express';
import { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse } from '../types/ai';
import { generateCommitNote, generateAIReview, generateAIFix, generateChatResponse } from '../services/aiService';

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

# 2. ИСПРАВЛЯЕМ src/services/aiService.ts (убираем .js из импортов)  
cat > src/services/aiService.ts << 'EOF'
import OpenAI from 'openai';
import { AIConfig } from '../types/ai';

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

# 3. ПРОВЕРЯЕМ, ЧТО server.ts НЕ ИМЕЕТ .js ИМПОРТОВ
if grep -q "\.js'" src/server.ts; then
  echo "🔧 Исправляем импорты в server.ts..."
  sed -i '' "s/from '\.\/.*\.js'/from '&'/g" src/server.ts
  sed -i '' "s/\.js'/''/g" src/server.ts
fi

# 4. ПРОВЕРЯЕМ СТРУКТУРУ ФАЙЛОВ
echo "📁 Проверяем структуру файлов..."
ls -la src/
ls -la src/types/
ls -la src/services/
ls -la src/routes/
ls -la src/middleware/

echo "🔨 Пересобираем проект..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Сборка успешна!"
    echo "🚀 Запускаем server..."
    echo ""
    echo "Теперь попробуйте: npm run dev"
else
    echo "❌ Ошибки при сборке."
fi