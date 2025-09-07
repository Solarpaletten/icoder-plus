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
