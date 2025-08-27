#!/bin/bash

echo "🔗 ПОДКЛЮЧАЕМ FRONTEND К BACKEND НА RENDER"

# ============================================================================
# 1. НАСТРОИТЬ ENVIRONMENT VARIABLES ДЛЯ PRODUCTION
# ============================================================================

cat > frontend/.env.production << 'EOF'
# Production Environment Variables for Frontend
VITE_API_URL=https://icoder-plus.onrender.com
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
VITE_APP_DESCRIPTION=AI-first IDE in a bottom sheet
NODE_ENV=production
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_LIVE_PREVIEW=true
EOF

echo "✅ .env.production создан с URL нашего Render backend"

# ============================================================================
# 2. ОБНОВИТЬ VITE CONFIG ДЛЯ PRODUCTION
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
      '@utils': resolve(__dirname, './src/utils'),
      '@hooks': resolve(__dirname, './src/hooks')
    }
  },
  server: {
    port: 5173,
    host: true,
    open: true,
    proxy: {
      '/api': {
        target: process.env.NODE_ENV === 'production' 
          ? 'https://icoder-plus.onrender.com' 
          : 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
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
          utils: ['diff2html', 'clsx', 'axios']
        },
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    },
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    }
  },
  optimizeDeps: {
    include: [
      'react', 
      'react-dom', 
      'lucide-react', 
      'axios',
      'monaco-editor/esm/vs/language/typescript/ts.worker',
      'monaco-editor/esm/vs/language/json/json.worker',
      'monaco-editor/esm/vs/editor/editor.worker'
    ]
  },
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version || '2.0.0'),
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
  }
})
EOF

echo "✅ vite.config.js обновлен для подключения к Render"

# ============================================================================
# 3. ОБНОВИТЬ API CLIENT ДЛЯ RENDER BACKEND
# ============================================================================

mkdir -p frontend/src/services

cat > frontend/src/services/apiClient.js << 'EOF'
import axios from 'axios'

// API Base URL - автоматически определяется из environment variables
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'

console.log('🔗 API Base URL:', API_BASE_URL)

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Log request in development
    if (import.meta.env.DEV) {
      console.log('🚀 API Request:', {
        method: config.method?.toUpperCase(),
        url: `${config.baseURL}${config.url}`,
        data: config.data
      })
    }
    
    return config
  },
  (error) => {
    console.error('❌ Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor
apiClient.interceptors.response.use(
  (response) => {
    // Log response in development
    if (import.meta.env.DEV) {
      console.log('✅ API Response:', {
        status: response.status,
        url: response.config.url,
        data: response.data
      })
    }
    
    return response
  },
  (error) => {
    // Handle common errors
    if (error.response) {
      const { status, data } = error.response
      
      switch (status) {
        case 401:
          console.error('🔐 Unauthorized: Check your API key')
          break
        case 403:
          console.error('🚫 Forbidden: Insufficient permissions')
          break
        case 429:
          console.error('🐌 Rate limited: Too many requests')
          break
        case 500:
          console.error('💥 Server error: Please try again later')
          break
        default:
          console.error('⚠️ API Error:', data?.message || error.message)
      }
    } else if (error.request) {
      console.error('🌐 Network error: Unable to reach server at', API_BASE_URL)
    } else {
      console.error('❌ Request error:', error.message)
    }
    
    return Promise.reject(error)
  }
)

// AI Service API calls
export const aiAPI = {
  // Analyze code with AI
  analyze: async (code, fileName, analysisType = 'review', oldCode = null) => {
    const response = await apiClient.post('/api/ai/analyze', {
      code,
      fileName,
      analysisType,
      oldCode
    })
    return response.data
  },

  // Chat with AI
  chat: async (message, code = null, fileName = null) => {
    const response = await apiClient.post('/api/ai/chat', {
      message,
      code,
      fileName
    })
    return response.data
  },

  // Apply AI fixes
  applyFix: async (code, fileName) => {
    const response = await apiClient.post('/api/ai/fix/apply', {
      code,
      fileName
    })
    return response.data
  }
}

// Health check
export const healthAPI = {
  check: async () => {
    const response = await apiClient.get('/health')
    return response.data
  }
}

// Test connection
export const testConnection = async () => {
  try {
    const response = await apiClient.get('/')
    console.log('✅ Backend connection successful:', response.data)
    return true
  } catch (error) {
    console.error('❌ Backend connection failed:', error.message)
    return false
  }
}

export default apiClient
EOF

echo "✅ API Client настроен для подключения к Render backend"

# ============================================================================
# 4. СОЗДАТЬ ТЕСТОВЫЙ КОМПОНЕНТ ДЛЯ ПРОВЕРКИ СВЯЗИ
# ============================================================================

mkdir -p frontend/src/components

cat > frontend/src/components/BackendStatus.jsx << 'EOF'
import { useState, useEffect } from 'react'
import { healthAPI, testConnection } from '../services/apiClient'

export default function BackendStatus() {
  const [status, setStatus] = useState('checking')
  const [backendInfo, setBackendInfo] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkBackendStatus()
  }, [])

  const checkBackendStatus = async () => {
    try {
      setStatus('checking')
      setError(null)

      // Test basic connection
      const isConnected = await testConnection()
      
      if (!isConnected) {
        setStatus('error')
        setError('Cannot connect to backend')
        return
      }

      // Get health status
      const healthData = await healthAPI.check()
      setBackendInfo(healthData)
      setStatus('connected')

    } catch (err) {
      setStatus('error')
      setError(err.message)
    }
  }

  const getStatusColor = () => {
    switch (status) {
      case 'checking': return 'text-yellow-500'
      case 'connected': return 'text-green-500'
      case 'error': return 'text-red-500'
      default: return 'text-gray-500'
    }
  }

  const getStatusText = () => {
    switch (status) {
      case 'checking': return 'Checking connection...'
      case 'connected': return 'Backend connected ✅'
      case 'error': return 'Backend error ❌'
      default: return 'Unknown status'
    }
  }

  return (
    <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-white">Backend Status</h3>
        <button 
          onClick={checkBackendStatus}
          className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
        >
          Refresh
        </button>
      </div>
      
      <div className={`mt-2 font-medium ${getStatusColor()}`}>
        {getStatusText()}
      </div>

      {backendInfo && (
        <div className="mt-3 text-sm text-gray-300">
          <p>• Version: {backendInfo.version}</p>
          <p>• Environment: {backendInfo.environment}</p>
          <p>• Port: {backendInfo.port}</p>
          <p>• Tech: {backendInfo.tech}</p>
          <p className="text-xs text-gray-400 mt-1">
            {new Date(backendInfo.timestamp).toLocaleString()}
          </p>
        </div>
      )}

      {error && (
        <div className="mt-2 text-sm text-red-400 bg-red-900/20 p-2 rounded">
          Error: {error}
        </div>
      )}

      <div className="mt-3 text-xs text-gray-400">
        Backend URL: {import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'}
      </div>
    </div>
  )
}
EOF

echo "✅ BackendStatus компонент создан для мониторинга связи"

# ============================================================================
# 5. ТЕСТИРОВАТЬ ПОДКЛЮЧЕНИЕ ЛОКАЛЬНО
# ============================================================================

echo "🔨 Проверяем настройки frontend..."
cd frontend

# Проверить что есть нужные зависимости
if [ ! -d "node_modules" ]; then
    echo "📦 Устанавливаем зависимости..."
    npm install
fi

# Проверить что можем собрать
echo "🔧 Тестируем сборку..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend собирается успешно"
else
    echo "❌ Ошибки при сборке frontend"
    exit 1
fi

cd ..

# ============================================================================
# 6. ИНСТРУКЦИИ ДЛЯ РАЗВЕРТЫВАНИЯ
# ============================================================================

echo ""
echo "🚀 FRONTEND НАСТРОЕН ДЛЯ ПОДКЛЮЧЕНИЯ К RENDER!"
echo ""
echo "✅ ЧТО НАСТРОЕНО:"
echo "- API URL: https://icoder-plus.onrender.com"
echo "- Environment variables (.env.production)"
echo "- API Client с правильными endpoints"
echo "- Компонент для мониторинга статуса backend"
echo ""
echo "📋 ВАРИАНТЫ РАЗВЕРТЫВАНИЯ FRONTEND:"
echo ""
echo "🎯 ВАРИАНТ 1 - Vercel:"
echo "cd frontend"
echo "npm run build"
echo "npx vercel --prod"
echo ""
echo "🎯 ВАРИАНТ 2 - Netlify:"
echo "cd frontend"  
echo "npm run build"
echo "# Загрузить папку dist/ на Netlify"
echo ""
echo "🎯 ВАРИАНТ 3 - GitHub Pages:"
echo "cd frontend"
echo "npm run build"
echo "# Коммитнуть dist/ и настроить GitHub Pages"
echo ""
echo "✅ ГОТОВО К КОММИТУ:"
echo ""
echo "git add ."
echo "git commit -m '🔗 Connect frontend to Render backend'"
echo "git push origin main"
echo ""
echo "🌐 ПОСЛЕ РАЗВЕРТЫВАНИЯ FRONTEND:"
echo "1. Откройте frontend URL"
echo "2. Проверьте компонент BackendStatus"
echo "3. Убедитесь что показывает 'Backend connected ✅'"
echo ""
echo "🎯 Frontend теперь будет работать с Render backend!"
