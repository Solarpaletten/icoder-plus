#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОСТАВШИХСЯ PROPS ОШИБОК"
echo "===================================="

# 1. Проверить и исправить LeftSidebar.tsx - убрать требование isVisible
cat > src/components/panels/LeftSidebar.tsx << 'EOF'
import React from 'react';
import { FileTree } from '../FileTree';
import type { FileItem } from '../../types';

interface LeftSidebarProps {
  files: FileItem[];
  selectedFileId: string | null;
  onFileSelect: (file: FileItem) => void;
  onFileCreate: (parentId: string | null, name: string, type: 'file' | 'folder') => void;
  onFileRename: (id: string, newName: string) => void;
  onFileDelete: (id: string) => void;
  onSearchQuery: (query: string) => void;
}

export const LeftSidebar: React.FC<LeftSidebarProps> = ({
  files,
  selectedFileId,
  onFileSelect,
  onFileCreate,
  onFileRename,
  onFileDelete,
  onSearchQuery
}) => {
  return (
    <div className="w-64 bg-gray-900 border-r border-gray-700 h-full">
      <FileTree
        files={files}
        onFileSelect={onFileSelect}
        selectedFileId={selectedFileId}
        onFileCreate={onFileCreate}
        onFileRename={onFileRename}
        onFileDelete={onFileDelete}
        setSearchQuery={onSearchQuery}
      />
    </div>
  );
};
EOF

# 2. Исправить BottomTerminal.tsx - передать props в VSCodeTerminal
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { Maximize2, Minimize2, X } from 'lucide-react';
import { VSCodeTerminal } from '../VSCodeTerminal';

interface BottomTerminalProps {
  height: number;
  onToggle: () => void;
  onResize: (height: number) => void;
}

export const BottomTerminal: React.FC<BottomTerminalProps> = ({
  height,
  onToggle,
  onResize
}) => {
  const [isMaximized, setIsMaximized] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const terminalRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    e.preventDefault();
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging) return;
      
      const windowHeight = window.innerHeight;
      const newHeight = windowHeight - e.clientY - 24; // 24px for status bar
      const clampedHeight = Math.max(100, Math.min(500, newHeight));
      onResize(clampedHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, onResize]);

  const finalHeight = isMaximized ? 400 : height;

  return (
    <div 
      className="bg-gray-900 border-t border-gray-700 flex flex-col"
      style={{ height: `${finalHeight}px` }}
      ref={terminalRef}
    >
      {/* Resize Handle */}
      <div
        className={`h-1 cursor-ns-resize bg-gray-700 hover:bg-blue-500 transition-colors
          ${isDragging ? 'bg-blue-500' : ''}`}
        onMouseDown={handleMouseDown}
      />
      
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
        </div>
        
        <div className="flex items-center gap-1">
          <button
            onClick={() => setIsMaximized(!isMaximized)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="Close terminal"
          >
            <X size={14} />
          </button>
        </div>
      </div>
      
      {/* Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <VSCodeTerminal 
          isVisible={true}
          height={finalHeight - 36} // Subtract header height
        />
      </div>
    </div>
  );
};
EOF

echo "✅ LeftSidebar.tsx исправлен - убран обязательный isVisible"
echo "✅ BottomTerminal.tsx исправлен - добавлены props для VSCodeTerminal"

# Финальное тестирование
echo "🧪 Тестируем исправления props..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 ВСЕ PROPS ОШИБКИ ИСПРАВЛЕНЫ!"
  echo "🏗️ АРХИТЕКТУРА ПОЛНОСТЬЮ СИНХРОНИЗИРОВАНА!"
  echo ""
  echo "📋 Финальная структура:"
  echo "   ✅ AppShell (контейнер)"
  echo "   ✅ LeftSidebar (файловая система)"
  echo "   ✅ MainEditor (центральный редактор)"
  echo "   ✅ RightPanel (AI ассистенты)"
  echo "   ✅ BottomTerminal (терминал)"
  echo "   ✅ StatusBar (статус)"
  echo ""
  echo "🚀 Проект готов к запуску: npm run dev"
  echo "🌐 URL: http://localhost:5173"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi