import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left Sidebar */}
        {panelState.leftVisible && (
          <LeftSidebar
            files={fileManager.fileTree}
            selectedFileId={fileManager.selectedFileId}
            onFileSelect={fileManager.openFile}
            onFileCreate={(parentId, name, type) => {
              if (type === 'file') {
                fileManager.createFile(parentId, name);
              } else {
                fileManager.createFolder(parentId, name);
              }
            }}
            onFileRename={fileManager.renameFile}
            onFileDelete={fileManager.deleteFile}
            onSearchQuery={fileManager.setSearchQuery}
          />
        )}
        
        {/* Main Editor Area */}
        <div className="flex-1 flex flex-col">
          <MainEditor
            openTabs={fileManager.openTabs}
            activeTab={fileManager.activeTab}
            closeTab={fileManager.closeTab}
            setActiveTab={fileManager.setActiveTab}
            updateFileContent={fileManager.updateFileContent}
          />
        </div>
        
        {/* Right Panel */}
        {panelState.rightVisible && (
          <RightPanel />
        )}
      </div>
      
      {/* Bottom Terminal */}
      {panelState.bottomVisible && (
        <BottomTerminal
          height={panelState.bottomHeight}
          onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
          onResize={(height: number) => panelState.setBottomHeight(height)}
        />
      )}
      
      {/* Status Bar */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={panelState.toggleStatus}
      />
    </div>
  );
};
