import React, { useState, useEffect } from 'react';
import { GitBranch, GitCommit, GitPullRequest, RefreshCw, Plus, Minus, X, Check, Upload, Download } from 'lucide-react';
import type { FileItem } from '../../types';

interface GitFileStatus {
  path: string;
  status: 'modified' | 'added' | 'deleted' | 'untracked' | 'staged';
  changes: number;
}

interface GitPanelProps {
  files: FileItem[];
  onFileSelect: (file: FileItem) => void;
  onClose: () => void;
}

export const GitPanel: React.FC<GitPanelProps> = ({
  files,
  onFileSelect,
  onClose
}) => {
  const [commitMessage, setCommitMessage] = useState('');
  const [currentBranch, setCurrentBranch] = useState('main');
  const [changedFiles, setChangedFiles] = useState<GitFileStatus[]>([]);
  const [stagedFiles, setStagedFiles] = useState<GitFileStatus[]>([]);
  const [isCommitting, setIsCommitting] = useState(false);
  const [lastCommit, setLastCommit] = useState('');

  // Mock git data initialization
  useEffect(() => {
    // Simulate git status
    const mockChangedFiles: GitFileStatus[] = [
      { path: 'src/components/panels/SearchPanel.tsx', status: 'modified', changes: 15 },
      { path: 'src/components/panels/LeftSidebar.tsx', status: 'modified', changes: 8 },
      { path: 'src/components/AppShell.tsx', status: 'modified', changes: 3 },
      { path: 'package.json', status: 'modified', changes: 2 }
    ];
    
    setChangedFiles(mockChangedFiles);
    setLastCommit('feat: Add search panel with full-text search');
  }, []);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey && e.key === 'G') {
        e.preventDefault();
        const input = document.querySelector('#commit-message') as HTMLInputElement;
        input?.focus();
      }
      if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const getStatusIcon = (status: GitFileStatus['status']) => {
    switch (status) {
      case 'modified': return <span className="text-orange-400">M</span>;
      case 'added': return <span className="text-green-400">A</span>;
      case 'deleted': return <span className="text-red-400">D</span>;
      case 'untracked': return <span className="text-gray-400">U</span>;
      case 'staged': return <span className="text-green-400">✓</span>;
      default: return <span className="text-gray-400">?</span>;
    }
  };

  const getStatusColor = (status: GitFileStatus['status']) => {
    switch (status) {
      case 'modified': return 'text-orange-400';
      case 'added': return 'text-green-400';
      case 'deleted': return 'text-red-400';
      case 'untracked': return 'text-gray-400';
      case 'staged': return 'text-green-400';
      default: return 'text-gray-400';
    }
  };

  const stageFile = (file: GitFileStatus) => {
    setChangedFiles(prev => prev.filter(f => f.path !== file.path));
    setStagedFiles(prev => [...prev, { ...file, status: 'staged' }]);
  };

  const unstageFile = (file: GitFileStatus) => {
    setStagedFiles(prev => prev.filter(f => f.path !== file.path));
    setChangedFiles(prev => [...prev, { ...file, status: 'modified' }]);
  };

  const stageAllFiles = () => {
    setStagedFiles(prev => [...prev, ...changedFiles.map(f => ({ ...f, status: 'staged' as const }))]);
    setChangedFiles([]);
  };

  const unstageAllFiles = () => {
    setChangedFiles(prev => [...prev, ...stagedFiles.map(f => ({ ...f, status: 'modified' as const }))]);
    setStagedFiles([]);
  };

  const handleCommit = async () => {
    if (!commitMessage.trim() || stagedFiles.length === 0) return;

    setIsCommitting(true);
    
    // Simulate commit process
    setTimeout(() => {
      setLastCommit(commitMessage);
      setCommitMessage('');
      setStagedFiles([]);
      setIsCommitting(false);
      
      // Show success message
      console.log(`Committed: ${commitMessage}`);
    }, 1500);
  };

  const handleFileClick = (filePath: string) => {
    // Find file in tree and open it
    const findFile = (items: FileItem[], path: string): FileItem | null => {
      for (const item of items) {
        if (item.type === 'file' && path.includes(item.name)) {
          return item;
        }
        if (item.children) {
          const found = findFile(item.children, path);
          if (found) return found;
        }
      }
      return null;
    };

    const file = findFile(files, filePath);
    if (file) {
      onFileSelect(file);
    }
  };

  return (
    <div className="h-full bg-gray-900 text-gray-200 flex flex-col">
      {/* Header */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-sm font-medium text-gray-300">SOURCE CONTROL</h3>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
          >
            <X size={14} />
          </button>
        </div>

        {/* Branch Info */}
        <div className="flex items-center gap-2 mb-3">
          <GitBranch size={14} className="text-blue-400" />
          <span className="text-sm text-gray-300">{currentBranch}</span>
          <div className="flex items-center gap-1 ml-auto">
            <button
              className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
              title="Pull"
            >
              <Download size={12} />
            </button>
            <button
              className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
              title="Push"
            >
              <Upload size={12} />
            </button>
            <button
              className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
              title="Refresh"
            >
              <RefreshCw size={12} />
            </button>
          </div>
        </div>

        {/* Commit Message */}
        <div className="space-y-2">
          <textarea
            id="commit-message"
            placeholder="Message (Ctrl+Enter to commit)"
            className="w-full bg-gray-800 text-gray-200 text-sm rounded px-3 py-2 h-16
                       border border-gray-600 focus:border-blue-500 focus:outline-none resize-none"
            value={commitMessage}
            onChange={(e) => setCommitMessage(e.target.value)}
            onKeyDown={(e) => {
              if (e.ctrlKey && e.key === 'Enter') {
                e.preventDefault();
                handleCommit();
              }
            }}
          />
          
          <div className="flex items-center justify-between">
            <span className="text-xs text-gray-400">
              {stagedFiles.length} staged changes
            </span>
            <button
              onClick={handleCommit}
              disabled={!commitMessage.trim() || stagedFiles.length === 0 || isCommitting}
              className="px-3 py-1 bg-blue-600 text-white text-xs rounded disabled:bg-gray-600 disabled:opacity-50 hover:bg-blue-700 transition-colors flex items-center gap-1"
            >
              {isCommitting ? (
                <>
                  <RefreshCw size={12} className="animate-spin" />
                  Committing...
                </>
              ) : (
                <>
                  <GitCommit size={12} />
                  Commit
                </>
              )}
            </button>
          </div>
        </div>

        {/* Last Commit */}
        {lastCommit && (
          <div className="mt-2 p-2 bg-gray-800 rounded text-xs">
            <div className="flex items-center gap-1 text-gray-400">
              <Check size={10} />
              Last commit:
            </div>
            <div className="text-gray-300 mt-1">{lastCommit}</div>
          </div>
        )}
      </div>

      {/* File Changes */}
      <div className="flex-1 overflow-y-auto">
        {/* Staged Changes */}
        {stagedFiles.length > 0 && (
          <div className="border-b border-gray-800">
            <div className="px-3 py-2 bg-gray-800 border-b border-gray-700 flex items-center justify-between">
              <span className="text-sm font-medium text-gray-300">
                Staged Changes ({stagedFiles.length})
              </span>
              <button
                onClick={unstageAllFiles}
                className="text-xs text-gray-400 hover:text-white"
                title="Unstage All"
              >
                <Minus size={12} />
              </button>
            </div>
            
            {stagedFiles.map((file, index) => (
              <div
                key={index}
                className="flex items-center px-3 py-2 hover:bg-gray-800 cursor-pointer group"
                onClick={() => handleFileClick(file.path)}
              >
                <div className="mr-2 w-4 text-center">
                  {getStatusIcon(file.status)}
                </div>
                <span className="flex-1 text-sm text-gray-300 truncate">
                  {file.path}
                </span>
                <span className="text-xs text-gray-500 mr-2">
                  +{file.changes}
                </span>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    unstageFile(file);
                  }}
                  className="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-700 rounded"
                  title="Unstage"
                >
                  <Minus size={10} />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Changes */}
        {changedFiles.length > 0 && (
          <div>
            <div className="px-3 py-2 bg-gray-800 border-b border-gray-700 flex items-center justify-between">
              <span className="text-sm font-medium text-gray-300">
                Changes ({changedFiles.length})
              </span>
              <button
                onClick={stageAllFiles}
                className="text-xs text-gray-400 hover:text-white"
                title="Stage All"
              >
                <Plus size={12} />
              </button>
            </div>
            
            {changedFiles.map((file, index) => (
              <div
                key={index}
                className="flex items-center px-3 py-2 hover:bg-gray-800 cursor-pointer group"
                onClick={() => handleFileClick(file.path)}
              >
                <div className="mr-2 w-4 text-center">
                  {getStatusIcon(file.status)}
                </div>
                <span className={`flex-1 text-sm truncate ${getStatusColor(file.status)}`}>
                  {file.path}
                </span>
                <span className="text-xs text-gray-500 mr-2">
                  +{file.changes}
                </span>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    stageFile(file);
                  }}
                  className="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-700 rounded"
                  title="Stage"
                >
                  <Plus size={10} />
                </button>
              </div>
            ))}
          </div>
        )}

        {/* No Changes */}
        {changedFiles.length === 0 && stagedFiles.length === 0 && (
          <div className="p-4 text-center text-gray-500">
            <GitBranch className="mx-auto mb-2 opacity-50" size={32} />
            <p className="text-sm">No changes</p>
            <div className="text-xs mt-2 space-y-1">
              <p>• Working tree clean</p>
              <p>• All changes committed</p>
              <p>• Use Ctrl+Shift+G to open source control</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
