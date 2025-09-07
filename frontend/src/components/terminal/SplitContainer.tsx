import React, { useState, useRef } from 'react';

interface SplitContainerProps {
  direction: 'horizontal' | 'vertical';
  children: React.ReactNode[];
  minSize?: number;
}

export const SplitContainer: React.FC<SplitContainerProps> = ({
  direction,
  children,
  minSize = 100
}) => {
  const [sizes, setSizes] = useState<number[]>(
    new Array(children.length).fill(100 / children.length)
  );
  const [isDragging, setIsDragging] = useState(false);
  const [dragIndex, setDragIndex] = useState(-1);
  const containerRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = (index: number) => (e: React.MouseEvent) => {
    setIsDragging(true);
    setDragIndex(index);
    e.preventDefault();
  };

  React.useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || dragIndex === -1 || !containerRef.current) return;

      const container = containerRef.current;
      const rect = container.getBoundingClientRect();
      const totalSize = direction === 'horizontal' ? rect.width : rect.height;
      const mousePos = direction === 'horizontal' ? e.clientX - rect.left : e.clientY - rect.top;
      
      const newSizes = [...sizes];
      const currentPos = sizes.slice(0, dragIndex + 1).reduce((sum, size) => sum + (size / 100) * totalSize, 0);
      const diff = mousePos - currentPos;
      
      const leftPercent = ((sizes[dragIndex] / 100) * totalSize + diff) / totalSize * 100;
      const rightPercent = ((sizes[dragIndex + 1] / 100) * totalSize - diff) / totalSize * 100;
      
      if (leftPercent >= (minSize / totalSize * 100) && rightPercent >= (minSize / totalSize * 100)) {
        newSizes[dragIndex] = leftPercent;
        newSizes[dragIndex + 1] = rightPercent;
        setSizes(newSizes);
      }
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      setDragIndex(-1);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, dragIndex, sizes, direction, minSize]);

  if (children.length === 1) {
    return <div className="w-full h-full">{children[0]}</div>;
  }

  return (
    <div 
      ref={containerRef}
      className={`flex ${direction === 'horizontal' ? 'flex-row' : 'flex-col'} w-full h-full`}
    >
      {children.map((child, index) => (
        <React.Fragment key={index}>
          <div 
            className="flex-shrink-0"
            style={{
              [direction === 'horizontal' ? 'width' : 'height']: `${sizes[index]}%`
            }}
          >
            {child}
          </div>
          {index < children.length - 1 && (
            <div
              className={`flex-shrink-0 ${
                direction === 'horizontal' 
                  ? 'w-1 cursor-col-resize border-l border-gray-600 hover:border-blue-500' 
                  : 'h-1 cursor-row-resize border-t border-gray-600 hover:border-blue-500'
              } ${isDragging && dragIndex === index ? 'border-blue-500 bg-blue-500' : 'bg-gray-700'}`}
              onMouseDown={handleMouseDown(index)}
            />
          )}
        </React.Fragment>
      ))}
    </div>
  );
};
