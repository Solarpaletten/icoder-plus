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
