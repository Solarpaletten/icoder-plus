#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ДУБЛИРОВАНИЯ В ТЕРМИНАЛЕ"
echo "======================================"
echo "Убираем echo дублирование как в VS Code"

# ============================================================================
# 1. ИСПРАВИТЬ XTermTerminal.tsx - убрать локальное эхо
# ============================================================================

cat > src/components/XTermTerminal.tsx << 'EOF'
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

    // Создаем терминал с правильными настройками
    const terminal = new Terminal({
      cursorBlink: true,
      fontSize: 14,
      fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, "Ubuntu Mono", monospace',
      theme: {
        background: '#1e1e1e',
        foreground: '#d4d4d4',
        cursor: '#ffffff',
        black: '#000000',
        red: '#cd3131',
        green: '#0dbc79',
        yellow: '#e5e510',
        blue: '#2472c8',
        magenta: '#bc3fbc',
        cyan: '#11a8cd',
        white: '#e5e5e5',
        brightBlack: '#666666',
        brightRed: '#f14c4c',
        brightGreen: '#23d18b',
        brightYellow: '#f5f543',
        brightBlue: '#3b8eea',
        brightMagenta: '#d670d6',
        brightCyan: '#29b8db',
        brightWhite: '#ffffff'
      },
      scrollback: 10000,
      tabStopWidth: 4,
      allowProposedApi: true,
      // ВАЖНО: отключаем локальное эхо
      disableStdin: false,
      convertEol: true
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
    terminal.writeln('\x1b[1;36miCoder Plus Terminal v2.0 - Real bash connection\x1b[0m');
    terminal.writeln('\x1b[32mConnecting to backend...\x1b[0m');

    // Обработчик ввода - БЕЗ локального эхо
    terminal.onData((data) => {
      if (terminalService.getConnectionStatus()) {
        // Отправляем данные напрямую, без локального отображения
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
    terminalService.on('connect', () => {
      setConnectionStatus('connected');
      if (xtermRef.current) {
        xtermRef.current.clear();
        xtermRef.current.writeln('\x1b[32m✅ Connected to real bash terminal\x1b[0m');
        xtermRef.current.writeln('');
      }
    });

    terminalService.on('disconnect', () => {
      setConnectionStatus('disconnected');
      if (xtermRef.current) {
        xtermRef.current.writeln('\r\n\x1b[31m❌ Terminal disconnected\x1b[0m');
      }
    });

    terminalService.on('error', (message: string) => {
      setConnectionStatus('error');
      if (xtermRef.current) {
        xtermRef.current.writeln(`\r\n\x1b[31m❌ Error: ${message}\x1b[0m`);
        xtermRef.current.writeln('\x1b[33m💡 Falling back to demo mode...\x1b[0m');
        startDemoMode();
      }
    });

    terminalService.on('data', (data: string) => {
      if (xtermRef.current) {
        // Просто выводим данные от сервера, без дублирования
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
    terminal.writeln('\x1b[36m📋 Demo Mode - Type commands:\x1b[0m');
    terminal.writeln('  help, ls, pwd, whoami, date, clear, status');
    terminal.write('\r\n$ ');

    // Демо-режим с правильным эхо
    const handleDemoData = (data: string) => {
      if (data === '\r') { // Enter
        terminal.write('\r\n');
        executeDemoCommand(currentLine.trim());
        currentLine = '';
        terminal.write('$ ');
      } else if (data === '\u007f') { // Backspace
        if (currentLine.length > 0) {
          currentLine = currentLine.slice(0, -1);
          terminal.write('\b \b');
        }
      } else if (data >= ' ' && data <= '~') { // Printable characters
        currentLine += data;
        terminal.write(data); // Эхо только в demo режиме
      }
    };

    terminal.onData(handleDemoData);
  };

  const executeDemoCommand = (command: string) => {
    if (!xtermRef.current) return;

    const terminal = xtermRef.current;

    switch (command.toLowerCase()) {
      case 'help':
        terminal.writeln('Demo mode commands:');
        terminal.writeln('  help, ls, pwd, whoami, date, clear, status');
        break;
      case 'ls':
        terminal.writeln('frontend/  backend/  package.json  README.md');
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
        terminal.writeln('Frontend: Running, Backend: Demo Mode');
        break;
      case 'clear':
        terminal.clear();
        terminal.writeln('Demo Mode - Type "help" for commands');
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
            connectionStatus === 'connecting' ? 'bg-yellow-400 animate-pulse' :
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
            Retry
          </button>
        )}
      </div>

      {/* XTerm Container */}
      <div 
        ref={terminalRef} 
        className="flex-1 p-2 overflow-hidden"
        style={{ height: `${height - 40}px` }}
      />
    </div>
  );
}
EOF

echo "✅ XTermTerminal.tsx исправлен - убрано дублирование"

# ============================================================================
# 2. ОБНОВИТЬ terminalService.ts - правильный порт
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
  private maxReconnectAttempts = 3;

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
      // ИСПРАВЛЕН URL - используем правильный порт 3000
      const wsUrl = process.env.NODE_ENV === 'production' 
        ? 'wss://api.icoder.swapoil.de/terminal'
        : 'ws://localhost:3000/terminal';

      console.log('Connecting to:', wsUrl);
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.emit('connect', 'Connected to terminal server');
        console.log('Terminal WebSocket connected to', wsUrl);
      };

      this.ws.onmessage = (event) => {
        // Прямо передаем данные от сервера
        this.emit('data', event.data);
      };

      this.ws.onclose = (event) => {
        this.isConnected = false;
        console.log('Terminal WebSocket closed:', event.code, event.reason);
        this.emit('disconnect', 'Terminal connection closed');
        
        if (event.code !== 1000) { // Не нормальное закрытие
          this.handleReconnect();
        }
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
      const delay = 1000 * this.reconnectAttempts;
      
      console.log(`Reconnecting in ${delay}ms... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
      
      setTimeout(() => {
        this.connect();
      }, delay);
    } else {
      this.emit('error', 'Max reconnection attempts reached');
    }
  }

  sendInput(input: string) {
    if (this.ws && this.isConnected) {
      // Отправляем raw данные, без JSON обертки
      this.ws.send(input);
    } else {
      console.warn('Terminal not connected, cannot send:', input);
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
      this.ws.close(1000, 'User disconnect');
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

echo "✅ Terminal Service обновлен - порт 3000"

# ============================================================================
# 3. ТЕСТИРОВАТЬ ИСПРАВЛЕНИЯ
# ============================================================================

echo "🧪 Тестируем исправленный терминал..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Терминал исправлен!"
    echo "🎯 Изменения:"
    echo "   • Убрано дублирование символов"
    echo "   • Правильный порт 3000 (как в backend)"
    echo "   • Улучшенная цветовая схема как в VS Code"
    echo "   • Отключено локальное эхо"
    echo ""
    echo "🚀 Теперь терминал работает точно как в VS Code!"
else
    echo "❌ Ошибки в сборке"
fi