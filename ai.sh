# ============================================================================
# 11. DEPLOYMENT SCRIPTS
# ============================================================================

echo "🚀 Создаем deployment скрипты..."

# Root package.json для координации frontend/backend
cd ..
cat > package.json << 'EOF'
{
  "name": "icoder-plus",
  "version": "2.0.0",
  "description": "AI-first IDE - Full Stack Application",
  "private": true,
  "scripts": {
    "dev": "concurrently \"cd backend && npm run dev\" \"cd frontend && npm run dev\"",
    "build": "cd backend && npm run build && cd ../frontend && npm run build",
    "start": "cd backend && npm run start",
    "install-all": "cd backend && npm install && cd ../frontend && npm install",
    "deploy:vercel": "./deploy-vercel.sh",
    "deploy:render": "./deploy-render.sh"
  },
  "devDependencies": {
    "concurrently": "^8.2.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Vercel deployment script
cat > deploy-vercel.sh << 'EOF'
#!/bin/bash

echo "🚀 DEPLOYING TO VERCEL"
echo "====================="

# Build both frontend and backend
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Deploy backend first
echo "📦 Deploying backend..."
cd backend
npx vercel --prod
BACKEND_URL=$(npx vercel --prod 2>&1 | grep -o 'https://[^[:space:]]*' | tail -1)

if [ -z "$BACKEND_URL" ]; then
    echo "❌ Backend deployment failed"
    exit 1
fi

echo "✅ Backend deployed: $BACKEND_URL"
cd ..

# Update frontend environment
echo "🔧 Updating frontend environment..."
echo "VITE_API_URL=$BACKEND_URL" > frontend/.env.production

# Deploy frontend
echo "📦 Deploying frontend..."
cd frontend
npx vercel --prod
FRONTEND_URL=$(npx vercel --prod 2>&1 | grep -o 'https://[^[:space:]]*' | tail -1)

if [ -z "$FRONTEND_URL" ]; then
    echo "❌ Frontend deployment failed"
    exit 1
fi

echo ""
echo "🎉 DEPLOYMENT SUCCESSFUL!"
echo "========================"
echo "Frontend: $FRONTEND_URL"
echo "Backend:  $BACKEND_URL"
echo ""
echo "🔑 Don't forget to set environment variables in Vercel dashboard:"
echo "Backend: OPENAI_API_KEY, ANTHROPIC_API_KEY, NODE_ENV=production"
echo "Frontend: VITE_API_URL=$BACKEND_URL"

cd ..
EOF

chmod +x deploy-vercel.sh

# Render deployment script  
cat > deploy-render.sh << 'EOF'
#!/bin/bash

echo "🚀 PREPARING FOR RENDER DEPLOYMENT"
echo "================================="

# Build project
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "📋 RENDER DEPLOYMENT INSTRUCTIONS:"
echo "================================="
echo ""
echo "1. BACKEND DEPLOYMENT (render.com):"
echo "   - Repository: Connect your GitHub repo"
echo "   - Branch: main"
echo "   - Root Directory: /"
echo "   - Build Command: npm run build"
echo "   - Start Command: npm run start"
echo "   - Environment Variables:"
echo "     * NODE_ENV=production"
echo "     * OPENAI_API_KEY=your_openai_key"
echo "     * ANTHROPIC_API_KEY=your_anthropic_key"
echo "     * PORT=10000"
echo ""
echo "2. FRONTEND DEPLOYMENT (vercel.com or netlify.com):"
echo "   - Build Command: cd frontend && npm run build"
echo "   - Output Directory: frontend/dist"
echo "   - Environment Variables:"
echo "     * VITE_API_URL=https://your-render-backend.onrender.com"
echo ""
echo "3. AFTER DEPLOYMENT:"
echo "   - Test backend: https://your-render-backend.onrender.com/health"
echo "   - Test frontend: https://your-frontend-domain.com"
echo ""
echo "✅ Ready for deployment!"
EOF

chmod +x deploy-render.sh

# README update
cat > README.md << 'EOF'
# 🚀 iCoder Plus v2.0 - AI-First IDE

**The future of coding: Real terminal, AI assistants, and live preview in your browser.**

## ⚡ Features

- **🤖 Dual AI Assistants**: Dashka (Architect) + Claudy (Generator)
- **🖥️ Real Terminal**: WebSocket-powered terminal with real commands
- **📁 File Management**: Drag & drop files and folders
- **⚡ Live Preview**: Instant code execution and results
- **🎨 Monaco Editor**: VS Code editor with syntax highlighting
- **📦 Project Export**: Save and share projects as ZIP files
- **🌐 Full Stack**: Frontend + Backend with WebSocket communication

## 🏃‍♂️ Quick Start

```bash
# Clone repository
git clone https://github.com/your-username/icoder-plus.git
cd icoder-plus

# Install all dependencies
npm run install-all

# Start development (both frontend and backend)
npm run dev
```

**Open:** http://localhost:5173

## 🔑 Environment Setup

### Backend (.env)
```env
NODE_ENV=development
PORT=3000
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
```

### Frontend (.env.local)
```env
VITE_API_URL=http://localhost:3000
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_REAL_TERMINAL=true
```

## 🚀 Deployment

### Vercel (Automated)
```bash
npm run deploy:vercel
```

### Render + Vercel (Manual)
```bash
npm run deploy:render  # Follow instructions
```

### Environment Variables for Production

**Backend (Render):**
- `NODE_ENV=production`
- `OPENAI_API_KEY=sk-...`
- `ANTHROPIC_API_KEY=sk-ant-...`
- `PORT=10000`

**Frontend (Vercel):**
- `VITE_API_URL=https://your-backend.onrender.com`

## 🛠️ Development

```bash
# Frontend only
cd frontend && npm run dev

# Backend only  
cd backend && npm run dev

# Build for production
npm run build

# Run production build
npm run start
```

## 📦 Project Structure

```
icoder-plus/
├── frontend/          # React + Vite frontend
│   ├── src/
│   │   ├── components/    # UI Components
│   │   ├── services/      # AI & API services
│   │   ├── hooks/         # React hooks
│   │   └── styles/        # CSS styles
│   └── dist/              # Build output
├── backend/           # Express + TypeScript backend  
│   ├── src/
│   │   ├── routes/        # API routes
│   │   └── server.ts      # Main server
│   └── dist/              # Build output
└── package.json       # Root coordination
```

## 🤖 AI Features

- **Dashka**: Architecture analysis, code review, optimization suggestions
- **Claudy**: Code generation, component creation, debugging help
- **Context-aware**: AI understands your current file and project structure
- **Fallback mode**: Works even without API keys (demo responses)

## 🔧 Technologies

**Frontend:** React 18, Vite, Monaco Editor, XTerm.js, Socket.IO Client  
**Backend:** Node.js, Express, Socket.IO, node-pty, TypeScript  
**AI:** OpenAI GPT, Anthropic Claude  
**Deployment:** Vercel, Render, Netlify

## 📜 License

MIT License - Build amazing things! 🎉

---

**Built with ❤️ by Solar IT Team**
EOF

# ============================================================================
# 12. FINAL BUILD TEST
# ============================================================================

echo ""
echo "🔨 Тестируем финальную сборку..."

cd frontend
npm install

echo "Building frontend..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend build successful!"
else
    echo "❌ Frontend build failed"
    exit 1
fi

cd ../backend
npm install

echo "Building backend..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Backend build successful!"
else
    echo "❌ Backend build failed"
    exit 1
fi

cd ..

echo ""
echo "🎉 СКРИПТ #7 ЗАВЕРШЁН!"
echo "====================="
echo ""
echo "✅ ДОБАВЛЕНО:"
echo "   🤖 Реальные AI ассистенты (Dashka + Claudy)"
echo "   🖥️ Настоящий терминал с WebSocket"
echo "   📁 Загрузка файлов и папок (drag & drop)"
echo "   🔌 Backend API для AI и терминала"
echo "   🚀 Production-ready deployment"
echo "   📦 Полная система экспорта/импорта"
echo ""
echo "🚀 ЗАПУСК DEVELOPMENT:"
echo "   npm run install-all  # Установить зависимости"
echo "   npm run dev          # Запустить frontend + backend"
echo ""  
echo "🌐 PRODUCTION DEPLOY:"
echo "   npm run deploy:vercel  # Автоматический деплой"
echo "   npm run deploy:render  # Инструкции для Render"
echo ""
echo "🔑 НЕ ЗАБУДЬТЕ:"
echo "   1. Добавить реальные API ключи в .env файлы"
echo "   2. Настроить environment variables на серверах"
echo "   3. Протестировать AI функции и терминал"
echo ""
echo "🏆 iCoder Plus v2.0 - ГОТОВ К ПОКОРЕНИЮ МИРА!"