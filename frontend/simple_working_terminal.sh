#!/bin/bash

echo "🔧 ПРОСТОЙ РАБОЧИЙ ТЕРМИНАЛ"
echo "=========================="
echo "Создаем максимально простую версию без лишних настроек"

# Создать простейший терминал без сложных настроек
cat > src/components/SimpleTerminal.tsx << 'EOF'
import { useEffect, useRef, useState } from 'react';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import '@xterm/xterm/css/xterm.css';

interface SimpleTerminalProps {
  isVisible: boolean;
  height: number;
}

export function SimpleTerminal({ isVisible, height }: SimpleTerminalProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const xtermRef = useRef<Terminal | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const [status, setStatus] = useState('connecting');

  useEffect(() => {
    if (!terminalRef.current || !isVisible) return;

    // Простейший терминал без сложных настроек
    const terminal = new Terminal({
      cursorBlink: true,
      fontSize: 14,
      fontFamily: 'monospace',
      theme: {
        background: '#000000',
        foreground: '#ffffff',
        cursor: '#ffffff'
      }
    });

    const fitAddon = new FitAddon();
    terminal.loadAddon(fitAddon);
    
    terminal.open(terminalRef.current);
    xtermRef.current = terminal;
    
    fitAddon.fit();
    
    terminal.writeln('Connecting to terminal...');

    // Простое WebSocket подключение
    const ws = new WebSocket('ws://localhost:3000/terminal');
    wsRef.current = ws;

    ws.onopen = () => {
      setStatus('connected');
      terminal.clear();
      terminal.writeln('Connected! Type commands:');
      terminal.focus();
    };

    ws.onmessage = (event) => {
      terminal.write(event.data);
    };

    ws.onclose = () => {
      setStatus('disconnected');
      terminal.writeln('\r\nDisconnected');
    };

    ws.onerror = () => {
      setStatus('error');
      terminal.writeln('\r\nConnection error');
    };

    // Простая обработка ввода
    terminal.onData((data) => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(data);
      }
    });

    // Принудительный фокус через несколько способов
    setTimeout(() => {
      terminal.focus();
      if (terminalRef.current) {
        terminalRef.current.click();
        terminalRef.current.focus();
      }
    }, 500);

    return () => {
      ws.close();
      terminal.dispose();
    };
  }, [isVisible]);

  // Обработчик клика
  const handleClick = () => {
    if (xtermRef.current) {
      xtermRef.current.focus();
    }
  };

  return (
    <div className="h-full flex flex-col bg-black">
      {/* Простой статус */}
      <div className="p-2 bg-gray-800 text-white text-sm">
        Status: {status} - Click terminal and type
        <button 
          onClick={handleClick}
          className="ml-4 px-2 py-1 bg-blue-600 text-white rounded text-xs"
        >
          Focus
        </button>
      </div>
      
      {/* Терминал */}
      <div 
        ref={terminalRef} 
        className="flex-1"
        onClick={handleClick}
        style={{ height: `${height - 50}px` }}
      />
    </div>
  );
}
EOF

echo "✅ Простой терминал создан"

# Обновить Terminal.tsx для использования простого терминала
cat > src/components/Terminal.tsx << 'EOF'
import { SimpleTerminal } from './SimpleTerminal';

interface TerminalProps {
  isVisible?: boolean;
  height?: number;
}

export function Terminal({ isVisible = true, height = 200 }: TerminalProps) {
  return <SimpleTerminal isVisible={isVisible} height={height} />;
}
EOF

echo "✅ Terminal.tsx обновлен"

# Тестировать
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Простой терминал готов!"
    echo "🎯 Максимально упрощен:"
    echo "   • Убраны все сложные настройки"
    echo "   • Прямое WebSocket подключение"
    echo "   • Принудительный фокус"
    echo "   • Простая обработка ввода"
    echo ""
    echo "💡 Попробуйте кликнуть в терминал и ввести команду"
else
    echo "❌ Ошибки сборки"
fi