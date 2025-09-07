#!/bin/bash

echo "🔧 PHASE 4.1: TERMINAL MAX HEIGHT FIX"
echo "===================================="
echo "Цель: Терминал должен подниматься до 95% высоты (как в VS Code)"

# 1. Обновить ResizablePanelGroup с правильными ограничениями
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
      
      // VS Code style limits: минимум 80px, максимум 95% от высоты (оставляем ~5% для кода)
      const minHeight = 80;
      const maxHeight = containerRect.height * 0.95; // Увеличено с 0.8 до 0.95
      const clampedHeight = Math.max(minHeight, Math.min(maxHeight, newBottomHeight));
      
      onBottomResize(clampedHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      // Prevent text selection during drag
      document.body.style.userSelect = 'none';
    } else {
      document.body.style.userSelect = '';
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.userSelect = '';
    };
  }, [isDragging, onBottomResize]);

  // Calculate remaining editor height
  const editorHeight = bottomVisible ? containerRef.current ? 
    Math.max(containerRef.current.getBoundingClientRect().height * 0.05, 40) : 40 : '100%';

  return (
    <div ref={containerRef} className="flex flex-col h-full">
      {/* Main Editor - динамическая высота */}
      <div 
        className="flex-shrink-0 min-h-0 overflow-hidden"
        style={{ 
          height: bottomVisible ? `calc(100% - ${bottomHeight}px - 1px)` : '100%',
          minHeight: typeof editorHeight === 'number' ? `${editorHeight}px` : '40px'
        }}
      >
        {mainEditor}
      </div>
      
      {/* Resize Handle - только когда терминал видим */}
      {bottomVisible && (
        <div
          className={`h-0.5 cursor-ns-resize bg-blue-500 hover:bg-blue-400 transition-colors flex-shrink-0
            ${isDragging ? 'bg-blue-400 h-1' : ''}`}
          onMouseDown={handleMouseDown}
          style={{ 
            boxShadow: isDragging ? '0 0 8px rgba(59, 130, 246, 0.5)' : 'none',
            zIndex: 10
          }}
        />
      )}
      
      {/* Bottom Panel - фиксированная высота */}
      {bottomVisible && (
        <div 
          className="flex-shrink-0 overflow-hidden"
          style={{ height: `${bottomHeight}px` }}
        >
          {bottomPanel}
        </div>
      )}
    </div>
  );
};
EOF

# 2. Обновить BottomTerminal с улучшенными кнопками maximize
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState } from 'react';
import { Maximize2, Minimize2, X, ChevronUp, ChevronDown } from 'lucide-react';
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
      onResize(250); // Restore to default
      setIsMaximized(false);
    } else {
      // Calculate 90% of parent container height (almost full screen like VS Code)
      const parentHeight = window.innerHeight - 100; // Subtract header + status bar
      const maxHeight = Math.floor(parentHeight * 0.9);
      onResize(maxHeight);
      setIsMaximized(true);
    }
  };

  const handleQuickResize = (percentage: number) => {
    const parentHeight = window.innerHeight - 100;
    const newHeight = Math.floor(parentHeight * percentage);
    onResize(newHeight);
    setIsMaximized(percentage >= 0.8);
  };

  return (
    <div className="bg-gray-900 border-t border-gray-700 flex flex-col h-full">
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
          <span className="text-xs text-gray-500">
            {height}px {isMaximized ? '(Maximized)' : ''}
          </span>
        </div>
        
        <div className="flex items-center gap-1">
          {/* Quick resize buttons */}
          <button
            onClick={() => handleQuickResize(0.3)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title="Small (30%)"
          >
            <ChevronDown size={12} />
          </button>
          
          <button
            onClick={() => handleQuickResize(0.6)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title="Medium (60%)"
          >
            <ChevronUp size={12} />
          </button>
          
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title={isMaximized ? "Restore" : "Maximize (90%)"}
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

# 3. Обновить usePanelState с улучшенными лимитами
cat > src/hooks/usePanelState.ts << 'EOF'
import { useState, useCallback } from 'react';

interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
  leftVisible: boolean;
  rightVisible: boolean;
  bottomVisible: boolean;
}

export function usePanelState() {
  const [panelState, setPanelState] = useState<PanelState>({
    leftWidth: 280,
    rightWidth: 350,
    bottomHeight: 250, // Increased default height
    isLeftCollapsed: false,
    isRightCollapsed: false,
    isBottomCollapsed: false,
    isStatusCollapsed: false,
    leftVisible: true,
    rightVisible: true,
    bottomVisible: true,
  });

  const toggleLeft = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isLeftCollapsed: !prev.isLeftCollapsed,
      leftVisible: !prev.leftVisible 
    }));
  }, []);

  const toggleRight = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isRightCollapsed: !prev.isRightCollapsed,
      rightVisible: !prev.rightVisible 
    }));
  }, []);

  const toggleBottom = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isBottomCollapsed: !prev.isBottomCollapsed,
      bottomVisible: !prev.bottomVisible 
    }));
  }, []);

  const toggleStatus = useCallback(() => {
    setPanelState(prev => ({ ...prev, isStatusCollapsed: !prev.isStatusCollapsed }));
  }, []);

  const setBottomHeight = useCallback((height: number) => {
    // VS Code style limits: минимум 80px, максимум вычисляется динамически
    const windowHeight = window.innerHeight;
    const maxHeight = (windowHeight - 150) * 0.95; // 95% от доступной высоты
    const minHeight = 80;
    
    const clampedHeight = Math.max(minHeight, Math.min(maxHeight, height));
    setPanelState(prev => ({ ...prev, bottomHeight: clampedHeight }));
  }, []);

  const setLeftWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(500, width)) }));
  }, []);

  const setRightWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(500, width)) }));
  }, []);

  const setBottomVisible = useCallback((visible: boolean) => {
    setPanelState(prev => ({ ...prev, bottomVisible: visible }));
  }, []);

  return {
    ...panelState,
    toggleLeft,
    toggleRight,
    toggleBottom,
    toggleStatus,
    setBottomHeight,
    setLeftWidth,
    setRightWidth,
    setBottomVisible,
  };
}
EOF

echo "✅ ResizablePanelGroup обновлен - максимум 95% высоты"
echo "✅ BottomTerminal получил кнопки быстрого resize"
echo "✅ usePanelState обновлен с динамическими лимитами"

# Тестируем сборку
echo "🧪 Тестируем Phase 4.1 Terminal Max Height Fix..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.1 ЗАВЕРШЕН!"
  echo "🏆 Терминал теперь может подниматься до 95% высоты!"
  echo ""
  echo "📋 Новые возможности:"
  echo "   ✅ Максимум 95% высоты (как в VS Code)"
  echo "   ✅ Минимум одна строка кода остается видимой"
  echo "   ✅ Кнопки быстрого resize (30%, 60%, 90%)"
  echo "   ✅ Улучшенный resize handle с визуальной обратной связью"
  echo "   ✅ Индикатор размера в заголовке терминала"
  echo "   ✅ Плавные анимации и hover эффекты"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Теперь терминал работает точно как в VS Code!"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi