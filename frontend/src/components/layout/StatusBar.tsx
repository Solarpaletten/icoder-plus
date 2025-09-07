import React from 'react';
import { GitBranch, Check, AlertCircle, Wifi, Bug, Play, Square } from 'lucide-react';

interface StatusBarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export const StatusBar: React.FC<StatusBarProps> = ({ isCollapsed, onToggle }) => {
  if (isCollapsed) return null;
  
  return (
    <div className="h-6 bg-blue-600 flex items-center justify-between px-4 text-xs text-white">
      <div className="flex items-center space-x-4">
        {/* Git Branch */}
        <div className="flex items-center space-x-1 hover:bg-blue-700 px-2 py-1 rounded cursor-pointer">
          <GitBranch size={12} />
          <span>main</span>
        </div>
        
        {/* Git Status */}
        <div className="flex items-center space-x-1">
          <Check size={12} className="text-green-300" />
          <span>Clean</span>
        </div>

        {/* Debug Status */}
        <div className="flex items-center space-x-1 hover:bg-blue-700 px-2 py-1 rounded cursor-pointer">
          <Bug size={12} />
          <span>No Debug</span>
        </div>
        
        {/* Connection Status */}
        <div className="flex items-center space-x-1">
          <Wifi size={12} className="text-green-300" />
          <span>Connected</span>
        </div>
        
        <span>TypeScript</span>
        <span>UTF-8</span>
      </div>
      <div className="flex items-center space-x-4">
        <span>Ln 1, Col 1</span>
        <span>Spaces: 2</span>
        <div className="flex items-center space-x-1">
          <AlertCircle size={12} />
          <span>0 errors</span>
        </div>
      </div>
    </div>
  );
};
