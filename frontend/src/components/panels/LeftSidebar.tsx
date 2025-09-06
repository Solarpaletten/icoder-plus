import React from 'react';
import { FileTree } from '../FileTree';
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

export const LeftSidebar: React.FC<LeftSidebarProps> = ({
  files,
  selectedFileId,
  onFileSelect,
  onFileCreate,
  onFileRename,
  onFileDelete,
  onSearchQuery
}) => {
  return (
    <div className="w-64 bg-gray-900 border-r border-gray-700 h-full">
      <FileTree
        files={files}
        onFileSelect={onFileSelect}
        selectedFileId={selectedFileId}
        onFileCreate={onFileCreate}
        onFileRename={onFileRename}
        onFileDelete={onFileDelete}
        setSearchQuery={onSearchQuery}
      />
    </div>
  );
};
