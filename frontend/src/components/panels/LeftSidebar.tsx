import React, { useState } from 'react';
import { FileTree } from '../FileTree';
import { SearchPanel } from './SearchPanel';
import { GitPanel } from './GitPanel';
import { ExtensionsPanel } from './ExtensionsPanel';
import { DebugPanel } from './DebugPanel';
import { Folder, Search, GitBranch, Package, Bug } from 'lucide-react';
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

type SidebarMode = 'explorer' | 'search' | 'git' | 'extensions' | 'debug';

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
      if (e.ctrlKey && e.shiftKey && e.key === 'X') {
        e.preventDefault();
        setMode('extensions');
      }
      if (e.ctrlKey && e.shiftKey && e.key === 'D') {
        e.preventDefault();
        setMode('debug');
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const tabs = [
    { id: 'explorer', icon: Folder, label: 'EXPLORER', hotkey: 'Ctrl+Shift+E' },
    { id: 'search', icon: Search, label: 'SEARCH', hotkey: 'Ctrl+Shift+F' },
    { id: 'git', icon: GitBranch, label: 'GIT', hotkey: 'Ctrl+Shift+G' },
    { id: 'extensions', icon: Package, label: 'EXT', hotkey: 'Ctrl+Shift+X' },
    { id: 'debug', icon: Bug, label: 'DEBUG', hotkey: 'Ctrl+Shift+D' }
  ];

  return (
    <div className="w-64 bg-gray-900 border-r border-gray-700 h-full flex flex-col">
      {/* Sidebar Tabs */}
      <div className="flex border-b border-gray-700 overflow-x-auto">
        {tabs.map(tab => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              className={`flex-1 flex items-center justify-center py-2 px-1 text-xs font-medium min-w-0
                ${mode === tab.id 
                  ? 'bg-gray-800 text-white border-b-2 border-blue-500' 
                  : 'text-gray-400 hover:text-white hover:bg-gray-800'
                }`}
              onClick={() => setMode(tab.id as SidebarMode)}
              title={`${tab.label} (${tab.hotkey})`}
            >
              <Icon size={12} className="mr-1 flex-shrink-0" />
              <span className="truncate">{tab.label}</span>
            </button>
          );
        })}
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
        
        {mode === 'extensions' && (
          <ExtensionsPanel
            onClose={() => setMode('explorer')}
          />
        )}
        
        {mode === 'debug' && (
          <DebugPanel
            files={files}
            onFileSelect={onFileSelect}
            onClose={() => setMode('explorer')}
          />
        )}
      </div>
    </div>
  );
};
