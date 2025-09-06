import { useEffect, useRef, useState } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { WebLinksAddon } from '@xterm/addon-web-links';
import '@xterm/xterm/css/xterm.css';
import { terminalService } from '../services/terminalService';

interface XTermTerminalProps {
  isVisible: boolean;
  height: number;
}

export function XTermTerminal({ isVisible, height }: XTermTerminalProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const xtermRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<'connecting' | 'connected' | 'disconnected' | 'error'>('disconnected');

  useEffect(() => {
    if (!terminalRef.current || !isVisible) return;

    // Создаем терминал с исправленной темой
    const terminal = new Terminal({
      cursorBlink: true,
      fontSize: 13,
      fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, Inconsolata, "Roboto Mono", "Source Code Pro", monospace',
      theme: {
        background: '#1a1a1a',
        foreground: '#ffffff',
        cursor: '#ffffff',
        // Убрали selection - его нет в новом API
        black: '#1e1e1e',
        red: '#f56565',
        green: '#48bb78',
        yellow: '#ed8936',
        blue: '#4299e1',
        magenta: '#9f7aea',
        cyan: '#38b2ac',
        white: '#f7fafc',
        brightBlack: '#2d3748',
        brightRed: '#feb2b2',
        brightGreen: '#9ae6b4',
        brightYellow: '#fbd38d',
        brightBlue: '#90cdf4',
        brightMagenta: '#d6bcfa',
        brightCyan: '#81e6d9',
        brightWhite: '#ffffff'
      },
      scrollback: 1000,
      tabStopWidth: 4,
      allowProposedApi: true
    });

    // Создаем аддоны
    const fitAddon = new FitAddon();
    const webLinksAddon = new WebLinksAddon();

    // Подключаем аддоны
    terminal.loadAddon(fitAddon);
    terminal.loadAddon(webLinksAddon);

    // Открываем терминал
    terminal.open(terminalRef.current);

    // Сохраняем ссылки
    xtermRef.current = terminal;
    fitAddonRef.current = fitAddon;

    // Подгоняем размер
    fitAddon.fit();

    // Приветственное сообщение
    terminal.writeln('\x1b[1;34m🚀 iCoder Plus Terminal v2.0\x1b[0m');
    terminal.writeln('\x1b[32m💻 Connecting to backend...\x1b[0m');
    terminal.writeln('');

    // Обработчик ввода
    terminal.onData((data) => {
      if (terminalService.getConnectionStatus()) {
        terminalService.sendInput(data);
      }
    });

    // Подключение к сервису
    connectTerminal();

    return () => {
      terminal.dispose();
      xtermRef.current = null;
      fitAddonRef.current = null;
    };
  }, [isVisible]);

  const connectTerminal = async () => {
    setConnectionStatus('connecting');

    // Обработчики событий терминального сервиса
    terminalService.on('connect', (message: string) => {
      setConnectionStatus('connected');
      if (xtermRef.current) {
        xtermRef.current.writeln('\x1b[32m✅ Connected to terminal server\x1b[0m');
        xtermRef.current.writeln('\x1b[33mType commands and press Enter...\x1b[0m');
        xtermRef.current.writeln('');
      }
    });

    terminalService.on('disconnect', (message: string) => {
      setConnectionStatus('disconnected');
      if (xtermRef.current) {
        xtermRef.current.writeln('\x1b[31m❌ Terminal disconnected\x1b[0m');
      }
    });

    terminalService.on('error', (message: string) => {
      setConnectionStatus('error');
      if (xtermRef.current) {
        xtermRef.current.writeln(`\x1b[31m❌ Error: ${message}\x1b[0m`);
        xtermRef.current.writeln('\x1b[33m💡 Falling back to demo mode...\x1b[0m');
        startDemoMode();
      }
    });

    terminalService.on('data', (data: string) => {
      if (xtermRef.current) {
        xtermRef.current.write(data);
      }
    });

    // Попытка подключения
    const connected = await terminalService.connect();
    if (!connected) {
      setConnectionStatus('error');
    }
  };

  const startDemoMode = () => {
    if (!xtermRef.current) return;

    const terminal = xtermRef.current;
    let currentLine = '';

    terminal.writeln('');
    terminal.writeln('\x1b[36m📋 Demo Mode Commands:\x1b[0m');
    terminal.writeln('  help, ls, pwd, whoami, date, clear, status');
    terminal.write('\x1b[32m$ \x1b[0m');

    // Простой обработчик демо-команд
    const handleDemoData = (data: string) => {
      if (data === '\r') { // Enter
        terminal.writeln('');
        executeDemoCommand(currentLine.trim());
        currentLine = '';
        terminal.write('\x1b[32m$ \x1b[0m');
      } else if (data === '\u007f') { // Backspace
        if (currentLine.length > 0) {
          currentLine = currentLine.slice(0, -1);
          terminal.write('\b \b');
        }
      } else if (data >= ' ' && data <= '~') { // Printable characters
        currentLine += data;
        terminal.write(data);
      }
    };

    terminal.onData(handleDemoData);
  };

  const executeDemoCommand = (command: string) => {
    if (!xtermRef.current) return;

    const terminal = xtermRef.current;

    switch (command.toLowerCase()) {
      case 'help':
        terminal.writeln('\x1b[33mAvailable demo commands:\x1b[0m');
        terminal.writeln('  help     - Show this help');
        terminal.writeln('  ls       - List files');
        terminal.writeln('  pwd      - Current directory');
        terminal.writeln('  whoami   - Current user');
        terminal.writeln('  date     - Current date');
        terminal.writeln('  status   - Backend status');
        terminal.writeln('  clear    - Clear screen');
        break;
      case 'ls':
        terminal.writeln('\x1b[34msrc/\x1b[0m  package.json  README.md  App.tsx');
        break;
      case 'pwd':
        terminal.writeln('/workspace/icoder-plus');
        break;
      case 'whoami':
        terminal.writeln('developer');
        break;
      case 'date':
        terminal.writeln(new Date().toString());
        break;
      case 'status':
        terminal.writeln('\x1b[32m✅ Frontend: Running\x1b[0m');
        terminal.writeln('\x1b[33m⚠️  Backend: Demo Mode\x1b[0m');
        terminal.writeln('\x1b[34mℹ️  Terminal: XTerm.js v5\x1b[0m');
        break;
      case 'clear':
        terminal.clear();
        terminal.writeln('\x1b[36m📋 Demo Mode - Type "help" for commands\x1b[0m');
        break;
      case '':
        break;
      default:
        terminal.writeln(`\x1b[31mbash: ${command}: command not found\x1b[0m`);
        terminal.writeln('\x1b[33mType "help" for available commands\x1b[0m');
    }
  };

  // Подгонка размера при изменении высоты
  useEffect(() => {
    if (fitAddonRef.current && isVisible) {
      const timer = setTimeout(() => {
        fitAddonRef.current?.fit();
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [height, isVisible]);

  // Фокус при показе
  useEffect(() => {
    if (isVisible && xtermRef.current) {
      xtermRef.current.focus();
    }
  }, [isVisible]);

  return (
    <div className="h-full flex flex-col bg-gray-900">
      {/* Connection Status */}
      <div className="flex items-center justify-between px-3 py-1 bg-gray-800 border-b border-gray-700">
        <div className="flex items-center space-x-2">
          <div className={`w-2 h-2 rounded-full ${
            connectionStatus === 'connected' ? 'bg-green-400' :
            connectionStatus === 'connecting' ? 'bg-yellow-400' :
            connectionStatus === 'error' ? 'bg-orange-400' :
            'bg-red-400'
          }`} />
          <span className="text-xs text-gray-400">
            {connectionStatus === 'connected' ? 'Backend Connected' :
             connectionStatus === 'connecting' ? 'Connecting...' :
             connectionStatus === 'error' ? 'Demo Mode' :
             'Disconnected'}
          </span>
        </div>
        
        {connectionStatus === 'error' && (
          <button
            onClick={connectTerminal}
            className="text-xs text-blue-400 hover:text-blue-300"
          >
            Retry Connection
          </button>
        )}
      </div>

      {/* XTerm Container */}
      <div 
        ref={terminalRef} 
        className="flex-1 p-2"
        style={{ height: `${height - 60}px` }}
      />
    </div>
  );
}
