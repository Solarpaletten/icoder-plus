export interface FileItem {
  id: string;
  name: string;
  type: 'file' | 'folder';
  content?: string;
  language?: string;
  expanded?: boolean;
  children?: FileItem[];
}

export interface TabItem {
  id: string;
  name: string;
  content: string;
  language?: string;
  isDirty?: boolean;
}

export type AgentType = 'dashka' | 'claudy';

export interface FileManagerState {
  fileTree: FileItem[];
  openTabs: TabItem[];
  activeTab: TabItem | null;
  searchQuery: string;
}
