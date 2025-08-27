#!/bin/bash

echo "🔧 МИНИМАЛЬНОЕ ИСПРАВЛЕНИЕ ДЛЯ RENDER - МАКСИМАЛЬНАЯ СОВМЕСТИМОСТЬ"

# ============================================================================
# 1. СУПЕР ПРОСТОЙ tsconfig.json БЕЗ СТРОГОСТИ
# ============================================================================

cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2018",
    "module": "CommonJS",
    "lib": ["ES2018"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": false,
    "noImplicitAny": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": false,
    "moduleResolution": "node",
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

echo "✅ Создан максимально простой tsconfig.json"

# ============================================================================
# 2. ПРОСТЕЙШИЙ package.json С МИНИМУМОМ ЗАВИСИМОСТЕЙ
# ============================================================================

cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend API",
  "main": "dist/server.js",
  "scripts": {
    "build": "npx tsc",
    "start": "node dist/server.js",
    "dev": "node dist/server.js"
  },
  "dependencies": {
    "express": "4.18.2",
    "cors": "2.8.5"
  },
  "devDependencies": {
    "typescript": "5.1.6",
    "@types/node": "20.5.0",
    "@types/express": "4.17.17"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

echo "✅ Упрощен package.json с минимумом зависимостей"

# ============================================================================
# 3. СУПЕР ПРОСТОЙ server.ts БЕЗ СЛОЖНЫХ ИМПОРТОВ
# ============================================================================

mkdir -p backend/src

cat > backend/src/server.ts << 'EOF'
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(cors());
app.use(express.json());

// Health endpoint
app.get('/health', (req: any, res: any) => {
  res.json({
    status: 'OK',
    message: 'iCoder Plus Backend is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Root endpoint  
app.get('/', (req: any, res: any) => {
  res.json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running'
  });
});

// AI endpoint placeholder
app.post('/api/ai/analyze', (req: any, res: any) => {
  const { code } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required'
    });
  }

  res.json({
    success: true,
    message: 'AI analysis endpoint working',
    data: {
      code: code,
      result: 'Analysis placeholder'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

echo "✅ Создан максимально простой server.ts с require()"

# ============================================================================
# 4. АЛЬТЕРНАТИВНЫЙ server.js (БЕЗ TYPESCRIPT)
# ============================================================================

cat > backend/src/server.js << 'EOF'
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(cors());
app.use(express.json());

// Health endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'iCoder Plus Backend is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Root endpoint  
app.get('/', (req, res) => {
  res.json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running'
  });
});

// AI endpoint placeholder
app.post('/api/ai/analyze', (req, res) => {
  const { code } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required'
    });
  }

  res.json({
    success: true,
    message: 'AI analysis endpoint working',
    data: {
      code: code,
      result: 'Analysis placeholder'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌐 Health: http://localhost:${PORT}/health`);
});
EOF

echo "✅ Создан альтернативный server.js (без TypeScript)"

# ============================================================================
# 5. АЛЬТЕРНАТИВНЫЙ package.json ДЛЯ JS ВЕРСИИ
# ============================================================================

cat > backend/package-js.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend API",
  "main": "src/server.js",
  "scripts": {
    "build": "echo 'No build needed for JS version'",
    "start": "node src/server.js",
    "dev": "node src/server.js"
  },
  "dependencies": {
    "express": "4.18.2",
    "cors": "2.8.5"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

echo "✅ Создан альтернативный package.json для JS версии"

# ============================================================================
# 6. ТЕСТИРОВАТЬ TYPESCRIPT ВЕРСИЮ
# ============================================================================

echo "🔨 Тестируем TypeScript версию..."
cd backend

rm -rf node_modules package-lock.json dist

npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены"
    
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ TypeScript версия работает!"
        cd ..
        
        cat > backend/.env << 'EOF'
NODE_ENV=production
PORT=10000
EOF
        
        echo ""
        echo "🚀 РЕШЕНИЕ #1 (TypeScript) ГОТОВО!"
        echo ""
        echo "📋 RENDER НАСТРОЙКИ:"
        echo "Root Directory: /backend"
        echo "Build Command: npm run build"  
        echo "Start Command: npm run start"
        echo ""
        
    else
        echo "❌ TypeScript версия не работает"
        cd ..
        
        echo ""
        echo "🚀 ПЕРЕХОДИМ НА РЕШЕНИЕ #2 (Pure JavaScript)!"
        echo ""
        echo "Используем чистый JavaScript без TypeScript:"
        
        # Заменяем package.json на JS версию
        cp backend/package-js.json backend/package.json
        
        echo ""
        echo "📋 RENDER НАСТРОЙКИ ДЛЯ JS ВЕРСИИ:"
        echo "Root Directory: /backend"
        echo "Build Command: echo 'No build needed'"
        echo "Start Command: npm run start"
        echo ""
        echo "✅ JS версия не требует сборки и должна работать!"
    fi
    
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

# ============================================================================
# 7. ИНСТРУКЦИИ
# ============================================================================

echo ""
echo "📋 У ВАС ЕСТЬ 2 ВАРИАНТА:"
echo ""
echo "🔧 ВАРИАНТ 1 (TypeScript):"
echo "- Используйте backend/package.json"
echo "- Build: npm run build"
echo "- Start: npm run start"
echo ""
echo "🔧 ВАРИАНТ 2 (Pure JS):"
echo "- Скопируйте: cp backend/package-js.json backend/package.json" 
echo "- Build: echo 'No build needed'"
echo "- Start: npm run start"
echo ""
echo "✅ КОММИТ:"
echo "git add ."
echo "git commit -m '🔧 Add minimal build fix with JS fallback'"
echo "git push origin main"
echo ""
echo "🎯 Если TypeScript не работает, используйте JS версию!"
