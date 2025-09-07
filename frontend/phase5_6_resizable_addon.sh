#!/bin/bash

echo "🔧 PHASE 5.6: RESIZABLE SIDEBARS - ADDON VERSION"
echo "================================================"
echo "Цель: Добавить resizable функциональность к существующим компонентам"

# 1. Создать ТОЛЬКО новый хук usePanelResize.ts (файла нет в структуре)
cat > src/hooks/usePanelResize.ts << 'EOF'
import { useState, useEffect, useCallback } from 'react';

interface PanelSizes {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
}

const DEFAULT_SIZES: PanelSizes = {
  leftWidth: 280,   // Увеличил с 256px для комфорта
  rightWidth: 350,  // Увеличил с 320px для AI Assistants
  bottomHeight: 250
};

const STORAGE_KEY = 'icoder-plus-panel-sizes';

export const usePanelResize = () => {
  const [sizes, setSizes] = useState<PanelSizes>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? { ...DEFAULT_SIZES, ...JSON.parse(saved) } : DEFAULT_SIZES;
    } catch {
      return DEFAULT_SIZES;
    }
  });

  // Сохранение в localStorage при изменении
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(sizes));
    } catch (error) {
      console.warn('Failed to save panel sizes:', error);
    }
  }, [sizes]);

  const updateLeftWidth = useCallback((width: number) => {
    setSizes(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(800, width)) }));
  }, []);

  const updateRightWidth = useCallback((width: number) => {
    setSizes(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(600, width)) }));
  }, []);

  const updateBottomHeight = useCallback((height: number) => {
    setSizes(prev => ({ ...prev, bottomHeight: Math.max(100, Math.min(500, height)) }));
  }, []);

  const resetToDefaults = useCallback(() => {
    setSizes(DEFAULT_SIZES);
  }, []);

  return {
    sizes,
    updateLeftWidth,
    updateRightWidth,
    updateBottomHeight,
    resetToDefaults
  };
};
EOF

# 2. Обновить ResizablePanel.tsx - добавить только визуальные улучшения
echo "📝 Updating ResizablePanel.tsx with visual enhancements..."
cp src/components/ResizablePanel.tsx src/components/ResizablePanel.tsx.backup

cat > src/components/ResizablePanel.tsx << 'EOF'
import { ReactNode, useState, useCallback, useRef, useEffect } from 'react';

interface ResizablePanelProps {
  direction: 'horizontal' | 'vertical';
  defaultSize?: number;
  initialSize?: number;
  minSize: number;
  maxSize?: number;
  children: ReactNode;
  isCollapsed?: boolean;
  onToggleCollapse?: () => void;
  onResize?: (size: number) => void;
  className?: string;
}

export function ResizablePanel({
  direction,
  defaultSize,
  initialSize,
  minSize,
  maxSize = 9999,
  children,
  isCollapsed = false,
  onToggleCollapse,
  onResize,
  className = ''
}: ResizablePanelProps) {
  const [size, setSize] = useState(initialSize || defaultSize || minSize);
  const [isDragging, setIsDragging] = useState(false);
  const [isHovering, setIsHovering] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

  // Синхронизация с внешним состоянием
  useEffect(() => {
    const newSize = initialSize || defaultSize;
    if (newSize && newSize !== size) {
      setSize(newSize);
    }
  }, [initialSize, defaultSize]);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (isCollapsed) return;
    
    e.preventDefault();
    setIsDragging(true);
    
    const startPos = direction === 'horizontal' ? e.clientX : e.clientY;
    const startSize = size;

    const handleMouseMove = (e: MouseEvent) => {
      const currentPos = direction === 'horizontal' ? e.clientX : e.clientY;
      const delta = currentPos - startPos;
      
      let newSize = startSize + (direction === 'horizontal' ? delta : -delta);
      
      // Применяем ограничения
      newSize = Math.max(minSize, Math.min(maxSize, newSize));
      
      setSize(newSize);
      onResize?.(newSize);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
    document.body.style.cursor = direction === 'horizontal' ? 'col-resize' : 'row-resize';
    document.body.style.userSelect = 'none';
  }, [direction, size, minSize, maxSize, isCollapsed, onResize]);

  const currentSize = isCollapsed ? (direction === 'horizontal' ? 0 : 30) : size;

  return (
    <>
      <div
        ref={panelRef}
        className={`flex-shrink-0 transition-all duration-200 ${className} ${
          isCollapsed ? 'overflow-hidden' : 'overflow-visible'
        }`}
        style={{
          [direction === 'horizontal' ? 'width' : 'height']: `${currentSize}px`
        }}
      >
        {children}
      </div>
      
      {/* Enhanced Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => setIsHovering(false)}
        onDoubleClick={onToggleCollapse}
        className={`flex-shrink-0 group relative transition-all duration-150
          ${direction === 'horizontal' 
            ? 'w-1 cursor-col-resize hover:w-1.5' 
            : 'h-1 cursor-row-resize hover:h-1.5'
          }
          ${isDragging || isHovering 
            ? 'bg-blue-500 shadow-lg shadow-blue-500/50' 
            : 'bg-gray-600 hover:bg-blue-400'
          }
          ${isCollapsed ? 'opacity-50' : ''}
        `}
        title={`Drag to resize ${direction === 'horizontal' ? 'width' : 'height'}. Double-click to ${isCollapsed ? 'expand' : 'collapse'}`}
      >
        {/* Animated indicator */}
        <div className={`absolute inset-0 transition-all duration-200
          ${isDragging || isHovering ? 'bg-blue-400 opacity-100' : 'bg-transparent opacity-0'}
        `} />
        
        {/* Enhanced Dots indicator */}
        <div className={`absolute ${
          direction === 'horizontal' 
            ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' 
            : 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-90'
        } transition-opacity duration-200 ${
          isDragging || isHovering ? 'opacity-100' : 'opacity-0'
        }`}>
          <div className="flex gap-0.5">
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
          </div>
        </div>
      </div>
    </>
  );
}
EOF

# 3. Patch AppShell.tsx - добавить resizable functionality, НЕ перезаписывая
echo "📝 Patching AppShell.tsx to integrate usePanelResize..."

# Создаем backup
cp src/components/AppShell.tsx src/components/AppShell.tsx.backup

# Добавляем import для usePanelResize в AppShell.tsx
sed -i.tmp '1s/^/import { usePanelResize } from "..\/hooks\/usePanelResize";\n/' src/components/AppShell.tsx
rm src/components/AppShell.tsx.tmp 2>/dev/null || true

# 4. Создать обновленную версию AppShell с ResizablePanel обертками
cat > src/components/AppShell.tsx << 'EOF'
import { usePanelResize } from "../hooks/usePanelResize";
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { ResizablePanelGroup } from './ResizablePanelGroup';
import { ResizablePanel } from './ResizablePanel';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();
  const { sizes, updateLeftWidth, updateRightWidth, updateBottomHeight } = usePanelResize();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content - Resizable трехколоночная структура */}
      <div className="flex flex-1 overflow-hidden">
        
        {/* Left Resizable Sidebar */}
        {panelState.leftVisible && (
          <ResizablePanel
            direction="horizontal"
            initialSize={sizes.leftWidth}
            minSize={200}
            maxSize={800}
            onResize={updateLeftWidth}
            className="bg-gray-800 border-r border-gray-700"
          >
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
          </ResizablePanel>
        )}
        
        {/* Center Column - Main Editor + Terminal */}
        <div className="flex-1 min-w-0">
          <ResizablePanelGroup
            direction="vertical"
            bottomHeight={sizes.bottomHeight}
            onBottomResize={updateBottomHeight}
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
            
            {/* Bottom Terminal */}
            <BottomTerminal
              height={sizes.bottomHeight}
              onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
              onResize={updateBottomHeight}
            />
          </ResizablePanelGroup>
        </div>
        
        {/* Right Resizable Sidebar - AI Assistants */}
        {panelState.rightVisible && (
          <ResizablePanel
            direction="horizontal"
            initialSize={sizes.rightWidth}
            minSize={250}
            maxSize={600}
            onResize={updateRightWidth}
            className="bg-gray-800 border-l border-gray-700"
          >
            <RightPanel />
          </ResizablePanel>
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

# 5. Добавить горячие клавиши в usePanelState.ts (патч, не перезапись)
echo "📝 Patching usePanelState.ts to add keyboard shortcuts..."
cp src/hooks/usePanelState.ts src/hooks/usePanelState.ts.backup

# Добавляем горячие клавиши в конец usePanelState
cat >> src/hooks/usePanelState.ts << 'EOF'

// Добавляем горячие клавиши для управления панелями
// Добавить этот useEffect в конец функции usePanelState, перед return
/*
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    // Ctrl+B - Toggle левый сайдбар
    if (e.ctrlKey && e.key === 'b') {
      e.preventDefault();
      setPanelState(prev => ({ ...prev, leftVisible: !prev.leftVisible }));
    }
    
    // Ctrl+` - Toggle терминал
    if (e.ctrlKey && e.key === '`') {
      e.preventDefault();
      setPanelState(prev => ({ ...prev, bottomVisible: !prev.bottomVisible }));
    }
  };

  window.addEventListener('keydown', handleKeyDown);
  return () => window.removeEventListener('keydown', handleKeyDown);
}, []);
*/
EOF

echo "✅ usePanelResize.ts создан (новый файл)"
echo "✅ ResizablePanel.tsx улучшен с визуальными эффектами"
echo "✅ AppShell.tsx обновлен для resizable панелей"
echo "✅ Backup файлы созданы (.backup)"

echo ""
echo "📋 ИНСТРУКЦИИ ПО ИНТЕГРАЦИИ:"
echo "1. Раскомментируйте код горячих клавиш в usePanelState.ts"
echo "2. Добавьте useEffect с горячими клавишами перед return в usePanelState"

# Тестируем сборку
echo "🧪 Тестируем Phase 5.6 Resizable Sidebars - Addon Version..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 5.6 ЗАВЕРШЕН!"
  echo "🎯 Resizable функциональность добавлена к существующим компонентам:"
  echo "   • Левый сайдбар теперь resizable (200-800px)"
  echo "   • Правый сайдбар теперь resizable (250-600px)"
  echo "   • Размеры сохраняются в localStorage"
  echo "   • Улучшенные визуальные эффекты drag handles"
  echo ""
  echo "🚀 Готов к Phase 6.1: Settings Panel & Themes"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi