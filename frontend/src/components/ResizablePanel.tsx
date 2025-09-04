import { ReactNode, useState, useCallback, useRef } from 'react';

interface ResizablePanelProps {
  direction: 'horizontal' | 'vertical';
  defaultSize: number;
  minSize: number;
  maxSize?: number;
  children: ReactNode;
  isCollapsed?: boolean;
  onToggleCollapse?: () => void;
}

export function ResizablePanel({
  direction,
  defaultSize,
  minSize,
  maxSize = 9999,
  children,
  isCollapsed = false,
  onToggleCollapse
}: ResizablePanelProps) {
  const [size, setSize] = useState(defaultSize);
  const [isDragging, setIsDragging] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (isCollapsed) return;
    
    e.preventDefault();
    setIsDragging(true);
    
    const startPos = direction === 'horizontal' ? e.clientX : e.clientY;
    const startSize = size;

    const handleMouseMove = (e: MouseEvent) => {
      const currentPos = direction === 'horizontal' ? e.clientX : e.clientY;
      const delta = currentPos - startPos;
      
      let newSize = startSize + (direction === 'horizontal' ? delta : -delta);
      
      // Применяем ограничения
      if (newSize < minSize) newSize = minSize;
      if (newSize > maxSize) newSize = maxSize;
      
      setSize(newSize);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  }, [direction, size, minSize, maxSize, isCollapsed]);

  const currentSize = isCollapsed ? (direction === 'horizontal' ? 0 : 30) : size;

  return (
    <>
      <div
        ref={panelRef}
        className={`flex-shrink-0 transition-all duration-200 ${
          isCollapsed ? 'overflow-hidden' : 'overflow-visible'
        }`}
        style={{
          [direction === 'horizontal' ? 'width' : 'height']: `${currentSize}px`
        }}
      >
        {children}
      </div>
      
      {/* Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        className={`flex-shrink-0 bg-gray-600 hover:bg-blue-500 transition-colors group ${
          direction === 'horizontal' 
            ? 'w-1 cursor-col-resize hover:w-1.5' 
            : 'h-1 cursor-row-resize hover:h-1.5'
        } ${isDragging ? 'bg-blue-500' : ''} ${
          isCollapsed ? 'opacity-50' : ''
        }`}
        onDoubleClick={onToggleCollapse}
        title={`${direction === 'horizontal' ? 'Drag to resize width' : 'Drag to resize height'}. Double-click to ${isCollapsed ? 'expand' : 'collapse'}`}
      >
        <div className={`w-full h-full bg-blue-400 opacity-0 group-hover:opacity-100 transition-opacity ${
          isDragging ? 'opacity-100' : ''
        }`} />
      </div>
    </>
  );
}
