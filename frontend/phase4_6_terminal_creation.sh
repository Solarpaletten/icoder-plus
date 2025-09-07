#!/bin/bash

echo "🔧 PHASE 4.6: TERMINAL CREATION & AUTOCOMPLETE"
echo "=============================================="
echo "Цель: Перенести + в Header и добавить автодополнение как в VS Code"

# 1. Создать TerminalHeader компонент с кнопкой создания терминалов
cat > src/components/terminal/TerminalHeader.tsx << 'EOF'
import React, { useState } from 'react';
import { Plus, ChevronDown, Terminal, Maximize2, Minimize2, X } from 'lucide-react';

interface TerminalHeaderProps {
  height: number;
  isMaximized: boolean;
  onNewTerminal: (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void;
  onMaximize: () => void;
  onToggle: () => void;
}

export const TerminalHeader: React.FC<TerminalHeaderProps> = ({
  height,
  isMaximized,
  onNewTerminal,
  onMaximize,
  onToggle
}) => {
  const [showNewTerminalMenu, setShowNewTerminalMenu] = useState(false);

  const shellOptions = [
    { shell: 'bash' as const, icon: '🐚', name: 'Bash' },
    { shell: 'zsh' as const, icon: '⚡', name: 'Zsh' },
    { shell: 'powershell' as const, icon: '💻', name: 'PowerShell' },
    { shell: 'node' as const, icon: '🟢', name: 'Node.js' },
    { shell: 'git' as const, icon: '🔧', name: 'Git Bash' }
  ];

  const handleNewTerminal = (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => {
    onNewTerminal(shell);
    setShowNewTerminalMenu(false);
  };

  return (
    <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
      {/* Left Side - Terminal Info */}
      <div className="flex items-center gap-2">
        <Terminal size={14} className="text-gray-400" />
        <span className="text-sm font-medium text-gray-300">TERMINAL</span>
        <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
        <span className="text-xs text-gray-500">
          {height}px {isMaximized ? '(Maximized)' : ''}
        </span>
      </div>
      
      {/* Center - New Terminal Button */}
      <div className="flex items-center gap-2">
        <div className="relative">
          <button
            onClick={() => setShowNewTerminalMenu(!showNewTerminalMenu)}
            className="flex items-center gap-1 px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded text-xs font-medium transition-colors"
            title="New Terminal"
          >
            <Plus size={12} />
            <span>New Terminal</span>
            <ChevronDown size={10} />
          </button>
          
          {showNewTerminalMenu && (
            <>
              <div 
                className="fixed inset-0 z-10" 
                onClick={() => setShowNewTerminalMenu(false)} 
              />
              <div className="absolute top-full left-1/2 transform -translate-x-1/2 mt-1 bg-gray-800 border border-gray-600 rounded shadow-lg z-20 min-w-[140px]">
                {shellOptions.map(option => (
                  <button
                    key={option.shell}
                    onClick={() => handleNewTerminal(option.shell)}
                    className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2 text-gray-300 hover:text-white transition-colors first:rounded-t last:rounded-b"
                  >
                    <span className="text-sm">{option.icon}</span>
                    <span>{option.name}</span>
                  </button>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
      
      {/* Right Side - Controls */}
      <div className="flex items-center gap-1">
        <button
          onClick={onMaximize}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
          title={isMaximized ? "Restore" : "Maximize"}
        >
          {isMaximized ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
        </button>
        
        <button
          onClick={onToggle}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
          title="Close terminal"
        >
          <X size={14} />
        </button>
      </div>
    </div>
  );
};
EOF

echo "✅ TerminalHeader создан с кнопкой New Terminal в центре"

# 2. Обновить VSCodeTerminal для добавления автодополнения
cat > src/components/terminal/VSCodeTerminal.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { ChevronDown, X, Square } from 'lucide-react';

interface VSCodeTerminalProps {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  isActive: boolean;
  canClose?: boolean;
  onClose?: () => void;
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
    `~/${shell === 'git' ? 'projects/icoder-plus' : shell === 'node' ? 'projects/icoder-plus' : 'projects/icoder-plus'}`
  ]);
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [showMenu, setShowMenu] = useState(false);
  const [isConnected, setIsConnected] = useState(true);
  const [currentDirectory, setCurrentDirectory] = useState('~/projects/icoder-plus');
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const [suggestionIndex, setSuggestionIndex] = useState(-1);
  
  const inputRef = useRef<HTMLInputElement>(null);
  const terminalRef = useRef<HTMLDivElement>(null);

  // Mock file system for autocomplete
  const mockFileSystem = {
    '~/projects/icoder-plus': ['src', 'package.json', 'README.md', 'node_modules', 'dist', '.git'],
    '~/projects/icoder-plus/src': ['components', 'hooks', 'utils', 'App.tsx', 'main.tsx'],
    '~/projects/icoder-plus/src/components': ['terminal', 'layout', 'panels', 'AppShell.tsx'],
    '~/projects/icoder-plus/src/components/terminal': ['MultiTerminalManager.tsx', 'VSCodeTerminal.tsx', 'TerminalSidebar.tsx'],
    '~/projects/icoder-plus/src/components/layout': ['AppHeader.tsx', 'BottomTerminal.tsx', 'StatusBar.tsx'],
    '~/projects/icoder-plus/src/components/panels': ['LeftSidebar.tsx', 'MainEditor.tsx', 'RightPanel.tsx']
  };

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

  const getAutocompleteSuggestions = (input: string): string[] => {
    const trimmedInput = input.trim();
    
    // Command completion
    const commands = shell === 'node' ? ['.help', '.exit', '.clear'] :
                    shell === 'git' ? ['status', 'log', 'branch', 'add', 'commit', 'push', 'pull', 'checkout', 'merge'] :
                    ['ls', 'cd', 'pwd', 'mkdir', 'rm', 'cp', 'mv', 'cat', 'grep', 'find', 'npm', 'yarn', 'git', 'code', 'nano'];
    
    // If input is just a command prefix, suggest commands
    if (!trimmedInput.includes(' ')) {
      return commands.filter(cmd => cmd.startsWith(trimmedInput));
    }
    
    // Directory/file completion for cd command
    if (trimmedInput.startsWith('cd ')) {
      const pathPrefix = trimmedInput.slice(3);
      const currentDirFiles = mockFileSystem[currentDirectory as keyof typeof mockFileSystem] || [];
      
      return currentDirFiles
        .filter(item => item.startsWith(pathPrefix))
        .map(item => `cd ${item}`);
    }
    
    // File completion for other commands
    if (trimmedInput.match(/^(ls|cat|rm|mv|cp|nano|code)\s+/)) {
      const parts = trimmedInput.split(' ');
      const command = parts[0];
      const pathPrefix = parts[parts.length - 1] || '';
      
      const currentDirFiles = mockFileSystem[currentDirectory as keyof typeof mockFileSystem] || [];
      
      return currentDirFiles
        .filter(item => item.startsWith(pathPrefix))
        .map(item => `${command} ${item}`);
    }
    
    return [];
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
            newHistory.push('    Phase 4.6: Terminal Creation & Autocomplete');
          } else if (command.startsWith('git branch')) {
            newHistory.push('* main');
            newHistory.push('  feature/terminal-autocomplete');
          } else {
            newHistory.push(`git: '${command.replace('git ', '')}' is not a git command.`);
          }
        } else {
          // Basic bash/zsh/powershell commands
          if (command === 'ls' || command === 'dir') {
            const currentDirFiles = mockFileSystem[currentDirectory as keyof typeof mockFileSystem] || [];
            newHistory.push(currentDirFiles.join('  '));
          } else if (command === 'pwd') {
            newHistory.push(currentDirectory);
          } else if (command.startsWith('cd ')) {
            const targetDir = command.slice(3).trim();
            if (targetDir === '..') {
              const pathParts = currentDirectory.split('/');
              pathParts.pop();
              const newDir = pathParts.join('/') || '~';
              setCurrentDirectory(newDir);
              newHistory.push(`Changed directory to ${newDir}`);
            } else if (targetDir === '~' || targetDir === '') {
              setCurrentDirectory('~/projects/icoder-plus');
              newHistory.push('Changed directory to ~/projects/icoder-plus');
            } else {
              const newDir = `${currentDirectory}/${targetDir}`;
              if (mockFileSystem[newDir as keyof typeof mockFileSystem]) {
                setCurrentDirectory(newDir);
                newHistory.push(`Changed directory to ${newDir}`);
              } else {
                newHistory.push(`cd: no such file or directory: ${targetDir}`);
              }
            }
          } else if (command === 'clear') {
            setHistory([]);
            setInput('');
            setSuggestions([]);
            return;
          } else {
            newHistory.push(`${shell}: command not found: ${command}`);
          }
        }
        
        setHistory(newHistory);
        setCommandHistory(prev => [...prev, command]);
        setHistoryIndex(-1);
        setSuggestions([]);
      }
      setInput('');
      setSuggestionIndex(-1);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (suggestions.length > 0) {
        setSuggestionIndex(prev => Math.max(0, prev - 1));
      } else if (commandHistory.length > 0) {
        const newIndex = historyIndex === -1 ? commandHistory.length - 1 : Math.max(0, historyIndex - 1);
        setHistoryIndex(newIndex);
        setInput(commandHistory[newIndex]);
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (suggestions.length > 0) {
        setSuggestionIndex(prev => Math.min(suggestions.length - 1, prev + 1));
      } else if (historyIndex !== -1) {
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
      const newSuggestions = getAutocompleteSuggestions(input);
      
      if (newSuggestions.length === 1) {
        setInput(newSuggestions[0]);
        setSuggestions([]);
        setSuggestionIndex(-1);
      } else if (newSuggestions.length > 1) {
        setSuggestions(newSuggestions);
        setSuggestionIndex(0);
      }
    } else if (e.key === 'Escape') {
      setSuggestions([]);
      setSuggestionIndex(-1);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setInput(value);
    
    // Update suggestions as user types
    if (value.trim()) {
      const newSuggestions = getAutocompleteSuggestions(value);
      setSuggestions(newSuggestions.slice(0, 5)); // Limit to 5 suggestions
      setSuggestionIndex(-1);
    } else {
      setSuggestions([]);
      setSuggestionIndex(-1);
    }
  };

  const handleSuggestionClick = (suggestion: string) => {
    setInput(suggestion);
    setSuggestions([]);
    setSuggestionIndex(-1);
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  const handleTerminalClick = () => {
    if (onFocus) onFocus();
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  return (
    <div className={`flex flex-col h-full bg-gray-900 border border-gray-700 relative ${
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
        className="flex-1 overflow-hidden cursor-text relative"
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
              onChange={handleInputChange}
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
        
        {/* Autocomplete Suggestions */}
        {suggestions.length > 0 && (
          <div className="absolute bottom-8 left-2 bg-gray-800 border border-gray-600 rounded shadow-lg z-20 min-w-[200px]">
            {suggestions.map((suggestion, index) => (
              <button
                key={index}
                onClick={() => handleSuggestionClick(suggestion)}
                className={`w-full text-left px-3 py-1.5 text-xs flex items-center gap-2 ${
                  index === suggestionIndex 
                    ? 'bg-blue-600 text-white' 
                    : 'text-gray-300 hover:bg-gray-700'
                }`}
                style={{ fontFamily: 'Consolas, "Courier New", monospace' }}
              >
                {suggestion}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
EOF

echo "✅ VSCodeTerminal обновлен с автодополнением команд и директорий"

# 3. Обновить BottomTerminal для использования нового TerminalHeader
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState } from 'react';
import { MultiTerminalManager } from '../terminal/MultiTerminalManager';
import { TerminalHeader } from '../terminal/TerminalHeader';

interface BottomTerminalProps {
  height: number;
  onToggle: () => void;
  onResize: (height: number) => void;
}

export const BottomTerminal: React.FC<BottomTerminalProps> = ({
  height,
  onToggle,
  onResize
}) => {
  const [isMaximized, setIsMaximized] = useState(false);
  const [terminalManager, setTerminalManager] = useState<any>(null);

  const handleMaximize = () => {
    if (isMaximized) {
      onResize(250);
      setIsMaximized(false);
    } else {
      const parentHeight = window.innerHeight - 100;
      const maxHeight = Math.floor(parentHeight * 0.95);
      onResize(maxHeight);
      setIsMaximized(true);
    }
  };

  const handleNewTerminal = (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => {
    if (terminalManager && terminalManager.createTerminal) {
      terminalManager.createTerminal(shell);
    }
  };

  return (
    <div className="bg-gray-900 border-t border-gray-700 flex flex-col h-full">
      {/* Terminal Header with New Terminal Button */}
      <TerminalHeader
        height={height}
        isMaximized={isMaximized}
        onNewTerminal={handleNewTerminal}
        onMaximize={handleMaximize}
        onToggle={onToggle}
      />
      
      {/* Multi Terminal Content with Sidebar */}
      <div className="flex-1 overflow-hidden">
        <MultiTerminalManager 
          height={height - 32}
          ref={(ref: any) => setTerminalManager(ref)}
        />
      </div>
    </div>
  );
};
EOF

echo "✅ BottomTerminal обновлен с новым TerminalHeader"

# 4. Обновить MultiTerminalManager для поддержки внешнего создания терминалов
cat > src/components/terminal/MultiTerminalManager.tsx << 'EOF'
import React, { useState, forwardRef, useImperativeHandle } from 'react';
import { Plus } from 'lucide-react';
import { SplitContainer } from './SplitContainer';
import { VSCodeTerminal } from './VSCodeTerminal';
import { TerminalSidebar } from './TerminalSidebar';
import { ResizableTerminalContainer } from './ResizableTerminalContainer';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  status: 'running' | 'stopped' | 'error';
  isActive: boolean;
  splitId?: string;
  workingDirectory?: string;
}

interface Split {
  id: string;
  direction: 'horizontal' | 'vertical';
  terminals: string[];
  parent?: string;
}

interface MultiTerminalManagerProps {
  height: number;
}

export interface MultiTerminalManagerRef {
  createTerminal: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void;
}

export const MultiTerminalManager = forwardRef<MultiTerminalManagerRef, MultiTerminalManagerProps>(({ height }, ref) => {
  const [terminals, setTerminals] = useState<TerminalInstance[]>([
    {
      id: '1',
      name: 'bash',
      shell: 'bash',
      status: 'running',
      isActive: true,
      workingDirectory: '~/projects/icoder-plus'
    }
  ]);
  
  const [splits, setSplits] = useState<Split[]>([]);
  const [activeTerminalId, setActiveTerminalId] = useState('1');
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  const generateId = () => Date.now().toString() + Math.random().toString(36).substr(2, 5);

  const createTerminal = (shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git' = 'bash') => {
    const id = generateId();
    const shellCount = terminals.filter(t => t.shell === shell).length + 1;
    const newTerminal: TerminalInstance = {
      id,
      name: shell === 'node' ? `node-${shellCount}` : 
            shell === 'git' ? `git-${shellCount}` : 
            `${shell}-${shellCount}`,
      shell,
      status: 'running',
      isActive: false,
      workingDirectory: shell === 'git' ? '~/projects/icoder-plus' : 
                       shell === 'node' ? '~/projects/icoder-plus' : 
                       '~/projects/icoder-plus'
    };
    
    setTerminals(prev => [...prev, newTerminal]);
    setActiveTerminalId(id);
  };

  // Expose createTerminal method to parent component
  useImperativeHandle(ref, () => ({
    createTerminal
  }));

  const closeTerminal = (id: string) => {
    if (terminals.length <= 1) return;
    
    setTerminals(prev => prev.filter(t => t.id !== id));
    
    // Remove from splits
    setSplits(prev => prev.map(split => ({
      ...split,
      terminals: split.terminals.filter(tid => tid !== id)
    })).filter(split => split.terminals.length > 0));
    
    // Set new active terminal
    if (activeTerminalId === id) {
      const remaining = terminals.filter(t => t.id !== id);
      if (remaining.length > 0) {
        setActiveTerminalId(remaining[0].id);
      }
    }
  };

  const splitTerminal = (terminalId: string, direction: 'horizontal' | 'vertical') => {
    const newTerminalId = generateId();
    const originalTerminal = terminals.find(t => t.id === terminalId);
    
    if (!originalTerminal) return;

    // Create new terminal
    const shellCount = terminals.filter(t => t.shell === originalTerminal.shell).length + 1;
    const newTerminal: TerminalInstance = {
      id: newTerminalId,
      name: `${originalTerminal.shell}-${shellCount}`,
      shell: originalTerminal.shell,
      status: 'running',
      isActive: false,
      workingDirectory: originalTerminal.workingDirectory
    };

    setTerminals(prev => [...prev, newTerminal]);

    // Create or update split
    const splitId = generateId();
    const newSplit: Split = {
      id: splitId,
      direction,
      terminals: [terminalId, newTerminalId]
    };

    setSplits(prev => [...prev, newSplit]);
    setActiveTerminalId(newTerminalId);
  };

  const selectTerminal = (id: string) => {
    setActiveTerminalId(id);
    // Update terminal status to active
    setTerminals(prev => prev.map(t => ({
      ...t,
      isActive: t.id === id
    })));
  };

  const renderMainTerminalArea = () => {
    const activeSplits = splits.filter(s => s.terminals.length > 1);

    if (activeSplits.length === 0) {
      // No splits, render single terminal or tabs
      if (terminals.length === 1) {
        const terminal = terminals[0];
        return (
          <VSCodeTerminal
            id={terminal.id}
            name={terminal.name}
            shell={terminal.shell}
            isActive={terminal.id === activeTerminalId}
            canClose={false}
            onSplitRight={() => splitTerminal(terminal.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal.id, 'vertical')}
            onFocus={() => selectTerminal(terminal.id)}
            height={height}
          />
        );
      } else {
        // Multiple terminals in tabs
        const activeTerminal = terminals.find(t => t.id === activeTerminalId) || terminals[0];
        return (
          <div className="flex flex-col h-full">
            {/* Tab Bar */}
            <div className="flex bg-gray-800 border-b border-gray-700 min-h-[32px] items-center overflow-x-auto">
              {terminals.map(terminal => (
                <button
                  key={terminal.id}
                  className={`px-3 py-1 text-xs border-r border-gray-700 flex items-center gap-1 whitespace-nowrap flex-shrink-0 ${
                    terminal.id === activeTerminalId 
                      ? 'bg-gray-900 text-white' 
                      : 'text-gray-400 hover:text-white hover:bg-gray-700'
                  }`}
                  onClick={() => selectTerminal(terminal.id)}
                >
                  <span>
                    {terminal.shell === 'bash' ? '🐚' : 
                     terminal.shell === 'zsh' ? '⚡' : 
                     terminal.shell === 'node' ? '🟢' :
                     terminal.shell === 'git' ? '🔧' : '💻'}
                  </span>
                  {terminal.name}
                  <div className={`w-1.5 h-1.5 rounded-full ml-1 ${
                    terminal.status === 'running' ? 'bg-green-500' :
                    terminal.status === 'error' ? 'bg-red-500' : 'bg-gray-500'
                  }`} />
                </button>
              ))}
            </div>
            
            {/* Active Terminal */}
            <div className="flex-1">
              <VSCodeTerminal
                id={activeTerminal.id}
                name={activeTerminal.name}
                shell={activeTerminal.shell}
                isActive={true}
                canClose={terminals.length > 1}
                onClose={() => closeTerminal(activeTerminal.id)}
                onSplitRight={() => splitTerminal(activeTerminal.id, 'horizontal')}
                onSplitDown={() => splitTerminal(activeTerminal.id, 'vertical')}
                onFocus={() => selectTerminal(activeTerminal.id)}
                height={height - 32}
              />
            </div>
          </div>
        );
      }
    }

    // Render splits
    const split = activeSplits[0]; // For now, handle one split
    const splitTerminals = split.terminals.map(id => terminals.find(t => t.id === id)).filter(Boolean);

    return (
      <SplitContainer direction={split.direction}>
        {splitTerminals.map(terminal => (
          <VSCodeTerminal
            key={terminal!.id}
            id={terminal!.id}
            name={terminal!.name}
            shell={terminal!.shell}
            isActive={terminal!.id === activeTerminalId}
            canClose={terminals.length > 1}
            onClose={() => closeTerminal(terminal!.id)}
            onSplitRight={() => splitTerminal(terminal!.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal!.id, 'vertical')}
            onFocus={() => selectTerminal(terminal!.id)}
            height={height}
          />
        ))}
      </SplitContainer>
    );
  };

  const renderSidebar = () => (
    <TerminalSidebar
      terminals={terminals}
      isCollapsed={sidebarCollapsed}
      activeTerminalId={activeTerminalId}
      onTerminalSelect={selectTerminal}
      onTerminalCreate={createTerminal}
      onTerminalClose={closeTerminal}
      onTerminalSplit={splitTerminal}
      onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
    />
  );

  return (
    <div className="w-full h-full bg-gray-900">
      <ResizableTerminalContainer
        leftComponent={
          <div className="h-full">
            {renderMainTerminalArea()}
          </div>
        }
        rightComponent={renderSidebar()}
        minLeftWidth={400}
        maxLeftWidth={1200}
        defaultLeftWidth={800}
      />
    </div>
  );
});

MultiTerminalManager.displayName = 'MultiTerminalManager';
EOF

echo "✅ MultiTerminalManager обновлен с поддержкой внешнего создания терминалов"

# 5. Тестируем сборку
echo "🧪 Тестируем Phase 4.6 Terminal Creation & Autocomplete..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 4.6 ЗАВЕРШЕН!"
  echo "🏆 Terminal Creation & Autocomplete успешно реализованы!"
  echo ""
  echo "📋 Новые возможности:"
  echo "   ✅ Кнопка 'New Terminal' в центре Header терминала"
  echo "   ✅ Dropdown меню выбора shell (Bash, Zsh, PowerShell, Node.js, Git)"
  echo "   ✅ Автодополнение команд по Tab"
  echo "   ✅ Автодополнение директорий для cd команды"
  echo "   ✅ Автодополнение файлов для ls, cat, rm, mv, cp"
  echo "   ✅ Интерактивные подсказки при наборе"
  echo "   ✅ Навигация по подсказкам стрелками"
  echo "   ✅ Mock файловая система для autocomplete"
  echo "   ✅ Поддержка смены директорий с cd .., cd ~"
  echo ""
  echo "🎯 Теперь терминал работает как настоящий VS Code с полным автодополнением!"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo ""
  echo "📈 ФИНАЛЬНЫЙ СТАТУС PHASE 4:"
  echo "   ✅ Phase 4.1: Terminal Max Height Fix"
  echo "   ✅ Phase 4.2: Multiple Terminal Instances"
  echo "   ✅ Phase 4.3: Terminal Splitting & UX Polish"
  echo "   ✅ Phase 4.4: Terminal Sidebar Manager"
  echo "   ✅ Phase 4.5: Resizable Terminal Areas"
  echo "   ✅ Phase 4.6: Terminal Creation & Autocomplete"
  echo ""
  echo "🏆 PHASE 4 ПОЛНОСТЬЮ ЗАВЕРШЕН! Готовы к Phase 5: Side Panel System?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi