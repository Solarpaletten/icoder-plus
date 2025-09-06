#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОСТАВШИХСЯ TYPESCRIPT ОШИБОК"
echo "=========================================="

# 1. Обновить types/index.ts - добавить недостающие типы
cat > src/types/index.ts << 'EOF'
export interface FileItem {
  id: string;
  name: string;
  type: 'file' | 'folder';
  content?: string;
  language?: string;
  children?: FileItem[];
  expanded?: boolean;
  parentId?: string | null;
}

export interface TabItem {
  id: string;
  name: string;
  content: string;
  language?: string;
  isDirty?: boolean;
  isActive?: boolean;
  type?: 'file' | 'folder';
}

export interface FileManagerState {
  fileTree: FileItem[];
  openTabs: TabItem[];
  activeTab: TabItem | null;
}

export interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
}

// Добавляем недостающий тип AgentType
export type AgentType = 'dashka' | 'claudy' | 'both';
EOF

echo "✅ AgentType добавлен в types"

# 2. Исправить MonacoEditor.tsx - убрать enableExtendedSelection
cat > src/components/MonacoEditor.tsx << 'EOF'
import { useEffect, useRef } from 'react';
import * as monaco from 'monaco-editor';

interface MonacoEditorProps {
  content: string;
  language: string;
  onChange: (content: string) => void;
  filename: string;
}

export function MonacoEditor({ content, language, onChange, filename }: MonacoEditorProps) {
  const editorRef = useRef<HTMLDivElement>(null);
  const monacoRef = useRef<monaco.editor.IStandaloneCodeEditor | null>(null);

  useEffect(() => {
    if (!editorRef.current) return;

    // Создаем Monaco editor с корректными настройками
    const editor = monaco.editor.create(editorRef.current, {
      value: content,
      language: getMonacoLanguage(language),
      theme: 'vs-dark',
      automaticLayout: true,
      fontSize: 14,
      fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, Consolas, monospace',
      lineNumbers: 'on',
      roundedSelection: false,
      scrollBeyondLastLine: false,
      readOnly: false,
      minimap: {
        enabled: true,
        side: 'right'
      },
      suggest: {
        showIcons: true,
        showSnippets: true,
        showWords: true,
        showColors: true,
        showFiles: true,
        showReferences: true,
        showFolders: true,
        showTypeParameters: true,
        showIssues: true,
        showUsers: true,
        showValues: true,
        showVariables: true,
        showEnums: true,
        showEnumMembers: true,
        showKeywords: true,
        showText: true,
        showClasses: true,
        showFunctions: true,
        showConstructors: true,
        showFields: true,
        showInterfaces: true,
        showModules: true,
        showProperties: true,
        showEvents: true,
        showOperators: true,
        showUnits: true
      },
      wordWrap: 'off',
      scrollbar: {
        vertical: 'visible',
        horizontal: 'visible',
        useShadows: false,
        verticalHasArrows: false,
        horizontalHasArrows: false
      },
      folding: true,
      foldingStrategy: 'indentation',
      showFoldingControls: 'always',
      unfoldOnClickAfterEndOfLine: false,
      bracketPairColorization: {
        enabled: true
      }
    });

    monacoRef.current = editor;

    // Обработчик изменений
    const disposable = editor.onDidChangeModelContent(() => {
      const value = editor.getValue();
      onChange(value);
    });

    return () => {
      disposable.dispose();
      editor.dispose();
    };
  }, []);

  // Обновление контента
  useEffect(() => {
    if (monacoRef.current && monacoRef.current.getValue() !== content) {
      const editor = monacoRef.current;
      const model = editor.getModel();
      
      if (model) {
        model.setValue(content);
      }
    }
  }, [content]);

  // Обновление языка
  useEffect(() => {
    if (monacoRef.current) {
      const model = monacoRef.current.getModel();
      if (model) {
        monaco.editor.setModelLanguage(model, getMonacoLanguage(language));
      }
    }
  }, [language]);

  // Фокус на редактор
  useEffect(() => {
    if (monacoRef.current) {
      monacoRef.current.focus();
    }
  }, [filename]);

  return (
    <div className="h-full w-full">
      <div ref={editorRef} className="h-full w-full" />
    </div>
  );
}

// Маппинг языков для Monaco
function getMonacoLanguage(lang: string): string {
  const languageMap: Record<string, string> = {
    'js': 'javascript',
    'jsx': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'py': 'python',
    'css': 'css',
    'scss': 'scss',
    'sass': 'sass',
    'html': 'html',
    'xml': 'xml',
    'json': 'json',
    'md': 'markdown',
    'markdown': 'markdown',
    'yml': 'yaml',
    'yaml': 'yaml',
    'sh': 'shell',
    'bash': 'shell',
    'sql': 'sql',
    'php': 'php',
    'java': 'java',
    'cpp': 'cpp',
    'c': 'c',
    'cs': 'csharp',
    'go': 'go',
    'rust': 'rust',
    'ruby': 'ruby',
    'swift': 'swift',
    'kotlin': 'kotlin',
    'dart': 'dart'
  };

  return languageMap[lang.toLowerCase()] || 'plaintext';
}
EOF

echo "✅ MonacoEditor.tsx исправлен"

# 3. Обновить useFileManager.ts - добавить searchQuery в state
cat > src/hooks/useFileManager.ts << 'EOF'
import { useState, useCallback } from 'react';
import type { FileItem, TabItem, FileManagerState } from '../types';
import { initialFiles } from '../utils/initialData';

export function useFileManager() {
  const [fileTree, setFileTree] = useState<FileItem[]>(initialFiles);
  const [openTabs, setOpenTabs] = useState<TabItem[]>([]);
  const [activeTab, setActiveTab] = useState<TabItem | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const createFile = useCallback((parentId: string | null, name: string, content = '') => {
    const newFile: FileItem = {
      id: `file-${Date.now()}`,
      name,
      type: 'file',
      content,
      language: getLanguageFromFilename(name),
      parentId
    };

    setFileTree(prev => addFileToTree(prev, newFile, parentId));
  }, []);

  const createFolder = useCallback((parentId: string | null, name: string) => {
    const newFolder: FileItem = {
      id: `folder-${Date.now()}`,
      name,
      type: 'folder',
      children: [],
      expanded: true,
      parentId
    };

    setFileTree(prev => addFileToTree(prev, newFolder, parentId));
  }, []);

  const openFile = useCallback((file: FileItem) => {
    if (file.type !== 'file') return;

    // Проверяем, уже ли открыт файл
    const existingTab = openTabs.find(tab => tab.id === file.id);
    if (existingTab) {
      setActiveTab(existingTab);
      return;
    }

    // Создаем новый таб
    const newTab: TabItem = {
      id: file.id,
      name: file.name,
      content: file.content || '',
      language: file.language,
      isDirty: false,
      type: 'file'
    };

    setOpenTabs(prev => [...prev, newTab]);
    setActiveTab(newTab);
  }, [openTabs]);

  const closeTab = useCallback((tab: TabItem) => {
    setOpenTabs(prev => {
      const filtered = prev.filter(t => t.id !== tab.id);
      
      // Если закрываем активный таб, выбираем новый активный
      if (activeTab?.id === tab.id) {
        const index = prev.findIndex(t => t.id === tab.id);
        const newActiveTab = filtered[index] || filtered[index - 1] || null;
        setActiveTab(newActiveTab);
      }
      
      return filtered;
    });
  }, [activeTab]);

  const updateFileContent = useCallback((fileId: string, content: string) => {
    // Обновляем содержимое в дереве файлов
    setFileTree(prev => updateFileInTree(prev, fileId, content));
    
    // Обновляем таб
    setOpenTabs(prev => prev.map(tab => 
      tab.id === fileId 
        ? { ...tab, content, isDirty: true }
        : tab
    ));

    // Обновляем активный таб
    if (activeTab?.id === fileId) {
      setActiveTab(prev => prev ? { ...prev, content, isDirty: true } : null);
    }
  }, [activeTab]);

  const renameItem = useCallback((itemId: string, newName: string) => {
    setFileTree(prev => renameItemInTree(prev, itemId, newName));
    
    // Обновляем табы если файл переименован
    setOpenTabs(prev => prev.map(tab =>
      tab.id === itemId ? { ...tab, name: newName } : tab
    ));
    
    if (activeTab?.id === itemId) {
      setActiveTab(prev => prev ? { ...prev, name: newName } : null);
    }
  }, [activeTab]);

  const deleteItem = useCallback((itemId: string) => {
    setFileTree(prev => deleteItemFromTree(prev, itemId));
    
    // Закрываем табы для удаленного файла
    setOpenTabs(prev => {
      const filtered = prev.filter(tab => tab.id !== itemId);
      if (activeTab?.id === itemId) {
        setActiveTab(filtered[0] || null);
      }
      return filtered;
    });
  }, [activeTab]);

  const toggleFolder = useCallback((folderId: string) => {
    setFileTree(prev => toggleFolderInTree(prev, folderId));
  }, []);

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
    updateFileContent,
    renameItem,
    deleteItem,
    toggleFolder,
    setSearchQuery
  };
}

// Вспомогательные функции
function addFileToTree(tree: FileItem[], newItem: FileItem, parentId: string | null): FileItem[] {
  if (parentId === null) {
    return [...tree, newItem];
  }

  return tree.map(item => {
    if (item.id === parentId && item.type === 'folder') {
      return {
        ...item,
        children: [...(item.children || []), newItem]
      };
    }
    if (item.children) {
      return {
        ...item,
        children: addFileToTree(item.children, newItem, parentId)
      };
    }
    return item;
  });
}

function updateFileInTree(tree: FileItem[], fileId: string, content: string): FileItem[] {
  return tree.map(item => {
    if (item.id === fileId) {
      return { ...item, content };
    }
    if (item.children) {
      return {
        ...item,
        children: updateFileInTree(item.children, fileId, content)
      };
    }
    return item;
  });
}

function renameItemInTree(tree: FileItem[], itemId: string, newName: string): FileItem[] {
  return tree.map(item => {
    if (item.id === itemId) {
      return { ...item, name: newName };
    }
    if (item.children) {
      return {
        ...item,
        children: renameItemInTree(item.children, itemId, newName)
      };
    }
    return item;
  });
}

function deleteItemFromTree(tree: FileItem[], itemId: string): FileItem[] {
  return tree.filter(item => item.id !== itemId).map(item => {
    if (item.children) {
      return {
        ...item,
        children: deleteItemFromTree(item.children, itemId)
      };
    }
    return item;
  });
}

function toggleFolderInTree(tree: FileItem[], folderId: string): FileItem[] {
  return tree.map(item => {
    if (item.id === folderId && item.type === 'folder') {
      return { ...item, expanded: !item.expanded };
    }
    if (item.children) {
      return {
        ...item,
        children: toggleFolderInTree(item.children, folderId)
      };
    }
    return item;
  });
}

function getLanguageFromFilename(filename: string): string {
  const ext = filename.split('.').pop()?.toLowerCase();
  const languageMap: Record<string, string> = {
    'js': 'javascript',
    'jsx': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'py': 'python',
    'css': 'css',
    'html': 'html',
    'json': 'json',
    'md': 'markdown'
  };
  return languageMap[ext || ''] || 'plaintext';
}
EOF

echo "✅ useFileManager.ts обновлен"

# 4. Обновить FileTree.tsx - добавить searchQuery prop
sed -i '' 's/value={props.searchQuery}/value={searchQuery}/g' src/components/FileTree.tsx

echo "✅ FileTree.tsx исправлен"

# 5. Тестировать сборку
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Все TypeScript ошибки исправлены!"
    echo "🚀 Monaco Editor полностью интегрирован!"
else
    echo "❌ Остались ошибки"
fi