import { Menu, Settings, Code } from 'lucide-react';
import type { TabItem } from '../../types';

interface AppHeaderProps {
  activeTab: TabItem | null;
  onMenuToggle: () => void;
}

export function AppHeader({ activeTab, onMenuToggle }: AppHeaderProps) {
  return (
    <header className="h-10 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4 flex-shrink-0">
      <div className="flex items-center space-x-4">
        <button onClick={onMenuToggle} className="p-1.5 hover:bg-gray-700 rounded">
          <Menu size={16} />
        </button>
        
        <div className="flex items-center space-x-3">
          <div className="w-4 h-4 bg-blue-500 rounded-sm flex items-center justify-center">
            <Code size={10} className="text-white" />
          </div>
          <span className="text-sm font-medium">iCoder Plus</span>
          <span className="text-xs text-gray-400">v2.2</span>
        </div>
      </div>

      <div className="flex items-center space-x-4">
        <div className="px-3 py-1 bg-blue-600 rounded text-xs font-medium">
          {activeTab?.name || 'Welcome'}
        </div>
        
        <button className="p-1.5 hover:bg-gray-700 rounded">
          <Settings size={14} />
        </button>
      </div>
    </header>
  );
}
