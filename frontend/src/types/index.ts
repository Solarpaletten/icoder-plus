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
  modified?: boolean;
}

export type AgentType = 'dashka' | 'claudy' | 'both';

export interface FileManagerState {
  fileTree: FileItem[];
  openTabs: TabItem[];
  activeTab: TabItem | null;
  searchQuery: string;
}
