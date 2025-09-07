import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { SplitContainer } from './SplitContainer';
import { VSCodeTerminal } from './VSCodeTerminal';

interface TerminalInstance {
  id: string;
  name: string;
  shell: 'bash' | 'zsh' | 'powershell';
  isActive: boolean;
  splitId?: string;
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

export const MultiTerminalManager: React.FC<MultiTerminalManagerProps> = ({ height }) => {
  const [terminals, setTerminals] = useState<TerminalInstance[]>([
    {
      id: '1',
      name: 'bash',
      shell: 'bash',
      isActive: true
    }
  ]);
  
  const [splits, setSplits] = useState<Split[]>([]);
  const [activeTerminalId, setActiveTerminalId] = useState('1');

  const generateId = () => Date.now().toString() + Math.random().toString(36).substr(2, 5);

  const createTerminal = (shell: 'bash' | 'zsh' | 'powershell' = 'bash') => {
    const id = generateId();
    const newTerminal: TerminalInstance = {
      id,
      name: `${shell}-${terminals.filter(t => t.shell === shell).length + 1}`,
      shell,
      isActive: false
    };
    
    setTerminals(prev => [...prev, newTerminal]);
    setActiveTerminalId(id);
  };

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
    const newTerminal: TerminalInstance = {
      id: newTerminalId,
      name: `${originalTerminal.shell}-${terminals.filter(t => t.shell === originalTerminal.shell).length + 1}`,
      shell: originalTerminal.shell,
      isActive: false
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

  const renderTerminals = () => {
    const rootTerminals = terminals.filter(t => !splits.some(s => s.terminals.includes(t.id)));
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
            onNewTerminal={() => createTerminal()}
            onSplitRight={() => splitTerminal(terminal.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal.id, 'vertical')}
            onFocus={() => setActiveTerminalId(terminal.id)}
            height={height}
          />
        );
      } else {
        // Multiple terminals in tabs
        const activeTerminal = terminals.find(t => t.id === activeTerminalId) || terminals[0];
        return (
          <div className="flex flex-col h-full">
            {/* Tab Bar */}
            <div className="flex bg-gray-800 border-b border-gray-700 min-h-[32px] items-center">
              {terminals.map(terminal => (
                <button
                  key={terminal.id}
                  className={`px-3 py-1 text-xs border-r border-gray-700 ${
                    terminal.id === activeTerminalId 
                      ? 'bg-gray-900 text-white' 
                      : 'text-gray-400 hover:text-white hover:bg-gray-700'
                  }`}
                  onClick={() => setActiveTerminalId(terminal.id)}
                >
                  {terminal.shell === 'bash' ? '🐚' : terminal.shell === 'zsh' ? '⚡' : '💻'} {terminal.name}
                </button>
              ))}
              <button
                className="px-2 py-1 text-gray-400 hover:text-white hover:bg-gray-700"
                onClick={() => createTerminal()}
              >
                <Plus size={12} />
              </button>
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
                onNewTerminal={() => createTerminal()}
                onSplitRight={() => splitTerminal(activeTerminal.id, 'horizontal')}
                onSplitDown={() => splitTerminal(activeTerminal.id, 'vertical')}
                onFocus={() => setActiveTerminalId(activeTerminal.id)}
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
            onNewTerminal={() => createTerminal()}
            onSplitRight={() => splitTerminal(terminal!.id, 'horizontal')}
            onSplitDown={() => splitTerminal(terminal!.id, 'vertical')}
            onFocus={() => setActiveTerminalId(terminal!.id)}
            height={height}
          />
        ))}
      </SplitContainer>
    );
  };

  return (
    <div className="w-full h-full bg-gray-900">
      {renderTerminals()}
    </div>
  );
};
