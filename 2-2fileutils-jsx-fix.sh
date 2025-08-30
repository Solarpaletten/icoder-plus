#!/bin/bash

echo "Исправляем JSX рендеринг в fileUtils.js"

cd frontend/src/utils

# ============================================================================
# ИСПРАВИТЬ fileUtils.js - ПРАВИЛЬНЫЙ JSX РЕНДЕРИНГ
# ============================================================================

cat > fileUtils.js << 'EOF'
import React from 'react'
import { 
  FileText, 
  Code, 
  Image, 
  FileJson, 
  FileCode2, 
  Palette,
  File as FileIcon
} from 'lucide-react'

export const getFileIcon = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  // Возвращаем функцию рендеринга, а не JSX объект
  const getIcon = () => {
    switch(ext) {
      // Code files
      case 'js':
        return <Code size={16} className="text-yellow-400" />
      case 'jsx':
        return <Code size={16} className="text-blue-400" />
      case 'ts':
        return <FileCode2 size={16} className="text-blue-500" />
      case 'tsx':
        return <FileCode2 size={16} className="text-blue-500" />
      case 'py':
        return <Code size={16} className="text-green-400" />
      
      // Web files
      case 'html':
        return <Code size={16} className="text-orange-400" />
      case 'css':
        return <Palette size={16} className="text-blue-300" />
      case 'scss':
        return <Palette size={16} className="text-pink-400" />
      
      // Data files
      case 'json':
        return <FileJson size={16} className="text-yellow-300" />
      case 'md':
        return <FileText size={16} className="text-gray-300" />
      case 'txt':
        return <FileText size={16} className="text-gray-400" />
      
      // Images
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return <Image size={16} className="text-green-400" />
      case 'svg':
        return <Image size={16} className="text-purple-400" />
      
      // Default
      default:
        return <FileIcon size={16} className="text-gray-400" />
    }
  }
  
  return getIcon()
}

export const getLanguageFromExtension = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const languageMap = {
    js: 'javascript',
    jsx: 'javascript', 
    ts: 'typescript',
    tsx: 'typescript',
    py: 'python',
    html: 'html',
    css: 'css',
    scss: 'scss',
    json: 'json',
    md: 'markdown',
    txt: 'text'
  }
  
  return languageMap[ext] || 'text'
}

export const isImageFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp'].includes(ext)
}

export const isExecutableFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['html', 'js', 'jsx'].includes(ext)
}
EOF

echo "✅ fileUtils.js исправлен"

# ============================================================================
# ТЕСТИРОВАТЬ ИСПРАВЛЕНИЕ
# ============================================================================

cd ../../..
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ JSX РЕНДЕРИНГ ИСПРАВЛЕН!"
    echo ""
    echo "ТЕПЕРЬ ИКОНКИ ФАЙЛОВ ДОЛЖНЫ ОТОБРАЖАТЬСЯ КОРРЕКТНО:"
    echo "- .js файлы: желтая иконка Code"
    echo "- .jsx файлы: синяя иконка Code" 
    echo "- .css файлы: синяя иконка Palette"
    echo "- .json файлы: желтая иконка FileJson"
    echo "- .md файлы: серая иконка FileText"
    echo "- другие: серая иконка File"
    
    echo ""
    echo "🔧 КОММИТ ИЗМЕНЕНИЙ:"
    echo "git add ."
    echo "git commit -m 'Fix JSX rendering in fileUtils for proper file icons'"
    echo "git push origin main"
    
else
    echo "❌ Build failed - проверьте консоль на ошибки"
    exit 1
fi