import { usePanelResize } from "../hooks/usePanelResize";
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { ResizablePanelGroup } from './ResizablePanelGroup';
import { ResizablePanel } from './ResizablePanel';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export const AppShell: React.FC = () => {
  const fileManager = useFileManager();
  const panelState = usePanelState();
  const { sizes, updateLeftWidth, updateRightWidth, updateBottomHeight } = usePanelResize();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-gray-100">
      {/* Header */}
      <AppHeader />
      
      {/* Main Content - Resizable трехколоночная структура */}
      <div className="flex flex-1 overflow-hidden">
        
        {/* Left Resizable Sidebar */}
        {panelState.leftVisible && (
          <ResizablePanel
            direction="horizontal"
            initialSize={sizes.leftWidth}
            minSize={200}
            maxSize={800}
            onResize={updateLeftWidth}
            className="bg-gray-800 border-r border-gray-700"
          >
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
          </ResizablePanel>
        )}
        
        {/* Center Column - Main Editor + Terminal */}
        <div className="flex-1 min-w-0">
          <ResizablePanelGroup
            direction="vertical"
            bottomHeight={sizes.bottomHeight}
            onBottomResize={updateBottomHeight}
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
            
            {/* Bottom Terminal */}
            <BottomTerminal
              height={sizes.bottomHeight}
              onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
              onResize={updateBottomHeight}
            />
          </ResizablePanelGroup>
        </div>
        
        {/* Right Resizable Sidebar - AI Assistants */}
        {panelState.rightVisible && (
          <ResizablePanel
            direction="horizontal"
            initialSize={sizes.rightWidth}
            minSize={250}
            maxSize={600}
            onResize={updateRightWidth}
            className="bg-gray-800 border-l border-gray-700"
          >
            <RightPanel />
          </ResizablePanel>
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
