import React from 'react';
import { X } from 'lucide-react';
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
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-light text-primary mb-2">iCoder Plus v2.0</h2>
          <p className="text-gray-400 mb-4">Clean TypeScript Architecture</p>
          <p className="text-sm text-gray-500">Select a file from the explorer to start editing</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col">
      {/* Tabs */}
      <div className="flex bg-surface border-b border-border overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-3 py-2 border-r border-border cursor-pointer min-w-32 ${
              activeTab?.id === tab.id ? 'bg-background' : 'hover:bg-gray-700'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            <span className="text-sm truncate flex-1">{tab.name}</span>
            <button
              onClick={(e) => { e.stopPropagation(); closeTab(tab); }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Editor Content */}
      {activeTab && (
        <div className="flex-1 overflow-hidden">
          <textarea
            value={activeTab.content}
            onChange={(e) => updateFileContent(activeTab.id, e.target.value)}
            className="w-full h-full p-4 bg-background text-white font-mono text-sm resize-none outline-none"
            placeholder="Start typing your code..."
            spellCheck={false}
          />
        </div>
      )}
    </div>
  );
}
