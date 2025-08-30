#!/bin/bash

echo "🎨 ИСПРАВЛЯЕМ ИКОНКИ ФАЙЛОВ"

cd frontend

# ============================================================================
# 1. ПЕРЕИМЕНОВАТЬ fileUtils.js → fileUtils.jsx
# ============================================================================

if [ -f "src/utils/fileUtils.js" ]; then
    mv src/utils/fileUtils.js src/utils/fileUtils.jsx
    echo "✅ fileUtils.js переименован в fileUtils.jsx"
elif [ -f "src/utils/fileUtils.jsx" ]; then
    echo "✅ fileUtils.jsx уже существует"
else
    echo "❌ fileUtils не найден"
fi

# ============================================================================
# 2. ИСПРАВИТЬ fileUtils.jsx - ДОБАВИТЬ FALLBACK И УЛУЧШИТЬ ЛОГИКУ
# ============================================================================

cat > src/utils/fileUtils.jsx << 'EOF'
import { 
  FileText, 
  Code, 
  Image, 
  FileJson, 
  FileCode2, 
  Palette,
  File as FileIcon,
  Folder
} from 'lucide-react'

export const getFileIcon = (fileName) => {
  if (!fileName) {
    return <FileIcon size={16} className="text-gray-400" />
  }

  const ext = fileName.split('.').pop()?.toLowerCase()
  
  // Если нет расширения - возвращаем общую иконку
  if (!ext || ext === fileName.toLowerCase()) {
    return <FileIcon size={16} className="text-gray-400" />
  }
  
  // Используем switch для JSX элементов
  switch(ext) {
    // JavaScript files
    case 'js':
      return <Code size={16} className="text-yellow-400" />
    case 'jsx':
      return <Code size={16} className="text-blue-400" />
    case 'ts':
      return <FileCode2 size={16} className="text-blue-500" />
    case 'tsx':
      return <FileCode2 size={16} className="text-blue-500" />
    case 'mjs':
      return <Code size={16} className="text-yellow-300" />
    
    // Web files
    case 'html':
    case 'htm':
      return <Code size={16} className="text-orange-400" />
    case 'css':
      return <Palette size={16} className="text-blue-300" />
    case 'scss':
    case 'sass':
      return <Palette size={16} className="text-pink-400" />
    case 'less':
      return <Palette size={16} className="text-blue-400" />
    
    // Data files
    case 'json':
      return <FileJson size={16} className="text-yellow-300" />
    case 'xml':
      return <FileCode2 size={16} className="text-green-400" />
    case 'yaml':
    case 'yml':
      return <FileText size={16} className="text-purple-400" />
    
    // Documentation
    case 'md':
    case 'markdown':
      return <FileText size={16} className="text-blue-300" />
    case 'txt':
      return <FileText size={16} className="text-gray-400" />
    case 'readme':
      return <FileText size={16} className="text-green-400" />
    
    // Images
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
    case 'bmp':
      return <Image size={16} className="text-green-400" />
    case 'svg':
      return <Image size={16} className="text-purple-400" />
    case 'ico':
      return <Image size={16} className="text-blue-400" />
    
    // Config files
    case 'config':
    case 'conf':
      return <FileCode2 size={16} className="text-gray-500" />
    case 'env':
      return <FileText size={16} className="text-yellow-500" />
    
    // Default fallback
    default:
      return <FileIcon size={16} className="text-gray-400" />
  }
}

export const getFolderIcon = (folderName, expanded = false) => {
  return <Folder size={16} className={expanded ? "text-blue-400" : "text-blue-300"} />
}

export const getLanguageFromExtension = (fileName) => {
  if (!fileName) return 'text'
  
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const languageMap = {
    js: 'javascript',
    jsx: 'javascript', 
    mjs: 'javascript',
    ts: 'typescript',
    tsx: 'typescript',
    py: 'python',
    html: 'html',
    htm: 'html',
    css: 'css',
    scss: 'scss',
    sass: 'scss',
    less: 'less',
    json: 'json',
    xml: 'xml',
    yaml: 'yaml',
    yml: 'yaml',
    md: 'markdown',
    markdown: 'markdown',
    txt: 'text'
  }
  
  return languageMap[ext] || 'text'
}

export const isImageFile = (fileName) => {
  if (!fileName) return false
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp', 'ico'].includes(ext)
}

export const isExecutableFile = (fileName) => {
  if (!fileName) return false
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['html', 'js', 'jsx', 'mjs', 'ts', 'tsx'].includes(ext)
}
EOF

echo "✅ fileUtils.jsx обновлен с расширенными иконками"

# ============================================================================
# 3. ПРОВЕРИТЬ И ОБНОВИТЬ TAILWIND CONFIG
# ============================================================================

if [ -f "tailwind.config.js" ]; then
    echo "🎨 Проверяем Tailwind конфиг..."
    
    if grep -q "jsx" tailwind.config.js; then
        echo "✅ Tailwind уже настроен для JSX"
    else
        echo "⚠️ Добавляем JSX в Tailwind content"
        
        # Создаем обновленный конфиг
        cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}",
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
        echo "✅ Tailwind конфиг обновлен"
    fi
else
    echo "❌ tailwind.config.js не найден"
fi

# ============================================================================
# 4. ОБНОВИТЬ ИМПОРТ В FileTree.jsx
# ============================================================================

if [ -f "src/components/FileTree.jsx" ]; then
    echo "🔄 Обновляем импорт в FileTree.jsx..."
    
    # Проверяем есть ли уже правильный импорт
    if grep -q "getFileIcon.*getFolderIcon" src/components/FileTree.jsx; then
        echo "✅ Импорт уже корректен"
    else
        # Заменяем импорт
        sed -i.bak "s/import { getFileIcon }/import { getFileIcon, getFolderIcon }/" src/components/FileTree.jsx
        echo "✅ Импорт обновлен"
    fi
else
    echo "❌ FileTree.jsx не найден"
fi

# ============================================================================
# 5. ТЕСТ СБОРКИ
# ============================================================================

echo "🧪 Тестируем сборку с иконками..."

