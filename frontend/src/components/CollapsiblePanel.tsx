import { ReactNode } from 'react';
import { ChevronLeft, ChevronRight, ChevronDown, ChevronUp } from 'lucide-react';

interface CollapsiblePanelProps {
  direction: 'horizontal' | 'vertical';
  isCollapsed: boolean;
  onToggle: () => void;
  title: string;
  children: ReactNode;
}

export function CollapsiblePanel({
  direction,
  isCollapsed,
  onToggle,
  title,
  children
}: CollapsiblePanelProps) {
  if (isCollapsed) {
    return (
      <div
        className={`flex items-center justify-center bg-gray-800 border-gray-700 cursor-pointer hover:bg-gray-700 transition-colors ${
          direction === 'horizontal' 
            ? 'border-r w-8 writing-mode-vertical' 
            : 'border-t h-8'
        }`}
        onClick={onToggle}
        title={`Expand ${title}`}
      >
        {direction === 'horizontal' ? (
          <div className="flex flex-col items-center">
            <ChevronRight size={14} className="text-gray-400" />
            <span className="text-xs text-gray-400 mt-1 transform rotate-90 whitespace-nowrap origin-center">
              {title}
            </span>
          </div>
        ) : (
          <div className="flex items-center space-x-2">
            <ChevronUp size={14} className="text-gray-400" />
            <span className="text-xs text-gray-400">{title}</span>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between p-2 bg-gray-750 border-b border-gray-700">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
          {title}
        </span>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
          title={`Collapse ${title}`}
        >
          {direction === 'horizontal' ? (
            <ChevronLeft size={12} />
          ) : (
            <ChevronDown size={12} />
          )}
        </button>
      </div>
      <div className="flex-1 overflow-hidden">
        {children}
      </div>
    </div>
  );
}
