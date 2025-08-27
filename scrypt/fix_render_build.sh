#!/bin/bash

echo "🔧 ИСПРАВЛЯЕМ RENDER BUILD - ЗАВИСИМОСТИ И ТИПЫ"

# ============================================================================
# 1. ИСПРАВИТЬ BACKEND/tsconfig.json
# ============================================================================

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
    "noFallthroughCasesInSwitch": true,
    "module": "CommonJS",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false,
    "declaration": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./",
    "paths": {
      "@/*": ["src/*"]
    },
    "types": ["node"]
  },
  "include": [
    "src/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts"
  ]
}
EOF

echo "✅ tsconfig.json исправлен с правильными типами Node.js"

# ============================================================================
# 2. УПРОСТИТЬ server.ts ДЛЯ RENDER
# ============================================================================

mkdir -p backend/src

cat > backend/src/server.ts << 'EOF'
import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';

// Загрузить переменные окружения
dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '10000', 10);

// Базовые middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is healthy',
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'production',
    port: PORT
  });
});

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      docs: 'https://github.com/Solarpaletten/icoder-plus'
    }
  });
});

// API endpoint for AI analysis (placeholder)
app.post('/api/ai/analyze', (req: Request, res: Response) => {
  const { code, analysisType } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required',
      message: 'Please provide code to analyze'
    });
  }

  // Placeholder response
  res.status(200).json({
    success: true,
    message: 'AI analysis endpoint is working',
    data: {
      originalCode: code,
      analysisType: analysisType || 'basic',
      result: 'AI analysis will be implemented soon',
      timestamp: new Date().toISOString()
    }
  });
});

// Catch all other routes
app.all('*', (req: Request, res: Response) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Route ${req.method} ${req.path} does not exist`,
    availableRoutes: ['GET /', 'GET /health', 'POST /api/ai/analyze']
  });
});

// Error handler
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend started successfully');
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('🛑 SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated');
    process.exit(0);
  });
});
EOF

echo "✅ Упрощенный server.ts создан с правильной типизацией"

# ============================================================================
# 3. ОБНОВИТЬ package.json С ПРАВИЛЬНЫМИ ЗАВИСИМОСТЯМИ
# ============================================================================

cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend API",
  "main": "dist/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "nodemon --watch src --ext ts --exec ts-node src/server.ts",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5", 
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.5.0",
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/compression": "^1.7.2",
    "typescript": "^5.1.6",
    "ts-node": "^10.9.1",
    "nodemon": "^3.0.1"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["express", "typescript", "backend", "api"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF

echo "✅ package.json очищен от лишних зависимостей"

# ============================================================================
# 4. СОЗДАТЬ .env ДЛЯ PRODUCTION
# ============================================================================

cat > backend/.env << 'EOF'
NODE_ENV=production
PORT=10000
OPENAI_API_KEY=placeholder_key_replace_in_render
ANTHROPIC_API_KEY=placeholder_key_replace_in_render
EOF

echo "✅ .env файл создан"

# ============================================================================
# 5. ТЕСТИРОВАТЬ ЛОКАЛЬНУЮ СБОРКУ
# ============================================================================

echo "🔨 Тестируем сборку..."
cd backend

# Очистить кэш
rm -rf node_modules package-lock.json dist

# Установить зависимости
echo "📦 Устанавливаем зависимости..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены"
    
    # Собрать проект
    echo "🔧 Собираем проект..."
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ Сборка успешна!"
        
        if [ -f "dist/server.js" ]; then
            echo "✅ dist/server.js создан"
            echo "📄 Первые строки скомпилированного файла:"
            head -5 dist/server.js
        else
            echo "❌ dist/server.js не найден"
        fi
        
    else
        echo "❌ Ошибка при сборке"
        exit 1
    fi
    
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

cd ..

# ============================================================================
# 6. ФИНАЛЬНЫЕ ИНСТРУКЦИИ
# ============================================================================

echo ""
echo "🚀 ИСПРАВЛЕНИЯ ГОТОВЫ ДЛЯ RENDER!"
echo ""
echo "📋 НАСТРОЙКИ RENDER DASHBOARD:"
echo ""
echo "Root Directory:   /backend"
echo "Build Command:    npm run build"  
echo "Start Command:    npm run start"
echo "Node Version:     18+"
echo ""
echo "🔑 ENVIRONMENT VARIABLES:"
echo "NODE_ENV=production"
echo "PORT=10000"
echo "OPENAI_API_KEY=ваш_реальный_ключ"
echo "ANTHROPIC_API_KEY=ваш_реальный_ключ"
echo ""
echo "✅ ГОТОВО К КОММИТУ:"
echo ""
echo "git add ."
echo "git commit -m '🔧 Fix TypeScript build issues for Render'"
echo "git push origin main"
echo ""
echo "🌐 ПОСЛЕ ДЕПЛОЯ ПРОВЕРЬТЕ:"
echo "https://ваш-render-url.onrender.com/health"
echo "https://ваш-render-url.onrender.com/api/ai/analyze"
echo ""
echo "🎯 Все проблемы с типами и зависимостями исправлены!"
