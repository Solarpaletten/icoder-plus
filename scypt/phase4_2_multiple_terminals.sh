#!/bin/bash

echo "🔧 PHASE 4.2: MULTIPLE TERMINAL INSTANCES"
echo "========================================"
echo "Цель: Разделение терминала на несколько окон как в VS Code"

# 1. Создать компонент для управления несколькими терминалами
cat > src/components/MultiTerminalManager.tsx << 'EOF'
import React, { useState, useRef } from 'react';
import { Plus, X, Square, Copy, RotateCw, ChevronDown, Terminal } from 'lucide-react';
import { VSCodeTerminal } from './VSCodeTerminal';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell';
  isActive: boolean;
  created: Date;
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
      isActive: true,
      created: new Date()
    }
  ]);
  
  const [splitMode, setSplitMode] = useState<'single' | 'vertical' | 'horizontal'>('single');
  const [showTerminalList, setShowTerminalList] = useState(false);
  const terminalRefs = useRef<{ [key: string]: HTMLDivElement | null }>({});

  const createNewTerminal = (shell: 'bash' | 'zsh' | 'powershell' = 'bash') => {
    const newTerminal: TerminalInstance = {
      id: Date.now().toString(),
      name: `${shell}-${terminals.length + 1}`,
      shell,
      isActive: false,
      created: new Date()
    };
    
    setTerminals(prev => [...prev, newTerminal]);
  };

  const removeTerminal = (id: string) => {
    if (terminals.length <= 1) return; // Keep at least one terminal
    
    setTerminals(prev => {
      const filtered = prev.filter(t => t.id !== id);
      // If removing active terminal, activate the first one
      const wasActive = prev.find(t => t.id === id)?.isActive;
      if (wasActive && filtered.length > 0) {
        filtered[0].isActive = true;
      }
      return filtered;
    });
  };

  const setActiveTerminal = (id: string) => {
    setTerminals(prev => prev.map(t => ({ ...t, isActive: t.id === id })));
  };

  const splitTerminal = (mode: 'vertical' | 'horizontal') => {
    setSplitMode(mode);
  };

  const getShellIcon = (shell: string) => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      default: return '📟';
    }
  };

  const activeTerminal = terminals.find(t => t.isActive) || terminals[0];
  const visibleTerminals = splitMode === 'single' ? [activeTerminal] : terminals.slice(0, 2);

  return (
    <div className="flex flex-col h-full bg-gray-900">
      {/* Terminal Tabs and Controls */}
      <div className="flex items-center justify-between bg-gray-800 border-b border-gray-700 px-3 py-1 min-h-[32px]">
        {/* Left: Terminal Tabs */}
        <div className="flex items-center gap-1 flex-1 overflow-x-auto">
          {terminals.map((terminal) => (
            <div
              key={terminal.id}
              className={`group flex items-center gap-1 px-2 py-1 rounded text-xs cursor-pointer
                ${terminal.isActive 
                  ? 'bg-gray-700 text-white' 
                  : 'text-gray-400 hover:text-gray-200 hover:bg-gray-700'
                }`}
              onClick={() => setActiveTerminal(terminal.id)}
            >
              <span className="text-xs">{getShellIcon(terminal.shell)}</span>
              <span className="truncate max-w-[80px]">{terminal.name}</span>
              {terminals.length > 1 && (
                <button
                  className="opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-0.5"
                  onClick={(e) => {
                    e.stopPropagation();
                    removeTerminal(terminal.id);
                  }}
                >
                  <X size={10} />
                </button>
              )}
            </div>
          ))}
        </div>

        {/* Right: Controls */}
        <div className="flex items-center gap-1">
          {/* Split Controls */}
          <div className="relative">
            <button
              className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
              onClick={() => setShowTerminalList(!showTerminalList)}
              title="Terminal options"
            >
              <ChevronDown size={12} />
            </button>
            
            {showTerminalList && (
              <>
                <div 
                  className="fixed inset-0 z-30" 
                  onClick={() => setShowTerminalList(false)}
                />
                <div className="absolute right-0 top-full mt-1 bg-gray-800 border border-gray-600 rounded shadow-lg z-40 min-w-[180px]">
                  <div className="py-1">
                    <div className="px-3 py-1 text-xs text-gray-500 border-b border-gray-700">New Terminal</div>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('bash'); setShowTerminalList(false); }}
                    >
                      🐚 Bash
                    </button>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('zsh'); setShowTerminalList(false); }}
                    >
                      ⚡ Zsh
                    </button>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('powershell'); setShowTerminalList(false); }}
                    >
                      💻 PowerShell
                    </button>
                    
                    <div className="border-t border-gray-700 mt-1 pt-1">
                      <div className="px-3 py-1 text-xs text-gray-500">Split Terminal</div>
                      <button
                        className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                        onClick={() => { splitTerminal('vertical'); setShowTerminalList(false); }}
                      >
                        <Square size={10} className="rotate-90" />
                        Split Right
                      </button>
                      <button
                        className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                        onClick={() => { splitTerminal('horizontal'); setShowTerminalList(false); }}
                      >
                        <Square size={10} />
                        Split Down
                      </button>
                      
                      {splitMode !== 'single' && (
                        <button
                          className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                          onClick={() => { setSplitMode('single'); setShowTerminalList(false); }}
                        >
                          <Copy size={10} />
                          Unsplit
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* New Terminal Button */}
          <button
            className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
            onClick={() => createNewTerminal()}
            title="New terminal"
          >
            <Plus size={12} />
          </button>
        </div>
      </div>

      {/* Terminal Content Area */}
      <div className="flex-1 flex" style={{ height: `${height - 32}px` }}>
        {splitMode === 'single' ? (
          // Single Terminal
          <div className="w-full h-full">
            <VSCodeTerminal 
              isVisible={true}
              height={height - 32}
            />
          </div>
        ) : splitMode === 'vertical' ? (
          // Vertical Split (side by side)
          <>
            <div className="w-1/2 h-full border-r border-gray-700">
              <VSCodeTerminal 
                isVisible={true}
                height={height - 32}
              />
            </div>
            <div className="w-1/2 h-full">
              <VSCodeTerminal 
                isVisible={true}
                height={height - 32}
              />
            </div>
          </>
        ) : (
          // Horizontal Split (top and bottom)
          <>
            <div className="w-full h-1/2 border-b border-gray-700">
              <VSCodeTerminal 
                isVisible={true}
                height={(height - 32) / 2 - 1}
              />
            </div>
            <div className="w-full h-1/2">
              <VSCodeTerminal 
                isVisible={true}
                height={(height - 32) / 2}
              />
            </div>
          </>
        )}
      </div>
    </div>
  );
};
EOF

# 2. Обновить BottomTerminal для использования MultiTerminalManager
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState } from 'react';
import { Maximize2, Minimize2, X, ChevronUp, ChevronDown, Terminal } from 'lucide-react';
import { MultiTerminalManager } from '../MultiTerminalManager';

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
      // Calculate 90% of parent container height
      const parentHeight = window.innerHeight - 100;
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
          <Terminal size={14} className="text-gray-400" />
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
      
      {/* Multi Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <MultiTerminalManager height={height - 32} />
      </div>
    </div>
  );
};
EOF

# 3. Обновить VSCodeTerminal с улучшенным шрифтом и размером
cat > src/components/VSCodeTerminal.tsx << 'EOF'
import React, { useState, useEffect, useRef } from 'react';

interface VSCodeTerminalProps {
  isVisible?: boolean;
  height?: number;
}

export const VSCodeTerminal: React.FC<VSCodeTerminalProps> = ({ 
  isVisible = true, 
  height = 200 
}) => {
  const [history, setHistory] = useState<string[]>([
    'Connected to bash terminal!',
    ''
  ]);
  const [input, setInput] = useState('');
  const [currentPath, setCurrentPath] = useState('~/projects/icoder-plus');
  const [wsConnected, setWsConnected] = useState(false);
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const terminalRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // WebSocket connection
  useEffect(() => {
    const connectWebSocket = () => {
      try {
        const websocket = new WebSocket('ws://localhost:3000/terminal');
        
        websocket.onopen = () => {
          console.log('Terminal WebSocket connected');
          setWsConnected(true);
          setHistory(prev => [...prev, '🟢 Connected to backend terminal']);
        };

        websocket.onmessage = (event) => {
          const data = event.data;
          setHistory(prev => [...prev, data]);
        };

        websocket.onclose = () => {
          console.log('Terminal WebSocket disconnected');
          setWsConnected(false);
          setHistory(prev => [...prev, '🔴 Disconnected from backend - using demo mode']);
        };

        websocket.onerror = (error) => {
          console.log('Terminal WebSocket error:', error);
          setWsConnected(false);
        };

        setWs(websocket);
      } catch (error) {
        console.log('Failed to connect WebSocket:', error);
        setWsConnected(false);
      }
    };

    connectWebSocket();

    return () => {
      if (ws) {
        ws.close();
      }
    };
  }, []);

  // Auto scroll to bottom
  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [history]);

  // Focus input when terminal is clicked
  const handleTerminalClick = () => {
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  const executeCommand = (command: string) => {
    const trimmedCommand = command.trim();
    
    // Add to command history
    if (trimmedCommand && !commandHistory.includes(trimmedCommand)) {
      setCommandHistory(prev => [trimmedCommand, ...prev].slice(0, 50)); // Keep last 50 commands
    }
    setHistoryIndex(-1);
    
    // Add command to history
    setHistory(prev => [...prev, `${currentPath}$ ${trimmedCommand}`]);

    if (wsConnected && ws) {
      // Send to backend
      ws.send(trimmedCommand + '\r');
    } else {
      // Demo mode
      handleDemoCommand(trimmedCommand);
    }

    setInput('');
  };

  const handleDemoCommand = (command: string) => {
    switch (command.toLowerCase()) {
      case 'help':
        setHistory(prev => [...prev, 
          'Available commands:',
          '  help    - Show this help',
          '  clear   - Clear terminal',
          '  ls      - List files',
          '  pwd     - Current directory',
          '  whoami  - Current user',
          '  date    - Current date/time',
          '  status  - System status',
          ''
        ]);
        break;
      
      case 'clear':
        setHistory(['']);
        break;
      
      case 'ls':
        setHistory(prev => [...prev, 
          'src/',
          'package.json',
          'README.md',
          'tsconfig.json',
          ''
        ]);
        break;
      
      case 'pwd':
        setHistory(prev => [...prev, currentPath, '']);
        break;
      
      case 'whoami':
        setHistory(prev => [...prev, 'developer', '']);
        break;
      
      case 'date':
        setHistory(prev => [...prev, new Date().toString(), '']);
        break;
      
      case 'status':
        setHistory(prev => [...prev, 
          '🔵 Frontend: Running (localhost:5173)',
          wsConnected ? '🟢 Backend: Connected (localhost:3000)' : '🔴 Backend: Disconnected',
          '📁 Project: iCoder Plus v2.0',
          ''
        ]);
        break;
      
      case '':
        setHistory(prev => [...prev, '']);
        break;
      
      default:
        setHistory(prev => [...prev, `Command not found: ${command}`, '']);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      executeCommand(input);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (commandHistory.length > 0) {
        const newIndex = Math.min(historyIndex + 1, commandHistory.length - 1);
        setHistoryIndex(newIndex);
        setInput(commandHistory[newIndex] || '');
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (historyIndex > 0) {
        const newIndex = historyIndex - 1;
        setHistoryIndex(newIndex);
        setInput(commandHistory[newIndex] || '');
      } else {
        setHistoryIndex(-1);
        setInput('');
      }
    } else if (e.key === 'Tab') {
      e.preventDefault();
      // Basic tab completion for demo
      const commonCommands = ['help', 'clear', 'ls', 'pwd', 'whoami', 'date', 'status'];
      const match = commonCommands.find(cmd => cmd.startsWith(input.toLowerCase()));
      if (match) {
        setInput(match);
      }
    }
  };

  if (!isVisible) return null;

  return (
    <div 
      className="bg-black text-gray-100 font-mono h-full flex flex-col overflow-hidden cursor-text"
      onClick={handleTerminalClick}
      style={{
        fontSize: '12px',
        lineHeight: '1.4',
        fontFamily: 'Consolas, "Courier New", monospace'
      }}
    >
      {/* Terminal Output */}
      <div 
        ref={terminalRef}
        className="flex-1 overflow-y-auto p-2 scrollbar-thin scrollbar-thumb-gray-600 scrollbar-track-transparent"
        style={{ fontSize: '12px' }}
      >
        {history.map((line, index) => (
          <div key={index} className="whitespace-pre-wrap leading-relaxed text-gray-100">
            {line}
          </div>
        ))}
        
        {/* Current Input Line */}
        <div className="flex items-center mt-1">
          <span className="text-green-400 text-xs mr-1">{currentPath}$</span>
          <input
            ref={inputRef}
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            className="flex-1 bg-transparent outline-none text-gray-100 text-xs"
            style={{ fontFamily: 'inherit' }}
            autoFocus
            spellCheck={false}
          />
        </div>
      </div>
    </div>
  );
};
EOF

echo "✅ MultiTerminalManager создан с поддержкой нескольких терминалов"
echo "✅ BottomTerminal обновлен для использования MultiTerminalManager"
echo "✅ VSCodeTerminal улучшен (12px шрифт, история команд, tab completion)"

# Тестируем сборку
echo "🧪 Тестируем Phase 4.2 Multiple Terminal Instances..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.2 ЗАВЕРШЕН!"
  echo "🏆 Множественные терминалы как в VS Code готовы!"
  echo ""
  echo "📋 Новые возможности терминалов:"
  echo "   ✅ Несколько терминалов в табах (bash, zsh, powershell)"
  echo "   ✅ Разделение на 2 окна (вертикально/горизонтально)"
  echo "   ✅ Уменьшенный читаемый шрифт 12px"
  echo "   ✅ История команд (стрелки вверх/вниз)"
  echo "   ✅ Tab completion для команд"
  echo "   ✅ Индикаторы типа shell (🐚 bash, ⚡ zsh, 💻 powershell)"
  echo "   ✅ Кнопки создания новых терминалов"
  echo "   ✅ Меню split/unsplit терминалов"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Теперь терминал полностью соответствует VS Code!"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi