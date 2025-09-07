import React, { useState, useRef } from 'react';
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
  const terminalManagerRef = useRef<{ createTerminal: (shell?: 'bash' | 'zsh' | 'powershell' | 'node' | 'git') => void } | null>(null);

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
    if (terminalManagerRef.current) {
      terminalManagerRef.current.createTerminal(shell);
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
          ref={terminalManagerRef}
        />
      </div>
    </div>
  );
};
