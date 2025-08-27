#!/bin/bash

echo "🗑️ УДАЛЯЕМ КОРНЕВОЙ PACKAGE.JSON - НАСТРАИВАЕМ ПРЯМОЙ ДЕПЛОЙ"

# ============================================================================
# 1. УДАЛИТЬ КОРНЕВОЙ package.json
# ============================================================================

if [ -f "package.json" ]; then
    echo "🗑️ Удаляем корневой package.json..."
    rm package.json
    echo "✅ Корневой package.json удален"
else
    echo "ℹ️ Корневой package.json не найден - всё в порядке"
fi

# ============================================================================
# 2. ПРОВЕРИТЬ BACKEND package.json
# ============================================================================

echo "📦 Проверяем backend/package.json..."

if [ ! -f "backend/package.json" ]; then
    echo "❌ backend/package.json не найден! Создаём..."
    
    cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.0.0",
  "description": "iCoder Plus Backend API",
  "main": "dist/server.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "nodemon --watch src --ext ts --exec ts-node -r tsconfig-paths/register src/server.ts",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "openai": "^4.58.1"
  },
  "devDependencies": {
    "@types/node": "^20.5.0",
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/compression": "^1.7.2",
    "@types/morgan": "^1.9.4",
    "typescript": "^5.1.6",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "nodemon": "^3.0.1"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["express", "typescript", "ai", "openai"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF
    echo "✅ backend/package.json создан"
else
    echo "✅ backend/package.json найден"
fi

# ============================================================================
# 3. ПРОВЕРИТЬ tsconfig.json
# ============================================================================

if [ ! -f "backend/tsconfig.json" ]; then
    echo "📄 Создаём tsconfig.json..."
    
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
    "declaration": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src"
  },
  "include": [
    "src/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF
    echo "✅ tsconfig.json создан"
else
    echo "✅ tsconfig.json найден"
fi

# ============================================================================
# 4. СОЗДАТЬ .env ДЛЯ PRODUCTION
# ============================================================================

if [ ! -f "backend/.env" ]; then
    cat > backend/.env << 'EOF'
NODE_ENV=production
PORT=10000
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
EOF
    echo "✅ .env файл создан"
else
    echo "✅ .env файл существует"
fi

# ============================================================================
# 5. ПРОВЕРИТЬ СТРУКТУРУ
# ============================================================================

echo ""
echo "📁 СТРУКТУРА ПРОЕКТА:"
echo "├── backend/"
echo "│   ├── package.json ✅"
echo "│   ├── tsconfig.json ✅"
echo "│   ├── .env ✅"
echo "│   └── src/"
echo "│       └── server.ts"
echo "└── frontend/"
echo ""

# ============================================================================
# 6. ИНСТРУКЦИИ ДЛЯ RENDER
# ============================================================================

echo "🚀 НАСТРОЙКИ ДЛЯ RENDER DASHBOARD:"
echo ""
echo "🎯 ГЛАВНОЕ ИЗМЕНЕНИЕ:"
echo "Root Directory: /backend  ⬅️ ОБЯЗАТЕЛЬНО!"
echo ""
echo "📋 Остальные настройки:"
echo "Build Command:    npm run build"
echo "Start Command:    npm run start"  
echo "Node Version:     18 или выше"
echo ""
echo "🔑 Environment Variables:"
echo "NODE_ENV=production"
echo "PORT=10000"
echo "OPENAI_API_KEY=ваш_реальный_ключ"
echo "ANTHROPIC_API_KEY=ваш_реальный_ключ"
echo ""
echo "✅ ГОТОВО К КОММИТУ:"
echo ""
echo "git add ."
echo "git commit -m '🗑️ Remove root package.json, use /backend directly'"
echo "git push origin main"
echo ""
echo "🌐 После деплоя проверьте:"
echo "https://ваш-render-url.onrender.com/health"
echo ""
echo "🎯 Теперь Render будет работать напрямую с папкой backend!"
