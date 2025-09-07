#!/bin/bash

echo "🔧 PHASE 4.4: TERMINAL SIDEBAR MANAGER"
echo "====================================="
echo "Цель: Добавить правую панель управления терминалами как в VS Code"

# 1. Создать TerminalSidebar компонент
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
      <div className="w-8 bg-gray-800 border-l border-gray-700 flex flex-col">
        <button
          onClick={onToggleCollapse}
          className="p-2 hover:bg-gray-700 text-gray-400 hover:text-white transition-colors"
          title="Expand Terminal Panel"
        >
          <ChevronRight size={12} />
        </button>
        
        <div className="flex-1 flex flex-col gap-1 p-1">
          {terminals.map(terminal => (
            <button
              key={terminal.id}
              onClick={() => onTerminalSelect(terminal.id)}
              className={`w-6 h-6 rounded flex items-center justify-center text-xs transition-colors ${
                terminal.id === activeTerminalId
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
              title={`${terminal.name} (${terminal.shell})`}
            >
              <span className="text-xs">{getShellIcon(terminal.shell)}</span>
            </button>
          ))}
          
          <button
            onClick={() => onTerminalCreate()}
            className="w-6 h-6 rounded bg-gray-700 hover:bg-gray-600 flex items-center justify-center text-gray-300 hover:text-white transition-colors"
            title="New Terminal"
          >
            <Plus size={10} />
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="w-64 bg-gray-800 border-l border-gray-700 flex flex-col">
      {/* Header */}
      <div className="h-8 bg-gray-900 border-b border-gray-700 flex items-center justify-between px-3">
        <div className="flex items-center gap-2">
          <span className="text-xs font-medium text-gray-300 uppercase tracking-wide">
            TERMINALS
          </span>
          <span className="text-xs text-gray-500">({terminals.length})</span>
        </div>
        
        <div className="flex items-center gap-1">
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
                  <span className="text-sm">{getShellIcon(terminal.shell)}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium text-gray-200 truncate">
                        {terminal.name}
                      </span>
                      <div className={`w-2 h-2 rounded-full ${getStatusColor(terminal.status)}`} />
                    </div>
                    {terminal.workingDirectory && (
                      <div className="text-xs text-gray-400 truncate mt-1">
                        {terminal.workingDirectory}
                      </div>
                    )}
                  </div>
                </div>
                
                {/* Terminal Actions */}
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
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
      <div className="border-t border-gray-700 p-2">
        <div className="text-xs text-gray-500 mb-2">SHELL TYPES</div>
        <div className="grid grid-cols-2 gap-1">
          {(['bash', 'zsh', 'powershell', 'node'] as const).map(shell => (
            <button
              key={shell}
              onClick={() => onTerminalCreate(shell)}
              className="p-2 text-xs bg-gray-700 hover:bg-gray-600 rounded flex items-center gap-1 text-gray-300 hover:text-white transition-colors"
              title={`New ${shell} Terminal`}
            >
              <span>{getShellIcon(shell)}</span>
              <span className="capitalize">{shell}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
EOF

echo "✅ TerminalSidebar создан с полным функционалом управления"

# 2. Обновить MultiTerminalManager для интеграции с Sidebar
cat > src/components/terminal/MultiTerminalManager.tsx << 'EOF'
import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { SplitContainer } from './SplitContainer';
import { VSCodeTerminal } from './VSCodeTerminal';
import { TerminalSidebar } from './TerminalSidebar';

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

  const renderTerminals = () => {
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
            <div className="flex bg-gray-800 border-b border-gray-700 min-h-[32px] items-center">
              {terminals.map(terminal => (
                <button
                  key={terminal.id}
                  className={`px-3 py-1 text-xs border-r border-gray-700 flex items-center gap-1 ${
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
                className="px-2 py-1 text-gray-400 hover:text-white hover:bg-gray-700"
                onClick={() => createTerminal()}
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

  return (
    <div className="w-full h-full bg-gray-900 flex">
      {/* Main Terminal Area */}
      <div className="flex-1">
        {renderTerminals()}
      </div>
      
      {/* Terminal Sidebar */}
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
    </div>
  );
};
EOF

echo "✅ MultiTerminalManager обновлен с интеграцией TerminalSidebar"

# 3. Обновить BottomTerminal для поддержки новой архитектуры
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState } from 'react';
import { Maximize2, Minimize2, X, ChevronUp, ChevronDown, Terminal } from 'lucide-react';
import { MultiTerminalManager } from '../terminal/MultiTerminalManager';

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
      onResize(250);
      setIsMaximized(false);
    } else {
      const parentHeight = window.innerHeight - 100;
      const maxHeight = Math.floor(parentHeight * 0.95);
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
          <Terminal size={14} className="text-gray-400" />
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
          <span className="text-xs text-gray-500">
            {height}px {isMaximized ? '(Maximized)' : ''}
          </span>
        </div>
        
        <div className="flex items-center gap-1">
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
            title={isMaximized ? "Restore" : "Maximize (95%)"}
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
      
      {/* Multi Terminal Content with Sidebar */}
      <div className="flex-1 overflow-hidden">
        <MultiTerminalManager height={height - 32} />
      </div>
    </div>
  );
};
EOF

echo "✅ BottomTerminal обновлен для поддержки Sidebar"

# 4. Тестируем сборку
echo "🧪 Тестируем Phase 4.4 Terminal Sidebar Manager..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.4 ЗАВЕРШЕН!"
  echo "🏆 Terminal Sidebar Manager успешно реализован!"
  echo ""
  echo "📋 Новые возможности:"
  echo "   ✅ Правая панель управления терминалами (как в VS Code)"
  echo "   ✅ Список всех открытых терминалов с статусами"
  echo "   ✅ Неограниченное количество терминалов (3, 5, 10+)"
  echo "   ✅ Быстрое создание bash, zsh, powershell, node терминалов"
  echo "   ✅ Split Right/Down прямо из Sidebar"
  echo "   ✅ Сворачиваемая панель с компактным режимом"
  echo "   ✅ Индикаторы статуса (🟢 running, 🔴 error, ⚪ stopped)"
  echo "   ✅ Рабочие директории для каждого терминала"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Теперь можно управлять неограниченным количеством терминалов!"
  echo ""
  echo "📈 СТАТУС ROADMAP:"
  echo "   ✅ Phase 1: Monaco Editor Integration"
  echo "   ✅ Phase 2: Tab System Enhancement"  
  echo "   ✅ Phase 4: Terminal Perfection (Complete - 4.1 + 4.2 + 4.3 + 4.4)"
  echo ""
  echo "🎯 Готовы к Phase 5: Side Panel System?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi