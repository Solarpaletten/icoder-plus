import React, { useState } from 'react';
import { FileTree } from '../FileTree';
import { SearchPanel } from './SearchPanel';
import { GitPanel } from './GitPanel';
import { Folder, Search, GitBranch } from 'lucide-react';
import type { FileItem } from '../../types';

interface LeftSidebarProps {
  files: FileItem[];
  selectedFileId: string | null;
  onFileSelect: (file: FileItem) => void;
  onFileCreate: (parentId: string | null, name: string, type: 'file' | 'folder') => void;
  onFileRename: (id: string, newName: string) => void;
  onFileDelete: (id: string) => void;
  onSearchQuery: (query: string) => void;
}

type SidebarMode = 'explorer' | 'search' | 'git';

export const LeftSidebar: React.FC<LeftSidebarProps> = ({
  files,
  selectedFileId,
  onFileSelect,
  onFileCreate,
  onFileRename,
  onFileDelete,
  onSearchQuery
}) => {
  const [mode, setMode] = useState<SidebarMode>('explorer');

  // Keyboard shortcuts
  React.useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey && e.key === 'F') {
        e.preventDefault();
        setMode('search');
      }
      if (e.ctrlKey && e.shiftKey && e.key === 'G') {
        e.preventDefault();
        setMode('git');
      }
      if (e.ctrlKey && e.shiftKey && e.key === 'E') {
        e.preventDefault();
        setMode('explorer');
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <div className="w-64 bg-gray-900 border-r border-gray-700 h-full flex flex-col">
      {/* Sidebar Tabs */}
      <div className="flex border-b border-gray-700">
        <button
          className={`flex-1 flex items-center justify-center py-2 px-2 text-xs font-medium
            ${mode === 'explorer' 
              ? 'bg-gray-800 text-white border-b-2 border-blue-500' 
              : 'text-gray-400 hover:text-white hover:bg-gray-800'
            }`}
          onClick={() => setMode('explorer')}
          title="Explorer (Ctrl+Shift+E)"
        >
          <Folder size={14} className="mr-1" />
          EXPLORER
        </button>
        <button
          className={`flex-1 flex items-center justify-center py-2 px-2 text-xs font-medium
            ${mode === 'search' 
              ? 'bg-gray-800 text-white border-b-2 border-blue-500' 
              : 'text-gray-400 hover:text-white hover:bg-gray-800'
            }`}
          onClick={() => setMode('search')}
          title="Search (Ctrl+Shift+F)"
        >
          <Search size={14} className="mr-1" />
          SEARCH
        </button>
        <button
          className={`flex-1 flex items-center justify-center py-2 px-2 text-xs font-medium
            ${mode === 'git' 
              ? 'bg-gray-800 text-white border-b-2 border-blue-500' 
              : 'text-gray-400 hover:text-white hover:bg-gray-800'
            }`}
          onClick={() => setMode('git')}
          title="Source Control (Ctrl+Shift+G)"
        >
          <GitBranch size={14} className="mr-1" />
          GIT
        </button>
      </div>

      {/* Panel Content */}
      <div className="flex-1 overflow-hidden">
        {mode === 'explorer' && (
          <FileTree
            files={files}
            onFileSelect={onFileSelect}
            selectedFileId={selectedFileId}
            onFileCreate={onFileCreate}
            onFileRename={onFileRename}
            onFileDelete={onFileDelete}
            setSearchQuery={onSearchQuery}
          />
        )}
        
        {mode === 'search' && (
          <SearchPanel
            files={files}
            onFileSelect={onFileSelect}
            onClose={() => setMode('explorer')}
          />
        )}
        
        {mode === 'git' && (
          <GitPanel
            files={files}
            onFileSelect={onFileSelect}
            onClose={() => setMode('explorer')}
          />
        )}
      </div>
    </div>
  );
};
