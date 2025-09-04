import { CollapsiblePanel } from '../utils/CollapsiblePanel';
import { FileTree } from '../FileTree';
import { FileUploader } from '../features/FileUploader';
import type { FileManagerState } from '../../types';

interface LeftSidebarProps extends FileManagerState {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: any) => void;
  toggleFolder: (folder: any) => void;
  setSearchQuery: (query: string) => void;
  isCollapsed: boolean;
  onToggle: () => void;
}

export function LeftSidebar(props: LeftSidebarProps) {
  if (props.isCollapsed) {
    return (
      <div className="w-8 bg-gray-800 border-r border-gray-700 flex flex-col items-center py-2">
        <button onClick={props.onToggle} className="p-2 hover:bg-gray-700 rounded">
          📁
        </button>
      </div>
    );
  }

  return (
    <div className="w-80 bg-gray-800 border-r border-gray-700 flex flex-col">
      <CollapsiblePanel
        direction="horizontal"
        isCollapsed={false}
        onToggle={props.onToggle}
        title="Explorer"
      >
        {/* File Uploader - отдельный компонент */}
        <FileUploader
          onFileUpload={(files) => console.log('Files uploaded:', files)}
          onFolderUpload={(folder) => console.log('Folder uploaded:', folder)}
        />
        
        {/* File Tree - существующий компонент */}
        <FileTree {...props} />
      </CollapsiblePanel>
    </div>
  );
}
