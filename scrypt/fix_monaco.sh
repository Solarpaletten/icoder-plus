#!/bin/bash

cd frontend

echo "🔧 Исправляем проблему с Monaco Editor..."

# 1. УСТАНАВЛИВАЕМ MONACO EDITOR
echo "📦 Устанавливаем @monaco-editor/react..."
npm install @monaco-editor/react monaco-editor

# 2. УСТАНАВЛИВАЕМ НЕДОСТАЮЩИЕ ЗАВИСИМОСТИ ИЗ VITE.CONFIG
echo "📦 Устанавливаем дополнительные зависимости..."
npm install diff2html

# 3. ОБНОВЛЯЕМ PACKAGE.JSON С ПРАВИЛЬНЫМИ ЗАВИСИМОСТЯМИ
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
    "monaco-editor"
  ],
  "author": "Solar IT Team",
  "license": "MIT",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

# 4. СОЗДАЕМ ОПТИМИЗИРОВАННУЮ ВЕРСИЮ VITE.CONFIG.JS
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vitejs.dev/config/
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
      // Проксировать API запросы на backend
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          // Monaco Editor в отдельном чанке для оптимизации
          editor: ['monaco-editor', '@monaco-editor/react'],
          utils: ['diff2html', 'clsx', 'axios']
        }
      }
    }
  },
  optimizeDeps: {
    include: [
      'react', 
      'react-dom', 
      'lucide-react', 
      'axios',
      // Предварительная оптимизация Monaco
      'monaco-editor/esm/vs/language/typescript/ts.worker',
      'monaco-editor/esm/vs/language/json/json.worker',
      'monaco-editor/esm/vs/editor/editor.worker'
    ]
  },
  define: {
    // Определить глобальные константы
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version)
  },
  worker: {
    format: 'es'
  }
})
EOF

# 5. СОЗДАЕМ ДИНАМИЧЕСКИЙ КОМПОНЕНТ MONACO (ОПЦИОНАЛЬНАЯ ЗАГРУЗКА)
mkdir -p src/components

cat > src/components/CodeEditor.jsx << 'EOF'
import React, { Suspense, lazy } from 'react';

// Динамический импорт Monaco Editor для уменьшения начального bundle
const MonacoEditor = lazy(() => 
  import('@monaco-editor/react').then(module => ({
    default: module.default || module.Editor
  }))
);

// Компонент загрузки
const EditorSkeleton = () => (
  <div className="w-full h-64 bg-gray-800 rounded-lg flex items-center justify-center">
    <div className="text-gray-400 animate-pulse">Loading Code Editor...</div>
  </div>
);

// Обертка для Monaco с fallback
const CodeEditor = ({ 
  value = '', 
  language = 'javascript', 
  onChange, 
  theme = 'vs-dark',
  height = '300px',
  ...props 
}) => {
  const handleEditorChange = (newValue) => {
    if (onChange) {
      onChange(newValue || '');
    }
  };

  return (
    <Suspense fallback={<EditorSkeleton />}>
      <MonacoEditor
        height={height}
        language={language}
        value={value}
        theme={theme}
        onChange={handleEditorChange}
        options={{
          selectOnLineNumbers: true,
          roundedSelection: false,
          readOnly: false,
          cursorStyle: 'line',
          automaticLayout: true,
          minimap: { enabled: false },
          scrollBeyondLastLine: false,
          fontSize: 14,
          fontFamily: 'JetBrains Mono, Consolas, Monaco, monospace',
          ...props.options
        }}
        {...props}
      />
    </Suspense>
  );
};

export default CodeEditor;
EOF

# 6. СОЗДАЕМ ПРОСТОЙ FALLBACK EDITOR (если Monaco не загрузился)
cat > src/components/SimpleEditor.jsx << 'EOF'
import React from 'react';

// Простой textarea fallback, если Monaco Editor не загружается
const SimpleEditor = ({ 
  value = '', 
  onChange, 
  language = 'javascript',
  height = '300px',
  placeholder = 'Enter your code here...'
}) => {
  const handleChange = (e) => {
    if (onChange) {
      onChange(e.target.value);
    }
  };

  return (
    <textarea
      value={value}
      onChange={handleChange}
      placeholder={placeholder}
      style={{ height }}
      className="w-full bg-gray-900 text-green-400 font-mono p-4 rounded-lg border border-gray-700 focus:border-blue-500 focus:outline-none resize-none"
      spellCheck={false}
    />
  );
};

export default SimpleEditor;
EOF

# 7. СОЗДАЕМ УМНЫЙ EDITOR WRAPPER
cat > src/components/SmartCodeEditor.jsx << 'EOF'
import React, { useState, useEffect } from 'react';
import CodeEditor from './CodeEditor';
import SimpleEditor from './SimpleEditor';

// Умный компонент, который выбирает Monaco или fallback
const SmartCodeEditor = (props) => {
  const [useMonaco, setUseMonaco] = useState(true);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Проверяем, доступен ли Monaco Editor
    const checkMonaco = async () => {
      try {
        await import('@monaco-editor/react');
        setUseMonaco(true);
      } catch (error) {
        console.warn('Monaco Editor not available, falling back to simple editor');
        setUseMonaco(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkMonaco();
  }, []);

  if (isLoading) {
    return (
      <div className="w-full h-64 bg-gray-800 rounded-lg flex items-center justify-center">
        <div className="text-gray-400 animate-pulse">Initializing Editor...</div>
      </div>
    );
  }

  // Используем Monaco если доступен, иначе простой редактор
  return useMonaco ? <CodeEditor {...props} /> : <SimpleEditor {...props} />;
};

export default SmartCodeEditor;
EOF

# 8. ПЕРЕУСТАНАВЛИВАЕМ ЗАВИСИМОСТИ
echo "🔄 Переустанавливаем зависимости..."
rm -rf node_modules package-lock.json
npm install

# 9. ТЕСТИРУЕМ СБОРКУ
echo "🔨 Тестируем сборку..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend сборка успешна!"
    echo ""
    echo "🎯 Monaco Editor исправлен!"
    echo "📦 Доступные компоненты:"
    echo "   - CodeEditor (Monaco с динамической загрузкой)"
    echo "   - SimpleEditor (textarea fallback)"
    echo "   - SmartCodeEditor (автоматический выбор)"
    echo ""
    echo "🚀 Теперь можете запустить:"
    echo "   npm run dev"
else
    echo "❌ Ошибки при сборке frontend"
fi