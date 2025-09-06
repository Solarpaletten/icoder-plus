import { useState, useRef, useEffect } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2, Terminal as TerminalIcon, X } from 'lucide-react';

interface TerminalLine {
  type: 'command' | 'output' | 'error' | 'info';
  content: string;
  timestamp?: Date;
}

interface RealTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
  height: number;
  onResize: (height: number) => void;
}

export function RealTerminal({ isCollapsed, onToggle, height, onResize }: RealTerminalProps) {
  const [lines, setLines] = useState<TerminalLine[]>([
    { type: 'info', content: '🚀 iCoder Plus Terminal v2.0' },
    { type: 'info', content: '💻 Backend: api.icoder.swapoil.de - Online' },
    { type: 'info', content: 'Ready for development...' },
    { type: 'output', content: '' }
  ]);
  
  const [currentCommand, setCurrentCommand] = useState('');
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [isDragging, setIsDragging] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  
  const inputRef = useRef<HTMLInputElement>(null);
  const terminalRef = useRef<HTMLDivElement>(null);

  // Auto-focus input when not collapsed
  useEffect(() => {
    if (!isCollapsed && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isCollapsed]);

  // Scroll to bottom when new lines added
  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [lines]);

  const executeCommand = (cmd: string) => {
    const trimmedCmd = cmd.trim();
    if (!trimmedCmd) return;

    // Add command to history
    setCommandHistory(prev => [...prev, trimmedCmd]);
    setHistoryIndex(-1);

    // Add command line
    setLines(prev => [...prev, { type: 'command', content: `$ ${trimmedCmd}` }]);

    // Process command
    let output: TerminalLine[] = [];
    
    switch (trimmedCmd.toLowerCase()) {
      case 'help':
        output = [
          { type: 'output', content: 'Available commands:' },
          { type: 'output', content: '  help     - Show this help message' },
          { type: 'output', content: '  clear    - Clear terminal' },
          { type: 'output', content: '  ls       - List files' },
          { type: 'output', content: '  pwd      - Current directory' },
          { type: 'output', content: '  whoami   - Current user' },
          { type: 'output', content: '  date     - Current date' },
          { type: 'output', content: '  status   - Backend status' },
          { type: 'output', content: '  build    - Build project' },
          { type: 'output', content: '  dev      - Start dev server' }
        ];
        break;
        
      case 'clear':
        setLines([{ type: 'output', content: '' }]);
        return;
        
      case 'ls':
        output = [
          { type: 'output', content: 'src/' },
          { type: 'output', content: 'App.tsx' },
          { type: 'output', content: 'README.md' },
          { type: 'output', content: 'package.json' }
        ];
        break;
        
      case 'pwd':
        output = [{ type: 'output', content: '/workspace/icoder-plus' }];
        break;
        
      case 'whoami':
        output = [{ type: 'output', content: 'developer' }];
        break;
        
      case 'date':
        output = [{ type: 'output', content: new Date().toString() }];
        break;
        
      case 'status':
        output = [
          { type: 'info', content: '✅ Frontend: Running' },
          { type: 'info', content: '✅ Backend: api.icoder.swapoil.de - Online' },
          { type: 'info', content: '✅ TypeScript: Clean Architecture Loaded' }
        ];
        break;
        
      case 'build':
        output = [
          { type: 'info', content: 'Building project...' },
          { type: 'output', content: '> tsc && vite build' },
          { type: 'info', content: '✅ Build completed successfully' }
        ];
        break;
        
      case 'dev':
        output = [
          { type: 'info', content: 'Starting development server...' },
          { type: 'output', content: '> npm run dev' },
          { type: 'info', content: '🚀 Dev server running on http://localhost:5173' }
        ];
        break;
        
      default:
        output = [{ type: 'error', content: `Command not found: ${trimmedCmd}. Type 'help' for available commands.` }];
    }

    // Add output lines
    setLines(prev => [...prev, ...output, { type: 'output', content: '' }]);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      executeCommand(currentCommand);
      setCurrentCommand('');
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (commandHistory.length > 0) {
        const newIndex = historyIndex === -1 ? commandHistory.length - 1 : Math.max(0, historyIndex - 1);
        setHistoryIndex(newIndex);
        setCurrentCommand(commandHistory[newIndex] || '');
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (historyIndex !== -1) {
        const newIndex = historyIndex + 1;
        if (newIndex >= commandHistory.length) {
          setHistoryIndex(-1);
          setCurrentCommand('');
        } else {
          setHistoryIndex(newIndex);
          setCurrentCommand(commandHistory[newIndex] || '');
        }
      }
    }
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
    const startY = e.clientY;
    const startHeight = height;

    const handleMouseMove = (ev: MouseEvent) => {
      const deltaY = startY - ev.clientY;
      const newHeight = Math.max(100, Math.min(600, startHeight + deltaY));
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

  const getLineColor = (type: TerminalLine['type']) => {
    switch (type) {
      case 'command': return 'text-blue-400';
      case 'error': return 'text-red-400';
      case 'info': return 'text-green-400';
      default: return 'text-gray-300';
    }
  };

  if (isCollapsed) {
    return (
      <div 
        className="h-8 bg-gray-800 border-t border-gray-700 flex items-center justify-between px-3 cursor-pointer hover:bg-gray-700 transition-colors"
        onClick={onToggle}
      >
        <div className="flex items-center space-x-2">
          <TerminalIcon size={14} className="text-gray-400" />
          <span className="text-xs text-gray-300 font-medium">TERMINAL</span>
        </div>
        <ChevronUp size={12} className="text-gray-400" />
      </div>
    );
  }

  return (
    <div 
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
        <div className="flex items-center space-x-2">
          <TerminalIcon size={14} className="text-gray-300" />
          <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Terminal</span>
        </div>
        
        <div className="flex items-center space-x-1">
          <button
            onClick={() => setLines([{ type: 'output', content: '' }])}
            className="px-2 py-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white text-xs"
            title="Clear terminal"
          >
            Clear
          </button>
          
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
      <div 
        ref={terminalRef}
        className="flex-1 overflow-y-auto p-2 font-mono text-sm bg-gray-900"
        onClick={() => inputRef.current?.focus()}
      >
        {lines.map((line, index) => (
          <div key={index} className={`${getLineColor(line.type)} leading-relaxed`}>
            {line.content}
          </div>
        ))}
        
        {/* Current input line */}
        <div className="flex items-center text-blue-400">
          <span className="mr-2">$</span>
          <input
            ref={inputRef}
            type="text"
            value={currentCommand}
            onChange={(e) => setCurrentCommand(e.target.value)}
            onKeyDown={handleKeyDown}
            className="flex-1 bg-transparent outline-none text-gray-300 caret-blue-400"
            placeholder="Type command... (try 'help')"
            autoComplete="off"
          />
        </div>
      </div>
    </div>
  );
}
