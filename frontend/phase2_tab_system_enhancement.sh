#!/bin/bash

echo "🚀 PHASE 2: TAB SYSTEM ENHANCEMENT"
echo "================================="
echo "Цель: Сделать табы как в VS Code"

# 1. Создать улучшенный TabBar компонент с drag & drop
cat > src/components/TabBar.tsx << 'EOF'
import React, { useState, useRef } from 'react';
import { X, Plus, MoreHorizontal } from 'lucide-react';
import type { TabItem } from '../types';

interface TabBarProps {
  tabs: TabItem[];
  activeTabId: string | null;
  onTabSelect: (id: string) => void;
  onTabClose: (id: string) => void;
  onTabsReorder: (fromIndex: number, toIndex: number) => void;
}

interface TabContextMenuProps {
  x: number;
  y: number;
  tabId: string;
  onClose: () => void;
  onCloseTab: (id: string) => void;
  onCloseOthers: (id: string) => void;
  onCloseAll: () => void;
  onCloseToRight: (id: string) => void;
}

const TabContextMenu: React.FC<TabContextMenuProps> = ({
  x, y, tabId, onClose, onCloseTab, onCloseOthers, onCloseAll, onCloseToRight
}) => {
  return (
    <>
      <div 
        className="fixed inset-0 z-40" 
        onClick={onClose}
        onContextMenu={(e) => e.preventDefault()}
      />
      <div
        className="absolute bg-gray-800 text-white text-sm rounded shadow-lg z-50 border border-gray-600 py-1"
        style={{ top: y, left: x }}
      >
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseTab(tabId); onClose(); }}
        >
          Close
        </button>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseOthers(tabId); onClose(); }}
        >
          Close Others
        </button>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseToRight(tabId); onClose(); }}
        >
          Close to the Right
        </button>
        <div className="border-t border-gray-600 my-1"></div>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseAll(); onClose(); }}
        >
          Close All
        </button>
      </div>
    </>
  );
};

export const TabBar: React.FC<TabBarProps> = ({
  tabs,
  activeTabId,
  onTabSelect,
  onTabClose,
  onTabsReorder
}) => {
  const [draggedTab, setDraggedTab] = useState<string | null>(null);
  const [dragOverIndex, setDragOverIndex] = useState<number | null>(null);
  const [contextMenu, setContextMenu] = useState<{ x: number; y: number; tabId: string } | null>(null);
  const tabsContainerRef = useRef<HTMLDivElement>(null);

  const getFileIcon = (filename: string) => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const iconMap: { [key: string]: string } = {
      'ts': '🟦', 'tsx': '🟦', 'js': '🟨', 'jsx': '🟨',
      'json': '📄', 'md': '📝', 'html': '🌐', 'css': '🎨',
      'py': '🐍', 'go': '🟢', 'rs': '🦀', 'java': '☕'
    };
    return iconMap[ext || ''] || '📄';
  };

  const handleDragStart = (e: React.DragEvent, tabId: string, index: number) => {
    setDraggedTab(tabId);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', tabId);
  };

  const handleDragOver = (e: React.DragEvent, index: number) => {
    e.preventDefault();
    setDragOverIndex(index);
  };

  const handleDragEnd = () => {
    setDraggedTab(null);
    setDragOverIndex(null);
  };

  const handleDrop = (e: React.DragEvent, dropIndex: number) => {
    e.preventDefault();
    if (draggedTab) {
      const draggedIndex = tabs.findIndex(tab => tab.id === draggedTab);
      if (draggedIndex !== -1 && draggedIndex !== dropIndex) {
        onTabsReorder(draggedIndex, dropIndex);
      }
    }
    handleDragEnd();
  };

  const handleMouseDown = (e: React.MouseEvent, tabId: string) => {
    // Middle click to close
    if (e.button === 1) {
      e.preventDefault();
      onTabClose(tabId);
    }
  };

  const handleContextMenu = (e: React.MouseEvent, tabId: string) => {
    e.preventDefault();
    setContextMenu({ x: e.clientX, y: e.clientY, tabId });
  };

  const closeContextMenu = () => setContextMenu(null);

  const handleCloseOthers = (keepTabId: string) => {
    tabs.forEach(tab => {
      if (tab.id !== keepTabId) {
        onTabClose(tab.id);
      }
    });
  };

  const handleCloseToRight = (fromTabId: string) => {
    const fromIndex = tabs.findIndex(tab => tab.id === fromTabId);
    if (fromIndex !== -1) {
      tabs.slice(fromIndex + 1).forEach(tab => {
        onTabClose(tab.id);
      });
    }
  };

  const handleCloseAll = () => {
    tabs.forEach(tab => onTabClose(tab.id));
  };

  return (
    <div className="flex bg-gray-800 border-b border-gray-700 min-h-[40px] relative">
      <div 
        ref={tabsContainerRef}
        className="flex flex-1 overflow-x-auto scrollbar-none"
        style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
      >
        {tabs.map((tab, index) => (
          <div
            key={tab.id}
            draggable
            onDragStart={(e) => handleDragStart(e, tab.id, index)}
            onDragOver={(e) => handleDragOver(e, index)}
            onDragEnd={handleDragEnd}
            onDrop={(e) => handleDrop(e, index)}
            onMouseDown={(e) => handleMouseDown(e, tab.id)}
            onContextMenu={(e) => handleContextMenu(e, tab.id)}
            className={`group flex items-center px-3 py-2 border-r border-gray-700 cursor-pointer 
              min-w-[120px] max-w-[200px] relative transition-all duration-150
              ${tab.id === activeTabId 
                ? 'bg-gray-900 text-white border-t-2 border-t-blue-500' 
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
              }
              ${draggedTab === tab.id ? 'opacity-50' : ''}
              ${dragOverIndex === index ? 'bg-blue-900' : ''}`}
            onClick={() => onTabSelect(tab.id)}
          >
            {/* File Icon */}
            <span className="mr-2 text-sm">{getFileIcon(tab.name)}</span>
            
            {/* File Name */}
            <span className="truncate text-sm mr-2 flex-1">{tab.name}</span>
            
            {/* Modified Indicator */}
            {tab.modified && (
              <div 
                className="w-2 h-2 bg-white rounded-full mr-1 flex-shrink-0"
                title="Unsaved changes"
              />
            )}
            
            {/* Close Button */}
            <button
              className="opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-0.5 
                         flex-shrink-0 transition-opacity duration-150"
              onClick={(e) => {
                e.stopPropagation();
                onTabClose(tab.id);
              }}
              title="Close tab"
            >
              <X size={12} />
            </button>

            {/* Drag indicator */}
            {dragOverIndex === index && (
              <div className="absolute left-0 top-0 bottom-0 w-0.5 bg-blue-500" />
            )}
          </div>
        ))}
      </div>
      
      {/* New Tab Button */}
      <button
        className="px-3 py-2 text-gray-400 hover:text-white hover:bg-gray-700 
                   border-r border-gray-700 transition-colors duration-150"
        title="New tab"
      >
        <Plus size={16} />
      </button>

      {/* More options */}
      <button
        className="px-2 py-2 text-gray-400 hover:text-white hover:bg-gray-700 
                   transition-colors duration-150"
        title="More options"
      >
        <MoreHorizontal size={16} />
      </button>

      {/* Context Menu */}
      {contextMenu && (
        <TabContextMenu
          x={contextMenu.x}
          y={contextMenu.y}
          tabId={contextMenu.tabId}
          onClose={closeContextMenu}
          onCloseTab={onTabClose}
          onCloseOthers={handleCloseOthers}
          onCloseAll={handleCloseAll}
          onCloseToRight={handleCloseToRight}
        />
      )}
    </div>
  );
};
EOF

# 2. Обновить useFileManager для поддержки reorder
cat > src/hooks/useFileManager.ts << 'EOF'
import { useState, useCallback } from 'react';
import type { FileItem, TabItem } from '../types';
import { initialFiles } from '../utils/initialData';

export function useFileManager() {
  const [fileTree, setFileTree] = useState<FileItem[]>(initialFiles);
  const [openTabs, setOpenTabs] = useState<TabItem[]>([]);
  const [activeTab, setActiveTab] = useState<TabItem | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFileId, setSelectedFileId] = useState<string | null>(null);

  const generateId = () => Math.random().toString(36).substr(2, 9);

  const createFile = useCallback((parentId: string | null, name: string, content = '') => {
    const newFile: FileItem = {
      id: generateId(),
      name,
      type: 'file',
      content,
    };
    
    if (parentId) {
      setFileTree(prev => updateFileTree(prev, parentId, newFile));
    } else {
      setFileTree(prev => [...prev, newFile]);
    }
  }, []);

  const createFolder = useCallback((parentId: string | null, name: string) => {
    const newFolder: FileItem = {
      id: generateId(),
      name,
      type: 'folder',
      children: [],
    };
    
    if (parentId) {
      setFileTree(prev => updateFileTree(prev, parentId, newFolder));
    } else {
      setFileTree(prev => [...prev, newFolder]);
    }
  }, []);

  const updateFileTree = (files: FileItem[], parentId: string, newItem: FileItem): FileItem[] => {
    return files.map(file => {
      if (file.id === parentId && file.type === 'folder') {
        return {
          ...file,
          children: [...(file.children || []), newItem]
        };
      }
      if (file.children) {
        return {
          ...file,
          children: updateFileTree(file.children, parentId, newItem)
        };
      }
      return file;
    });
  };

  const openFile = useCallback((file: FileItem) => {
    if (file.type !== 'file') return;
    
    setSelectedFileId(file.id);
    
    const existingTab = openTabs.find(tab => tab.id === file.id);
    if (existingTab) {
      setActiveTab(existingTab);
      return;
    }

    const newTab: TabItem = {
      id: file.id,
      name: file.name,
      content: file.content || '',
      modified: false,
    };

    setOpenTabs(prev => [...prev, newTab]);
    setActiveTab(newTab);
  }, [openTabs]);

  const closeTab = useCallback((tabId: string) => {
    setOpenTabs(prev => {
      const filtered = prev.filter(tab => tab.id !== tabId);
      
      // If closing active tab, select another one
      if (activeTab?.id === tabId) {
        const currentIndex = prev.findIndex(tab => tab.id === tabId);
        if (filtered.length > 0) {
          const nextTab = filtered[Math.min(currentIndex, filtered.length - 1)];
          setActiveTab(nextTab);
        } else {
          setActiveTab(null);
        }
      }
      
      return filtered;
    });
  }, [activeTab]);

  const setActiveTabById = useCallback((tabId: string) => {
    const tab = openTabs.find(t => t.id === tabId);
    if (tab) {
      setActiveTab(tab);
    }
  }, [openTabs]);

  // NEW: Reorder tabs functionality
  const reorderTabs = useCallback((fromIndex: number, toIndex: number) => {
    setOpenTabs(prev => {
      const newTabs = [...prev];
      const [movedTab] = newTabs.splice(fromIndex, 1);
      newTabs.splice(toIndex, 0, movedTab);
      return newTabs;
    });
  }, []);

  const updateFileContent = useCallback((fileId: string, content: string) => {
    setOpenTabs(prev => prev.map(tab => 
      tab.id === fileId 
        ? { ...tab, content, modified: true }
        : tab
    ));
    
    if (activeTab?.id === fileId) {
      setActiveTab(prev => prev ? { ...prev, content, modified: true } : null);
    }
  }, [activeTab]);

  const renameFile = useCallback((id: string, newName: string) => {
    console.log('Rename file:', id, newName);
    // TODO: Implement rename logic
  }, []);

  const deleteFile = useCallback((id: string) => {
    console.log('Delete file:', id);
    // TODO: Implement delete logic
  }, []);

  return {
    // State
    fileTree,
    openTabs,
    activeTab,
    searchQuery,
    selectedFileId,
    
    // Actions
    createFile,
    createFolder,
    openFile,
    closeTab,
    setActiveTab: setActiveTabById,
    reorderTabs, // NEW
    updateFileContent,
    setSearchQuery,
    renameFile,
    deleteFile,
  };
}
EOF

# 3. Обновить MainEditor для использования нового TabBar
cat > src/components/panels/MainEditor.tsx << 'EOF'
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
EOF

# 4. Обновить AppShell для передачи reorderTabs
cat > src/components/AppShell.tsx << 'EOF'
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
            reorderTabs={fileManager.reorderTabs}
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
EOF

echo "✅ TabBar.tsx создан с drag & drop и контекстным меню"
echo "✅ useFileManager.ts обновлен с reorderTabs"
echo "✅ MainEditor.tsx интегрирован с новым TabBar"
echo "✅ AppShell.tsx обновлен"

# Тестируем сборку
echo "🧪 Тестируем Phase 2 Tab System Enhancement..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 PHASE 2 ЗАВЕРШЕН!"
  echo "🏆 Tab System как в VS Code готов!"
  echo ""
  echo "📋 Новые возможности табов:"
  echo "   ✅ Индикаторы несохраненных изменений (белый кружок)"
  echo "   ✅ Средняя кнопка мыши для закрытия"
  echo "   ✅ Drag & drop перестановка табов"
  echo "   ✅ Контекстное меню (Close, Close Others, Close All, Close to Right)"
  echo "   ✅ Иконки файлов по типам"
  echo "   ✅ Плавные анимации и hover эффекты"
  echo "   ✅ Кнопки New Tab и More Options"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "🎯 Следующий: Phase 5 (Side Panel System) или Phase 4 (Terminal fixes)?"
else
  echo "❌ Ошибки в сборке - проверьте консоль"
fi