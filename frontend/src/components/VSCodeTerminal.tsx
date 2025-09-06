import { useEffect, useRef, useState } from 'react';

interface VSCodeTerminalProps {
  isVisible: boolean;
  height: number;
}

export function VSCodeTerminal({ isVisible, height }: VSCodeTerminalProps) {
  const [lines, setLines] = useState<string[]>(['Connected to bash terminal!', '']);
  const [currentInput, setCurrentInput] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [currentDir, setCurrentDir] = useState('~');
  const wsRef = useRef<WebSocket | null>(null);
  const terminalRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!isVisible) return;

    // WebSocket подключение
    const ws = new WebSocket('ws://localhost:3000/terminal');
    wsRef.current = ws;

    ws.onopen = () => {
      setIsConnected(true);
      setLines(['Connected to bash terminal!', '']);
    };

    ws.onmessage = (event) => {
      const data: string = event.data;
      
      // Обработка вывода от сервера
      if (data.includes('$')) {
        // Это промпт - извлекаем текущую директорию
        const parts = data.split('$');
        if (parts[0].trim()) {
          const dirMatch = parts[0].match(/([^/\s]+)?\s*\$?\s*$/);
          if (dirMatch) {
            setCurrentDir(dirMatch[1] || '~');
          }
        }
      }

      // Добавляем вывод к строкам
      const newLines: string[] = data.split('\n');
      setLines(prev => {
        const updated = [...prev];
        
        // Добавляем каждую строку - ИСПРАВЛЕНА ТИПИЗАЦИЯ
        newLines.forEach((line: string, index: number) => {
          if (index === 0) {
            // Первая строка добавляется к последней существующей
            updated[updated.length - 1] += line;
          } else {
            // Остальные строки добавляются как новые
            updated.push(line);
          }
        });
        
        return updated;
      });

      // Автоскролл
      setTimeout(() => {
        if (terminalRef.current) {
          terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
        }
      }, 10);
    };

    ws.onclose = () => {
      setIsConnected(false);
      setLines(prev => [...prev, 'Connection closed']);
    };

    ws.onerror = () => {
      setIsConnected(false);
      setLines(prev => [...prev, 'Connection error']);
    };

    return () => {
      ws.close();
    };
  }, [isVisible]);

  const executeCommand = () => {
    if (!currentInput.trim() || !wsRef.current || !isConnected) return;

    // Добавляем команду в вывод
    setLines(prev => [...prev, `${currentDir}$ ${currentInput}`, '']);

    // Отправляем команду на сервер
    wsRef.current.send(currentInput + '\r');
    
    // Очищаем ввод
    setCurrentInput('');
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      executeCommand();
    } else if (e.ctrlKey && e.key === 'c') {
      e.preventDefault();
      if (wsRef.current && isConnected) {
        wsRef.current.send('\x03');
        setLines(prev => [...prev, '^C', '']);
        setCurrentInput('');
      }
    } else if (e.ctrlKey && e.key === 'l') {
      e.preventDefault();
      setLines(['']);
      setCurrentInput('');
    }
  };

  // Фокус на input при клике в терминал
  const handleTerminalClick = () => {
    inputRef.current?.focus();
  };

  // Автофокус при монтировании
  useEffect(() => {
    if (isVisible && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isVisible]);

  return (
    <div className="h-full flex flex-col bg-black text-green-400 font-mono">
      {/* Заголовок */}
      <div className="flex items-center justify-between px-3 py-1 bg-gray-800 text-white text-sm border-b border-gray-600">
        <div className="flex items-center space-x-2">
          <span className={`w-2 h-2 rounded-full ${
            isConnected ? 'bg-green-400' : 'bg-red-400'
          }`}></span>
          <span>Terminal - {currentDir}</span>
        </div>
        <span className="text-gray-400 text-xs">
          Ctrl+C: interrupt, Ctrl+L: clear
        </span>
      </div>

      {/* Область терминала */}
      <div 
        ref={terminalRef}
        className="flex-1 p-3 overflow-y-auto cursor-text"
        style={{ height: `${height - 80}px` }}
        onClick={handleTerminalClick}
      >
        {/* Вывод всех строк */}
        {lines.map((line: string, index: number) => (
          <div key={index} className="leading-relaxed">
            {line}
          </div>
        ))}
        
        {/* Текущая строка ввода */}
        {isConnected && (
          <div className="flex items-center">
            <span className="mr-1">{currentDir}$</span>
            <input
              ref={inputRef}
              type="text"
              value={currentInput}
              onChange={(e) => setCurrentInput(e.target.value)}
              onKeyDown={handleKeyDown}
              className="flex-1 bg-transparent outline-none text-green-400 caret-green-400"
              style={{ minWidth: '10px' }}
              autoComplete="off"
              spellCheck={false}
            />
          </div>
        )}
      </div>

      {/* Подсказки внизу */}
      <div className="px-3 py-1 bg-gray-900 border-t border-gray-700 text-xs text-gray-500">
        Try: pwd, ls, cd /tmp, whoami, ps aux, top
      </div>
    </div>
  );
}
