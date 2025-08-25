#!/bin/bash

echo "🚀 ГОТОВИМ iCoder Plus К ДЕПЛОЮ НА VERCEL!"
echo "=================================================="

# 1. СОЗДАЕМ VERCEL.JSON КОНФИГУРАЦИЮ ДЛЯ FRONTEND
cd frontend

cat > vercel.json << 'EOF'
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "name": "icoder-plus-frontend",
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "dist"
      }
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "https://icoder-plus-backend.vercel.app/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  },
  "build": {
    "env": {
      "NODE_ENV": "production"
    }
  }
}
EOF

# 2. СОЗДАЕМ .ENV.PRODUCTION ДЛЯ VERCEL
cat > .env.production << 'EOF'
# Production Environment Variables for Vercel
VITE_API_URL=https://icoder-plus-backend.vercel.app/api
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
VITE_APP_DESCRIPTION=AI-first IDE in a bottom sheet
NODE_ENV=production
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_LIVE_PREVIEW=true
EOF

# 3. ОБНОВЛЯЕМ PACKAGE.JSON ДЛЯ VERCEL BUILD
cat > package.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module",
  "description": "iCoder Plus Frontend - AI-first IDE UI in React",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint . --ext js,jsx --fix"
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
  "keywords": [
    "react",
    "vite",
    "tailwind",
    "ide",
    "ai",
    "code-editor",
    "bottom-sheet",
    "monaco-editor",
    "vercel"
  ],
  "author": "Solar IT Team",
  "license": "MIT",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

# 4. ОПТИМИЗИРУЕМ VITE.CONFIG.JS ДЛЯ PRODUCTION
cat > vite.config.js << 'EOF'
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
          ? 'https://icoder-plus-backend.vercel.app' 
          : 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: false, // Отключаем sourcemap для production
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
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
  }
})
EOF

