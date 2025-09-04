#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ НЕДОСТАЮЩИХ КОМПОНЕНТОВ"
echo "======================================"

# 1. Создать недостающий BottomTerminal в layout/
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import { useState, useRef } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2, X } from 'lucide-react';
import { Terminal } from '../Terminal';

interface BottomTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
  height: number;
  onResize: (height: number) => void;
}

export function BottomTerminal({ isCollapsed, onToggle, height, onResize }: BottomTerminalProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  const terminalRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
    const startY = e.clientY;
    const startHeight = height;

    const handleMouseMove = (ev: MouseEvent) => {
      const deltaY = startY - ev.clientY;
      const newHeight = Math.max(80, Math.min(600, startHeight + deltaY));
      onResize(newHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  };

  const handleMaximize = () => {
    if (isMaximized) {
      onResize(200);
      setIsMaximized(false);
    } else {
      onResize(400);
      setIsMaximized(true);
    }
  };

  if (isCollapsed) {
    return (
      <div 
        className="h-6 bg-gray-800 border-t border-gray-700 flex items-center justify-between px-3 cursor-pointer hover:bg-gray-700"
        onClick={onToggle}
      >
        <span className="text-xs text-gray-400">Terminal</span>
        <ChevronUp size={12} className="text-gray-400" />
      </div>
    );
  }

  return (
    <div 
      ref={terminalRef}
      className="flex flex-col bg-gray-900 border-t border-gray-700"
      style={{ height: `${height}px` }}
    >
      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        className={`h-1 w-full cursor-row-resize border-t-2 transition-colors ${
          isDragging ? 'border-blue-500' : 'border-transparent hover:border-blue-400'
        }`}
        title="Drag to resize terminal height"
      >
        <div className={`w-full h-full bg-blue-400 opacity-0 hover:opacity-100 transition-opacity ${
          isDragging ? 'opacity-100' : ''
        }`} />
      </div>

      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 flex items-center justify-between px-3 border-b border-gray-700 flex-shrink-0">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Terminal</span>
        
        <div className="flex items-center space-x-1">
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={12} /> : <Maximize2 size={12} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title="Collapse terminal"
          >
            <ChevronDown size={14} />
          </button>
        </div>
      </div>

      {/* Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <Terminal />
      </div>
    </div>
  );
}
EOF

echo "✅ BottomTerminal.tsx создан"

# 2. Исправить типизацию в AppShell.tsx
sed -i '' 's/onResize={(height) => panelState.setBottomHeight(height)}/onResize={(height: number) => panelState.setBottomHeight(height)}/g' src/components/AppShell.tsx

echo "✅ Типизация в AppShell.tsx исправлена"

# 3. Убедиться что Terminal компонент существует, если нет - создать базовую версию
if [ ! -f "src/components/Terminal.tsx" ]; then
cat > src/components/Terminal.tsx << 'EOF'
import { useState } from 'react';

export function Terminal() {
  const [input, setInput] = useState('');
  const [history, setHistory] = useState<string[]>([
    '🚀 iCoder Plus starting...',
    'Welcome to iCoder Plus IDE Shell Terminal',
    'Type "help" for available commands',
    ''
  ]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (input.trim()) {
      setHistory(prev => [...prev, `$ ${input}`, 'Command executed', '']);
      setInput('');
    }
  };

  return (
    <div className="h-full bg-gray-900 text-white font-mono text-xs p-2 overflow-y-auto">
      <div className="space-y-1">
        {history.map((line, index) => (
          <div key={index} className="text-gray-300">
            {line}
          </div>
        ))}
      </div>
      
      <form onSubmit={handleSubmit} className="flex items-center mt-2">
        <span className="text-blue-400 mr-2">$</span>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          className="flex-1 bg-transparent outline-none text-white"
          placeholder="Enter command..."
          autoFocus
        />
      </form>
    </div>
  );
}
EOF
echo "✅ Terminal.tsx создан (базовая версия)"
fi

# 4. Тестировать сборку
echo "🧪 Тестируем исправления..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Все ошибки исправлены! Финальная архитектура готова"
else
    echo "❌ Остались ошибки - проверьте консоль"
fi