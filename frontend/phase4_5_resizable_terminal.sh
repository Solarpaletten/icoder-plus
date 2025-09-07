#!/bin/bash

echo "🔧 PHASE 4.5: RESIZABLE TERMINAL AREAS"
echo "====================================="
echo "Цель: Добавить resize для терминала и sidebar как в VS Code"

# 1. Создать ResizableTerminalContainer для управления размерами
cat > src/components/terminal/ResizableTerminalContainer.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';

interface ResizableTerminalContainerProps {
  leftComponent: React.ReactNode;
  rightComponent: React.ReactNode;
  minLeftWidth?: number;
  maxLeftWidth?: number;
  defaultLeftWidth?: number;
}

export const ResizableTerminalContainer: React.FC<ResizableTerminalContainerProps> = ({
  leftComponent,
  rightComponent,
  minLeftWidth = 300,
  maxLeftWidth = 800,
  defaultLeftWidth = 600
}) => {
  const [leftWidth, setLeftWidth] = useState(defaultLeftWidth);
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const resizerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !containerRef.current) return;

      const containerRect = containerRef.current.getBoundingClientRect();
      const newWidth = e.clientX - containerRect.left;
      
      // Применяем ограничения
      const constrainedWidth = Math.max(
        minLeftWidth,
        Math.min(maxLeftWidth, newWidth)
      );
      
      setLeftWidth(constrainedWidth);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.body.style.cursor = 'default';
      document.body.style.userSelect = 'auto';
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, minLeftWidth, maxLeftWidth]);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  return (
    <div ref={containerRef} className="flex h-full bg-gray-900">
      {/* Left Component (Main Terminal Area) */}
      <div 
        className="flex-shrink-0 bg-gray-900"
        style={{ width: `${leftWidth}px` }}
      >
        {leftComponent}
      </div>
      
      {/* Resizer */}
      <div
        ref={resizerRef}
        className="w-1 bg-gray-700 hover:bg-blue-500 cursor-col-resize transition-colors duration-200 relative group"
        onMouseDown={handleMouseDown}
      >
        {/* Visual indicator */}
        <div className="absolute inset-y-0 -left-0.5 -right-0.5 bg-transparent group-hover:bg-blue-500/20 transition-colors" />
        
        {/* Drag handle dots */}
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
          <div className="flex flex-col gap-0.5">
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
          </div>
        </div>
      </div>
      
      {/* Right Component (Terminal Sidebar) */}
      <div className="flex-1 bg-gray-800 min-w-0">
        {rightComponent}
      </div>
    </div>
  );
};
EOF

echo "✅ ResizableTerminalContainer создан для resize терминала"

# 2. Обновить MultiTerminalManager для использования ResizableTerminalContainer
cat > src/components/terminal/MultiTerminalManager.tsx << 'EOF'
import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { SplitContainer } from './SplitContainer';
import { VSCodeTerminal } from './VSCodeTerminal';
import { TerminalSidebar } from './TerminalSidebar';
import { ResizableTerminalContainer } from './ResizableTerminalContainer';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  status: 'running' | 'stopped' | 'error';
  isActive: boolean;
  splitId?: string;
  workingDirectory?: string;
}

interface Split {
  id: string;
  direction: 'horizontal' | 'vertical';
  terminals: string[];
  parent?: string;
}

interface MultiTerminalManagerProps {
  height: number;
}

export const MultiTerminalManager: React.FC<MultiTerminalManagerProps> = ({ height }) => {
  const [terminals, setTerminals] = useState<TerminalInstance[]>([
    {
      id: '1',
      name: 'bash',
      shell: 'bash',
      status: 'running',
      isActive: true,
      workingDirectory: '~/projects/icoder-plus'
    }
  ]);
  
  const [splits, setSplits] = useState<Split[]>([]);
  const [activeTerminalId, setActiveTerminalId] = useState('1');
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  const generateId = () => Date.now().toString() + Math.random().toString(36).substr(2, 5);

  const createTerminal = (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git' = 'bash') => {
    const id = generateId();
    const shellCount = terminals.filter(t => t.shell === shell).length + 1;
    const newTerminal: TerminalInstance = {
      id,
      name: shell === 'node' ? `node-${shellCount}` : 
            shell === 'git' ? `git-${shellCount}` : 
            `${shell}-${shellCount}`,
      shell,
      status: 'running',
      isActive: false,
      workingDirectory: shell === 'git' ? '~/projects/icoder-plus' : 
                       shell === 'node' ? '~/projects/icoder-plus' : 
                       '~/projects/icoder-plus'
    };
    
    setTerminals(prev => [...prev, newTerminal]);
    setActiveTerminalId(id);
  };

  const closeTerminal = (id: string) => {
    if (terminals.length <= 1) return;
    
    setTerminals(prev => prev.filter(t => t.id !== id));
    
    // Remove from splits
    setSplits(prev => prev.map(split => ({
      ...split,
      terminals: split.terminals.filter(tid => tid !== id)
    })).filter(split => split.terminals.length > 0));
    
    // Set new active terminal
    if (activeTerminalId === id) {
      const remaining = terminals.filter(t => t.id !== id);
      if (remaining.length > 0) {
        setActiveTerminalId(remaining[0].id);
      }
    }
  };

  const splitTerminal = (terminalId: string, direction: 'horizontal' | 'vertical') => {
    const newTerminalId = generateId();
    const originalTerminal = terminals.find(t => t.id === terminalId);
    
    if (!originalTerminal) return;

    // Create new terminal
    const shellCount = terminals.filter(t => t.shell === originalTerminal.shell).length + 1;
    const newTerminal: TerminalInstance = {
      id: newTerminalId,
      name: `${originalTerminal.shell}-${shellCount}`,
      shell: originalTerminal.shell,
      status: 'running',
      isActive: false,
      workingDirectory: originalTerminal.workingDirectory
    };

    setTerminals(prev => [...prev, newTerminal]);

    // Create or update split
    const splitId = generateId();
    const newSplit: Split = {
      id: splitId,
      direction,
      terminals: [terminalId, newTerminalId]
    };

    setSplits(prev => [...prev, newSplit]);
    setActiveTerminalId(newTerminalId);
  };

  const selectTerminal = (id: string) => {
    setActiveTerminalId(id);
    // Update terminal status to active
    setTerminals(prev => prev.map(t => ({
      ...t,
      isActive: t.id === id
    })));
  };

  const renderMainTerminalArea = () => {
    const activeSplits = splits.filter(s => s.terminals.length > 1);

    if (activeSplits.length === 0) {
      // No splits, render single terminal or tabs
      if (terminals.length === 1) {
        const terminal = terminals[0];
        return (
          <VSCodeTerminal
            id={terminal.id}
            name={terminal.name}
            shell={terminal.shell}
            isActive={terminal.id === activeTerminalId}
            canClose={false}
            onNewTerminal={() => createTerminal()}
            onSplitRight={() => splitTerminal(terminal.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal.id, 'vertical')}
            onFocus={() => selectTerminal(terminal.id)}
            height={height}
          />
        );
      } else {
        // Multiple terminals in tabs
        const activeTerminal = terminals.find(t => t.id === activeTerminalId) || terminals[0];
        return (
          <div className="flex flex-col h-full">
            {/* Tab Bar */}
            <div className="flex bg-gray-800 border-b border-gray-700 min-h-[32px] items-center overflow-x-auto">
              {terminals.map(terminal => (
                <button
                  key={terminal.id}
                  className={`px-3 py-1 text-xs border-r border-gray-700 flex items-center gap-1 whitespace-nowrap flex-shrink-0 ${
                    terminal.id === activeTerminalId 
                      ? 'bg-gray-900 text-white' 
                      : 'text-gray-400 hover:text-white hover:bg-gray-700'
                  }`}
                  onClick={() => selectTerminal(terminal.id)}
                >
                  <span>
                    {terminal.shell === 'bash' ? '🐚' : 
                     terminal.shell === 'zsh' ? '⚡' : 
                     terminal.shell === 'node' ? '🟢' :
                     terminal.shell === 'git' ? '🔧' : '💻'}
                  </span>
                  {terminal.name}
                  <div className={`w-1.5 h-1.5 rounded-full ml-1 ${
                    terminal.status === 'running' ? 'bg-green-500' :
                    terminal.status === 'error' ? 'bg-red-500' : 'bg-gray-500'
                  }`} />
                </button>
              ))}
              <button
                className="px-2 py-1 text-gray-400 hover:text-white hover:bg-gray-700 flex-shrink-0"
                onClick={() => createTerminal()}
                title="New Terminal"
              >
                <Plus size={12} />
              </button>
            </div>
            
            {/* Active Terminal */}
            <div className="flex-1">
              <VSCodeTerminal
                id={activeTerminal.id}
                name={activeTerminal.name}
                shell={activeTerminal.shell}
                isActive={true}
                canClose={terminals.length > 1}
                onClose={() => closeTerminal(activeTerminal.id)}
                onNewTerminal={() => createTerminal()}
                onSplitRight={() => splitTerminal(activeTerminal.id, 'horizontal')}
                onSplitDown={() => splitTerminal(activeTerminal.id, 'vertical')}
                onFocus={() => selectTerminal(activeTerminal.id)}
                height={height - 32}
              />
            </div>
          </div>
        );
      }
    }

    // Render splits
    const split = activeSplits[0]; // For now, handle one split
    const splitTerminals = split.terminals.map(id => terminals.find(t => t.id === id)).filter(Boolean);

    return (
      <SplitContainer direction={split.direction}>
        {splitTerminals.map(terminal => (
          <VSCodeTerminal
            key={terminal!.id}
            id={terminal!.id}
            name={terminal!.name}
            shell={terminal!.shell}
            isActive={terminal!.id === activeTerminalId}
            canClose={terminals.length > 1}
            onClose={() => closeTerminal(terminal!.id)}
            onNewTerminal={() => createTerminal()}
            onSplitRight={() => splitTerminal(terminal!.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal!.id, 'vertical')}
            onFocus={() => selectTerminal(terminal!.id)}
            height={height}
          />
        ))}
      </SplitContainer>
    );
  };

  const renderSidebar = () => (
    <TerminalSidebar
      terminals={terminals}
      isCollapsed={sidebarCollapsed}
      activeTerminalId={activeTerminalId}
      onTerminalSelect={selectTerminal}
      onTerminalCreate={createTerminal}
      onTerminalClose={closeTerminal}
      onTerminalSplit={splitTerminal}
      onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
    />
  );

  return (
    <div className="w-full h-full bg-gray-900">
      <ResizableTerminalContainer
        leftComponent={
          <div className="h-full">
            {renderMainTerminalArea()}
          </div>
        }
        rightComponent={renderSidebar()}
        minLeftWidth={400}
        maxLeftWidth={1200}
        defaultLeftWidth={800}
      />
    </div>
  );
};
EOF

echo "✅ MultiTerminalManager обновлен с resizable контейнером"

# 3. Обновить TerminalSidebar для лучшей работы с resize
cat > src/components/terminal/TerminalSidebar.tsx << 'EOF'
import React from 'react';
import { Plus, X, Square, GitBranch, Maximize2, ChevronRight, ChevronDown } from 'lucide-react';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  status: 'running' | 'stopped' | 'error';
  isActive: boolean;
  workingDirectory?: string;
}

interface TerminalSidebarProps {
  terminals: TerminalInstance[];
  isCollapsed: boolean;
  activeTerminalId: string;
  onTerminalSelect: (id: string) => void;
  onTerminalCreate: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void;
  onTerminalClose: (id: string) => void;
  onTerminalSplit: (id: string, direction: 'horizontal' | 'vertical') => void;
  onToggleCollapse: () => void;
}

export const TerminalSidebar: React.FC<TerminalSidebarProps> = ({
  terminals,
  isCollapsed,
  activeTerminalId,
  onTerminalSelect,
  onTerminalCreate,
  onTerminalClose,
  onTerminalSplit,
  onToggleCollapse
}) => {
  const getShellIcon = (shell: string) => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      case 'node': return '🟢';
      case 'git': return '🔧';
      default: return '💻';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running': return 'bg-green-500';
      case 'stopped': return 'bg-gray-500';
      case 'error': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  if (isCollapsed) {
    return (
      <div className="w-12 bg-gray-800 border-l border-gray-700 flex flex-col">
        <button
          onClick={onToggleCollapse}
          className="p-2 hover:bg-gray-700 text-gray-400 hover:text-white transition-colors border-b border-gray-700"
          title="Expand Terminal Panel"
        >
          <ChevronRight size={14} />
        </button>
        
        <div className="flex-1 flex flex-col gap-1 p-2 overflow-y-auto">
          {terminals.map(terminal => (
            <button
              key={terminal.id}
              onClick={() => onTerminalSelect(terminal.id)}
              className={`w-8 h-8 rounded flex items-center justify-center text-sm transition-colors relative ${
                terminal.id === activeTerminalId
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
              title={`${terminal.name} (${terminal.shell})`}
            >
              <span className="text-sm">{getShellIcon(terminal.shell)}</span>
              <div className={`absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full ${getStatusColor(terminal.status)}`} />
            </button>
          ))}
          
          <button
            onClick={() => onTerminalCreate()}
            className="w-8 h-8 rounded bg-gray-700 hover:bg-gray-600 flex items-center justify-center text-gray-300 hover:text-white transition-colors mt-2"
            title="New Terminal"
          >
            <Plus size={12} />
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full bg-gray-800 border-l border-gray-700 flex flex-col min-w-0">
      {/* Header */}
      <div className="h-8 bg-gray-900 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
        <div className="flex items-center gap-2 min-w-0">
          <span className="text-xs font-medium text-gray-300 uppercase tracking-wide truncate">
            TERMINALS
          </span>
          <span className="text-xs text-gray-500 flex-shrink-0">({terminals.length})</span>
        </div>
        
        <div className="flex items-center gap-1 flex-shrink-0">
          <button
            onClick={() => onTerminalCreate()}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white transition-colors"
            title="New Terminal"
          >
            <Plus size={12} />
          </button>
          
          <button
            onClick={onToggleCollapse}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white transition-colors"
            title="Collapse Panel"
          >
            <ChevronDown size={12} />
          </button>
        </div>
      </div>

      {/* Terminal List */}
      <div className="flex-1 overflow-y-auto">
        {terminals.map(terminal => (
          <div
            key={terminal.id}
            className={`group border-b border-gray-700 ${
              terminal.id === activeTerminalId ? 'bg-gray-700' : 'hover:bg-gray-750'
            }`}
          >
            <div
              className="p-3 cursor-pointer"
              onClick={() => onTerminalSelect(terminal.id)}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <span className="text-sm flex-shrink-0">{getShellIcon(terminal.shell)}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium text-gray-200 truncate">
                        {terminal.name}
                      </span>
                      <div className={`w-2 h-2 rounded-full flex-shrink-0 ${getStatusColor(terminal.status)}`} />
                    </div>
                    {terminal.workingDirectory && (
                      <div className="text-xs text-gray-400 truncate mt-1">
                        {terminal.workingDirectory}
                      </div>
                    )}
                  </div>
                </div>
                
                {/* Terminal Actions */}
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onTerminalSplit(terminal.id, 'horizontal');
                    }}
                    className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                    title="Split Right"
                  >
                    <Square size={10} className="rotate-90" />
                  </button>
                  
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onTerminalSplit(terminal.id, 'vertical');
                    }}
                    className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                    title="Split Down"
                  >
                    <Square size={10} />
                  </button>
                  
                  {terminals.length > 1 && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onTerminalClose(terminal.id);
                      }}
                      className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-red-400"
                      title="Close Terminal"
                    >
                      <X size={10} />
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Footer - Quick Actions */}
      <div className="border-t border-gray-700 p-2 flex-shrink-0">
        <div className="text-xs text-gray-500 mb-2">SHELL TYPES</div>
        <div className="grid grid-cols-2 gap-1">
          {(['bash', 'zsh', 'powershell', 'node'] as const).map(shell => (
            <button
              key={shell}
              onClick={() => onTerminalCreate(shell)}
              className="p-2 text-xs bg-gray-700 hover:bg-gray-600 rounded flex items-center gap-1 text-gray-300 hover:text-white transition-colors"
              title={`New ${shell} Terminal`}
            >
              <span className="flex-shrink-0">{getShellIcon(shell)}</span>
              <span className="capitalize truncate">{shell}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
EOF

echo "✅ TerminalSidebar оптимизирован для работы с resize"

# 4. Тестируем сборку
echo "🧪 Тестируем Phase 4.5 Resizable Terminal Areas..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.5 ЗАВЕРШЕН!"
  echo "🏆 Resizable Terminal Areas успешно реализованы!"
  echo ""
  echo "📋 Новые возможности:"
  echo "   ✅ Перетаскивание границы между терминалом и sidebar"
  echo "   ✅ Минимальная ширина: 400px, максимальная: 1200px"
  echo "   ✅ Визуальный индикатор при hover (точки на разделителе)"
  echo "   ✅ Плавная анимация resize с ограничениями"
  echo "   ✅ Оптимизированный sidebar для любой ширины"
  echo "   ✅ Scrollable табы терминалов при узкой ширине"
  echo "   ✅ Collapsed режим sidebar с компактными иконками"
  echo ""
  echo "🎯 Теперь можно растягивать терминал точно как в VS Code!"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo ""
  echo "📈 ПОЛНЫЙ СТАТУС ROADMAP:"
  echo "   ✅ Phase 1: Monaco Editor Integration"
  echo "   ✅ Phase 2: Tab System Enhancement"
  echo "   ✅ Phase 4: Terminal Perfection (Complete - 4.1 + 4.2 + 4.3 + 4.4 + 4.5)"
  echo ""
  echo "🎯 Phase 4 ПОЛНОСТЬЮ ЗАВЕРШЕН! Готовы к Phase 5: Side Panel System?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi