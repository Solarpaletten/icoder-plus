import React, { useState, useRef, useEffect } from 'react';

interface ResizablePanelGroupProps {
  children: [React.ReactNode, React.ReactNode]; // [MainEditor, BottomTerminal]
  direction: 'vertical';
  bottomHeight: number;
  onBottomResize: (height: number) => void;
  bottomVisible: boolean;
}

export const ResizablePanelGroup: React.FC<ResizablePanelGroupProps> = ({
  children,
  bottomHeight,
  onBottomResize,
  bottomVisible
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const [mainEditor, bottomPanel] = children;

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    e.preventDefault();
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !containerRef.current) return;
      
      const containerRect = containerRef.current.getBoundingClientRect();
      const relativeY = e.clientY - containerRect.top;
      const newBottomHeight = containerRect.height - relativeY;
      
      // VS Code style limits: минимум 80px, максимум 95% от высоты (оставляем ~5% для кода)
      const minHeight = 80;
      const maxHeight = containerRect.height * 0.95; // Увеличено с 0.8 до 0.95
      const clampedHeight = Math.max(minHeight, Math.min(maxHeight, newBottomHeight));
      
      onBottomResize(clampedHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      // Prevent text selection during drag
      document.body.style.userSelect = 'none';
    } else {
      document.body.style.userSelect = '';
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.userSelect = '';
    };
  }, [isDragging, onBottomResize]);

  // Calculate remaining editor height
  const editorHeight = bottomVisible ? containerRef.current ? 
    Math.max(containerRef.current.getBoundingClientRect().height * 0.05, 40) : 40 : '100%';

  return (
    <div ref={containerRef} className="flex flex-col h-full">
      {/* Main Editor - динамическая высота */}
      <div 
        className="flex-shrink-0 min-h-0 overflow-hidden"
        style={{ 
          height: bottomVisible ? `calc(100% - ${bottomHeight}px - 1px)` : '100%',
          minHeight: typeof editorHeight === 'number' ? `${editorHeight}px` : '40px'
        }}
      >
        {mainEditor}
      </div>
      
      {/* Resize Handle - только когда терминал видим */}
      {bottomVisible && (
        <div
          className={`h-0.5 cursor-ns-resize bg-blue-500 hover:bg-blue-400 transition-colors flex-shrink-0
            ${isDragging ? 'bg-blue-400 h-1' : ''}`}
          onMouseDown={handleMouseDown}
          style={{ 
            boxShadow: isDragging ? '0 0 8px rgba(59, 130, 246, 0.5)' : 'none',
            zIndex: 10
          }}
        />
      )}
      
      {/* Bottom Panel - фиксированная высота */}
      {bottomVisible && (
        <div 
          className="flex-shrink-0 overflow-hidden"
          style={{ height: `${bottomHeight}px` }}
        >
          {bottomPanel}
        </div>
      )}
    </div>
  );
};
