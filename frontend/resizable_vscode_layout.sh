#!/bin/bash

echo "🎨 VS CODE STYLE RESIZABLE LAYOUT"
echo "================================="
echo "Создаём перетаскиваемые панели как в VS Code"

# ============================================================================
# 1. СОЗДАТЬ ResizablePanel КОМПОНЕНТ
# ============================================================================

cat > src/components/ResizablePanel.tsx << 'EOF'
import { ReactNode, useState, useCallback, useRef } from 'react';

interface ResizablePanelProps {
  direction: 'horizontal' | 'vertical';
  defaultSize: number;
  minSize: number;
  maxSize?: number;
  children: ReactNode;
  isCollapsed?: boolean;
  onToggleCollapse?: () => void;
}

export function ResizablePanel({
  direction,
  defaultSize,
  minSize,
  maxSize = 9999,
  children,
  isCollapsed = false,
  onToggleCollapse
}: ResizablePanelProps) {
  const [size, setSize] = useState(defaultSize);
  const [isDragging, setIsDragging] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

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
      if (newSize < minSize) newSize = minSize;
      if (newSize > maxSize) newSize = maxSize;
      
      setSize(newSize);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  }, [direction, size, minSize, maxSize, isCollapsed]);

  const currentSize = isCollapsed ? (direction === 'horizontal' ? 0 : 30) : size;

  return (
    <>
      <div
        ref={panelRef}
        className={`flex-shrink-0 transition-all duration-200 ${
          isCollapsed ? 'overflow-hidden' : 'overflow-visible'
        }`}
        style={{
          [direction === 'horizontal' ? 'width' : 'height']: `${currentSize}px`
        }}
      >
        {children}
      </div>
      
      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        className={`flex-shrink-0 bg-gray-600 hover:bg-blue-500 transition-colors group ${
          direction === 'horizontal' 
            ? 'w-1 cursor-col-resize hover:w-1.5' 
            : 'h-1 cursor-row-resize hover:h-1.5'
        } ${isDragging ? 'bg-blue-500' : ''} ${
          isCollapsed ? 'opacity-50' : ''
        }`}
        onDoubleClick={onToggleCollapse}
        title={`${direction === 'horizontal' ? 'Drag to resize width' : 'Drag to resize height'}. Double-click to ${isCollapsed ? 'expand' : 'collapse'}`}
      >
        <div className={`w-full h-full bg-blue-400 opacity-0 group-hover:opacity-100 transition-opacity ${
          isDragging ? 'opacity-100' : ''
        }`} />
      </div>
    </>
  );
}
EOF

echo "✅ ResizablePanel создан"

# ============================================================================
# 2. СОЗДАТЬ COLLAPSIBLE ПАНЕЛЬ
# ============================================================================

cat > src/components/CollapsiblePanel.tsx << 'EOF'
import { ReactNode } from 'react';
import { ChevronLeft, ChevronRight, ChevronDown, ChevronUp } from 'lucide-react';

interface CollapsiblePanelProps {
  direction: 'horizontal' | 'vertical';
  isCollapsed: boolean;
  onToggle: () => void;
  title: string;
  children: ReactNode;
}

export function CollapsiblePanel({
  direction,
  isCollapsed,
  onToggle,
  title,
  children
}: CollapsiblePanelProps) {
  if (isCollapsed) {
    return (
      <div
        className={`flex items-center justify-center bg-gray-800 border-gray-700 cursor-pointer hover:bg-gray-700 transition-colors ${
          direction === 'horizontal' 
            ? 'border-r w-8 writing-mode-vertical' 
            : 'border-t h-8'
        }`}
        onClick={onToggle}
        title={`Expand ${title}`}
      >
        {direction === 'horizontal' ? (
          <div className="flex flex-col items-center">
            <ChevronRight size={14} className="text-gray-400" />
            <span className="text-xs text-gray-400 mt-1 transform rotate-90 whitespace-nowrap origin-center">
              {title}
            </span>
          </div>
        ) : (
          <div className="flex items-center space-x-2">
            <ChevronUp size={14} className="text-gray-400" />
            <span className="text-xs text-gray-400">{title}</span>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between p-2 bg-gray-750 border-b border-gray-700">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
          {title}
        </span>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
          title={`Collapse ${title}`}
        >
          {direction === 'horizontal' ? (
            <ChevronLeft size={12} />
          ) : (
            <ChevronDown size={12} />
          )}
        </button>
      </div>
      <div className="flex-1 overflow-hidden">
        {children}
      </div>
    </div>
  );
}
EOF

echo "✅ CollapsiblePanel создан"

# ============================================================================
# 3. ОБНОВИТЬ App.tsx С RESIZABLE LAYOUT
# ============================================================================

cat > src/App.tsx << 'EOF'
import { useState } from 'react';
import { Menu, Settings, Play, Code } from 'lucide-react';
import { ResizablePanel } from './components/ResizablePanel';
import { CollapsiblePanel } from './components/CollapsiblePanel';
import { FileTree } from './components/FileTree';
import { Editor } from './components/Editor';
import { AIAssistant } from './components/AIAssistant';
import { Terminal } from './components/Terminal';
import { LivePreview } from './components/LivePreview';
import { useFileManager } from './hooks/useFileManager';
import type { AgentType } from './types';

function App() {
  const [leftPanelCollapsed, setLeftPanelCollapsed] = useState(false);
  const [rightPanelCollapsed, setRightPanelCollapsed] = useState(false);
  const [terminalCollapsed, setTerminalCollapsed] = useState(false);
  const [activeAgent, setActiveAgent] = useState<AgentType>('claudy');
  const [activeRightPanel, setActiveRightPanel] = useState<'ai' | 'preview'>('preview');

  const fileManager = useFileManager();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white overflow-hidden">
      {/* VS Code Style Header */}
      <header className="h-10 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4 flex-shrink-0">
        <div className="flex items-center space-x-4">
          <button className="p-1.5 hover:bg-gray-700 rounded">
            <Menu size={16} />
          </button>
          
          <div className="flex items-center space-x-3">
            <div className="w-4 h-4 bg-blue-500 rounded-sm flex items-center justify-center">
              <Code size={10} className="text-white" />
            </div>
            <span className="text-sm font-medium">iCoder Plus</span>
            <span className="text-xs text-gray-400">v2.2</span>
          </div>
        </div>

        <div className="flex items-center space-x-4">
          <div className="px-3 py-1 bg-blue-600 rounded text-xs font-medium">
            {fileManager.activeTab?.name || 'Welcome'}
          </div>
          
          <button className="p-1.5 hover:bg-gray-700 rounded">
            <Settings size={14} />
          </button>
        </div>
      </header>

      {/* Main Layout */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left Sidebar */}
        <ResizablePanel
          direction="horizontal"
          defaultSize={320}
          minSize={200}
          maxSize={600}
          isCollapsed={leftPanelCollapsed}
          onToggleCollapse={() => setLeftPanelCollapsed(!leftPanelCollapsed)}
        >
          <CollapsiblePanel
            direction="horizontal"
            isCollapsed={leftPanelCollapsed}
            onToggle={() => setLeftPanelCollapsed(!leftPanelCollapsed)}
            title="Explorer"
          >
            <FileTree {...fileManager} />
          </CollapsiblePanel>
        </ResizablePanel>

        {/* Main Content Area */}
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Editor */}
          <div className="flex-1 overflow-hidden">
            <Editor {...fileManager} />
          </div>

          {/* Bottom Terminal */}
          <ResizablePanel
            direction="vertical"
            defaultSize={200}
            minSize={100}
            maxSize={400}
            isCollapsed={terminalCollapsed}
            onToggleCollapse={() => setTerminalCollapsed(!terminalCollapsed)}
          >
            <CollapsiblePanel
              direction="vertical"
              isCollapsed={terminalCollapsed}
              onToggle={() => setTerminalCollapsed(!terminalCollapsed)}
              title="Terminal"
            >
              <Terminal />
            </CollapsiblePanel>
          </ResizablePanel>
        </div>

        {/* Right Panel */}
        <ResizablePanel
          direction="horizontal"
          defaultSize={400}
          minSize={280}
          maxSize={800}
          isCollapsed={rightPanelCollapsed}
          onToggleCollapse={() => setRightPanelCollapsed(!rightPanelCollapsed)}
        >
          <CollapsiblePanel
            direction="horizontal"
            isCollapsed={rightPanelCollapsed}
            onToggle={() => setRightPanelCollapsed(!rightPanelCollapsed)}
            title={activeRightPanel === 'preview' ? 'Live Preview' : 'AI Assistant'}
          >
            <div className="h-full flex flex-col">
              {/* Right Panel Tabs */}
              <div className="flex border-b border-gray-700 bg-gray-800">
                <button
                  onClick={() => setActiveRightPanel('preview')}
                  className={`flex-1 px-4 py-2 text-xs font-medium ${
                    activeRightPanel === 'preview'
                      ? 'bg-gray-900 text-white border-b-2 border-blue-500'
                      : 'text-gray-400 hover:text-white hover:bg-gray-700'
                  }`}
                >
                  <Play size={12} className="inline mr-2" />
                  Live Preview
                </button>
                <button
                  onClick={() => setActiveRightPanel('ai')}
                  className={`flex-1 px-4 py-2 text-xs font-medium ${
                    activeRightPanel === 'ai'
                      ? 'bg-gray-900 text-white border-b-2 border-blue-500'
                      : 'text-gray-400 hover:text-white hover:bg-gray-700'
                  }`}
                >
                  🤖 AI Assistant
                </button>
              </div>

              {/* Panel Content */}
              <div className="flex-1 overflow-hidden">
                {activeRightPanel === 'preview' ? (
                  <LivePreview activeTab={fileManager.activeTab} />
                ) : (
                  <AIAssistant
                    activeAgent={activeAgent}
                    setActiveAgent={setActiveAgent}
                  />
                )}
              </div>
            </div>
          </CollapsiblePanel>
        </ResizablePanel>
      </div>

      {/* Status Bar */}
      <div className="h-6 bg-blue-600 flex items-center justify-between px-4 text-xs flex-shrink-0">
        <div className="flex items-center space-x-4">
          <span>✅ Backend: api.icoder.swapoil.de</span>
          <span>🔄 Ready</span>
        </div>
        <div className="flex items-center space-x-2">
          <span>{fileManager.activeTab?.language || 'Text'}</span>
          <span>UTF-8</span>
        </div>
      </div>
    </div>
  );
}

export default App;
EOF

echo "✅ App.tsx обновлен с VS Code layout"

# ============================================================================
# 4. ОБНОВИТЬ TAILWIND CONFIG ДЛЯ КУРСОРОВ
# ============================================================================

cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#007acc',
        secondary: '#4ec9b0',
        background: '#1e1e1e',
        surface: '#252526',
        border: '#464647',
        gray: {
          750: '#2d2d30',
          850: '#1a1a1a'
        }
      },
      cursor: {
        'col-resize': 'col-resize',
        'row-resize': 'row-resize'
      }
    },
  },
  plugins: [],
}
EOF

echo "✅ Tailwind config обновлен"

# ============================================================================
# 5. ТЕСТИРОВАНИЕ
# ============================================================================

echo "🔨 Тестируем VS Code layout..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "🚀 VS CODE LAYOUT ГОТОВ!"
    echo "======================="
    echo ""
    echo "✅ RESIZABLE PANELS:"
    echo "   • Left Sidebar → перетаскивание границы меняет ширину"
    echo "   • Bottom Terminal → перетаскивание меняет высоту"
    echo "   • Right Panel → перетаскивание границы меняет ширину"
    echo ""
    echo "✅ COLLAPSIBLE PANELS:"
    echo "   • Двойной клик на границу → сворачивает/разворачивает"
    echo "   • Кнопки в заголовке → сворачивает панель"
    echo "   • Свернутые панели → минимальная полоска как в VS Code"
    echo ""
    echo "🎨 VS CODE FEATURES:"
    echo "   • Resize курсоры при наведении на границы"
    echo "   • Плавная анимация сворачивания"
    echo "   • Ограничения min/max размеров"
    echo "   • Blue accent на активных элементах"
    echo ""
    echo "💻 Запуск: npm run dev"
    echo "🎯 Теперь интерфейс работает точно как VS Code!"
else
    echo "❌ Ошибка сборки"
fi