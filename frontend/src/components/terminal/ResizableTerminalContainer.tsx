import React, { useState, useRef, useEffect } from 'react';

interface ResizableTerminalContainerProps {
  leftComponent: React.ReactNode;
  rightComponent: React.ReactNode;
  minLeftWidth?: number;
  maxLeftWidth?: number;
  defaultLeftWidth?: number;
}

export const ResizableTerminalContainer: React.FC<ResizableTerminalContainerProps> = ({
  leftComponent,
  rightComponent,
  minLeftWidth = 300,
  maxLeftWidth = 800,
  defaultLeftWidth = 600
}) => {
  const [leftWidth, setLeftWidth] = useState(defaultLeftWidth);
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const resizerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !containerRef.current) return;

      const containerRect = containerRef.current.getBoundingClientRect();
      const newWidth = e.clientX - containerRect.left;
      
      // Применяем ограничения
      const constrainedWidth = Math.max(
        minLeftWidth,
        Math.min(maxLeftWidth, newWidth)
      );
      
      setLeftWidth(constrainedWidth);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.body.style.cursor = 'default';
      document.body.style.userSelect = 'auto';
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, minLeftWidth, maxLeftWidth]);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  return (
    <div ref={containerRef} className="flex h-full bg-gray-900">
      {/* Left Component (Main Terminal Area) */}
      <div 
        className="flex-shrink-0 bg-gray-900"
        style={{ width: `${leftWidth}px` }}
      >
        {leftComponent}
      </div>
      
      {/* Resizer */}
      <div
        ref={resizerRef}
        className="w-1 bg-gray-700 hover:bg-blue-500 cursor-col-resize transition-colors duration-200 relative group"
        onMouseDown={handleMouseDown}
      >
        {/* Visual indicator */}
        <div className="absolute inset-y-0 -left-0.5 -right-0.5 bg-transparent group-hover:bg-blue-500/20 transition-colors" />
        
        {/* Drag handle dots */}
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
          <div className="flex flex-col gap-0.5">
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
            <div className="w-0.5 h-0.5 bg-gray-400 rounded-full"></div>
          </div>
        </div>
      </div>
      
      {/* Right Component (Terminal Sidebar) */}
      <div className="flex-1 bg-gray-800 min-w-0">
        {rightComponent}
      </div>
    </div>
  );
};
