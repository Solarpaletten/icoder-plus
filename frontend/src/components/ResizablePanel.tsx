import { ReactNode, useState, useCallback, useRef, useEffect } from 'react';

interface ResizablePanelProps {
  direction: 'horizontal' | 'vertical';
  defaultSize?: number;
  initialSize?: number;
  minSize: number;
  maxSize?: number;
  children: ReactNode;
  isCollapsed?: boolean;
  onToggleCollapse?: () => void;
  onResize?: (size: number) => void;
  className?: string;
}

export function ResizablePanel({
  direction,
  defaultSize,
  initialSize,
  minSize,
  maxSize = 9999,
  children,
  isCollapsed = false,
  onToggleCollapse,
  onResize,
  className = ''
}: ResizablePanelProps) {
  const [size, setSize] = useState(initialSize || defaultSize || minSize);
  const [isDragging, setIsDragging] = useState(false);
  const [isHovering, setIsHovering] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);

  // Синхронизация с внешним состоянием
  useEffect(() => {
    const newSize = initialSize || defaultSize;
    if (newSize && newSize !== size) {
      setSize(newSize);
    }
  }, [initialSize, defaultSize]);

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
      newSize = Math.max(minSize, Math.min(maxSize, newSize));
      
      setSize(newSize);
      onResize?.(newSize);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
    document.body.style.cursor = direction === 'horizontal' ? 'col-resize' : 'row-resize';
    document.body.style.userSelect = 'none';
  }, [direction, size, minSize, maxSize, isCollapsed, onResize]);

  const currentSize = isCollapsed ? (direction === 'horizontal' ? 0 : 30) : size;

  return (
    <>
      <div
        ref={panelRef}
        className={`flex-shrink-0 transition-all duration-200 ${className} ${
          isCollapsed ? 'overflow-hidden' : 'overflow-visible'
        }`}
        style={{
          [direction === 'horizontal' ? 'width' : 'height']: `${currentSize}px`
        }}
      >
        {children}
      </div>
      
      {/* Enhanced Resize Handle */}
      <div
        onMouseDown={handleMouseDown}
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => setIsHovering(false)}
        onDoubleClick={onToggleCollapse}
        className={`flex-shrink-0 group relative transition-all duration-150
          ${direction === 'horizontal' 
            ? 'w-1 cursor-col-resize hover:w-1.5' 
            : 'h-1 cursor-row-resize hover:h-1.5'
          }
          ${isDragging || isHovering 
            ? 'bg-blue-500 shadow-lg shadow-blue-500/50' 
            : 'bg-gray-600 hover:bg-blue-400'
          }
          ${isCollapsed ? 'opacity-50' : ''}
        `}
        title={`Drag to resize ${direction === 'horizontal' ? 'width' : 'height'}. Double-click to ${isCollapsed ? 'expand' : 'collapse'}`}
      >
        {/* Animated indicator */}
        <div className={`absolute inset-0 transition-all duration-200
          ${isDragging || isHovering ? 'bg-blue-400 opacity-100' : 'bg-transparent opacity-0'}
        `} />
        
        {/* Enhanced Dots indicator */}
        <div className={`absolute ${
          direction === 'horizontal' 
            ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' 
            : 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-90'
        } transition-opacity duration-200 ${
          isDragging || isHovering ? 'opacity-100' : 'opacity-0'
        }`}>
          <div className="flex gap-0.5">
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
            <div className="w-0.5 h-0.5 bg-white rounded-full shadow-sm"></div>
          </div>
        </div>
      </div>
    </>
  );
}
