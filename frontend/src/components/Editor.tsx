import { X } from 'lucide-react';
import { SmartCodeEditor } from './SmartCodeEditor';
import type { FileManagerState, TabItem } from '../types';

interface EditorProps extends FileManagerState {
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function Editor({ 
  openTabs, 
  activeTab, 
  closeTab, 
  setActiveTab, 
  updateFileContent 
}: EditorProps) {
  if (openTabs.length === 0) {
    return (
      <div className="h-full flex items-center justify-center bg-gray-900">
        <div className="text-center">
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2</h2>
          <p className="text-gray-400 mb-4">Clean TypeScript Architecture</p>
          <p className="text-sm text-gray-500">Select a file from the explorer to start editing</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col bg-gray-900">
      {/* Tabs */}
      <div className="flex bg-gray-800 border-b border-gray-700 overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-4 py-2 border-r border-gray-700 cursor-pointer min-w-32 ${
              activeTab?.id === tab.id 
                ? 'bg-gray-900 text-white border-b-2 border-blue-500' 
                : 'hover:bg-gray-700 text-gray-300'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            <span className="text-sm truncate flex-1">{tab.name}</span>
            {tab.isDirty && <span className="ml-2 w-2 h-2 bg-orange-400 rounded-full"></span>}
            <button
              onClick={(e) => { e.stopPropagation(); closeTab(tab); }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Editor Content */}
      {activeTab && (
        <div className="flex-1 overflow-hidden">
          <SmartCodeEditor
            content={activeTab.content}
            onChange={(content) => updateFileContent(activeTab.id, content)}
            language={activeTab.language}
          />
        </div>
      )}
    </div>
  );
}
