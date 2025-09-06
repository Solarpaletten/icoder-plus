#!/bin/bash

echo "🔧 РЕАЛЬНЫЙ ТЕРМИНАЛ НА XTERM.JS"
echo "==============================="
echo "Заменяем демо-терминал на полноценный с xterm.js + backend"

# ============================================================================
# 1. УСТАНОВИТЬ XTERM.JS И ЗАВИСИМОСТИ
# ============================================================================

echo "📦 Устанавливаем xterm.js..."
npm install xterm xterm-addon-fit xterm-addon-web-links

echo "✅ XTerm пакеты установлены"

# ============================================================================
# 2. СОЗДАТЬ TERMINAL SERVICE
# ============================================================================

cat > src/services/terminalService.ts << 'EOF'
interface TerminalMessage {
  type: 'command' | 'output' | 'error' | 'connect' | 'disconnect';
  data: string;
  timestamp?: number;
}

class TerminalService {
  private ws: WebSocket | null = null;
  private callbacks: Map<string, Function[]> = new Map();
  private isConnected = false;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;

  constructor() {
    this.initializeCallbacks();
  }

  private initializeCallbacks() {
    this.callbacks.set('data', []);
    this.callbacks.set('connect', []);
    this.callbacks.set('disconnect', []);
    this.callbacks.set('error', []);
  }

  async connect(): Promise<boolean> {
    try {
      // В продакшене используйте WSS и правильный URL
      const wsUrl = process.env.NODE_ENV === 'production' 
        ? 'wss://api.icoder.swapoil.de/terminal'
        : 'ws://localhost:3008/terminal';

      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.emit('connect', 'Connected to terminal server');
        console.log('Terminal WebSocket connected');
      };

      this.ws.onmessage = (event) => {
        try {
          const message: TerminalMessage = JSON.parse(event.data);
          this.emit('data', message.data);
        } catch (error) {
          // Fallback для простого текста
          this.emit('data', event.data);
        }
      };

      this.ws.onclose = () => {
        this.isConnected = false;
        this.emit('disconnect', 'Terminal connection closed');
        this.handleReconnect();
      };

      this.ws.onerror = (error) => {
        console.error('Terminal WebSocket error:', error);
        this.emit('error', 'Connection error');
      };

      return true;
    } catch (error) {
      console.error('Failed to connect to terminal:', error);
      this.emit('error', 'Failed to connect to terminal server');
      return false;
    }
  }

  private handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Attempting to reconnect... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
        this.connect();
      }, 2000 * this.reconnectAttempts);
    }
  }

  sendCommand(command: string) {
    if (this.ws && this.isConnected) {
      const message: TerminalMessage = {
        type: 'command',
        data: command,
        timestamp: Date.now()
      };
      this.ws.send(JSON.stringify(message));
    } else {
      this.emit('error', 'Terminal not connected');
    }
  }

  sendInput(input: string) {
    if (this.ws && this.isConnected) {
      this.ws.send(input);
    }
  }

  on(event: string, callback: Function) {
    if (!this.callbacks.has(event)) {
      this.callbacks.set(event, []);
    }
    this.callbacks.get(event)?.push(callback);
  }

  off(event: string, callback: Function) {
    const callbacks = this.callbacks.get(event);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  private emit(event: string, data: any) {
    const callbacks = this.callbacks.get(event);
    if (callbacks) {
      callbacks.forEach(callback => callback(data));
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.isConnected = false;
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}

export const terminalService = new TerminalService();
EOF

echo "✅ Terminal Service создан"

# ============================================================================
# 3. СОЗДАТЬ XTERM КОМПОНЕНТ
# ============================================================================

cat > src/components/XTermTerminal.tsx << 'EOF'
import { useEffect, useRef, useState } from 'react';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import { WebLinksAddon } from 'xterm-addon-web-links';
import 'xterm/css/xterm.css';
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

    // Создаем терминал
    const terminal = new Terminal({
      cursorBlink: true,
      fontSize: 13,
      fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, Inconsolata, "Roboto Mono", "Source Code Pro", monospace',
      theme: {
        background: '#1a1a1a',
        foreground: '#ffffff',
        cursor: '#ffffff',
        selection: '#3e4451',
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
      tabStopWidth: 4
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
    terminal.writeln('  help, ls, pwd, whoami, date, clear');
    terminal.write('\x1b[32m$ \x1b[0m');

    // Простой обработчик демо-команд
    terminal.onData((data) => {
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
    });
  };

  const executeDemoCommand = (command: string) => {
    if (!xtermRef.current) return;

    const terminal = xtermRef.current;

    switch (command.toLowerCase()) {
      case 'help':
        terminal.writeln('Available demo commands:');
        terminal.writeln('  help     - Show this help');
        terminal.writeln('  ls       - List files');
        terminal.writeln('  pwd      - Current directory');
        terminal.writeln('  whoami   - Current user');
        terminal.writeln('  date     - Current date');
        terminal.writeln('  clear    - Clear screen');
        break;
      case 'ls':
        terminal.writeln('src/  package.json  README.md  App.tsx');
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
      case 'clear':
        terminal.clear();
        break;
      case '':
        break;
      default:
        terminal.writeln(`bash: ${command}: command not found`);
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
EOF

echo "✅ XTerm компонент создан"

# ============================================================================
# 4. ОБНОВИТЬ Terminal.tsx ДЛЯ ИСПОЛЬЗОВАНИЯ XTERM
# ============================================================================

cat > src/components/Terminal.tsx << 'EOF'
import { XTermTerminal } from './XTermTerminal';

interface TerminalProps {
  isVisible?: boolean;
  height?: number;
}

export function Terminal({ isVisible = true, height = 200 }: TerminalProps) {
  return <XTermTerminal isVisible={isVisible} height={height} />;
}
EOF

echo "✅ Terminal.tsx обновлен для XTerm"

# ============================================================================
# 5. ОБНОВИТЬ BottomTerminal ДЛЯ ПЕРЕДАЧИ ПАРАМЕТРОВ
# ============================================================================

cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import { useState, useRef } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2, Terminal as TerminalIcon } from 'lucide-react';
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

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
    const startY = e.clientY;
    const startHeight = height;

    const handleMouseMove = (ev: MouseEvent) => {
      const deltaY = startY - ev.clientY;
      const newHeight = Math.max(150, Math.min(600, startHeight + deltaY));
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
      onResize(250);
      setIsMaximized(false);
    } else {
      onResize(500);
      setIsMaximized(true);
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
        <Terminal isVisible={!isCollapsed} height={height} />
      </div>
    </div>
  );
}
EOF

echo "✅ BottomTerminal.tsx обновлен"

# ============================================================================
# 6. ОБНОВИТЬ VITE CONFIG ДЛЯ XTERM CSS
# ============================================================================

if [ ! -f "vite.config.ts" ]; then
  cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  css: {
    preprocessorOptions: {
      css: {
        additionalData: `@import 'xterm/css/xterm.css';`
      }
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3008',
        changeOrigin: true
      },
      '/terminal': {
        target: 'ws://localhost:3008',
        ws: true
      }
    }
  }
})
EOF
  echo "✅ Vite config создан с поддержкой XTerm"
fi

# ============================================================================
# 7. ТЕСТИРОВАТЬ СБОРКУ
# ============================================================================

echo "🧪 Тестируем XTerm терминал..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ XTerm терминал готов!"
    echo "🎯 Функциональность:"
    echo "   • Настоящий терминал с xterm.js"
    echo "   • Подключение к backend через WebSocket"
    echo "   • Fallback в demo режим при отсутствии backend"
    echo "   • Индикатор статуса подключения"
    echo "   • Автофокус и автоскролл"
    echo "   • Resize, maximize, collapse как раньше"
    echo ""
    echo "📡 Для полной функциональности нужно:"
    echo "   1. Запустить backend с WebSocket поддержкой"
    echo "   2. Или использовать demo режим"
else
    echo "❌ Ошибки в сборке - проверьте консоль"
fi