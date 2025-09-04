import { useState, useRef, useCallback } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2 } from 'lucide-react';
import { Terminal } from '../Terminal';

interface BottomTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function BottomTerminal({ isCollapsed, onToggle }: BottomTerminalProps) {
  const [height, setHeight] = useState(200);
  const [isDragging, setIsDragging] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  const startPos = useRef(0);
  const startHeight = useRef(0);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (isCollapsed || isMaximized) return;
    
    e.preventDefault();
    setIsDragging(true);
    startPos.current = e.clientY;
    startHeight.current = height;

    const handleMouseMove = (e: MouseEvent) => {
      const deltaY = startPos.current - e.clientY;
      let newHeight = startHeight.current + deltaY;
      
      // Ограничения высоты
      if (newHeight < 100) newHeight = 100;
      if (newHeight > 600) newHeight = 600;
      
      setHeight(newHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  }, [height, isCollapsed, isMaximized]);

  const handleMaximize = () => {
    setIsMaximized(!isMaximized);
  };

  const currentHeight = isCollapsed ? 32 : (isMaximized ? '60vh' : `${height}px`);

  return (
    <div 
      className="border-t border-gray-700 bg-gray-900 transition-all duration-200 flex flex-col"
      style={{ height: currentHeight }}
    >
      {/* Resize Handle */}
      {!isCollapsed && !isMaximized && (
        <div
          onMouseDown={handleMouseDown}
          className={`h-1 bg-gray-600 hover:bg-blue-500 cursor-row-resize transition-colors ${
            isDragging ? 'bg-blue-500' : ''
          }`}
          title="Drag to resize terminal height"
        >
          <div className={`w-full h-full bg-blue-400 opacity-0 hover:opacity-100 transition-opacity ${
            isDragging ? 'opacity-100' : ''
          }`} />
        </div>
      )}

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
            title={isCollapsed ? "Expand terminal" : "Collapse terminal"}
          >
            {isCollapsed ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
          </button>
        </div>
      </div>

      {/* Terminal Content */}
      {!isCollapsed && (
        <div className="flex-1 overflow-hidden">
          <Terminal />
        </div>
      )}
    </div>
  );
}
