#!/bin/bash

echo "🔧 PHASE 4.4: TYPESCRIPT FIX"
echo "============================="
echo "Цель: Исправить типы для node и git терминалов"

# 1. Обновить VSCodeTerminal для поддержки новых типов shell
cat > src/components/terminal/VSCodeTerminal.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { ChevronDown, X, Plus, Square, Maximize2, Minimize2 } from 'lucide-react';

interface VSCodeTerminalProps {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  isActive: boolean;
  canClose?: boolean;
  onClose?: () => void;
  onNewTerminal?: () => void;
  onSplitRight?: () => void;
  onSplitDown?: () => void;
  onFocus?: () => void;
  height: number;
}

export const VSCodeTerminal: React.FC<VSCodeTerminalProps> = ({
  id,
  name,
  shell,
  isActive,
  canClose = true,
  onClose,
  onNewTerminal,
  onSplitRight,
  onSplitDown,
  onFocus,
  height
}) => {
  const [input, setInput] = useState('');
  const [history, setHistory] = useState<string[]>([
    `Welcome to ${shell} terminal!`,
    `🟢 Connected to ${shell} backend`,
    shell === 'bash' ? 'bash: no job control in this shell' : 
    shell === 'zsh' ? 'zsh: no job control in this shell' :
    shell === 'node' ? 'Node.js v18.17.0' :
    shell === 'git' ? 'git version 2.39.0' :
    'powershell: no job control in this shell',
    '',
    shell === 'bash' ? 'The default interactive shell is now zsh.' :
    shell === 'zsh' ? 'The default interactive shell is now zsh.' :
    shell === 'node' ? 'Type ".help" for more information.' :
    shell === 'git' ? 'Type "git --help" for more information.' :
    'The default interactive shell is now powershell.',
    shell === 'bash' ? 'To update your account to use zsh, please run `chsh -s /bin/zsh`.' :
    shell === 'zsh' ? 'To update your account to use zsh, please run `chsh -s /bin/zsh`.' :
    shell === 'node' ? 'Use Ctrl+C to exit REPL mode.' :
    shell === 'git' ? 'Configure with: git config --global user.name "Your Name"' :
    'To update your account to use powershell, please run `chsh -s /bin/powershell`.',
    shell === 'bash' ? 'For more details, please visit https://support.apple.com/kb/HT208050.' :
    shell === 'zsh' ? 'For more details, please visit https://support.apple.com/kb/HT208050.' :
    shell === 'node' ? 'Documentation: https://nodejs.org/en/docs/' :
    shell === 'git' ? 'Documentation: https://git-scm.com/docs' :
    'For more details, please visit https://support.microsoft.com/powershell.',
    `[${name}]-3.2$`,
    shell === 'node' ? '> ' : shell === 'git' ? 'git> ' : `🟢 Connected to ${shell} backend`,
    shell === 'node' ? '> ' : shell === 'git' ? 'git> ' : `${shell}: no job control in this shell`,
    '',
    shell === 'bash' ? 'The default interactive shell is now zsh.' :
    shell === 'zsh' ? 'The default interactive shell is now zsh.' :
    shell === 'node' ? '' :
    shell === 'git' ? '' :
    'The default interactive shell is now powershell.',
    shell === 'bash' ? 'To update your account to use zsh, please run `chsh -s /bin/zsh`.' :
    shell === 'zsh' ? 'To update your account to use zsh, please run `chsh -s /bin/zsh`.' :
    shell === 'node' ? '' :
    shell === 'git' ? '' :
    'To update your account to use powershell, please run `chsh -s /bin/powershell`.',
    shell === 'bash' ? 'For more details, please visit https://support.apple.com/kb/HT208050.' :
    shell === 'zsh' ? 'For more details, please visit https://support.apple.com/kb/HT208050.' :
    shell === 'node' ? '' :
    shell === 'git' ? '' :
    'For more details, please visit https://support.microsoft.com/powershell.',
    `[${name}]-3.2$`,
    `~/${shell === 'git' ? 'projects/icoder-plus' : shell === 'node' ? 'projects/icoder-plus' : 'projects/icoder-plus'}`
  ]);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [showMenu, setShowMenu] = useState(false);
  const [isConnected, setIsConnected] = useState(true);
  
  const inputRef = useRef<HTMLInputElement>(null);
  const terminalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isActive && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isActive]);

  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [history]);

  const getShellPrompt = () => {
    switch (shell) {
      case 'bash': return '$';
      case 'zsh': return '%';
      case 'powershell': return '>';
      case 'node': return '>';
      case 'git': return 'git>';
      default: return '$';
    }
  };

  const getShellIcon = () => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      case 'node': return '🟢';
      case 'git': return '🔧';
      default: return '💻';
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      if (input.trim()) {
        const command = input.trim();
        const newHistory = [...history, `${getShellPrompt()} ${command}`];
        
        // Simulate command execution
        if (shell === 'node') {
          if (command === '.help') {
            newHistory.push('.break    Sometimes you get stuck, this gets you out');
            newHistory.push('.clear    Alias for .break');
            newHistory.push('.exit     Exit the REPL');
            newHistory.push('.help     Print this help message');
          } else if (command === '.exit') {
            newHistory.push('Exiting Node.js REPL...');
          } else {
            try {
              const result = eval(command);
              newHistory.push(String(result));
            } catch (err) {
              newHistory.push(`Error: ${err}`);
            }
          }
        } else if (shell === 'git') {
          if (command.startsWith('git status')) {
            newHistory.push('On branch main');
            newHistory.push('Your branch is up to date with \'origin/main\'.');
            newHistory.push('nothing to commit, working tree clean');
          } else if (command.startsWith('git log')) {
            newHistory.push('commit a1b2c3d4e5f6g7h8i9j0 (HEAD -> main, origin/main)');
            newHistory.push('Author: Developer <dev@icoder.plus>');
            newHistory.push('Date:   Mon Sep 7 12:00:00 2025 +0300');
            newHistory.push('    Phase 4.4: Terminal Sidebar Manager');
          } else if (command.startsWith('git branch')) {
            newHistory.push('* main');
            newHistory.push('  feature/terminal-sidebar');
          } else {
            newHistory.push(`git: '${command.replace('git ', '')}' is not a git command.`);
          }
        } else {
          // Basic bash/zsh/powershell commands
          if (command === 'ls' || command === 'dir') {
            newHistory.push('README.md  package.json  src/  node_modules/');
          } else if (command === 'pwd') {
            newHistory.push(`/Users/${shell}/projects/icoder-plus`);
          } else if (command.startsWith('cd ')) {
            newHistory.push(`Changed directory to ${command.slice(3)}`);
          } else if (command === 'clear') {
            setHistory([]);
            setInput('');
            return;
          } else {
            newHistory.push(`${shell}: command not found: ${command}`);
          }
        }
        
        setHistory(newHistory);
        setCommandHistory(prev => [...prev, command]);
        setHistoryIndex(-1);
      }
      setInput('');
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (commandHistory.length > 0) {
        const newIndex = historyIndex === -1 ? commandHistory.length - 1 : Math.max(0, historyIndex - 1);
        setHistoryIndex(newIndex);
        setInput(commandHistory[newIndex]);
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (historyIndex !== -1) {
        const newIndex = historyIndex + 1;
        if (newIndex < commandHistory.length) {
          setHistoryIndex(newIndex);
          setInput(commandHistory[newIndex]);
        } else {
          setHistoryIndex(-1);
          setInput('');
        }
      }
    } else if (e.key === 'Tab') {
      e.preventDefault();
      // Basic tab completion
      const commands = shell === 'node' ? ['.help', '.exit', '.clear'] :
                      shell === 'git' ? ['status', 'log', 'branch', 'add', 'commit', 'push', 'pull'] :
                      ['ls', 'cd', 'pwd', 'mkdir', 'rm', 'cp', 'mv', 'cat', 'grep', 'find'];
      
      const matches = commands.filter(cmd => cmd.startsWith(input));
      if (matches.length === 1) {
        setInput(shell === 'git' && !input.startsWith('git ') ? `git ${matches[0]}` : matches[0]);
      }
    }
  };

  const handleTerminalClick = () => {
    if (onFocus) onFocus();
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  return (
    <div className={`flex flex-col h-full bg-gray-900 border border-gray-700 ${
      isActive ? 'border-blue-500' : 'border-gray-700'
    }`}>
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-2 flex-shrink-0">
        <div className="flex items-center gap-2">
          <span className="text-sm">{getShellIcon()}</span>
          <span className="text-xs font-medium text-gray-300">{name}</span>
          <div className={`w-1.5 h-1.5 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`} />
        </div>
        
        <div className="flex items-center gap-1">
          <div className="relative">
            <button
              onClick={() => setShowMenu(!showMenu)}
              className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            >
              <ChevronDown size={12} />
            </button>
            
            {showMenu && (
              <>
                <div className="fixed inset-0 z-10" onClick={() => setShowMenu(false)} />
                <div className="absolute right-0 top-full mt-1 bg-gray-800 border border-gray-600 rounded shadow-lg z-20 min-w-[120px]">
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
              </>
            )}
          </div>
          
          {canClose && (
            <button
              onClick={onClose}
              className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-red-400 transition-colors"
            >
              <X size={12} />
            </button>
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
EOF

echo "✅ VSCodeTerminal обновлен для поддержки node и git терминалов"

# 2. Тестируем исправления
echo "🧪 Тестируем исправленные типы..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.4 TYPESCRIPT FIX ЗАВЕРШЕН!"
  echo "🏆 Все типы исправлены, поддержка node и git терминалов добавлена!"
  echo ""
  echo "📋 Исправления:"
  echo "   ✅ VSCodeTerminal поддерживает: bash, zsh, powershell, node, git"
  echo "   ✅ Разные промпты: bash($), zsh(%), powershell(>), node(>), git(git>)"
  echo "   ✅ Специфичные команды для каждого shell"
  echo "   ✅ Tab completion для git команд"
  echo "   ✅ Node.js REPL функциональность"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Теперь доступны все типы терминалов без TypeScript ошибок!"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi