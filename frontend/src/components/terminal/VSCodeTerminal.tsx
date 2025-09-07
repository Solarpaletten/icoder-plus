import React, { useState, useEffect, useRef } from 'react';
import { X, MoreHorizontal, Plus, Square, Copy } from 'lucide-react';

interface VSCodeTerminalProps {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell';
  isActive: boolean;
  canClose: boolean;
  onClose?: () => void;
  onSplitRight?: () => void;
  onSplitDown?: () => void;
  onNewTerminal?: () => void;
  onFocus?: () => void;
  height?: number;
}

export const VSCodeTerminal: React.FC<VSCodeTerminalProps> = ({
  id,
  name,
  shell,
  isActive,
  canClose,
  onClose,
  onSplitRight,
  onSplitDown,
  onNewTerminal,
  onFocus,
  height = 200
}) => {
  const [history, setHistory] = useState<string[]>([
    `Welcome to ${shell} terminal!`,
    ''
  ]);
  const [input, setInput] = useState('');
  const [currentPath, setCurrentPath] = useState('~/projects/icoder-plus');
  const [wsConnected, setWsConnected] = useState(false);
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [showMenu, setShowMenu] = useState(false);
  const terminalRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const getShellIcon = () => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      default: return '📟';
    }
  };

  const getShellPrompt = () => {
    switch (shell) {
      case 'bash': return `${currentPath}$`;
      case 'zsh': return `${currentPath} %`;
      case 'powershell': return `PS ${currentPath}>`;
      default: return `${currentPath}$`;
    }
  };

  // WebSocket connection
  useEffect(() => {
    const connectWebSocket = () => {
      try {
        const websocket = new WebSocket('ws://localhost:3000/terminal');
        
        websocket.onopen = () => {
          setWsConnected(true);
          setHistory(prev => [...prev, `🟢 Connected to ${shell} backend`]);
        };

        websocket.onmessage = (event) => {
          setHistory(prev => [...prev, event.data]);
        };

        websocket.onclose = () => {
          setWsConnected(false);
          setHistory(prev => [...prev, `🔴 Disconnected - using ${shell} demo mode`]);
        };

        setWs(websocket);
      } catch (error) {
        setWsConnected(false);
      }
    };

    connectWebSocket();
    return () => ws?.close();
  }, [shell]);

  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [history]);

  const handleTerminalClick = () => {
    onFocus?.();
    inputRef.current?.focus();
  };

  const executeCommand = (command: string) => {
    const trimmedCommand = command.trim();
    
    if (trimmedCommand && !commandHistory.includes(trimmedCommand)) {
      setCommandHistory(prev => [trimmedCommand, ...prev].slice(0, 50));
    }
    setHistoryIndex(-1);
    
    setHistory(prev => [...prev, `${getShellPrompt()} ${trimmedCommand}`]);

    if (wsConnected && ws) {
      ws.send(trimmedCommand + '\r');
    } else {
      handleDemoCommand(trimmedCommand);
    }

    setInput('');
  };

  const handleDemoCommand = (command: string) => {
    const cmd = command.toLowerCase();
    setTimeout(() => {
      switch (cmd) {
        case 'help':
          setHistory(prev => [...prev, 
            `${shell.toUpperCase()} Help:`,
            '  help    - Show this help',
            '  clear   - Clear terminal',
            '  ls      - List files',
            '  pwd     - Current directory',
            '  whoami  - Current user',
            '  date    - Current date/time',
            '  echo    - Print message',
            ''
          ]);
          break;
        
        case 'clear':
          setHistory([`Welcome to ${shell} terminal!`, '']);
          break;
        
        case 'ls':
          setHistory(prev => [...prev, 
            'src/',
            'components/',
            'hooks/',
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
          setHistory(prev => [...prev, new Date().toLocaleString(), '']);
          break;
        
        case '':
          setHistory(prev => [...prev, '']);
          break;
        
        default:
          if (cmd.startsWith('echo ')) {
            const message = command.slice(5);
            setHistory(prev => [...prev, message, '']);
          } else {
            setHistory(prev => [...prev, `${shell}: command not found: ${command}`, '']);
          }
      }
    }, 100);
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
        setHistoryIndex(historyIndex - 1);
        setInput(commandHistory[historyIndex - 1] || '');
      } else {
        setHistoryIndex(-1);
        setInput('');
      }
    } else if (e.key === 'Tab') {
      e.preventDefault();
      const commands = ['help', 'clear', 'ls', 'pwd', 'whoami', 'date', 'echo'];
      const match = commands.find(cmd => cmd.startsWith(input.toLowerCase()));
      if (match) setInput(match);
    }
  };

  return (
    <div className={`flex flex-col h-full bg-black border border-gray-700 ${
      isActive ? 'border-blue-500' : ''
    }`}>
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-2 flex-shrink-0">
        <div className="flex items-center gap-2">
          <span className="text-xs">{getShellIcon()}</span>
          <span className="text-xs text-gray-300 font-medium">{name}</span>
          <div className={`w-1.5 h-1.5 rounded-full ${wsConnected ? 'bg-green-500' : 'bg-red-500'}`} />
        </div>
        
        <div className="flex items-center gap-1 relative">
          <button
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            onClick={() => setShowMenu(!showMenu)}
          >
            <MoreHorizontal size={12} />
          </button>
          
          {canClose && (
            <button
              className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
              onClick={onClose}
            >
              <X size={12} />
            </button>
          )}

          {/* Dropdown Menu */}
          {showMenu && (
            <>
              <div 
                className="fixed inset-0 z-30" 
                onClick={() => setShowMenu(false)}
              />
              <div className="absolute right-0 top-full mt-1 bg-gray-800 border border-gray-600 rounded shadow-lg z-40 min-w-[140px]">
                <div className="py-1">
                  <button
                    className="w-full text-left px-3 py-1.5 text-xs hover:bg-gray-700 flex items-center gap-2"
                    onClick={() => { onNewTerminal?.(); setShowMenu(false); }}
                  >
                    <Plus size={10} />
                    New Terminal
                  </button>
                  <button
                    className="w-full text-left px-3 py-1.5 text-xs hover:bg-gray-700 flex items-center gap-2"
                    onClick={() => { onSplitRight?.(); setShowMenu(false); }}
                  >
                    <Square size={10} className="rotate-90" />
                    Split Right
                  </button>
                  <button
                    className="w-full text-left px-3 py-1.5 text-xs hover:bg-gray-700 flex items-center gap-2"
                    onClick={() => { onSplitDown?.(); setShowMenu(false); }}
                  >
                    <Square size={10} />
                    Split Down
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Terminal Content */}
      <div 
        className="flex-1 overflow-hidden cursor-text"
        onClick={handleTerminalClick}
      >
        <div 
          ref={terminalRef}
          className="h-full overflow-y-auto p-2 scrollbar-thin scrollbar-thumb-gray-600"
          style={{
            fontFamily: 'Consolas, "Courier New", monospace',
            fontSize: '12px',
            lineHeight: '1.5'
          }}
        >
          {history.map((line, index) => (
            <div key={index} className="text-gray-100 whitespace-pre-wrap">
              {line}
            </div>
          ))}
          
          {/* Input Line */}
          <div className="flex items-center mt-1">
            <span className="text-green-400 mr-1" style={{ fontSize: '12px' }}>
              {getShellPrompt()}
            </span>
            <input
              ref={inputRef}
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              onFocus={onFocus}
              className="flex-1 bg-transparent outline-none text-gray-100"
              style={{ 
                fontFamily: 'inherit',
                fontSize: '12px'
              }}
              autoFocus={isActive}
              spellCheck={false}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
