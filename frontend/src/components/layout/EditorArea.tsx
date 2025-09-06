import { X, Circle } from 'lucide-react';
import { MonacoEditor } from '../MonacoEditor';
import type { FileManagerState, TabItem } from '../../types';

interface EditorAreaProps extends FileManagerState {
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function EditorArea({ 
  openTabs, 
  activeTab, 
  closeTab, 
  setActiveTab, 
  updateFileContent 
}: EditorAreaProps) {
  if (openTabs.length === 0) {
    return (
      <div className="flex-1 flex items-center justify-center bg-gray-900">
        <div className="text-center">
          <div className="text-6xl mb-4">🚀</div>
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2 - IDE Shell</h2>
          <p className="text-gray-400 mb-4">Professional Monaco Editor Integration</p>
          <div className="text-sm text-gray-500 space-y-1">
            <p>📁 Open files from Explorer</p>
            <p>⌨️ Full IntelliSense support</p>
            <p>🎨 Syntax highlighting</p>
            <p>📋 Advanced code editing</p>
          </div>
        </div>
      </div>
    );
  }

  const getFileIcon = (filename: string) => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const iconMap: Record<string, string> = {
      'js': '🟨', 'jsx': '🟨', 'ts': '🟦', 'tsx': '🟦',
      'html': '🟧', 'css': '🟪', 'scss': '🟪', 'sass': '🟪',
      'json': '🟩', 'md': '⬜', 'py': '🟨', 'java': '🟫',
      'cpp': '🟦', 'c': '🟦', 'cs': '🟪', 'php': '🟪',
      'rb': '🟥', 'go': '🟦', 'rs': '🟫', 'sh': '🟩'
    };
    return iconMap[ext || ''] || '📄';
  };

  return (
    <div className="flex-1 flex flex-col bg-gray-900">
      {/* Enhanced Tab Bar */}
      <div className="flex bg-gray-800 border-b border-gray-700 overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-3 py-2 border-r border-gray-700 cursor-pointer min-w-32 max-w-48 group ${
              activeTab?.id === tab.id 
                ? 'bg-gray-900 text-white border-b-2 border-blue-500' 
                : 'hover:bg-gray-700 text-gray-300'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            {/* File Icon */}
            <span className="mr-2 text-sm">{getFileIcon(tab.name)}</span>
            
            {/* File Name */}
            <span className="text-sm truncate flex-1">{tab.name}</span>
            
            {/* Modified Indicator */}
            {tab.isDirty && (
              <Circle 
                size={8} 
                className="ml-2 text-white fill-current" 
                title="Unsaved changes"
              />
            )}
            
            {/* Close Button */}
            <button
              onClick={(e) => { 
                e.stopPropagation(); 
                closeTab(tab); 
              }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded text-gray-400 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity"
              title="Close tab"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Monaco Editor */}
      <div className="flex-1 overflow-hidden">
        <MonacoEditor
          file={activeTab}
          onChange={updateFileContent}
        />
      </div>
    </div>
  );
}
