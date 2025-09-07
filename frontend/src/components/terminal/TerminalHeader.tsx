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
