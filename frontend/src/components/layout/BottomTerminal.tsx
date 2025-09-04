import { useState, useRef } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2, X } from 'lucide-react';
import { Terminal } from '../Terminal';

interface BottomTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
  height: number;
  onResize: (height: number) => void;
}

export function BottomTerminal({ isCollapsed, onToggle, height, onResize }: BottomTerminalProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  const terminalRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
    const startY = e.clientY;
    const startHeight = height;

    const handleMouseMove = (ev: MouseEvent) => {
      const deltaY = startY - ev.clientY;
      const newHeight = Math.max(80, Math.min(600, startHeight + deltaY));
      onResize(newHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  };

  const handleMaximize = () => {
    if (isMaximized) {
      onResize(200);
      setIsMaximized(false);
    } else {
      onResize(400);
      setIsMaximized(true);
    }
  };

  if (isCollapsed) {
    return (
      <div 
        className="h-6 bg-gray-800 border-t border-gray-700 flex items-center justify-between px-3 cursor-pointer hover:bg-gray-700"
        onClick={onToggle}
      >
        <span className="text-xs text-gray-400">Terminal</span>
        <ChevronUp size={12} className="text-gray-400" />
      </div>
    );
  }

  return (
    <div 
      ref={terminalRef}
      className="flex flex-col bg-gray-900 border-t border-gray-700"
      style={{ height: `${height}px` }}
    >
      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        className={`h-1 w-full cursor-row-resize border-t-2 transition-colors ${
          isDragging ? 'border-blue-500' : 'border-transparent hover:border-blue-400'
        }`}
        title="Drag to resize terminal height"
      >
        <div className={`w-full h-full bg-blue-400 opacity-0 hover:opacity-100 transition-opacity ${
          isDragging ? 'opacity-100' : ''
        }`} />
      </div>

      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 flex items-center justify-between px-3 border-b border-gray-700 flex-shrink-0">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Terminal</span>
        
        <div className="flex items-center space-x-1">
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={12} /> : <Maximize2 size={12} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title="Collapse terminal"
          >
            <ChevronDown size={14} />
          </button>
        </div>
      </div>

      {/* Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <Terminal />
      </div>
    </div>
  );
}
