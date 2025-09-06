#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ TYPESCRIPT ОШИБОК"
echo "=========================================="

# 1. Создать недостающий initialData.ts
cat > src/utils/initialData.ts << 'EOF'
import type { FileItem } from '../types';

export const initialFiles: FileItem[] = [
  {
    id: '1',
    name: 'src',
    type: 'folder',
    children: [
      {
        id: '2',
        name: 'App.tsx',
        type: 'file',
        content: `import React from 'react';
import { AppShell } from './components/AppShell';

function App() {
  return <AppShell />;
}

export default App;`
      },
      {
        id: '3',
        name: 'main.tsx',
        type: 'file',
        content: `import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)`
      },
      {
        id: '4',
        name: 'components',
        type: 'folder',
        children: [
          {
            id: '5',
            name: 'AppShell.tsx',
            type: 'file',
            content: '// AppShell component'
          }
        ]
      }
    ]
  },
  {
    id: '6',
    name: 'package.json',
    type: 'file',
    content: `{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module"
}`
  },
  {
    id: '7',
    name: 'README.md',
    type: 'file',
    content: '# iCoder Plus Frontend\n\nModern IDE built with React + TypeScript'
  }
];
EOF

# 2. Исправить FileTree.tsx - убрать ссылку на несуществующий searchQuery
cat > src/components/FileTree.tsx << 'EOF'
import React, { useState } from 'react';
import { 
  ChevronRight, 
  ChevronDown, 
  File, 
  Folder, 
  FolderOpen,
  Search,
  Plus,
  FileText,
  Edit3,
  Trash2
} from 'lucide-react';
import type { FileItem } from '../types';

interface FileTreeProps {
  files: FileItem[];
  onFileSelect: (file: FileItem) => void;
  selectedFileId: string | null;
  onFileCreate: (parentId: string | null, name: string, type: 'file' | 'folder') => void;
  onFileRename: (id: string, newName: string) => void;
  onFileDelete: (id: string) => void;
  setSearchQuery: (query: string) => void;
}

interface ContextMenuProps {
  x: number;
  y: number;
  onClose: () => void;
  onRename: () => void;
  onDelete: () => void;
  onNewFile: () => void;
  onNewFolder: () => void;
}

const ContextMenu: React.FC<ContextMenuProps> = ({ 
  x, y, onClose, onRename, onDelete, onNewFile, onNewFolder 
}) => {
  return (
    <div
      className="absolute bg-gray-800 text-white text-sm rounded shadow-lg z-50 border border-gray-600"
      style={{ top: y, left: x }}
      onClick={onClose}
    >
      <div className="py-1">
        <div
          className="px-3 py-2 hover:bg-gray-600 cursor-pointer flex items-center gap-2"
          onClick={(e) => { e.stopPropagation(); onRename(); }}
        >
          <Edit3 size={14} />
          Rename
        </div>
        <div
          className="px-3 py-2 hover:bg-red-600 cursor-pointer flex items-center gap-2 text-red-300"
          onClick={(e) => { e.stopPropagation(); onDelete(); }}
        >
          <Trash2 size={14} />
          Delete
        </div>
        <div className="border-t border-gray-600 my-1"></div>
        <div
          className="px-3 py-2 hover:bg-gray-600 cursor-pointer flex items-center gap-2"
          onClick={(e) => { e.stopPropagation(); onNewFile(); }}
        >
          <FileText size={14} />
          New File
        </div>
        <div
          className="px-3 py-2 hover:bg-gray-600 cursor-pointer flex items-center gap-2"
          onClick={(e) => { e.stopPropagation(); onNewFolder(); }}
        >
          <Plus size={14} />
          New Folder
        </div>
      </div>
    </div>
  );
};

export const FileTree: React.FC<FileTreeProps> = (props) => {
  const [expandedFolders, setExpandedFolders] = useState<Set<string>>(new Set(['1']));
  const [contextMenu, setContextMenu] = useState<{ x: number; y: number; fileId: string } | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const toggleFolder = (id: string) => {
    const newExpanded = new Set(expandedFolders);
    if (newExpanded.has(id)) {
      newExpanded.delete(id);
    } else {
      newExpanded.add(id);
    }
    setExpandedFolders(newExpanded);
  };

  const handleContextMenu = (e: React.MouseEvent, fileId: string) => {
    e.preventDefault();
    setContextMenu({ x: e.clientX, y: e.clientY, fileId });
  };

  const closeContextMenu = () => {
    setContextMenu(null);
  };

  const handleSearchChange = (value: string) => {
    setSearchQuery(value);
    props.setSearchQuery(value);
  };

  const filterFiles = (files: FileItem[], query: string): FileItem[] => {
    if (!query) return files;
    
    return files.filter(file => {
      if (file.name.toLowerCase().includes(query.toLowerCase())) {
        return true;
      }
      if (file.type === 'folder' && file.children) {
        return filterFiles(file.children, query).length > 0;
      }
      return false;
    }).map(file => {
      if (file.type === 'folder' && file.children) {
        return {
          ...file,
          children: filterFiles(file.children, query)
        };
      }
      return file;
    });
  };

  const filteredFiles = filterFiles(props.files, searchQuery);

  const renderFile = (file: FileItem, depth: number = 0) => {
    const isSelected = file.id === props.selectedFileId;
    const isExpanded = expandedFolders.has(file.id);
    
    return (
      <div key={file.id}>
        <div
          className={`flex items-center py-1 px-2 hover:bg-gray-700 cursor-pointer group
            ${isSelected ? 'bg-blue-600' : ''}`}
          style={{ paddingLeft: `${depth * 16 + 8}px` }}
          onClick={() => {
            if (file.type === 'folder') {
              toggleFolder(file.id);
            } else {
              props.onFileSelect(file);
            }
          }}
          onContextMenu={(e) => handleContextMenu(e, file.id)}
        >
          {file.type === 'folder' && (
            <div className="mr-1">
              {isExpanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
            </div>
          )}
          <div className="mr-2">
            {file.type === 'folder' 
              ? (isExpanded ? <FolderOpen size={16} /> : <Folder size={16} />)
              : <File size={16} />
            }
          </div>
          <span className="text-sm truncate">{file.name}</span>
          <div className="ml-auto opacity-0 group-hover:opacity-100">
            <span className="text-xs text-gray-400">⋮</span>
          </div>
        </div>
        
        {file.type === 'folder' && isExpanded && file.children && (
          <div>
            {file.children.map(child => renderFile(child, depth + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="w-64 bg-gray-900 text-gray-200 h-full relative">
      {/* Header */}
      <div className="p-3 border-b border-gray-700">
        <h3 className="text-sm font-medium text-gray-300 mb-2">EXPLORER</h3>
        
        {/* Search */}
        <div className="relative">
          <Search size={14} className="absolute left-2 top-2 text-gray-400" />
          <input
            type="text"
            placeholder="Search files..."
            className="w-full bg-gray-800 text-gray-200 text-xs rounded px-7 py-1.5 
                       border border-gray-600 focus:border-blue-500 focus:outline-none"
            value={searchQuery}
            onChange={(e) => handleSearchChange(e.target.value)}
          />
        </div>
      </div>

      {/* File Tree */}
      <div className="overflow-y-auto h-full">
        {filteredFiles.map(file => renderFile(file))}
      </div>

      {/* Context Menu */}
      {contextMenu && (
        <>
          <div 
            className="fixed inset-0 z-40" 
            onClick={closeContextMenu}
            onContextMenu={(e) => e.preventDefault()}
          />
          <ContextMenu
            x={contextMenu.x}
            y={contextMenu.y}
            onClose={closeContextMenu}
            onRename={() => {
              alert('Rename clicked');
              closeContextMenu();
            }}
            onDelete={() => {
              alert('Delete clicked');
              closeContextMenu();
            }}
            onNewFile={() => {
              alert('New File clicked');
              closeContextMenu();
            }}
            onNewFolder={() => {
              alert('New Folder clicked');
              closeContextMenu();
            }}
          />
        </>
      )}
    </div>
  );
};
EOF

# 3. Исправить MonacoEditor.tsx - убрать showText
cat > src/components/MonacoEditor.tsx << 'EOF'
import React, { useEffect, useRef } from 'react';
import * as monaco from 'monaco-editor';

interface MonacoEditorProps {
  filename: string;
  content: string;
  onChange: (value: string) => void;
}

export const MonacoEditor: React.FC<MonacoEditorProps> = ({ filename, content, onChange }) => {
  const editorRef = useRef<HTMLDivElement>(null);
  const monacoInstance = useRef<monaco.editor.IStandaloneCodeEditor | null>(null);

  const getLanguageFromFilename = (filename: string): string => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const languageMap: { [key: string]: string } = {
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'py': 'python',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'json': 'json',
      'md': 'markdown',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'sql': 'sql',
      'php': 'php',
      'go': 'go',
      'rs': 'rust',
      'cpp': 'cpp',
      'c': 'c',
      'java': 'java',
      'sh': 'shell'
    };
    return languageMap[ext || ''] || 'plaintext';
  };

  useEffect(() => {
    if (editorRef.current && !monacoInstance.current) {
      // Создаем редактор
      monacoInstance.current = monaco.editor.create(editorRef.current, {
        value: content,
        language: getLanguageFromFilename(filename),
        theme: 'vs-dark',
        fontSize: 14,
        fontFamily: 'Cascadia Code, Fira Code, Consolas, monospace',
        lineNumbers: 'on',
        roundedSelection: false,
        scrollBeyondLastLine: false,
        automaticLayout: true,
        tabSize: 2,
        insertSpaces: true,
        wordWrap: 'on',
        minimap: {
          enabled: true,
          side: 'right'
        },
        suggest: {
          showKeywords: true,
          showSnippets: true,
          showFunctions: true,
          showVariables: true
        },
        quickSuggestions: {
          other: true,
          comments: true,
          strings: true
        },
        folding: true,
        foldingStrategy: 'indentation',
        showFoldingControls: 'always',
        bracketPairColorization: {
          enabled: true
        }
      });

      // Обработчик изменений
      monacoInstance.current.onDidChangeModelContent(() => {
        const value = monacoInstance.current?.getValue() || '';
        onChange(value);
      });
    }

    return () => {
      monacoInstance.current?.dispose();
      monacoInstance.current = null;
    };
  }, []);

  // Обновляем содержимое при изменении файла
  useEffect(() => {
    if (monacoInstance.current) {
      const currentValue = monacoInstance.current.getValue();
      if (currentValue !== content) {
        monacoInstance.current.setValue(content);
      }
      
      // Обновляем язык
      const model = monacoInstance.current.getModel();
      if (model) {
        monaco.editor.setModelLanguage(model, getLanguageFromFilename(filename));
      }
    }
  }, [content, filename]);

  return (
    <div className="w-full h-full">
      <div ref={editorRef} className="w-full h-full" />
    </div>
  );
};
EOF

echo "✅ initialData.ts создан"
echo "✅ FileTree.tsx исправлен"  
echo "✅ MonacoEditor.tsx исправлен"

# Тестируем сборку
echo "🧪 Тестируем исправленный код..."
npm run build

if [ $? -eq 0 ]; then
  echo "✅ Все TypeScript ошибки исправлены!"
  echo "🎯 Monaco Editor готов к использованию"
  echo "🚀 Переходим к следующей фазе улучшений"
else
  echo "❌ Остались ошибки - проверьте консоль"
fi