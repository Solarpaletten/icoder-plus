import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { ResizablePanelGroup } from './ResizablePanelGroup';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content - Трехколоночная структура */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left Column - File Sidebar */}
        {panelState.leftVisible && (
          <div className="w-64 flex-shrink-0">
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
          </div>
        )}
        
        {/* Center Column - Main Editor + Terminal */}
        <div className="flex-1 min-w-0">
          <ResizablePanelGroup
            direction="vertical"
            bottomHeight={panelState.bottomHeight}
            onBottomResize={panelState.setBottomHeight}
            bottomVisible={panelState.bottomVisible}
          >
            {/* Main Editor */}
            <MainEditor
              openTabs={fileManager.openTabs}
              activeTab={fileManager.activeTab}
              closeTab={fileManager.closeTab}
              setActiveTab={fileManager.setActiveTab}
              reorderTabs={fileManager.reorderTabs}
              updateFileContent={fileManager.updateFileContent}
            />
            
            {/* Bottom Terminal - только в центральной колонке */}
            <BottomTerminal
              height={panelState.bottomHeight}
              onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
              onResize={panelState.setBottomHeight}
            />
          </ResizablePanelGroup>
        </div>
        
        {/* Right Column - AI Assistant */}
        {panelState.rightVisible && (
          <div className="w-80 flex-shrink-0">
            <RightPanel />
          </div>
        )}
      </div>
      
      {/* Status Bar */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={panelState.toggleStatus}
      />
    </div>
  );
};
