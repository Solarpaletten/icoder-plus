import { useState } from 'react';
import { ChevronRight, ChevronDown, File, Folder, FolderOpen, Plus, Search, X } from 'lucide-react';
import type { FileItem, FileManagerState } from '../../types';

interface FileSidebarProps extends FileManagerState {
  createFile: (parentId: string | null, name: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  onToggle: () => void;
}

export function FileSidebar({ 
  fileTree, 
  createFile, 
  createFolder, 
  openFile, 
  onToggle 
}: FileSidebarProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const renderFileItem = (item: FileItem, depth = 0): React.ReactNode => {
    const isFolder = item.type === 'folder';
    const hasChildren = item.children && item.children.length > 0;

    return (
      <div key={item.id} className="select-none">
        <div
          className="flex items-center py-1 px-2 hover:bg-gray-700 cursor-pointer text-xs"
          style={{ paddingLeft: `${8 + depth * 16}px` }}
          onClick={() => isFolder ? undefined : openFile(item)}
        >
          {isFolder && (
            <button className="flex items-center justify-center w-4 h-4 mr-1">
              {item.expanded ? (
                <ChevronDown size={10} className="text-gray-400" />
              ) : (
                <ChevronRight size={10} className="text-gray-400" />
              )}
            </button>
          )}
          
          {isFolder ? (
            item.expanded ? <FolderOpen size={14} className="text-blue-400 mr-2" /> : <Folder size={14} className="text-blue-400 mr-2" />
          ) : (
            <File size={14} className="text-gray-400 mr-2" />
          )}
          
          <span className="flex-1 truncate text-gray-300">{item.name}</span>
        </div>

        {isFolder && item.expanded && hasChildren && (
          <div>
            {item.children?.map(child => renderFileItem(child, depth + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="h-8 flex items-center justify-between px-3 bg-gray-750 border-b border-gray-700">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
          Explorer
        </span>
        <div className="flex items-center space-x-1">
          <button
            onClick={() => createFile(null, 'Untitled.js')}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="New File"
          >
            <Plus size={12} />
          </button>
          <button
            onClick={() => createFolder(null, 'New Folder')}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="New Folder"
          >
            <Folder size={12} />
          </button>
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="Hide Explorer"
          >
            <X size={12} />
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="p-2 border-b border-gray-700">
        <div className="relative">
          <Search size={12} className="absolute left-2 top-2 text-gray-400" />
          <input
            type="text"
            placeholder="Search files..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-6 pr-2 py-1 bg-gray-700 border border-gray-600 rounded text-xs text-gray-300 placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
        </div>
      </div>

      {/* File Tree */}
      <div className="flex-1 overflow-y-auto">
        {fileTree.length > 0 ? (
          fileTree.map(item => renderFileItem(item))
        ) : (
          <div className="p-4 text-center text-gray-500 text-xs">
            <FolderOpen className="mx-auto mb-2 opacity-50" size={24} />
            <p>No files yet</p>
            <p className="mt-1">Create your first file</p>
          </div>
        )}
      </div>
    </div>
  );
}
