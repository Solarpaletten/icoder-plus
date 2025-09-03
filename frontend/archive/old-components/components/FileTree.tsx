import React from 'react';
import { ChevronRight, ChevronDown, File, Folder, Plus } from 'lucide-react';
import type { FileItem, FileManagerState } from '../types';

interface FileTreeProps extends FileManagerState {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  toggleFolder: (folder: FileItem) => void;
  setSearchQuery: (query: string) => void;
}

export function FileTree({ 
  fileTree, 
  searchQuery, 
  setSearchQuery,
  createFile,
  createFolder,
  openFile,
  toggleFolder 
}: FileTreeProps) {
  const renderFileItem = (item: FileItem, level = 0) => (
    <div key={item.id} style={{ marginLeft: level * 16 }}>
      <div 
        className="flex items-center px-2 py-1 hover:bg-gray-700 cursor-pointer"
        onClick={() => item.type === 'folder' ? toggleFolder(item) : openFile(item)}
      >
        {item.type === 'folder' && (
          <span className="w-4 h-4 flex items-center justify-center">
            {item.expanded ? <ChevronDown size={12} /> : <ChevronRight size={12} />}
          </span>
        )}
        <span className="w-4 h-4 flex items-center justify-center ml-1">
          {item.type === 'folder' ? 
            <Folder size={14} className="text-blue-400" /> : 
            <File size={14} className="text-gray-300" />
          }
        </span>
        <span className="ml-2 text-sm">{item.name}</span>
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
      <div className="p-3 border-b border-border">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs uppercase font-semibold text-gray-300">Explorer</span>
          <div className="flex gap-1">
            <button 
              onClick={() => createFile(null, 'untitled.js', '// New file')}
              className="p-1 hover:bg-gray-700 rounded"
              title="New File"
            >
              <Plus size={12} />
            </button>
            <button 
              onClick={() => createFolder(null, 'New Folder')}
              className="p-1 hover:bg-gray-700 rounded"
              title="New Folder"
            >
              <Folder size={12} />
            </button>
          </div>
        </div>
        
        <input
          type="text"
          placeholder="Search files..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full px-2 py-1 text-xs bg-gray-800 border border-gray-600 rounded"
        />
      </div>
      
      <div className="flex-1 overflow-y-auto">
        {fileTree.map(item => renderFileItem(item))}
      </div>
    </div>
  );
}
