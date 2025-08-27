#!/bin/bash

echo "🔧 ИСПРАВЛЯЕМ TAILWIND CSS - БЫСТРЫЙ ФИX!"

# ============================================================================
# 1. ИСПРАВИТЬ index.css - УБРАТЬ ПРОБЛЕМНЫЕ КЛАССЫ
# ============================================================================

cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    box-sizing: border-box;
  }
  
  body {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
    background-color: #111827;
    color: #ffffff;
  }
}

/* Custom scrollbar для темной темы */
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background: #1f2937;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb {
  background: #4b5563;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #6b7280;
}

/* Utility classes */
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
EOF

echo "✅ index.css исправлен - убрали проблемные классы"

# ============================================================================
# 2. СОЗДАТЬ ПРОСТОЙ tailwind.config.js
# ============================================================================

cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
        }
      }
    },
  },
  plugins: [],
}
EOF

echo "✅ tailwind.config.js создан"

# ============================================================================
# 3. СОЗДАТЬ postcss.config.js
# ============================================================================

cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

echo "✅ postcss.config.js создан"

# ============================================================================
# 4. УПРОСТИТЬ App.jsx - УБРАТЬ СЛОЖНУЮ СТИЛИЗАЦИЮ
# ============================================================================

cat > frontend/src/App.jsx << 'EOF'
import { useState, useEffect } from 'react'
import BackendStatus from './components/BackendStatus'

function App() {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 1000)
    
    return () => clearTimeout(timer)
  }, [])

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center text-white">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <h2 className="text-xl font-semibold">Loading iCoder Plus...</h2>
          <p className="text-gray-400 mt-2">AI-first IDE</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <header className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">iC</span>
              </div>
              <div>
                <h1 className="text-xl font-bold">iCoder Plus</h1>
                <p className="text-sm text-gray-400">AI-first IDE v2.0</p>
              </div>
            </div>
            <div className="bg-green-800 px-3 py-1 rounded-full text-sm">
              ✅ Frontend on Render
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 py-8">
        {/* Welcome */}
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold mb-4">Welcome to iCoder Plus! 🚀</h2>
          <p className="text-gray-300 text-lg">Your AI-first IDE is now running on Render</p>
        </div>

        {/* Backend Status */}
        <div className="mb-8">
          <BackendStatus />
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <FeatureCard 
            icon="🤖"
            title="AI Analysis" 
            description="Smart code reviews powered by OpenAI"
          />
          <FeatureCard 
            icon="💬"
            title="AI Chat"
            description="Chat with AI about your code"
          />
          <FeatureCard 
            icon="🔧" 
            title="Auto Fix"
            description="Automatically fix coding issues"
          />
          <FeatureCard 
            icon="📝"
            title="Code Editor"
            description="Monaco editor with syntax highlighting"
          />
          <FeatureCard 
            icon="📊"
            title="Live Preview"
            description="See your changes in real-time"
          />
          <FeatureCard 
            icon="🌐"
            title="Cloud Ready"
            description="Deployed on Render with 99.9% uptime"
          />
        </div>

        {/* Footer */}
        <div className="text-center mt-12 pt-8 border-t border-gray-700">
          <p className="text-gray-400 mb-2">
            Backend API: <span className="text-blue-400">https://icoder-plus.onrender.com</span>
          </p>
          <p className="text-sm text-gray-500">
            Built with ❤️ by Solar IT Team
          </p>
        </div>
      </main>
    </div>
  )
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 hover:border-blue-500 transition-all duration-200">
      <div className="text-3xl mb-4">{icon}</div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-gray-400 text-sm">{description}</p>
    </div>
  )
}

export default App
EOF

echo "✅ App.jsx упрощен"

# ============================================================================
# 5. УПРОСТИТЬ BackendStatus КОМПОНЕНТ
# ============================================================================

cat > frontend/src/components/BackendStatus.jsx << 'EOF'
import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'

export default function BackendStatus() {
  const [status, setStatus] = useState('checking')
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkBackend()
  }, [])

  const checkBackend = async () => {
    try {
      setStatus('checking')
      setError(null)

      const response = await fetch(`${API_URL}/health`)
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      
      const result = await response.json()
      setData(result)
      setStatus('connected')
      
    } catch (err) {
      setStatus('error')
      setError(err.message)
      console.error('Backend check failed:', err)
    }
  }

  const getStatusInfo = () => {
    switch (status) {
      case 'checking': 
        return { icon: '🔄', text: 'Checking...', color: 'text-yellow-400' }
      case 'connected': 
        return { icon: '✅', text: 'Backend Connected', color: 'text-green-400' }
      case 'error': 
        return { icon: '❌', text: 'Connection Error', color: 'text-red-400' }
      default: 
        return { icon: '❓', text: 'Unknown', color: 'text-gray-400' }
    }
  }

  const statusInfo = getStatusInfo()

  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold">Backend Status</h3>
        <button 
          onClick={checkBackend}
          className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded text-sm transition-colors"
          disabled={status === 'checking'}
        >
          {status === 'checking' ? 'Checking...' : 'Refresh'}
        </button>
      </div>

      <div className={`flex items-center space-x-2 mb-4 ${statusInfo.color}`}>
        <span className="text-xl">{statusInfo.icon}</span>
        <span className="font-medium">{statusInfo.text}</span>
      </div>

      {data && (
        <div className="space-y-2 text-sm">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <span className="text-gray-400">Version:</span>
              <span className="text-white ml-2">{data.version || 'Unknown'}</span>
            </div>
            <div>
              <span className="text-gray-400">Environment:</span>
              <span className="text-white ml-2">{data.environment || 'production'}</span>
            </div>
            <div>
              <span className="text-gray-400">Status:</span>
              <span className="text-white ml-2">{data.status || 'OK'}</span>
            </div>
            <div>
              <span className="text-gray-400">Tech:</span>
              <span className="text-white ml-2">{data.tech || 'JavaScript'}</span>
            </div>
          </div>
          
          <div className="pt-3 text-xs text-gray-500 border-t border-gray-700">
            Last updated: {new Date().toLocaleTimeString()}
          </div>
        </div>
      )}

      {error && (
        <div className="mt-4 p-3 bg-red-900 bg-opacity-20 border border-red-800 rounded">
          <div className="text-red-400 text-sm">
            <strong>Error:</strong> {error}
          </div>
        </div>
      )}

      <div className="mt-4 text-xs text-gray-500">
        API URL: <span className="text-blue-400">{API_URL}</span>
      </div>
    </div>
  )
}
EOF

echo "✅ BackendStatus компонент упрощен"

# ============================================================================
# 6. ПРОТЕСТИРОВАТЬ ИСПРАВЛЕННУЮ СБОРКУ
# ============================================================================

echo "🔨 Тестируем исправленную сборку..."
cd frontend

# Очистить кеш
rm -rf dist .vite

# Собрать снова
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Сборка успешна!"
    
    if [ -d "dist" ]; then
        echo "📦 Размер сборки:"
        du -sh dist/
        echo "📁 Основные файлы:"
        ls -la dist/ | head -10
    fi
    
else
    echo "❌ Все еще ошибка сборки"
    exit 1
fi

cd ..

# ============================================================================
# 7. ФИНАЛЬНЫЕ ИНСТРУКЦИИ
# ============================================================================

echo ""
echo "🎉 FRONTEND ИСПРАВЛЕН И ГОТОВ!"
echo ""
echo "✅ ИСПРАВЛЕНИЯ:"
echo "- Убрали проблемные Tailwind классы"
echo "- Создали правильный tailwind.config.js"
echo "- Добавили postcss.config.js"
echo "- Упростили компоненты"
echo "- Сборка теперь работает!"
echo ""
echo "🚀 ГОТОВ К ДЕПЛОЮ НА RENDER:"
echo ""
echo "git add ."
echo "git commit -m '🔧 Fix Tailwind build issues'"
echo "git push origin main"
echo ""
echo "📋 НАСТРОЙКИ RENDER:"
echo "- New → Static Site"
echo "- Root Directory: frontend"
echo "- Build Command: npm install && npm run build"
echo "- Publish Directory: dist"
echo ""
echo "🎯 Frontend теперь успешно соберется на Render!"
