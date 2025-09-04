import { useState } from 'react';
import { ChevronRight, ChevronDown, File, Folder, Plus } from 'lucide-react';
import type { FileItem, FileManagerState } from '../types';

interface FileTreeProps extends FileManagerState {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  toggleFolder: (folder: FileItem) => void;
  setSearchQuery: (query: string) => void;
}

export function FileTree(props: FileTreeProps) {
  const [dragOver, setDragOver] = useState<string | null>(null);

  const handleDrop = (e: React.DragEvent, targetId: string | null) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(null);

    const files = Array.from(e.dataTransfer.files);
    if (files.length === 0) return;

    files.forEach(file => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const content = event.target?.result as string;
        props.createFile(targetId, file.name, content);
      };
      reader.readAsText(file);
    });
  };

  const handleDragOver = (e: React.DragEvent, itemId: string | null) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(itemId);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(null);
  };

  const renderFileItem = (item: FileItem, level = 0) => (
    <div key={item.id}>
      <div 
        className={`flex items-center px-2 py-1 hover:bg-gray-700 cursor-pointer text-sm transition-colors ${
          dragOver === item.id ? 'bg-blue-600' : ''
        }`}
        style={{ paddingLeft: `${level * 20 + 8}px` }}
        onClick={() => item.type === 'folder' ? props.toggleFolder(item) : props.openFile(item)}
        onDrop={(e) => handleDrop(e, item.type === 'folder' ? item.id : null)}
        onDragOver={(e) => handleDragOver(e, item.type === 'folder' ? item.id : null)}
        onDragLeave={handleDragLeave}
      >
        {item.type === 'folder' && (
          <span className="w-4 h-4 flex items-center justify-center mr-1">
            {item.expanded ? <ChevronDown size={12} /> : <ChevronRight size={12} />}
          </span>
        )}
        
        <span className="w-4 h-4 flex items-center justify-center mr-2">
          {item.type === 'folder' ? 
            <Folder size={14} className={`${dragOver === item.id ? 'text-blue-200' : 'text-blue-400'}`} /> : 
            <File size={14} className="text-gray-300" />
          }
        </span>
        
        <span className={`text-gray-200 ${dragOver === item.id ? 'text-white font-medium' : ''}`}>
          {item.name}
        </span>
      </div>
      
      {item.type === 'folder' && item.expanded && item.children && (
        <div>
          {item.children.map(child => renderFileItem(child, level + 1))}
        </div>
      )}
    </div>
  );

  return (
    <div className="h-full flex flex-col">
      {/* Header с кнопками создания */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Explorer</span>
          <div className="flex space-x-1">
            <button
              onClick={() => {
                const name = prompt('File name:');
                if (name) props.createFile(null, name, '// New file\n');
              }}
              className="p-1.5 bg-blue-600 hover:bg-blue-500 rounded text-white"
              title="New File"
            >
              <Plus size={12} />
            </button>
            <button
              onClick={() => {
                const name = prompt('Folder name:');
                if (name) props.createFolder(null, name);
              }}
              className="p-1.5 bg-green-600 hover:bg-green-500 rounded text-white"
              title="New Folder"
            >
              <Folder size={12} />
            </button>
          </div>
        </div>

        {/* Search */}
        <input
          type="text"
          placeholder="Search files..."
          value={props.searchQuery}
          onChange={(e) => props.setSearchQuery(e.target.value)}
          className="w-full px-2 py-1.5 text-xs bg-gray-800 border border-gray-600 rounded focus:border-blue-500 focus:outline-none"
        />
      </div>

      {/* File Tree с поддержкой drag & drop */}
      <div 
        className={`flex-1 overflow-y-auto ${dragOver === null ? 'bg-gray-900' : 'bg-blue-900/20'}`}
        onDrop={(e) => handleDrop(e, null)}
        onDragOver={(e) => handleDragOver(e, null)}
        onDragLeave={handleDragLeave}
      >
        {props.fileTree.length > 0 ? (
          props.fileTree.map(item => renderFileItem(item))
        ) : (
          <div className="p-4 text-center text-gray-500 text-sm">
            <Folder className="mx-auto mb-2 opacity-50" size={32} />
            <p>Drop files here or create new</p>
          </div>
        )}
      </div>
    </div>
  );
}
