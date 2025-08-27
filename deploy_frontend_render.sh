#!/bin/bash

echo "🚀 ДЕПЛОИМ FRONTEND НА RENDER - БЫСТРО И ПРОСТО!"

# ============================================================================
# 1. СОЗДАТЬ render.yaml ДЛЯ FRONTEND
# ============================================================================

cat > render.yaml << 'EOF'
services:
  - type: web
    name: icoder-plus-frontend
    runtime: static
    rootDir: frontend
    buildCommand: npm install && npm run build
    staticPublishPath: ./dist
    envVars:
      - key: NODE_ENV
        value: production
      - key: VITE_API_URL
        value: https://icoder-plus.onrender.com
      - key: VITE_APP_NAME
        value: iCoder Plus
      - key: VITE_APP_VERSION
        value: 2.0.0
EOF

echo "✅ render.yaml создан для автоматического деплоя frontend"

# ============================================================================
# 2. ОБНОВИТЬ FRONTEND package.json ДЛЯ RENDER
# ============================================================================

cat > frontend/package.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module",
  "description": "iCoder Plus Frontend - AI-first IDE UI",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2",
    "clsx": "^2.0.0",
    "lucide-react": "^0.294.0",
    "@monaco-editor/react": "^4.6.0",
    "monaco-editor": "^0.44.0",
    "diff2html": "^3.4.48"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.1.1",
    "autoprefixer": "^10.4.21",
    "eslint": "^8.53.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.4",
    "postcss": "^8.5.6",
    "tailwindcss": "^3.4.17",
    "vite": "^5.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["react", "vite", "tailwind", "ide", "ai", "render"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF

echo "✅ Frontend package.json оптимизирован для Render"

# ============================================================================
# 3. СОЗДАТЬ _redirects ДЛЯ SPA ROUTING
# ============================================================================

mkdir -p frontend/public

cat > frontend/public/_redirects << 'EOF'
/*    /index.html   200
/api/*  https://icoder-plus.onrender.com/api/:splat  200
EOF

echo "✅ _redirects создан для SPA и API proxy"

# ============================================================================
# 4. ОБНОВИТЬ VITE CONFIG ДЛЯ PRODUCTION
# ============================================================================

cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@services': resolve(__dirname, './src/services'),
      '@utils': resolve(__dirname, './src/utils')
    }
  },
  server: {
    port: 5173,
    host: true
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          editor: ['monaco-editor', '@monaco-editor/react'],
          utils: ['axios', 'clsx']
        }
      }
    }
  },
  define: {
    __APP_VERSION__: JSON.stringify('2.0.0')
  }
})
EOF

echo "✅ Vite config оптимизирован для production"

# ============================================================================
# 5. СОЗДАТЬ ПРОСТОЙ СТАРТОВЫЙ КОМПОНЕНТ
# ============================================================================

mkdir -p frontend/src

cat > frontend/src/App.jsx << 'EOF'
import { useState, useEffect } from 'react'
import BackendStatus from './components/BackendStatus'

function App() {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Simulate loading
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 1000)
    
    return () => clearTimeout(timer)
  }, [])

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center text-white">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500 mx-auto"></div>
          <h2 className="text-xl font-semibold mt-4">Loading iCoder Plus...</h2>
          <p className="text-gray-400 mt-2">AI-first IDE in a bottom sheet</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <header className="bg-gray-800 border-b border-gray-700">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold">iC</span>
              </div>
              <div>
                <h1 className="text-xl font-bold">iCoder Plus</h1>
                <p className="text-sm text-gray-400">AI-first IDE v2.0</p>
              </div>
            </div>
            <div className="text-sm text-gray-400">
              Frontend on Render ✅
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Welcome Section */}
          <div className="text-center mb-8">
            <h2 className="text-3xl font-bold mb-4">
              Welcome to iCoder Plus! 🚀
            </h2>
            <p className="text-gray-300 text-lg mb-6">
              Your AI-first IDE is now running on Render
            </p>
          </div>

          {/* Backend Status */}
          <div className="mb-8">
            <BackendStatus />
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            <FeatureCard 
              icon="🤖"
              title="AI Analysis" 
              description="Smart code reviews and suggestions powered by OpenAI"
            />
            <FeatureCard 
              icon="💬"
              title="AI Chat"
              description="Chat with AI about your code and get instant help"
            />
            <FeatureCard 
              icon="🔧" 
              title="Auto Fix"
              description="Automatically fix common coding issues and improve quality"
            />
            <FeatureCard 
              icon="📝"
              title="Code Editor"
              description="Monaco editor with syntax highlighting and IntelliSense"
            />
            <FeatureCard 
              icon="📊"
              title="Live Preview"
              description="See your changes in real-time with instant preview"
            />
            <FeatureCard 
              icon="🌐"
              title="Cloud Ready"
              description="Deployed on Render with 99.9% uptime guaranteed"
            />
          </div>

          {/* API Status */}
          <div className="mt-8 text-center">
            <p className="text-gray-400">
              Backend API: <span className="text-blue-400">https://icoder-plus.onrender.com</span>
            </p>
            <p className="text-sm text-gray-500 mt-1">
              Frontend deployed on Render Static Sites
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 hover:border-blue-500 transition-colors">
      <div className="text-2xl mb-3">{icon}</div>
      <h3 className="text-lg font-semibold mb-2 text-white">{title}</h3>
      <p className="text-gray-400 text-sm">{description}</p>
    </div>
  )
}

export default App
EOF

echo "✅ Стартовый App.jsx создан"

# ============================================================================
# 6. СОЗДАТЬ BackendStatus КОМПОНЕНТ
# ============================================================================

mkdir -p frontend/src/components

cat > frontend/src/components/BackendStatus.jsx << 'EOF'
import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'

export default function BackendStatus() {
  const [status, setStatus] = useState('checking')
  const [backendData, setBackendData] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkBackend()
  }, [])

  const checkBackend = async () => {
    try {
      setStatus('checking')
      setError(null)

      const response = await fetch(`${API_URL}/health`)
      const data = await response.json()

      if (response.ok) {
        setBackendData(data)
        setStatus('connected')
      } else {
        throw new Error(`HTTP ${response.status}`)
      }
    } catch (err) {
      setStatus('error')
      setError(err.message)
    }
  }

  const getStatusIcon = () => {
    switch (status) {
      case 'checking': return '🔄'
      case 'connected': return '✅'
      case 'error': return '❌'
      default: return '❓'
    }
  }

  const getStatusText = () => {
    switch (status) {
      case 'checking': return 'Checking connection...'
      case 'connected': return 'Backend Connected'
      case 'error': return 'Connection Error'
      default: return 'Unknown Status'
    }
  }

  const getStatusColor = () => {
    switch (status) {
      case 'checking': return 'text-yellow-400'
      case 'connected': return 'text-green-400'
      case 'error': return 'text-red-400'
      default: return 'text-gray-400'
    }
  }

  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-white">Backend Status</h3>
        <button 
          onClick={checkBackend}
          className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded text-sm transition-colors"
        >
          Refresh
        </button>
      </div>

      <div className={`flex items-center space-x-2 mb-3 ${getStatusColor()}`}>
        <span className="text-xl">{getStatusIcon()}</span>
        <span className="font-medium">{getStatusText()}</span>
      </div>

      {backendData && (
        <div className="space-y-2 text-sm">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <span className="text-gray-400">Version:</span>
              <span className="text-white ml-2">{backendData.version}</span>
            </div>
            <div>
              <span className="text-gray-400">Environment:</span>
              <span className="text-white ml-2">{backendData.environment}</span>
            </div>
            <div>
              <span className="text-gray-400">Port:</span>
              <span className="text-white ml-2">{backendData.port}</span>
            </div>
            <div>
              <span className="text-gray-400">Tech:</span>
              <span className="text-white ml-2">{backendData.tech || 'Node.js'}</span>
            </div>
          </div>
          <div className="pt-2 text-xs text-gray-500">
            Last checked: {new Date().toLocaleTimeString()}
          </div>
        </div>
      )}

      {error && (
        <div className="mt-3 p-3 bg-red-900/20 border border-red-800 rounded text-red-400 text-sm">
          <strong>Error:</strong> {error}
        </div>
      )}

      <div className="mt-4 text-xs text-gray-500 border-t border-gray-700 pt-3">
        Backend URL: <span className="text-blue-400">{API_URL}</span>
      </div>
    </div>
  )
}
EOF

echo "✅ BackendStatus компонент создан"

# ============================================================================
# 7. СОЗДАТЬ main.jsx
# ============================================================================

cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

echo "✅ main.jsx создан"

# ============================================================================
# 8. СОЗДАТЬ БАЗОВЫЕ СТИЛИ
# ============================================================================

cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  @apply bg-gray-800;
}

::-webkit-scrollbar-thumb {
  @apply bg-gray-600 rounded-full;
}

::-webkit-scrollbar-thumb:hover {
  @apply bg-gray-500;
}
EOF

echo "✅ Базовые стили созданы"

# ============================================================================
# 9. СОЗДАТЬ index.html
# ============================================================================

cat > frontend/index.html << 'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>iCoder Plus - AI-first IDE</title>
    <meta name="description" content="AI-first IDE in a bottom sheet. Code, analyze, and improve with AI assistance." />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

echo "✅ index.html создан"

# ============================================================================
# 10. ТЕСТИРОВАТЬ СБОРКУ
# ============================================================================

echo "🔨 Тестируем сборку frontend..."
cd frontend

rm -rf node_modules dist

npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены"
    
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ Frontend собран успешно!"
        
        if [ -d "dist" ]; then
            echo "📦 Размер сборки:"
            du -sh dist/
            echo "📁 Содержимое dist/:"
            ls -la dist/
        fi
        
    else
        echo "❌ Ошибка сборки"
        exit 1
    fi
    
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

cd ..

# ============================================================================
# 11. ИНСТРУКЦИИ ДЛЯ RENDER
# ============================================================================

echo ""
echo "🚀 FRONTEND ГОТОВ К ДЕПЛОЮ НА RENDER!"
echo ""
echo "✅ СТРУКТУРА ГОТОВА:"
echo "- render.yaml для автоматической настройки"
echo "- Статический сайт (Static Site на Render)"
echo "- Build команда: npm install && npm run build"
echo "- Publish директория: ./dist"
echo ""
echo "📋 ШАГИ ДЛЯ ДЕПЛОЯ:"
echo ""
echo "1. КОММИТ И PUSH:"
echo "   git add ."
echo "   git commit -m '🚀 Add frontend for Render deployment'"
echo "   git push origin main"
echo ""
echo "2. В RENDER DASHBOARD:"
echo "   - New → Static Site"
echo "   - Connect Repository: icoder-plus"
echo "   - Root Directory: frontend"
echo "   - Build Command: npm install && npm run build"
echo "   - Publish Directory: dist"
echo ""
echo "3. ENVIRONMENT VARIABLES НА RENDER:"
echo "   NODE_ENV=production"
echo "   VITE_API_URL=https://icoder-plus.onrender.com"
echo "   VITE_APP_NAME=iCoder Plus"
echo ""
echo "🌐 РЕЗУЛЬТАТ:"
echo "✅ Frontend URL: https://ваш-frontend.onrender.com"
echo "✅ Backend URL: https://icoder-plus.onrender.com"
echo "✅ Полностью рабочее приложение на Render!"
echo ""
echo "🎯 Frontend будет показывать статус подключения к backend!"
