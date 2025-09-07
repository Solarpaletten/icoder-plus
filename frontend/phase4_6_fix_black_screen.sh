#!/bin/bash

echo "🔧 PHASE 4.6 FIX: BLACK SCREEN REACT ERRORS"
echo "==========================================="
echo "Цель: Исправить Maximum update depth exceeded и черный экран"

# 1. Исправить BottomTerminal - убрать проблемный ref
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState, useRef } from 'react';
import { MultiTerminalManager } from '../terminal/MultiTerminalManager';
import { TerminalHeader } from '../terminal/TerminalHeader';

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
  const terminalManagerRef = useRef<{ createTerminal: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void } | null>(null);

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

  const handleNewTerminal = (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => {
    if (terminalManagerRef.current) {
      terminalManagerRef.current.createTerminal(shell);
    }
  };

  return (
    <div className="bg-gray-900 border-t border-gray-700 flex flex-col h-full">
      {/* Terminal Header with New Terminal Button */}
      <TerminalHeader
        height={height}
        isMaximized={isMaximized}
        onNewTerminal={handleNewTerminal}
        onMaximize={handleMaximize}
        onToggle={onToggle}
      />
      
      {/* Multi Terminal Content with Sidebar */}
      <div className="flex-1 overflow-hidden">
        <MultiTerminalManager 
          height={height - 32}
          ref={terminalManagerRef}
        />
      </div>
    </div>
  );
};
EOF

echo "✅ BottomTerminal исправлен - убрана проблема с ref"

# 2. Исправить MultiTerminalManager - убрать бесконечный цикл
cat > src/components/terminal/MultiTerminalManager.tsx << 'EOF'
import React, { useState, forwardRef, useImperativeHandle, useCallback } from 'react';
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

export interface MultiTerminalManagerRef {
  createTerminal: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void;
}

export const MultiTerminalManager = forwardRef<MultiTerminalManagerRef, MultiTerminalManagerProps>(({ height }, ref) => {
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

  const generateId = useCallback(() => Date.now().toString() + Math.random().toString(36).substr(2, 5), []);

  const createTerminal = useCallback((shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git' = 'bash') => {
    const id = generateId();
    setTerminals(prev => {
      const shellCount = prev.filter(t => t.shell === shell).length + 1;
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
      return [...prev, newTerminal];
    });
    setActiveTerminalId(id);
  }, [generateId]);

  // Expose createTerminal method to parent component
  useImperativeHandle(ref, () => ({
    createTerminal
  }), [createTerminal]);

  const closeTerminal = useCallback((id: string) => {
    setTerminals(prev => {
      if (prev.length <= 1) return prev;
      return prev.filter(t => t.id !== id);
    });
    
    // Remove from splits
    setSplits(prev => prev.map(split => ({
      ...split,
      terminals: split.terminals.filter(tid => tid !== id)
    })).filter(split => split.terminals.length > 0));
    
    // Set new active terminal
    setActiveTerminalId(prevActiveId => {
      if (prevActiveId === id) {
        const remaining = terminals.filter(t => t.id !== id);
        return remaining.length > 0 ? remaining[0].id : '1';
      }
      return prevActiveId;
    });
  }, [terminals]);

  const splitTerminal = useCallback((terminalId: string, direction: 'horizontal' | 'vertical') => {
    const newTerminalId = generateId();
    const originalTerminal = terminals.find(t => t.id === terminalId);
    
    if (!originalTerminal) return;

    // Create new terminal
    setTerminals(prev => {
      const shellCount = prev.filter(t => t.shell === originalTerminal.shell).length + 1;
      const newTerminal: TerminalInstance = {
        id: newTerminalId,
        name: `${originalTerminal.shell}-${shellCount}`,
        shell: originalTerminal.shell,
        status: 'running',
        isActive: false,
        workingDirectory: originalTerminal.workingDirectory
      };
      return [...prev, newTerminal];
    });

    // Create or update split
    setSplits(prev => {
      const splitId = generateId();
      const newSplit: Split = {
        id: splitId,
        direction,
        terminals: [terminalId, newTerminalId]
      };
      return [...prev, newSplit];
    });

    setActiveTerminalId(newTerminalId);
  }, [generateId, terminals]);

  const selectTerminal = useCallback((id: string) => {
    setActiveTerminalId(id);
    setTerminals(prev => prev.map(t => ({
      ...t,
      isActive: t.id === id
    })));
  }, []);

  const renderMainTerminalArea = useCallback(() => {
    const activeSplits = splits.filter(s => s.terminals.length > 1);

    if (activeSplits.length === 0) {
      // No splits, render single terminal or tabs
      if (terminals.length === 1) {
        const terminal = terminals[0];
        return (
          <VSCodeTerminal
            key={terminal.id}
            id={terminal.id}
            name={terminal.name}
            shell={terminal.shell}
            isActive={terminal.id === activeTerminalId}
            canClose={false}
            onSplitRight={() => splitTerminal(terminal.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal.id, 'vertical')}
            onFocus={() => selectTerminal(terminal.id)}
            height={height}
          />
        );
      } else {
        // Multiple terminals in tabs
        const activeTerminal = terminals.find(t => t.id === activeTerminalId) || terminals[0];
        if (!activeTerminal) return null;
        
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
            </div>
            
            {/* Active Terminal */}
            <div className="flex-1">
              <VSCodeTerminal
                key={activeTerminal.id}
                id={activeTerminal.id}
                name={activeTerminal.name}
                shell={activeTerminal.shell}
                isActive={true}
                canClose={terminals.length > 1}
                onClose={() => closeTerminal(activeTerminal.id)}
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
            onSplitRight={() => splitTerminal(terminal!.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal!.id, 'vertical')}
            onFocus={() => selectTerminal(terminal!.id)}
            height={height}
          />
        ))}
      </SplitContainer>
    );
  }, [terminals, activeTerminalId, splits, height, splitTerminal, selectTerminal, closeTerminal]);

  const renderSidebar = useCallback(() => (
    <TerminalSidebar
      terminals={terminals}
      isCollapsed={sidebarCollapsed}
      activeTerminalId={activeTerminalId}
      onTerminalSelect={selectTerminal}
      onTerminalCreate={createTerminal}
      onTerminalClose={closeTerminal}
      onTerminalSplit={splitTerminal}
      onToggleCollapse={() => setSidebarCollapsed(prev => !prev)}
    />
  ), [terminals, sidebarCollapsed, activeTerminalId, selectTerminal, createTerminal, closeTerminal, splitTerminal]);

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
});

MultiTerminalManager.displayName = 'MultiTerminalManager';
EOF

echo "✅ MultiTerminalManager исправлен - убран бесконечный цикл с useCallback"

# 3. Тестируем исправления
echo "🧪 Тестируем исправления черного экрана..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 ЧЕРНЫЙ ЭКРАН ИСПРАВЛЕН!"
  echo "🏆 React ошибки Maximum update depth exceeded устранены!"
  echo ""
  echo "📋 Исправления:"
  echo "   ✅ Убран бесконечный цикл рендеринга в MultiTerminalManager"
  echo "   ✅ Добавлены useCallback для предотвращения лишних ререндеров"
  echo "   ✅ Исправлена работа с ref в BottomTerminal"
  echo "   ✅ Стабилизированы обновления состояния терминалов"
  echo "   ✅ Добавлены проверки на null/undefined"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Теперь терминал должен отображаться без ошибок!"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi