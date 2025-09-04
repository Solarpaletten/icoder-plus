import { ChevronUp, ChevronDown, Circle, GitBranch, Wifi } from 'lucide-react';

interface StatusBarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function StatusBar({ isCollapsed, onToggle }: StatusBarProps) {
  if (isCollapsed) {
    return (
      <div 
        className="h-1 bg-blue-600 cursor-pointer hover:bg-blue-500 transition-colors"
        onClick={onToggle}
        title="Expand Status Bar"
      />
    );
  }

  return (
    <div className="h-6 bg-blue-600 flex items-center justify-between px-3 text-xs text-white">
      {/* Left Side */}
      <div className="flex items-center space-x-4">
        <div className="flex items-center">
          <Circle size={8} className="text-green-400 fill-current mr-1" />
          <span>Backend Connected</span>
        </div>
        
        <div className="flex items-center">
          <GitBranch size={12} className="mr-1" />
          <span>main</span>
        </div>
        
        <div className="flex items-center">
          <Wifi size={12} className="mr-1" />
          <span>API Ready</span>
        </div>
      </div>

      {/* Center */}
      <div className="flex items-center space-x-4">
        <span>JavaScript</span>
        <span>UTF-8</span>
        <span>Ln 1, Col 1</span>
      </div>

      {/* Right Side */}
      <div className="flex items-center space-x-2">
        <span>iCoder Plus starting...</span>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-blue-500 rounded"
          title="Collapse Status Bar"
        >
          <ChevronDown size={10} />
        </button>
      </div>
    </div>
  );
}
