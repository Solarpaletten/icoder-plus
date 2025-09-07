#!/bin/bash

echo "🔧 PHASE 5.6: RESIZABLE SIDEBARS"
echo "================================"
echo "Цель: Сделать левый и правый сайдбары растягивающимися как в VS Code"

# 1. Создать хук для управления размерами панелей с localStorage
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

# 2. Улучшить ResizablePanel с лучшими визуальными эффектами
cat > src/components/ResizablePanel.tsx << 'EOF'
import React, { ReactNode, useState, useCallback, useRef, useEffect } from 'react';

interface ResizablePanelProps {
  direction: 'horizontal' | 'vertical';
  initialSize: number;
  minSize: number;
  maxSize?: number;
  children: ReactNode;
  onResize?: (size: number) => void;
  className?: string;
}

export const ResizablePanel: React.FC<ResizablePanelProps> = ({
  direction,
  initialSize,
  minSize,
  maxSize = 9999,
  children,
  onResize,
  className = ''
}) => {
  const [size, setSize] = useState(initialSize);
  const [isDragging, setIsDragging] = useState(false);
  const [isHovering, setIsHovering] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

  // Синхронизация с внешним состоянием
  useEffect(() => {
    if (initialSize !== size) {
      setSize(initialSize);
    }
  }, [initialSize]);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
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
  }, [direction, size, minSize, maxSize, onResize]);

  return (
    <div className="flex">
      {/* Panel Content */}
      <div
        ref={panelRef}
        className={`flex-shrink-0 ${className}`}
        style={{
          [direction === 'horizontal' ? 'width' : 'height']: `${size}px`
        }}
      >
        {children}
      </div>
      
      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => setIsHovering(false)}
        className={`flex-shrink-0 group relative transition-all duration-150
          ${direction === 'horizontal' 
            ? 'w-1 cursor-col-resize hover:w-1.5' 
            : 'h-1 cursor-row-resize hover:h-1.5'
          }
          ${isDragging || isHovering 
            ? 'bg-blue-500 shadow-lg shadow-blue-500/50' 
            : 'bg-gray-600 hover:bg-blue-400'
          }`}
        title={`Drag to resize ${direction === 'horizontal' ? 'width' : 'height'}`}
      >
        {/* Animated indicator */}
        <div className={`absolute inset-0 transition-all duration-200
          ${isDragging || isHovering ? 'bg-blue-400 opacity-100' : 'bg-transparent opacity-0'}
        `} />
        
        {/* Dots indicator */}
        <div className={`absolute ${
          direction === 'horizontal' 
            ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' 
            : 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-90'
        } transition-opacity duration-200 ${
          isDragging || isHovering ? 'opacity-100' : 'opacity-0'
        }`}>
          <div className="flex gap-0.5">
            <div className="w-0.5 h-0.5 bg-white rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
  );
};
EOF

# 3. Обновить AppShell.tsx для использования ResizablePanel
cat > src/components/AppShell.tsx << 'EOF'
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { ResizablePanel } from './ResizablePanel';
import { ResizablePanelGroup } from './ResizablePanelGroup';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';
import { usePanelResize } from '../hooks/usePanelResize';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();
  const { sizes, updateLeftWidth, updateRightWidth, updateBottomHeight } = usePanelResize();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content - Трехколоночная resizable структура */}
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

# 4. Обновить usePanelState для интеграции с новой системой
cat > src/hooks/usePanelState.ts << 'EOF'
import { useState, useEffect } from 'react';

interface PanelState {
  leftVisible: boolean;
  rightVisible: boolean;
  bottomVisible: boolean;
  bottomHeight: number;
  isStatusCollapsed: boolean;
  activeTab: 'explorer' | 'search' | 'git' | 'extensions' | 'debug';
}

const STORAGE_KEY = 'icoder-plus-panel-state';

const DEFAULT_STATE: PanelState = {
  leftVisible: true,
  rightVisible: true,
  bottomVisible: true,
  bottomHeight: 250,
  isStatusCollapsed: false,
  activeTab: 'explorer'
};

export const usePanelState = () => {
  const [state, setState] = useState<PanelState>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? { ...DEFAULT_STATE, ...JSON.parse(saved) } : DEFAULT_STATE;
    } catch {
      return DEFAULT_STATE;
    }
  });

  // Сохранение состояния в localStorage
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (error) {
      console.warn('Failed to save panel state:', error);
    }
  }, [state]);

  const setLeftVisible = (visible: boolean) => {
    setState(prev => ({ ...prev, leftVisible: visible }));
  };

  const setRightVisible = (visible: boolean) => {
    setState(prev => ({ ...prev, rightVisible: visible }));
  };

  const setBottomVisible = (visible: boolean) => {
    setState(prev => ({ ...prev, bottomVisible: visible }));
  };

  const setBottomHeight = (height: number) => {
    setState(prev => ({ ...prev, bottomHeight: height }));
  };

  const toggleStatus = () => {
    setState(prev => ({ ...prev, isStatusCollapsed: !prev.isStatusCollapsed }));
  };

  const setActiveTab = (tab: PanelState['activeTab']) => {
    setState(prev => ({ ...prev, activeTab: tab }));
  };

  // Горячие клавиши для управления панелями
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey) {
        switch (e.key.toLowerCase()) {
          case 'e':
            e.preventDefault();
            setActiveTab('explorer');
            if (!state.leftVisible) setLeftVisible(true);
            break;
          case 'f':
            e.preventDefault();
            setActiveTab('search');
            if (!state.leftVisible) setLeftVisible(true);
            break;
          case 'g':
            e.preventDefault();
            setActiveTab('git');
            if (!state.leftVisible) setLeftVisible(true);
            break;
          case 'x':
            e.preventDefault();
            setActiveTab('extensions');
            if (!state.leftVisible) setLeftVisible(true);
            break;
          case 'd':
            e.preventDefault();
            setActiveTab('debug');
            if (!state.leftVisible) setLeftVisible(true);
            break;
        }
      }
      
      // Ctrl+B - Toggle левый сайдбар
      if (e.ctrlKey && e.key === 'b') {
        e.preventDefault();
        setLeftVisible(!state.leftVisible);
      }
      
      // Ctrl+` - Toggle терминал
      if (e.ctrlKey && e.key === '`') {
        e.preventDefault();
        setBottomVisible(!state.bottomVisible);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [state.leftVisible, state.bottomVisible]);

  return {
    ...state,
    setLeftVisible,
    setRightVisible,
    setBottomVisible,
    setBottomHeight,
    toggleStatus,
    setActiveTab
  };
};
EOF

echo "✅ usePanelResize.ts создан с localStorage поддержкой"
echo "✅ ResizablePanel.tsx улучшен с лучшими визуальными эффектами"
echo "✅ AppShell.tsx обновлен для использования ResizablePanel"
echo "✅ usePanelState.ts расширен с горячими клавишами"

# Тестируем сборку
echo "🧪 Тестируем Phase 5.6 Resizable Sidebars..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 5.6 ЗАВЕРШЕН!"
  echo "🎯 Теперь у вас полная VS Code структура:"
  echo "   • Resizable левый сайдбар (Explorer/Search/Git/Extensions/Debug)"
  echo "   • Resizable правый сайдбар (AI Assistants)"
  echo "   • Resizable терминал внизу"
  echo "   • Сохранение размеров в localStorage"
  echo "   • Горячие клавиши: Ctrl+B, Ctrl+`, Ctrl+Shift+E/F/G/X/D"
  echo ""
  echo "🚀 Следующий этап: Phase 6.1 - Settings Panel & Themes?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi