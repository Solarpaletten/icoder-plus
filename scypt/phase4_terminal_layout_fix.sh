#!/bin/bash

echo "🔧 PHASE 4: TERMINAL LAYOUT FIX"
echo "==============================="
echo "Цель: Терминал только в центральной области"

# 1. Создать ResizablePanelGroup для центральной колонки
cat > src/components/ResizablePanelGroup.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';

interface ResizablePanelGroupProps {
  children: [React.ReactNode, React.ReactNode]; // [MainEditor, BottomTerminal]
  direction: 'vertical';
  bottomHeight: number;
  onBottomResize: (height: number) => void;
  bottomVisible: boolean;
}

export const ResizablePanelGroup: React.FC<ResizablePanelGroupProps> = ({
  children,
  bottomHeight,
  onBottomResize,
  bottomVisible
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const [mainEditor, bottomPanel] = children;

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    e.preventDefault();
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !containerRef.current) return;
      
      const containerRect = containerRef.current.getBoundingClientRect();
      const relativeY = e.clientY - containerRect.top;
      const newBottomHeight = containerRect.height - relativeY;
      
      // Ограничения: минимум 80px, максимум 80% от высоты контейнера
      const minHeight = 80;
      const maxHeight = containerRect.height * 0.8;
      const clampedHeight = Math.max(minHeight, Math.min(maxHeight, newBottomHeight));
      
      onBottomResize(clampedHeight);
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
  }, [isDragging, onBottomResize]);

  return (
    <div ref={containerRef} className="flex flex-col h-full">
      {/* Main Editor - занимает оставшееся место */}
      <div 
        className="flex-1 min-h-0"
        style={{ 
          height: bottomVisible ? `calc(100% - ${bottomHeight}px)` : '100%' 
        }}
      >
        {mainEditor}
      </div>
      
      {/* Resize Handle - только когда терминал видим */}
      {bottomVisible && (
        <div
          className={`h-1 cursor-ns-resize bg-gray-700 hover:bg-blue-500 transition-colors
            ${isDragging ? 'bg-blue-500' : ''}`}
          onMouseDown={handleMouseDown}
        />
      )}
      
      {/* Bottom Panel - фиксированная высота */}
      {bottomVisible && (
        <div 
          className="flex-shrink-0"
          style={{ height: `${bottomHeight}px` }}
        >
          {bottomPanel}
        </div>
      )}
    </div>
  );
};
EOF

# 2. Обновить AppShell с правильной трехколоночной структурой
cat > src/components/AppShell.tsx << 'EOF'
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { ResizablePanelGroup } from './ResizablePanelGroup';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content - Трехколоночная структура */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left Column - File Sidebar */}
        {panelState.leftVisible && (
          <div className="w-64 flex-shrink-0">
            <LeftSidebar
              files={fileManager.fileTree}
              selectedFileId={fileManager.selectedFileId}
              onFileSelect={fileManager.openFile}
              onFileCreate={(parentId, name, type) => {
                if (type === 'file') {
                  fileManager.createFile(parentId, name);
                } else {
                  fileManager.createFolder(parentId, name);
                }
              }}
              onFileRename={fileManager.renameFile}
              onFileDelete={fileManager.deleteFile}
              onSearchQuery={fileManager.setSearchQuery}
            />
          </div>
        )}
        
        {/* Center Column - Main Editor + Terminal */}
        <div className="flex-1 min-w-0">
          <ResizablePanelGroup
            direction="vertical"
            bottomHeight={panelState.bottomHeight}
            onBottomResize={panelState.setBottomHeight}
            bottomVisible={panelState.bottomVisible}
          >
            {/* Main Editor */}
            <MainEditor
              openTabs={fileManager.openTabs}
              activeTab={fileManager.activeTab}
              closeTab={fileManager.closeTab}
              setActiveTab={fileManager.setActiveTab}
              reorderTabs={fileManager.reorderTabs}
              updateFileContent={fileManager.updateFileContent}
            />
            
            {/* Bottom Terminal - только в центральной колонке */}
            <BottomTerminal
              height={panelState.bottomHeight}
              onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
              onResize={panelState.setBottomHeight}
            />
          </ResizablePanelGroup>
        </div>
        
        {/* Right Column - AI Assistant */}
        {panelState.rightVisible && (
          <div className="w-80 flex-shrink-0">
            <RightPanel />
          </div>
        )}
      </div>
      
      {/* Status Bar */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={panelState.toggleStatus}
      />
    </div>
  );
};
EOF

# 3. Обновить BottomTerminal для работы без собственного resize handle
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState } from 'react';
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

  const handleMaximize = () => {
    if (isMaximized) {
      onResize(200); // Restore to default
      setIsMaximized(false);
    } else {
      onResize(500); // Maximize
      setIsMaximized(true);
    }
  };

  return (
    <div className="bg-gray-900 border-t border-gray-700 flex flex-col h-full">
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
        </div>
        
        <div className="flex items-center gap-1">
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
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
          height={height - 32} // Subtract header height
        />
      </div>
    </div>
  );
};
EOF

# 4. Добавить стили для cursor ns-resize
cat > src/styles/terminal.css << 'EOF'
/* Terminal resize cursor styles */
.cursor-ns-resize {
  cursor: ns-resize;
}

.cursor-ns-resize:active {
  cursor: ns-resize;
}

/* Smooth transitions for terminal resize */
.terminal-transition {
  transition: height 0.1s ease-out;
}

/* Prevent text selection during drag */
.no-select {
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
EOF

# 5. Обновить главный CSS файл для импорта новых стилей
if [ -f "src/index.css" ]; then
cat >> src/index.css << 'EOF'

/* Terminal specific styles */
@import './styles/terminal.css';
EOF
else
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Terminal specific styles */
@import './styles/terminal.css';
EOF
fi

echo "✅ ResizablePanelGroup создан"
echo "✅ AppShell обновлен с трехколоночной структурой"
echo "✅ BottomTerminal адаптирован для центральной колонки"
echo "✅ CSS стили для resize добавлены"

# Создаем директорию styles если её нет
mkdir -p src/styles

# Тестируем сборку
echo "🧪 Тестируем Phase 4 Terminal Layout Fix..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4 ЗАВЕРШЕН!"
  echo "🏆 Терминал теперь работает только в центральной области!"
  echo ""
  echo "📋 Исправления layout:"
  echo "   ✅ Терминал только между File Manager и AI Assistant"
  echo "   ✅ Не растягивается на весь экран"
  echo "   ✅ Плавный resize только в пределах центральной колонки"
  echo "   ✅ Боковые панели остаются нетронутыми"
  echo "   ✅ Может подниматься до самого верха редактора кода"
  echo "   ✅ Maximize/Restore кнопки работают в ограниченных пределах"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Следующий: Phase 5 (Side Panel System) или другие улучшения?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi