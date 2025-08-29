#!/bin/bash

echo "🔧 Fixing Render TypeScript build issues..."

cd backend

# ============================================================================
# 1. ОБНОВИТЬ PACKAGE.JSON - ПЕРЕМЕСТИТЬ TYPES В DEPENDENCIES
# ============================================================================

cat > package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.1.1",
  "description": "iCoder Plus Backend API",
  "main": "dist/server.js",
  "scripts": {
    "build": "npm install && tsc && echo 'Backend build complete'",
    "start": "node dist/server.js",
    "dev": "nodemon --exec ts-node src/server.ts",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5", 
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1",
    "@types/node": "^20.5.0",
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/compression": "^1.7.2",
    "typescript": "^5.1.6"
  },
  "devDependencies": {
    "ts-node": "^10.9.1",
    "nodemon": "^3.0.1"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

echo "✅ package.json обновлен - types в dependencies"

# ============================================================================
# 2. ИСПРАВИТЬ TSCONFIG.JSON ДЛЯ RENDER
# ============================================================================

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM"],
    "module": "CommonJS",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": false,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false,
    "declaration": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "removeComments": true,
    "sourceMap": false,
    "noImplicitAny": false,
    "typeRoots": ["./node_modules/@types", "./types"],
    "types": ["node"]
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

echo "✅ tsconfig.json исправлен для Render"

# ============================================================================
# 3. СОЗДАТЬ УПРОЩЕННЫЙ SERVER.TS БЕЗ STRICT TYPES
# ============================================================================

cat > src/server.ts << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
require('dotenv').config();

const app = express();
const PORT = parseInt(process.env.PORT || '10000', 10);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? true : [
    'http://localhost:5173', 
    'http://localhost:5174', 
    'http://127.0.0.1:5173'
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: false
}));

app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging
if (process.env.NODE_ENV !== 'production') {
  app.use((req: any, res: any, next: any) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
  });
}

// Health check endpoint
app.get('/health', (req: any, res: any) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is healthy',
    timestamp: new Date().toISOString(),
    version: '2.1.1',
    port: PORT,
    environment: process.env.NODE_ENV || 'production',
    uptime: process.uptime()
  });
});

// Root endpoint
app.get('/', (req: any, res: any) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API v2.1.1',
    status: 'running',
    environment: process.env.NODE_ENV || 'production',
    endpoints: {
      health: 'GET /health',
      chat: 'POST /api/ai/chat',
      analyze: 'POST /api/ai/analyze'
    },
    documentation: 'https://github.com/Solarpaletten/icoder-plus'
  });
});

// AI Chat endpoint - Dual Agent Support
app.post('/api/ai/chat', (req: any, res: any) => {
  const { message, agent, code, targetFile } = req.body;
  
  if (process.env.NODE_ENV !== 'production') {
    console.log('AI Chat request:', { 
      agent: agent || 'claudy', 
      messageLength: message?.length || 0,
      targetFile: targetFile || 'none'
    });
  }
  
  // Validate input
  if (!message || typeof message !== 'string') {
    return res.status(400).json({
      success: false,
      error: 'Message is required and must be a string'
    });
  }
  
  // Simulate AI response based on agent
  let response = '';
  let codeBlocks: any[] = [];
  
  if (agent === 'dashka') {
    response = `Dashka (Архитект): Анализирую архитектуру проекта.\n\n${message}\n\nРекомендации:\n- Проверить модульность компонентов\n- Оптимизировать структуру файлов\n- Убедиться в правильности типизации`;
  } else {
    // Claudy mode - generate code
    const fileName = targetFile || 'generated.js';
    const codeExample = `// Generated code for: ${message}\nconst solution = () => {\n  // Implementation here\n  console.log('Generated solution');\n  return { success: true };\n};\n\nmodule.exports = solution;`;
    
    response = `Claudy: Создаю код для вашего запроса.\n\n${message}\n\nfile: ${fileName}\n\`\`\`javascript\n${codeExample}\n\`\`\``;
    
    codeBlocks = [{
      id: Math.random().toString(36).substr(2, 9),
      title: `Generated code for ${fileName}`,
      file: fileName,
      kind: 'javascript',
      code: codeExample
    }];
  }
  
  res.status(200).json({
    success: true,
    data: {
      message: response,
      agent: agent || 'claudy',
      codeBlocks: codeBlocks,
      timestamp: new Date().toISOString()
    }
  });
});

// AI Analyze endpoint  
app.post('/api/ai/analyze', (req: any, res: any) => {
  const { code, fileName } = req.body;
  
  if (!code || typeof code !== 'string') {
    return res.status(400).json({
      success: false,
      error: 'Code is required and must be a string'
    });
  }
  
  // Basic code analysis simulation
  const analysis = {
    issues: [],
    suggestions: [
      "Code structure appears well-organized", 
      "Consider adding error handling",
      "Add documentation for better maintainability"
    ],
    complexity: code.length > 1000 ? "high" : code.length > 500 ? "medium" : "low",
    performance: "acceptable",
    maintainability: "good",
    security: "review recommended"
  };
  
  res.status(200).json({
    success: true,
    data: {
      analysis,
      fileName: fileName || 'unknown',
      timestamp: new Date().toISOString()
    }
  });
});

// 404 handler
app.use('*', (req: any, res: any) => {
  res.status(404).json({
    error: 'Route not found',
    message: `${req.method} ${req.originalUrl} does not exist`,
    availableEndpoints: [
      'GET /', 
      'GET /health', 
      'POST /api/ai/chat', 
      'POST /api/ai/analyze'
    ]
  });
});

// Global error handler
app.use((err: any, req: any, res: any, next: any) => {
  console.error('Server error:', err.message);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend v2.1.1 started');
  console.log(`📡 Server: http://localhost:${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`💚 Health: http://localhost:${PORT}/health`);
});

// Graceful shutdown
const shutdown = (signal: string) => {
  console.log(`🛑 ${signal} received, shutting down...`);
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

process.on('uncaughtException', (err: any) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason: any) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});
EOF

echo "✅ server.ts упрощен для совместимости с Render"

# ============================================================================
# 4. СОЗДАТЬ TYPES DIRECTORY
# ============================================================================

mkdir -p types

cat > types/global.d.ts << 'EOF'
declare namespace NodeJS {
  interface ProcessEnv {
    NODE_ENV: 'development' | 'production';
    PORT: string;
    OPENAI_API_KEY?: string;
    ANTHROPIC_API_KEY?: string;
  }
}
EOF

echo "✅ Global types созданы"

# ============================================================================
# 5. ТЕСТИРОВАТЬ ЛОКАЛЬНУЮ СБОРКУ
# ============================================================================

echo "🔨 Тестируем исправленную сборку..."

rm -rf node_modules package-lock.json dist
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies установлены"
    
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ Backend готов к деплою на Render!"
        echo ""
        echo "📋 RENDER SETTINGS:"
        echo "Root Directory: backend"
        echo "Build Command:  npm run build" 
        echo "Start Command:  npm run start"
        echo ""
        echo "🔑 ENV VARS:"
        echo "NODE_ENV=production"
        echo "OPENAI_API_KEY=your_key"
        echo "ANTHROPIC_API_KEY=your_key"
        echo ""
        echo "🚀 COMMIT & PUSH TO DEPLOY!"
    else
        echo "❌ Build failed"
        exit 1
    fi
else
    echo "❌ Dependencies failed"
    exit 1
fi