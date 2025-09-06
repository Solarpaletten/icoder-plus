import { useEffect, useRef, useState } from 'react';

interface BasicTerminalProps {
  isVisible: boolean;
  height: number;
}

export function BasicTerminal({ isVisible, height }: BasicTerminalProps) {
  const [output, setOutput] = useState('Connecting to terminal...\n');
  const [input, setInput] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const outputRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!isVisible) return;

    // Простое WebSocket подключение
    const ws = new WebSocket('ws://localhost:3000/terminal');
    wsRef.current = ws;

    ws.onopen = () => {
      setIsConnected(true);
      setOutput('Connected to bash terminal!\nType commands and press Enter:\n\n');
    };

    ws.onmessage = (event) => {
      setOutput(prev => prev + event.data);
      // Автоскролл вниз
      setTimeout(() => {
        if (outputRef.current) {
          outputRef.current.scrollTop = outputRef.current.scrollHeight;
        }
      }, 10);
    };

    ws.onclose = () => {
      setIsConnected(false);
      setOutput(prev => prev + '\nConnection closed\n');
    };

    ws.onerror = () => {
      setIsConnected(false);
      setOutput(prev => prev + '\nConnection error\n');
    };

    return () => {
      ws.close();
    };
  }, [isVisible]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      
      if (wsRef.current && isConnected) {
        // Отправляем команду
        wsRef.current.send(input + '\r');
        
        // Добавляем команду в вывод
        setOutput(prev => prev + `$ ${input}\n`);
        setInput('');
      }
    } else if (e.key === 'Backspace') {
      // Обычная обработка Backspace
    } else if (e.ctrlKey && e.key === 'c') {
      // Ctrl+C
      e.preventDefault();
      if (wsRef.current && isConnected) {
        wsRef.current.send('\x03'); // Ctrl+C signal
      }
    } else if (e.ctrlKey && e.key === 'l') {
      // Ctrl+L - очистить
      e.preventDefault();
      setOutput('');
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value);
  };

  return (
    <div className="h-full flex flex-col bg-black text-green-400 font-mono">
      {/* Статус */}
      <div className="p-2 bg-gray-800 text-white text-sm border-b border-gray-600">
        <span className={`inline-block w-2 h-2 rounded-full mr-2 ${
          isConnected ? 'bg-green-400' : 'bg-red-400'
        }`}></span>
        {isConnected ? 'Connected - Basic Terminal' : 'Disconnected'}
        <span className="ml-4 text-gray-400">
          Ctrl+C: interrupt, Ctrl+L: clear
        </span>
      </div>

      {/* Вывод терминала */}
      <div 
        ref={outputRef}
        className="flex-1 p-3 overflow-y-auto whitespace-pre-wrap text-sm leading-relaxed"
        style={{ height: `${height - 100}px` }}
      >
        {output}
      </div>

      {/* Поле ввода */}
      <div className="p-3 bg-gray-900 border-t border-gray-600">
        <div className="flex items-center">
          <span className="text-green-400 mr-2">$</span>
          <input
            type="text"
            value={input}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            placeholder={isConnected ? "Type command and press Enter" : "Connecting..."}
            disabled={!isConnected}
            className="flex-1 bg-transparent text-green-400 outline-none placeholder-gray-500"
            autoFocus
          />
        </div>
      </div>
      
      {/* Инструкции */}
      <div className="p-2 bg-gray-900 border-t border-gray-700 text-xs text-gray-500">
        Try: pwd, ls, whoami, date, cd /tmp, ps aux
      </div>
    </div>
  );
}
