import React from 'react';
import { Wifi, GitBranch, AlertCircle, CheckCircle } from 'lucide-react';

interface StatusBarProps {
  isCollapsed?: boolean;
  onToggle?: () => void;
}

export const StatusBar: React.FC<StatusBarProps> = ({ 
  isCollapsed = false, 
  onToggle = () => {} 
}) => {
  if (isCollapsed) {
    return (
      <div 
        className="h-1 bg-blue-500 cursor-pointer hover:bg-blue-400 transition-colors"
        onClick={onToggle}
        title="Expand status bar"
      />
    );
  }

  return (
    <div className="h-6 bg-blue-600 text-white text-xs flex items-center justify-between px-3">
      {/* Left Section */}
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-1">
          <CheckCircle size={12} className="text-green-300" />
          <span>Backend Connected</span>
        </div>
        
        <div className="flex items-center gap-1">
          <GitBranch size={12} />
          <span>main</span>
        </div>
        
        <div className="flex items-center gap-1">
          <Wifi size={12} />
          <span>api.icoder.swapoil.de</span>
        </div>
      </div>

      {/* Right Section */}
      <div className="flex items-center gap-4">
        <span>TypeScript</span>
        <span>UTF-8</span>
        <span>LF</span>
        <span>Ln 1, Col 1</span>
        
        <button 
          onClick={onToggle}
          className="hover:bg-blue-700 px-1 rounded"
          title="Collapse status bar"
        >
          ×
        </button>
      </div>
    </div>
  );
};
