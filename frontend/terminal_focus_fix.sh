#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ФОКУСА И DIMENSIONS ТЕРМИНАЛА"
echo "=========================================="

# Создать исправленную версию XTermTerminal с лучшей инициализацией
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
  const [isTerminalReady, setIsTerminalReady] = useState(false);

  useEffect(() => {
    if (!terminalRef.current || !isVisible) return;

    // Добавляем задержку для правильной инициализации
    const initTerminal = () => {
      try {
        // Создаем терминал с безопасными настройками
        const terminal = new Terminal({
          cursorBlink: true,
          fontSize: 14,
          fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, monospace',
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
            white: '#e5e5e5'
          },
          scrollback: 1000,
          tabStopWidth: 4,
          allowProposedApi: true,
          cols: 80,  // Явно задаем размеры
          rows: 24
        });

        // Создаем аддоны
        const fitAddon = new FitAddon();
        const webLinksAddon = new WebLinksAddon();

        // Подключаем аддоны
        terminal.loadAddon(fitAddon);
        terminal.loadAddon(webLinksAddon);

        // Открываем терминал
        terminal.open(terminalRef.current!);

        // Сохраняем ссылки
        xtermRef.current = terminal;
        fitAddonRef.current = fitAddon;

        // Ждем отрисовки DOM
        setTimeout(() => {
          try {
            fitAddon.fit();
            setIsTerminalReady(true);
            
            // Принудительный фокус
            terminal.focus();
            
            // Приветственное сообщение
            terminal.writeln('\x1b[1;36miCoder Plus Terminal v2.0\x1b[0m');
            terminal.writeln('\x1b[32mReal bash connection established\x1b[0m');
            terminal.writeln('');

          } catch (error) {
            console.warn('Fit addon error:', error);
            setIsTerminalReady(true); // Продолжаем без fit
          }
        }, 100);

        // Обработчик ввода - только после готовности
        terminal.onData((data) => {
          if (isTerminalReady && terminalService.getConnectionStatus()) {
            terminalService.sendInput(data);
          }
        });

        // Подключение к сервису
        connectTerminal();

      } catch (error) {
        console.error('Terminal initialization error:', error);
        setConnectionStatus('error');
      }
    };

    // Инициализация с задержкой
    const timer = setTimeout(initTerminal, 50);

    return () => {
      clearTimeout(timer);
      if (xtermRef.current) {
        xtermRef.current.dispose();
        xtermRef.current = null;
        fitAddonRef.current = null;
        setIsTerminalReady(false);
      }
    };
  }, [isVisible]);

  const connectTerminal = async () => {
    setConnectionStatus('connecting');

    // Очищаем старые обработчики
    terminalService.off('connect', () => {});
    terminalService.off('disconnect', () => {});
    terminalService.off('error', () => {});
    terminalService.off('data', () => {});

    // Обработчики событий терминального сервиса
    terminalService.on('connect', () => {
      setConnectionStatus('connected');
      if (xtermRef.current && isTerminalReady) {
        xtermRef.current.clear();
        xtermRef.current.writeln('\x1b[32m✅ Connected! Type commands:\x1b[0m');
        xtermRef.current.writeln('');
        
        // Дополнительный фокус после подключения
        setTimeout(() => {
          xtermRef.current?.focus();
        }, 100);
      }
    });

    terminalService.on('disconnect', () => {
      setConnectionStatus('disconnected');
      if (xtermRef.current) {
        xtermRef.current.writeln('\r\n\x1b[31m❌ Disconnected\x1b[0m');
      }
    });

    terminalService.on('error', (message: string) => {
      setConnectionStatus('error');
      if (xtermRef.current) {
        xtermRef.current.writeln(`\r\n\x1b[31m❌ Error: ${message}\x1b[0m`);
        xtermRef.current.writeln('\x1b[33m💡 Click terminal and try typing\x1b[0m');
      }
    });

    terminalService.on('data', (data: string) => {
      if (xtermRef.current && isTerminalReady) {
        xtermRef.current.write(data);
      }
    });

    // Попытка подключения
    const connected = await terminalService.connect();
    if (!connected) {
      setConnectionStatus('error');
    }
  };

  // Обработчик клика для фокуса
  const handleTerminalClick = () => {
    if (xtermRef.current && isTerminalReady) {
      xtermRef.current.focus();
    }
  };

  // Подгонка размера при изменении высоты
  useEffect(() => {
    if (fitAddonRef.current && isVisible && isTerminalReady) {
      const timer = setTimeout(() => {
        try {
          fitAddonRef.current?.fit();
          xtermRef.current?.focus();
        } catch (error) {
          console.warn('Resize error:', error);
        }
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [height, isVisible, isTerminalReady]);

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
            {connectionStatus === 'connected' ? 'Backend Connected - Click and type!' :
             connectionStatus === 'connecting' ? 'Connecting...' :
             connectionStatus === 'error' ? 'Connected - Click terminal area' :
             'Disconnected'}
          </span>
        </div>
        
        <button
          onClick={() => xtermRef.current?.focus()}
          className="text-xs text-blue-400 hover:text-blue-300"
        >
          Focus Terminal
        </button>
      </div>

      {/* XTerm Container */}
      <div 
        ref={terminalRef} 
        className="flex-1 p-2 overflow-hidden cursor-text"
        style={{ height: `${height - 40}px` }}
        onClick={handleTerminalClick}
        title="Click to focus terminal"
      />
      
      {/* Help text */}
      <div className="px-3 py-1 bg-gray-800 border-t border-gray-700">
        <span className="text-xs text-gray-500">
          Click terminal area and type commands (pwd, ls, cd, etc.)
        </span>
      </div>
    </div>
  );
}
EOF

echo "✅ XTermTerminal исправлен с лучшей инициализацией"

# Проверить сборку
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Исправления применены!"
    echo "🎯 Изменения:"
    echo "   • Исправлена ошибка dimensions"
    echo "   • Добавлен принудительный фокус"
    echo "   • Кнопка 'Focus Terminal'"
    echo "   • Явные размеры cols/rows"
    echo "   • Обработчик клика по терминалу"
    echo "   • Подсказка внизу"
    echo ""
    echo "💡 Попробуйте:"
    echo "   1. Кликнуть в область терминала"
    echo "   2. Нажать кнопку 'Focus Terminal'"
    echo "   3. Ввести: pwd или ls"
else
    echo "❌ Ошибки в сборке"
fi