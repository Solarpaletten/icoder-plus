import { ChevronRight, ChevronDown, File, Folder } from 'lucide-react';
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
  openFile,
  toggleFolder 
}: FileTreeProps) {
  const renderFileItem = (item: FileItem, level = 0) => (
    <div key={item.id}>
      <div 
        className="flex items-center px-2 py-1 hover:bg-gray-700 cursor-pointer text-sm"
        style={{ paddingLeft: `${level * 20 + 8}px` }}
        onClick={() => item.type === 'folder' ? toggleFolder(item) : openFile(item)}
      >
        {item.type === 'folder' && (
          <span className="w-4 h-4 flex items-center justify-center mr-1">
            {item.expanded ? <ChevronDown size={12} /> : <ChevronRight size={12} />}
          </span>
        )}
        
        <span className="w-4 h-4 flex items-center justify-center mr-2">
          {item.type === 'folder' ? 
            <Folder size={14} className="text-blue-400" /> : 
            <File size={14} className="text-gray-300" />
          }
        </span>
        
        <span className="text-gray-200">{item.name}</span>
      </div>
      
      {item.type === 'folder' && item.expanded && item.children && (
        <div>
          {item.children.map(child => renderFileItem(child, level + 1))}
        </div>
      )}
    </div>
  );

  return (
    <div className="h-full overflow-y-auto">
      {fileTree.map(item => renderFileItem(item))}
    </div>
  );
}
