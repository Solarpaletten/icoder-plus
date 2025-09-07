import React from 'react';
import { Plus, X, Square, GitBranch, Maximize2, ChevronRight, ChevronDown } from 'lucide-react';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell' | 'node' | 'git';
  status: 'running' | 'stopped' | 'error';
  isActive: boolean;
  workingDirectory?: string;
}

interface TerminalSidebarProps {
  terminals: TerminalInstance[];
  isCollapsed: boolean;
  activeTerminalId: string;
  onTerminalSelect: (id: string) => void;
  onTerminalCreate: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void;
  onTerminalClose: (id: string) => void;
  onTerminalSplit: (id: string, direction: 'horizontal' | 'vertical') => void;
  onToggleCollapse: () => void;
}

export const TerminalSidebar: React.FC<TerminalSidebarProps> = ({
  terminals,
  isCollapsed,
  activeTerminalId,
  onTerminalSelect,
  onTerminalCreate,
  onTerminalClose,
  onTerminalSplit,
  onToggleCollapse
}) => {
  const getShellIcon = (shell: string) => {
    switch (shell) {
      case 'bash': return '🐚';
      case 'zsh': return '⚡';
      case 'powershell': return '💻';
      case 'node': return '🟢';
      case 'git': return '🔧';
      default: return '💻';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running': return 'bg-green-500';
      case 'stopped': return 'bg-gray-500';
      case 'error': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  if (isCollapsed) {
    return (
      <div className="w-12 bg-gray-800 border-l border-gray-700 flex flex-col">
        <button
          onClick={onToggleCollapse}
          className="p-2 hover:bg-gray-700 text-gray-400 hover:text-white transition-colors border-b border-gray-700"
          title="Expand Terminal Panel"
        >
          <ChevronRight size={14} />
        </button>
        
        <div className="flex-1 flex flex-col gap-1 p-2 overflow-y-auto">
          {terminals.map(terminal => (
            <button
              key={terminal.id}
              onClick={() => onTerminalSelect(terminal.id)}
              className={`w-8 h-8 rounded flex items-center justify-center text-sm transition-colors relative ${
                terminal.id === activeTerminalId
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
              title={`${terminal.name} (${terminal.shell})`}
            >
              <span className="text-sm">{getShellIcon(terminal.shell)}</span>
              <div className={`absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full ${getStatusColor(terminal.status)}`} />
            </button>
          ))}
          
          <button
            onClick={() => onTerminalCreate()}
            className="w-8 h-8 rounded bg-gray-700 hover:bg-gray-600 flex items-center justify-center text-gray-300 hover:text-white transition-colors mt-2"
            title="New Terminal"
          >
            <Plus size={12} />
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full bg-gray-800 border-l border-gray-700 flex flex-col min-w-0">
      {/* Header */}
      <div className="h-8 bg-gray-900 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
        <div className="flex items-center gap-2 min-w-0">
          <span className="text-xs font-medium text-gray-300 uppercase tracking-wide truncate">
            TERMINALS
          </span>
          <span className="text-xs text-gray-500 flex-shrink-0">({terminals.length})</span>
        </div>
        
        <div className="flex items-center gap-1 flex-shrink-0">
          <button
            onClick={() => onTerminalCreate()}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white transition-colors"
            title="New Terminal"
          >
            <Plus size={12} />
          </button>
          
          <button
            onClick={onToggleCollapse}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white transition-colors"
            title="Collapse Panel"
          >
            <ChevronDown size={12} />
          </button>
        </div>
      </div>

      {/* Terminal List */}
      <div className="flex-1 overflow-y-auto">
        {terminals.map(terminal => (
          <div
            key={terminal.id}
            className={`group border-b border-gray-700 ${
              terminal.id === activeTerminalId ? 'bg-gray-700' : 'hover:bg-gray-750'
            }`}
          >
            <div
              className="p-3 cursor-pointer"
              onClick={() => onTerminalSelect(terminal.id)}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <span className="text-sm flex-shrink-0">{getShellIcon(terminal.shell)}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium text-gray-200 truncate">
                        {terminal.name}
                      </span>
                      <div className={`w-2 h-2 rounded-full flex-shrink-0 ${getStatusColor(terminal.status)}`} />
                    </div>
                    {terminal.workingDirectory && (
                      <div className="text-xs text-gray-400 truncate mt-1">
                        {terminal.workingDirectory}
                      </div>
                    )}
                  </div>
                </div>
                
                {/* Terminal Actions */}
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onTerminalSplit(terminal.id, 'horizontal');
                    }}
                    className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                    title="Split Right"
                  >
                    <Square size={10} className="rotate-90" />
                  </button>
                  
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onTerminalSplit(terminal.id, 'vertical');
                    }}
                    className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                    title="Split Down"
                  >
                    <Square size={10} />
                  </button>
                  
                  {terminals.length > 1 && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onTerminalClose(terminal.id);
                      }}
                      className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-red-400"
                      title="Close Terminal"
                    >
                      <X size={10} />
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Footer - Quick Actions */}
      <div className="border-t border-gray-700 p-2 flex-shrink-0">
        <div className="text-xs text-gray-500 mb-2">SHELL TYPES</div>
        <div className="grid grid-cols-2 gap-1">
          {(['bash', 'zsh', 'powershell', 'node'] as const).map(shell => (
            <button
              key={shell}
              onClick={() => onTerminalCreate(shell)}
              className="p-2 text-xs bg-gray-700 hover:bg-gray-600 rounded flex items-center gap-1 text-gray-300 hover:text-white transition-colors"
              title={`New ${shell} Terminal`}
            >
              <span className="flex-shrink-0">{getShellIcon(shell)}</span>
              <span className="capitalize truncate">{shell}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
