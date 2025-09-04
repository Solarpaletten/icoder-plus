import { useState } from 'react';
import { AppHeader } from './layout/AppHeader';
import { FileSidebar } from './layout/FileSidebar';
import { EditorArea } from './layout/EditorArea';
import { RightPanel } from './layout/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export function AppShell() {
  const fileManager = useFileManager();
  const panelState = usePanelState();
  
  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white">
      {/* Header с меню */}
      <AppHeader />
      
      {/* Основная область */}
      <div className="flex-1 flex min-h-0">
        {/* Left Sidebar - File Explorer */}
        {!panelState.isLeftCollapsed && (
          <div 
            className="bg-gray-800 border-r border-gray-700 flex-shrink-0"
            style={{ width: panelState.leftWidth }}
          >
            <FileSidebar 
              {...fileManager}
              onToggle={() => panelState.toggleLeft()}
            />
          </div>
        )}
        
        {/* Collapsed Left Button */}
        {panelState.isLeftCollapsed && (
          <button
            onClick={() => panelState.toggleLeft()}
            className="w-8 bg-gray-800 border-r border-gray-700 flex items-center justify-center hover:bg-gray-700"
            title="Show Explorer"
          >
            <span className="text-gray-400 text-xs writing-mode-vertical">EXPLORER</span>
          </button>
        )}
        
        {/* Center - Editor Area */}
        <div className="flex-1 flex flex-col min-w-0">
          <EditorArea {...fileManager} />
          
          {/* Bottom Terminal */}
          <BottomTerminal 
            isCollapsed={panelState.isBottomCollapsed}
            onToggle={() => panelState.toggleBottom()}
            height={panelState.bottomHeight}
            onResize={(height: number) => panelState.setBottomHeight(height)}
          />
        </div>
        
        {/* Right Panel - AI Assistants */}
        {!panelState.isRightCollapsed && (
          <div 
            className="bg-gray-800 border-l border-gray-700 flex-shrink-0"
            style={{ width: panelState.rightWidth }}
          >
            <RightPanel 
              onToggle={() => panelState.toggleRight()}
            />
          </div>
        )}
        
        {/* Collapsed Right Button */}
        {panelState.isRightCollapsed && (
          <button
            onClick={() => panelState.toggleRight()}
            className="w-8 bg-gray-800 border-l border-gray-700 flex items-center justify-center hover:bg-gray-700"
            title="Show AI Assistant"
          >
            <span className="text-gray-400 text-xs writing-mode-vertical">AI</span>
          </button>
        )}
      </div>
      
      {/* Status Bar - синяя полоса */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={() => panelState.toggleStatus()}
      />
    </div>
  );
}
