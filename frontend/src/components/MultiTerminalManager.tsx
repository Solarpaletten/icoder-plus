import React, { useState, useRef } from 'react';
import { Plus, X, Square, Copy, RotateCw, ChevronDown, Terminal } from 'lucide-react';
import { VSCodeTerminal } from './VSCodeTerminal';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell';
  isActive: boolean;
  created: Date;
}

interface MultiTerminalManagerProps {
  height: number;
}

export const MultiTerminalManager: React.FC<MultiTerminalManagerProps> = ({ height }) => {
  const [terminals, setTerminals] = useState<TerminalInstance[]>([
    {
      id: '1',
      name: 'bash',
      shell: 'bash',
      isActive: true,
      created: new Date()
    }
  ]);
  
  const [splitMode, setSplitMode] = useState<'single' | 'vertical' | 'horizontal'>('single');
  const [showTerminalList, setShowTerminalList] = useState(false);
  const terminalRefs = useRef<{ [key: string]: HTMLDivElement | null }>({});

  const createNewTerminal = (shell: 'bash' | 'zsh' | 'powershell' = 'bash') => {
    const newTerminal: TerminalInstance = {
      id: Date.now().toString(),
      name: `${shell}-${terminals.length + 1}`,
      shell,
      isActive: false,
      created: new Date()
    };
    
    setTerminals(prev => [...prev, newTerminal]);
  };

  const removeTerminal = (id: string) => {
    if (terminals.length <= 1) return; // Keep at least one terminal
    
    setTerminals(prev => {
      const filtered = prev.filter(t => t.id !== id);
      // If removing active terminal, activate the first one
      const wasActive = prev.find(t => t.id === id)?.isActive;
      if (wasActive && filtered.length > 0) {
        filtered[0].isActive = true;
      }
      return filtered;
    });
  };

  const setActiveTerminal = (id: string) => {
    setTerminals(prev => prev.map(t => ({ ...t, isActive: t.id === id })));
  };

  const splitTerminal = (mode: 'vertical' | 'horizontal') => {
    setSplitMode(mode);
  };

  const getShellIcon = (shell: string) => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      default: return '📟';
    }
  };

  const activeTerminal = terminals.find(t => t.isActive) || terminals[0];
  const visibleTerminals = splitMode === 'single' ? [activeTerminal] : terminals.slice(0, 2);

  return (
    <div className="flex flex-col h-full bg-gray-900">
      {/* Terminal Tabs and Controls */}
      <div className="flex items-center justify-between bg-gray-800 border-b border-gray-700 px-3 py-1 min-h-[32px]">
        {/* Left: Terminal Tabs */}
        <div className="flex items-center gap-1 flex-1 overflow-x-auto">
          {terminals.map((terminal) => (
            <div
              key={terminal.id}
              className={`group flex items-center gap-1 px-2 py-1 rounded text-xs cursor-pointer
                ${terminal.isActive 
                  ? 'bg-gray-700 text-white' 
                  : 'text-gray-400 hover:text-gray-200 hover:bg-gray-700'
                }`}
              onClick={() => setActiveTerminal(terminal.id)}
            >
              <span className="text-xs">{getShellIcon(terminal.shell)}</span>
              <span className="truncate max-w-[80px]">{terminal.name}</span>
              {terminals.length > 1 && (
                <button
                  className="opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-0.5"
                  onClick={(e) => {
                    e.stopPropagation();
                    removeTerminal(terminal.id);
                  }}
                >
                  <X size={10} />
                </button>
              )}
            </div>
          ))}
        </div>

        {/* Right: Controls */}
        <div className="flex items-center gap-1">
          {/* Split Controls */}
          <div className="relative">
            <button
              className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
              onClick={() => setShowTerminalList(!showTerminalList)}
              title="Terminal options"
            >
              <ChevronDown size={12} />
            </button>
            
            {showTerminalList && (
              <>
                <div 
                  className="fixed inset-0 z-30" 
                  onClick={() => setShowTerminalList(false)}
                />
                <div className="absolute right-0 top-full mt-1 bg-gray-800 border border-gray-600 rounded shadow-lg z-40 min-w-[180px]">
                  <div className="py-1">
                    <div className="px-3 py-1 text-xs text-gray-500 border-b border-gray-700">New Terminal</div>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('bash'); setShowTerminalList(false); }}
                    >
                      🐚 Bash
                    </button>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('zsh'); setShowTerminalList(false); }}
                    >
                      ⚡ Zsh
                    </button>
                    <button
                      className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                      onClick={() => { createNewTerminal('powershell'); setShowTerminalList(false); }}
                    >
                      💻 PowerShell
                    </button>
                    
                    <div className="border-t border-gray-700 mt-1 pt-1">
                      <div className="px-3 py-1 text-xs text-gray-500">Split Terminal</div>
                      <button
                        className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                        onClick={() => { splitTerminal('vertical'); setShowTerminalList(false); }}
                      >
                        <Square size={10} className="rotate-90" />
                        Split Right
                      </button>
                      <button
                        className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                        onClick={() => { splitTerminal('horizontal'); setShowTerminalList(false); }}
                      >
                        <Square size={10} />
                        Split Down
                      </button>
                      
                      {splitMode !== 'single' && (
                        <button
                          className="w-full text-left px-3 py-2 text-xs hover:bg-gray-700 flex items-center gap-2"
                          onClick={() => { setSplitMode('single'); setShowTerminalList(false); }}
                        >
                          <Copy size={10} />
                          Unsplit
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* New Terminal Button */}
          <button
            className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
            onClick={() => createNewTerminal()}
            title="New terminal"
          >
            <Plus size={12} />
          </button>
        </div>
      </div>

      {/* Terminal Content Area */}
      <div className="flex-1 flex" style={{ height: `${height - 32}px` }}>
        {splitMode === 'single' ? (
          // Single Terminal
          <div className="w-full h-full">
            <VSCodeTerminal 
              isVisible={true}
              height={height - 32}
            />
          </div>
        ) : splitMode === 'vertical' ? (
          // Vertical Split (side by side)
          <>
            <div className="w-1/2 h-full border-r border-gray-700">
              <VSCodeTerminal 
                isVisible={true}
                height={height - 32}
              />
            </div>
            <div className="w-1/2 h-full">
              <VSCodeTerminal 
                isVisible={true}
                height={height - 32}
              />
            </div>
          </>
        ) : (
          // Horizontal Split (top and bottom)
          <>
            <div className="w-full h-1/2 border-b border-gray-700">
              <VSCodeTerminal 
                isVisible={true}
                height={(height - 32) / 2 - 1}
              />
            </div>
            <div className="w-full h-1/2">
              <VSCodeTerminal 
                isVisible={true}
                height={(height - 32) / 2}
              />
            </div>
          </>
        )}
      </div>
    </div>
  );
};
