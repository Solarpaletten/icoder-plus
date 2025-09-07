import React from 'react';
import { TabBar } from '../TabBar';
import { MonacoEditor } from '../MonacoEditor';
import type { TabItem } from '../../types';

interface MainEditorProps {
  openTabs: TabItem[];
  activeTab: TabItem | null;
  closeTab: (id: string) => void;
  setActiveTab: (id: string) => void;
  reorderTabs: (fromIndex: number, toIndex: number) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export const MainEditor: React.FC<MainEditorProps> = ({
  openTabs,
  activeTab,
  closeTab,
  setActiveTab,
  reorderTabs,
  updateFileContent
}) => {
  return (
    <div className="flex flex-col h-full bg-gray-900">
      {/* Enhanced Tab Bar */}
      <TabBar
        tabs={openTabs}
        activeTabId={activeTab?.id || null}
        onTabSelect={setActiveTab}
        onTabClose={closeTab}
        onTabsReorder={reorderTabs}
      />

      {/* Editor Content */}
      <div className="flex-1 relative">
        {activeTab ? (
          <MonacoEditor
            filename={activeTab.name}
            content={activeTab.content || ''}
            onChange={(content) => updateFileContent(activeTab.id, content)}
          />
        ) : (
          <div className="flex items-center justify-center h-full text-gray-400">
            <div className="text-center">
              <div className="text-6xl mb-4">📝</div>
              <h2 className="text-xl mb-2">Welcome to iCoder Plus</h2>
              <p className="text-gray-500">Open a file to start editing</p>
              <div className="mt-4 text-sm text-gray-600">
                <p>💡 Tip: Right-click on tabs for more options</p>
                <p>🖱️ Middle-click to close tabs quickly</p>
                <p>📂 Drag tabs to reorder them</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
