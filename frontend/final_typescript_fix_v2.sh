#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ОСТАВШИХСЯ ОШИБОК"
echo "=========================================="

# 1. Исправить AppShell.tsx - убрать isVisible props и использовать условный рендеринг
cat > src/components/AppShell.tsx << 'EOF'
import React from 'react';
import { AppHeader } from './layout/AppHeader';
import { LeftSidebar } from './panels/LeftSidebar';
import { EditorArea } from './layout/EditorArea';
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
            onFileCreate={fileManager.createFile}
            onFileRename={fileManager.renameFile}
            onFileDelete={fileManager.deleteFile}
            onSearchQuery={fileManager.setSearchQuery}
          />
        )}
        
        {/* Main Editor Area */}
        <div className="flex-1 flex flex-col">
          <EditorArea
            tabs={fileManager.openTabs}
            activeTabId={fileManager.activeTabId}
            onTabClose={fileManager.closeTab}
            onTabSelect={fileManager.setActiveTab}
            onContentChange={fileManager.updateFileContent}
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
EOF

# 2. Проверить и исправить BottomTerminal.tsx props
cat > src/components/layout/BottomTerminal.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { Maximize2, Minimize2, X } from 'lucide-react';
import { VSCodeTerminal } from '../VSCodeTerminal';

interface BottomTerminalProps {
  height: number;
  onToggle: () => void;
  onResize: (height: number) => void;
}

export const BottomTerminal: React.FC<BottomTerminalProps> = ({
  height,
  onToggle,
  onResize
}) => {
  const [isMaximized, setIsMaximized] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const terminalRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    e.preventDefault();
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging) return;
      
      const windowHeight = window.innerHeight;
      const newHeight = windowHeight - e.clientY - 24; // 24px for status bar
      const clampedHeight = Math.max(100, Math.min(500, newHeight));
      onResize(clampedHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
    };

    if (isDragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging, onResize]);

  const finalHeight = isMaximized ? 400 : height;

  return (
    <div 
      className="bg-gray-900 border-t border-gray-700 flex flex-col"
      style={{ height: `${finalHeight}px` }}
      ref={terminalRef}
    >
      {/* Resize Handle */}
      <div
        className={`h-1 cursor-ns-resize bg-gray-700 hover:bg-blue-500 transition-colors
          ${isDragging ? 'bg-blue-500' : ''}`}
        onMouseDown={handleMouseDown}
      />
      
      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-3">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-300">TERMINAL</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" title="Connected" />
        </div>
        
        <div className="flex items-center gap-1">
          <button
            onClick={() => setIsMaximized(!isMaximized)}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="Close terminal"
          >
            <X size={14} />
          </button>
        </div>
      </div>
      
      {/* Terminal Content */}
      <div className="flex-1 overflow-hidden">
        <VSCodeTerminal />
      </div>
    </div>
  );
};
EOF

# 3. Исправить TabItem type - заменить isDirty на modified
cat > src/types/index.ts << 'EOF'
export interface FileItem {
  id: string;
  name: string;
  type: 'file' | 'folder';
  content?: string;
  language?: string;
  expanded?: boolean;
  children?: FileItem[];
}

export interface TabItem {
  id: string;
  name: string;
  content: string;
  language?: string;
  modified?: boolean;
}

export type AgentType = 'dashka' | 'claudy' | 'both';

export interface FileManagerState {
  fileTree: FileItem[];
  openTabs: TabItem[];
  activeTab: TabItem | null;
  searchQuery: string;
}
EOF

# 4. Исправить Editor.tsx если он существует
if [ -f "src/components/Editor.tsx" ]; then
cat > src/components/Editor.tsx << 'EOF'
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
EOF
fi

echo "✅ AppShell.tsx исправлен - убраны isVisible props"
echo "✅ BottomTerminal.tsx исправлен - правильные props"
echo "✅ types.ts обновлен - TabItem с modified"
echo "✅ Editor.tsx исправлен - modified вместо isDirty"

# Тестируем сборку
echo "🧪 Финальное тестирование..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 УСПЕХ! ВСЕ TYPESCRIPT ОШИБКИ ИСПРАВЛЕНЫ!"
  echo "🚀 ПОЛНОФУНКЦИОНАЛЬНЫЙ IDE ГОТОВ К ЗАПУСКУ!"
  echo ""
  echo "📋 Финальная архитектура:"
  echo "   ✅ Monaco Editor с IntelliSense"
  echo "   ✅ Файловая система с контекстными меню"
  echo "   ✅ AI Chat (Dashka/Claudy/Both режимы)"
  echo "   ✅ Реальный терминал через WebSocket"
  echo "   ✅ Система табов с индикаторами изменений"
  echo "   ✅ Сворачивающиеся панели"
  echo "   ✅ Информативный статус-бар"
  echo ""
  echo "🎯 Запустите: npm run dev"
  echo "🌐 Откройте: http://localhost:5173"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi