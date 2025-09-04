import type { TabItem } from '../../types';

interface AppStatusBarProps {
  activeTab: TabItem | null;
  backendStatus: string;
}

export function AppStatusBar({ activeTab, backendStatus }: AppStatusBarProps) {
  return (
    <div className="h-6 bg-blue-600 flex items-center justify-between px-4 text-xs flex-shrink-0">
      <div className="flex items-center space-x-4">
        <span>✅ Backend: {backendStatus}</span>
        <span>🔄 Ready</span>
      </div>
      <div className="flex items-center space-x-2">
        <span>{activeTab?.language || 'Text'}</span>
        <span>UTF-8</span>
      </div>
    </div>
  );
}
