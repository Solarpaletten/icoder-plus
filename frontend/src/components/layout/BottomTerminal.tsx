import React, { useState } from 'react';
import { Maximize2, Minimize2, X, ChevronUp, ChevronDown, Terminal } from 'lucide-react';
import { MultiTerminalManager } from '../terminal/MultiTerminalManager';

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

  const handleMaximize = () => {
    if (isMaximized) {
      onResize(250);
      setIsMaximized(false);
    } else {
      const parentHeight = window.innerHeight - 100;
      const maxHeight = Math.floor(parentHeight * 0.9);
      onResize(maxHeight);
      setIsMaximized(true);
    }
  };

  const handleQuickResize = (percentage: number) => {
    const parentHeight = window.innerHeight - 100;
    const newHeight = Math.floor(parentHeight * percentage);
    onResize(newHeight);
    setIsMaximized(percentage >= 0.8);
  };

  return (
    <div className="bg-gray-900 border-t border-gray-700 flex flex-col h-full">
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3 flex-shrink-0">
        <div className="flex items-center gap-2">
          <Terminal size={14} className="text-gray-400" />
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
          <span className="text-xs text-gray-500">
            {height}px {isMaximized ? '(Maximized)' : ''}
          </span>
        </div>
        
        <div className="flex items-center gap-1">
          <button
            onClick={() => handleQuickResize(0.3)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title="Small (30%)"
          >
            <ChevronDown size={12} />
          </button>
          
          <button
            onClick={() => handleQuickResize(0.6)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title="Medium (60%)"
          >
            <ChevronUp size={12} />
          </button>
          
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white transition-colors"
            title={isMaximized ? "Restore" : "Maximize (90%)"}
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
      
      {/* Multi Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <MultiTerminalManager height={height - 32} />
      </div>
    </div>
  );
};
