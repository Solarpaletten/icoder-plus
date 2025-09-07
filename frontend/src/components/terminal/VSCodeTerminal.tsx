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
