#!/bin/bash

echo "🔧 Fixing iCoder Plus Backend - All Issues"

# ============================================================================
# 1. ОСТАНОВИТЬ ВСЕ ПРОЦЕССЫ НА ПОРТАХ 3000 И 10000
# ============================================================================

echo "🛑 Останавливаем все процессы на портах 3000, 5173, 10000..."

lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true  
lsof -ti:5174 | xargs kill -9 2>/dev/null || true
lsof -ti:10000 | xargs kill -9 2>/dev/null || true

sleep 2

echo "✅ Порты очищены"

# ============================================================================
# 2. ИСПРАВИТЬ BACKEND PACKAGE.JSON С ПРАВИЛЬНЫМИ СКРИПТАМИ
# ============================================================================

echo "📦 Обновляем backend package.json..."

cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.1.1",
  "description": "iCoder Plus Backend API",
  "main": "dist/server.js",
  "type": "module",
  "scripts": {
    "build": "tsc && echo 'Backend build complete'",
    "start": "node dist/server.js",
    "dev": "nodemon src/server.ts",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist",
    "postbuild": "echo 'Build artifacts created in dist/'"
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
  }
}
EOF

# ============================================================================
# 3. СОЗДАТЬ РАБОЧИЙ server.ts С ПОРТОМ 3000
# ============================================================================

echo "🏗️ Создаем исправленный server.ts..."

mkdir -p backend/src

cat > backend/src/server.ts << 'EOF'
import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

// CORS configuration
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:5174', 'http://127.0.0.1:5173', '*'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true
}));

app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is running',
    timestamp: new Date().toISOString(),
    version: '2.1.1',
    port: PORT,
    environment: process.env.NODE_ENV || 'development'
  });
});

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API v2.1.1',
    status: 'running',
    endpoints: {
      health: 'GET /health',
      chat: 'POST /api/ai/chat',
      analyze: 'POST /api/ai/analyze'
    }
  });
});

// AI Chat endpoint
app.post('/api/ai/chat', (req: Request, res: Response) => {
  const { message, agent, code, targetFile } = req.body;
  
  console.log('AI Chat request:', { agent, message: message?.substring(0, 100) });
  
  // Simulate AI response based on agent
  let response = '';
  if (agent === 'dashka') {
    response = `Dashka: Анализирую архитектуру вашего кода. ${message ? 'Ваш запрос: ' + message : ''} - рекомендую проверить модульность компонентов.`;
  } else {
    response = `Claudy: Генерирую код для вашего запроса. ${message ? 'Запрос: ' + message : ''}\n\n\`\`\`javascript\n// Generated code example\nconst example = () => {\n  console.log('AI generated code');\n};\n\`\`\``;
  }
  
  res.status(200).json({
    success: true,
    data: {
      message: response,
      agent: agent || 'claudy',
      timestamp: new Date().toISOString()
    }
  });
});

// AI Analyze endpoint  
app.post('/api/ai/analyze', (req: Request, res: Response) => {
  const { code, fileName } = req.body;
  
  console.log('AI Analyze request:', { fileName, codeLength: code?.length || 0 });
  
  res.status(200).json({
    success: true,
    data: {
      analysis: {
        issues: [],
        suggestions: ["Code structure looks good", "Consider adding error handling"],
        complexity: "medium",
        performance: "good"
      },
      fileName: fileName || 'unknown',
      timestamp: new Date().toISOString()
    }
  });
});

// 404 handler
app.use('*', (req: Request, res: Response) => {
  res.status(404).json({
    error: 'Route not found',
    message: `${req.method} ${req.originalUrl} does not exist`,
    availableRoutes: ['GET /', 'GET /health', 'POST /api/ai/chat', 'POST /api/ai/analyze']
  });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Server error:', err.message);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server with proper error handling
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend v2.1.1 started successfully');
  console.log(`📡 Server running on http://localhost:${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`🤖 AI endpoints ready for Dual-Agent system`);
});

// Graceful shutdown handlers
const shutdown = (signal: string) => {
  console.log(`🛑 ${signal} received, shutting down gracefully`);
  server.close(() => {
    console.log('✅ Server closed successfully');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});
EOF

# ============================================================================
# 4. СОЗДАТЬ ПРАВИЛЬНЫЙ tsconfig.json
# ============================================================================

echo "⚙️ Создаем tsconfig.json..."

cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "ES2020",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false,
    "declaration": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "removeComments": true,
    "sourceMap": false
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

# ============================================================================
# 5. ОБНОВИТЬ .env ФАЙЛ
# ============================================================================

echo "🔑 Создаем .env файл..."

cat > backend/.env << 'EOF'
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173

# AI API Keys (add real keys for production)
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

LOG_LEVEL=info
EOF

# ============================================================================
# 6. СОЗДАТЬ КОРНЕВОЙ PACKAGE.JSON ДЛЯ RENDER
# ============================================================================

echo "📦 Обновляем корневой package.json для Render..."

cat > package.json << 'EOF'
{
  "name": "icoder-plus",
  "version": "2.1.1",
  "description": "iCoder Plus - AI-Powered Web IDE",
  "scripts": {
    "build": "cd backend && npm install && npm run build",
    "start": "cd backend && npm run start",
    "dev": "npm run dev:backend & npm run dev:frontend",
    "dev:backend": "cd backend && npm run dev",
    "dev:frontend": "cd frontend && npm run dev",
    "install:all": "cd backend && npm install && cd ../frontend && npm install"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/Solarpaletten/icoder-plus"
  }
}
EOF

# ============================================================================
# 7. ПЕРЕУСТАНОВИТЬ BACKEND ЗАВИСИМОСТИ
# ============================================================================

echo "🔄 Переустанавливаем backend зависимости..."

cd backend
rm -rf node_modules package-lock.json dist

npm install

if [ $? -eq 0 ]; then
    echo "✅ Backend зависимости установлены"
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

# ============================================================================
# 8. ТЕСТ СБОРКИ
# ============================================================================

echo "🔨 Тестируем сборку backend..."

npm run build

if [ $? -eq 0 ]; then
    echo "✅ Backend сборка успешна!"
    
    if [ -f "dist/server.js" ]; then
        echo "✅ dist/server.js создан"
        echo "📄 Первые строки скомпилированного файла:"
        head -5 dist/server.js
    else
        echo "❌ dist/server.js не найден"
    fi
else
    echo "❌ Ошибка сборки backend"
    exit 1
fi

cd ..

# ============================================================================
# 9. СОЗДАТЬ СКРИПТ ЗАПУСКА
# ============================================================================

cat > run-servers.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting iCoder Plus v2.1.1..."

# Kill existing processes
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

echo "Starting backend on port 3000..."
cd backend && npm run dev &
BACKEND_PID=$!

echo "Starting frontend on port 5173..."
cd ../frontend && npm run dev &
FRONTEND_PID=$!

echo ""
echo "✅ Servers running:"
echo "   Backend:  http://localhost:3000"
echo "   Frontend: http://localhost:5173" 
echo ""
echo "Press Ctrl+C to stop all servers"

trap 'kill $BACKEND_PID $FRONTEND_PID; echo "Servers stopped"; exit' INT
wait
EOF

chmod +x run-servers.sh

# ============================================================================
# 10. ФИНАЛЬНАЯ ИНСТРУКЦИЯ
# ============================================================================

echo ""
echo "🎉 BACKEND ИСПРАВЛЕН!"
echo ""
echo "✅ Исправления:"
echo "   - Порт изменен с 10000 на 3000"
echo "   - Добавлены build скрипты для Render"  
echo "   - Исправлены TypeScript настройки"
echo "   - Обновлены AI endpoints для Dual-Agent"
echo "   - Корневой package.json для деплоя"
echo ""
echo "🚀 Запуск серверов:"
echo "   ./run-servers.sh"
echo ""
echo "🌐 URLs после запуска:"
echo "   Backend:  http://localhost:3000/health"
echo "   Frontend: http://localhost:5173"
echo ""
echo "📋 Для деплоя на Render используйте:"
echo "   Build Command: npm run build"
echo "   Start Command: npm run start" 
echo "   Root Directory: /"
echo ""
echo "🔑 Environment Variables на Render:"
echo "   NODE_ENV=production"
echo "   PORT=10000"
echo "   OPENAI_API_KEY=ваш_ключ"
echo "   ANTHROPIC_API_KEY=ваш_ключ"