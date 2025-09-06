#!/bin/bash

echo "🔧 СИНХРОНИЗАЦИЯ АРХИТЕКТУРЫ РЕДАКТОРА"
echo "===================================="
echo "Убираем дублирование EditorArea ↔ MainEditor"

# 1. Архивируем EditorArea.tsx (создаем backup)
if [ -f "src/components/layout/EditorArea.tsx" ]; then
  mkdir -p archive
  cp src/components/layout/EditorArea.tsx archive/EditorArea.tsx.backup
  echo "✅ EditorArea.tsx заархивирован в archive/"
fi

# 2. Создаем правильный MainEditor.tsx как единственный центральный компонент
cat > src/components/panels/MainEditor.tsx << 'EOF'
import React from 'react';
import { X, Plus } from 'lucide-react';
import { MonacoEditor } from '../MonacoEditor';
import type { TabItem } from '../../types';

interface MainEditorProps {
  openTabs: TabItem[];
  activeTab: TabItem | null;
  closeTab: (id: string) => void;
  setActiveTab: (id: string) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export const MainEditor: React.FC<MainEditorProps> = ({
  openTabs,
  activeTab,
  closeTab,
  setActiveTab,
  updateFileContent
}) => {
  return (
    <div className="flex flex-col h-full bg-gray-900">
      {/* Tab Bar */}
      <div className="flex bg-gray-800 border-b border-gray-700 min-h-[40px]">
        <div className="flex flex-1 overflow-x-auto">
          {openTabs.map((tab) => (
            <div
              key={tab.id}
              className={`group flex items-center px-3 py-2 border-r border-gray-700 cursor-pointer min-w-0 max-w-[200px]
                ${tab.id === activeTab?.id 
                  ? 'bg-gray-900 text-white border-t-2 border-t-blue-500' 
                  : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
                }`}
              onClick={() => setActiveTab(tab.id)}
            >
              {/* File Icon */}
              <div className="mr-2 flex-shrink-0">
                <div className="w-4 h-4 bg-blue-500 rounded-sm flex items-center justify-center text-xs text-white">
                  {tab.name.split('.').pop()?.charAt(0)?.toUpperCase() || 'F'}
                </div>
              </div>
              
              {/* File Name */}
              <span className="truncate text-sm mr-2">{tab.name}</span>
              
              {/* Modified Indicator */}
              {tab.modified && (
                <div className="w-2 h-2 bg-white rounded-full mr-1 flex-shrink-0" />
              )}
              
              {/* Close Button */}
              <button
                className="ml-auto opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-0.5 flex-shrink-0"
                onClick={(e) => {
                  e.stopPropagation();
                  closeTab(tab.id);
                }}
                aria-label="Close tab"
              >
                <X size={14} />
              </button>
            </div>
          ))}
        </div>
        
        {/* New Tab Button */}
        <button
          className="px-3 py-2 text-gray-400 hover:text-white hover:bg-gray-700"
          aria-label="New tab"
        >
          <Plus size={16} />
        </button>
      </div>

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
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
EOF

# 3. Обновляем AppShell.tsx для использования только MainEditor
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

# 4. Удаляем EditorArea.tsx чтобы избежать конфликтов
if [ -f "src/components/layout/EditorArea.tsx" ]; then
  rm src/components/layout/EditorArea.tsx
  echo "✅ EditorArea.tsx удален (дублирование устранено)"
fi

# 5. Обновляем useFileManager для правильной работы с setActiveTab
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
    setOpenTabs(prev => prev.filter(tab => tab.id !== tabId));
    setActiveTab(prev => {
      if (prev?.id === tabId) {
        const remainingTabs = openTabs.filter(tab => tab.id !== tabId);
        return remainingTabs.length > 0 ? remainingTabs[remainingTabs.length - 1] : null;
      }
      return prev;
    });
  }, [openTabs]);

  // Исправленный setActiveTab - принимает string (id) вместо TabItem
  const setActiveTabById = useCallback((tabId: string) => {
    const tab = openTabs.find(t => t.id === tabId);
    if (tab) {
      setActiveTab(tab);
    }
  }, [openTabs]);

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
    
    // Actions - правильные типы для MainEditor
    createFile,
    createFolder,
    openFile,
    closeTab,
    setActiveTab: setActiveTabById, // Теперь принимает string
    updateFileContent,
    setSearchQuery,
    renameFile,
    deleteFile,
  };
}
EOF

echo "✅ MainEditor.tsx создан как единственный центральный компонент"
echo "✅ AppShell.tsx обновлен для использования MainEditor"
echo "✅ useFileManager.ts исправлен - setActiveTab принимает string"
echo "✅ Дублирование компонентов устранено"

# Финальное тестирование
echo "🧪 Тестируем синхронизированную архитектуру..."
npm run build

if [ $? -eq 0 ]; then
  echo ""
  echo "🎉 АРХИТЕКТУРА СИНХРОНИЗИРОВАНА!"
  echo "🏗️ Единая структура редактора готова"
  echo ""
  echo "📋 Архитектура теперь чистая:"
  echo "   ✅ AppShell → MainEditor (единственный центральный компонент)"
  echo "   ✅ MainEditor → MonacoEditor (редактор кода)"
  echo "   ✅ Никакого дублирования EditorArea/MainEditor"
  echo "   ✅ Корректная типизация всех props"
  echo ""
  echo "🚀 Запустите: npm run dev"
  echo "Теперь архитектура соответствует стандартам SmartVAT/Solar"
else
  echo "❌ Неожиданные ошибки - проверьте консоль"
fi