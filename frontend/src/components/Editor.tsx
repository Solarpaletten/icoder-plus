import React from 'react';
import { X } from 'lucide-react';
import { MonacoEditor } from './MonacoEditor';
import type { TabItem } from '../types';

interface EditorProps {
  tabs: TabItem[];
  activeTabId: string | null;
  onTabClose: (id: string) => void;
  onTabSelect: (id: string) => void;
  onContentChange: (id: string, content: string) => void;
}

export const Editor: React.FC<EditorProps> = ({
  tabs,
  activeTabId,
  onTabClose,
  onTabSelect,
  onContentChange
}) => {
  const activeTab = tabs.find(tab => tab.id === activeTabId);

  return (
    <div className="flex flex-col h-full">
      {/* Tabs */}
      <div className="flex bg-gray-800 border-b border-gray-700">
        {tabs.map((tab) => (
          <div
            key={tab.id}
            className={`flex items-center px-4 py-2 border-r border-gray-700 cursor-pointer
              ${tab.id === activeTabId ? 'bg-gray-900 text-white' : 'bg-gray-800 text-gray-300 hover:bg-gray-700'}`}
            onClick={() => onTabSelect(tab.id)}
          >
            <span className="text-sm">{tab.name}</span>
            {tab.modified && <span className="ml-2 w-2 h-2 bg-orange-400 rounded-full"></span>}
            <button
              className="ml-2 opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-1"
              onClick={(e) => {
                e.stopPropagation();
                onTabClose(tab.id);
              }}
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Editor Content */}
      <div className="flex-1">
        {activeTab ? (
          <MonacoEditor
            filename={activeTab.name}
            content={activeTab.content}
            onChange={(content) => onContentChange(activeTab.id, content)}
          />
        ) : (
          <div className="flex items-center justify-center h-full text-gray-400">
            <div className="text-center">
              <div className="text-6xl mb-4">📝</div>
              <h2 className="text-xl mb-2">No file open</h2>
              <p>Select a file to start editing</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
