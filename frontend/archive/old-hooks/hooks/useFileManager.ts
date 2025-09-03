import { useState, useCallback } from 'react';
import type { FileItem, TabItem, FileManagerState } from '../types';

const initialFiles: FileItem[] = [
  {
    id: 'src',
    name: 'src',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'app-tsx',
        name: 'App.tsx',
        type: 'file',
        content: '// Clean TypeScript App\nimport React from "react";\n\nfunction App() {\n  return <div>Hello, Clean Architecture!</div>;\n}\n\nexport default App;',
        language: 'typescript'
      }
    ]
  },
  {
    id: 'readme',
    name: 'README.md',
    type: 'file',
    content: '# iCoder Plus v2.0\n\nClean TypeScript + Tailwind architecture\n\n## Features\n- TypeScript for type safety\n- Tailwind CSS for styling\n- Clean component structure\n- No custom CSS bloat',
    language: 'markdown'
  }
];

export function useFileManager(): FileManagerState & {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  toggleFolder: (folder: FileItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
  setSearchQuery: (query: string) => void;
} {
  const [fileTree, setFileTree] = useState<FileItem[]>(initialFiles);
  const [openTabs, setOpenTabs] = useState<TabItem[]>([]);
  const [activeTab, setActiveTab] = useState<TabItem | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const generateId = () => Math.random().toString(36).substr(2, 9);

  const createFile = useCallback((parentId: string | null, name: string, content = '') => {
    const newFile: FileItem = {
      id: generateId(),
      name,
      type: 'file',
      content,
      language: name.endsWith('.ts') || name.endsWith('.tsx') ? 'typescript' : 'javascript'
    };

    if (parentId) {
      setFileTree(tree => tree.map(item => {
        if (item.id === parentId && item.type === 'folder') {
          return {
            ...item,
            children: [...(item.children || []), newFile]
          };
        }
        return item;
      }));
    } else {
      setFileTree(tree => [...tree, newFile]);
    }

    openFile(newFile);
  }, []);

  const createFolder = useCallback((parentId: string | null, name: string) => {
    const newFolder: FileItem = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: false,
      children: []
    };

    if (parentId) {
      setFileTree(tree => tree.map(item => {
        if (item.id === parentId && item.type === 'folder') {
          return {
            ...item,
            children: [...(item.children || []), newFolder]
          };
        }
        return item;
      }));
    } else {
      setFileTree(tree => [...tree, newFolder]);
    }
  }, []);

  const openFile = useCallback((file: FileItem) => {
    if (file.type !== 'file') return;

    const existingTab = openTabs.find(tab => tab.id === file.id);
    if (existingTab) {
      setActiveTab(existingTab);
      return;
    }

    const newTab: TabItem = {
      id: file.id,
      name: file.name,
      content: file.content || '',
      language: file.language
    };

    setOpenTabs(tabs => [...tabs, newTab]);
    setActiveTab(newTab);
  }, [openTabs]);

  const closeTab = useCallback((tab: TabItem) => {
    setOpenTabs(tabs => {
      const newTabs = tabs.filter(t => t.id !== tab.id);
      if (activeTab?.id === tab.id) {
        setActiveTab(newTabs.length > 0 ? newTabs[newTabs.length - 1] : null);
      }
      return newTabs;
    });
  }, [activeTab]);

  const toggleFolder = useCallback((folder: FileItem) => {
    setFileTree(tree => tree.map(item => {
      if (item.id === folder.id) {
        return { ...item, expanded: !item.expanded };
      }
      return item;
    }));
  }, []);

  const updateFileContent = useCallback((fileId: string, content: string) => {
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === fileId ? { ...tab, content, isDirty: true } : tab
    ));
    
    if (activeTab?.id === fileId) {
      setActiveTab({ ...activeTab, content, isDirty: true });
    }
  }, [activeTab]);

  return {
    fileTree,
    openTabs,
    activeTab,
    searchQuery,
    createFile,
    createFolder,
    openFile,
    closeTab,
    setActiveTab,
    toggleFolder,
    updateFileContent,
    setSearchQuery
  };
}
