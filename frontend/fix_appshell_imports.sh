#!/bin/bash

echo "🔧 FIX APPSHELL IMPORTS"
echo "======================="
echo "Цель: Исправить импорты в AppShell.tsx согласно текущей структуре"

# Исправить импорты в AppShell.tsx
cat > src/components/AppShell.tsx << 'EOF'
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { MainEditor } from './panels/MainEditor';
import { RightPanel } from './panels/RightPanel';  // ИСПРАВЛЕНО: из panels/, не layout/
import { BottomTerminal } from './layout/BottomTerminal';  // ИСПРАВЛЕНО: из layout/, не panels/
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
      
      {/* Main Content - Трехколоночная структура */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left Column - File Explorer */}
        <div className="w-64 flex-shrink-0 border-r border-gray-700">
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
        
        {/* Center Column - Main Editor + Terminal */}
        <div className="flex-1 min-w-0 flex flex-col">
          {/* Editor Area */}
          <div 
            className="flex-shrink-0"
            style={{ 
              height: panelState.bottomVisible 
                ? `calc(100% - ${panelState.bottomHeight}px)` 
                : '100%' 
            }}
          >
            <MainEditor
              openTabs={fileManager.openTabs}
              activeTab={fileManager.activeTab}
              closeTab={fileManager.closeTab}
              setActiveTab={fileManager.setActiveTab}
              reorderTabs={fileManager.reorderTabs}
              updateFileContent={fileManager.updateFileContent}
            />
          </div>
          
          {/* Bottom Terminal */}
          {panelState.bottomVisible && (
            <div 
              className="flex-shrink-0 border-t border-gray-700"
              style={{ height: `${panelState.bottomHeight}px` }}
            >
              <BottomTerminal
                height={panelState.bottomHeight}
                onToggle={() => panelState.setBottomVisible(!panelState.bottomVisible)}
                onResize={panelState.setBottomHeight}
              />
            </div>
          )}
        </div>
        
        {/* Right Column - AI Assistant */}
        <div className="w-80 flex-shrink-0 border-l border-gray-700">
          <RightPanel />
        </div>
      </div>
      
      {/* Status Bar */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={panelState.toggleStatus}
      />
    </div>
  );
};
EOF

echo "✅ AppShell.tsx исправлен с правильными импортами"
echo "✅ RightPanel импортируется из panels/"
echo "✅ BottomTerminal импортируется из layout/"

# Тестируем сборку
echo "🧪 Тестируем исправления импортов..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 ИМПОРТЫ ИСПРАВЛЕНЫ!"
  echo "🏆 AppShell.tsx компилируется без ошибок!"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🔍 Нажмите Ctrl+Shift+F для тестирования поиска!"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi