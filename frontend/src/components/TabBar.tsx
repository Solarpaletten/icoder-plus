import React, { useState, useRef } from 'react';
import { X, Plus, MoreHorizontal } from 'lucide-react';
import type { TabItem } from '../types';

interface TabBarProps {
  tabs: TabItem[];
  activeTabId: string | null;
  onTabSelect: (id: string) => void;
  onTabClose: (id: string) => void;
  onTabsReorder: (fromIndex: number, toIndex: number) => void;
}

interface TabContextMenuProps {
  x: number;
  y: number;
  tabId: string;
  onClose: () => void;
  onCloseTab: (id: string) => void;
  onCloseOthers: (id: string) => void;
  onCloseAll: () => void;
  onCloseToRight: (id: string) => void;
}

const TabContextMenu: React.FC<TabContextMenuProps> = ({
  x, y, tabId, onClose, onCloseTab, onCloseOthers, onCloseAll, onCloseToRight
}) => {
  return (
    <>
      <div 
        className="fixed inset-0 z-40" 
        onClick={onClose}
        onContextMenu={(e) => e.preventDefault()}
      />
      <div
        className="absolute bg-gray-800 text-white text-sm rounded shadow-lg z-50 border border-gray-600 py-1"
        style={{ top: y, left: x }}
      >
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseTab(tabId); onClose(); }}
        >
          Close
        </button>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseOthers(tabId); onClose(); }}
        >
          Close Others
        </button>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseToRight(tabId); onClose(); }}
        >
          Close to the Right
        </button>
        <div className="border-t border-gray-600 my-1"></div>
        <button
          className="w-full text-left px-3 py-1.5 hover:bg-gray-600"
          onClick={() => { onCloseAll(); onClose(); }}
        >
          Close All
        </button>
      </div>
    </>
  );
};

export const TabBar: React.FC<TabBarProps> = ({
  tabs,
  activeTabId,
  onTabSelect,
  onTabClose,
  onTabsReorder
}) => {
  const [draggedTab, setDraggedTab] = useState<string | null>(null);
  const [dragOverIndex, setDragOverIndex] = useState<number | null>(null);
  const [contextMenu, setContextMenu] = useState<{ x: number; y: number; tabId: string } | null>(null);
  const tabsContainerRef = useRef<HTMLDivElement>(null);

  const getFileIcon = (filename: string) => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const iconMap: { [key: string]: string } = {
      'ts': '🟦', 'tsx': '🟦', 'js': '🟨', 'jsx': '🟨',
      'json': '📄', 'md': '📝', 'html': '🌐', 'css': '🎨',
      'py': '🐍', 'go': '🟢', 'rs': '🦀', 'java': '☕'
    };
    return iconMap[ext || ''] || '📄';
  };

  const handleDragStart = (e: React.DragEvent, tabId: string, index: number) => {
    setDraggedTab(tabId);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', tabId);
  };

  const handleDragOver = (e: React.DragEvent, index: number) => {
    e.preventDefault();
    setDragOverIndex(index);
  };

  const handleDragEnd = () => {
    setDraggedTab(null);
    setDragOverIndex(null);
  };

  const handleDrop = (e: React.DragEvent, dropIndex: number) => {
    e.preventDefault();
    if (draggedTab) {
      const draggedIndex = tabs.findIndex(tab => tab.id === draggedTab);
      if (draggedIndex !== -1 && draggedIndex !== dropIndex) {
        onTabsReorder(draggedIndex, dropIndex);
      }
    }
    handleDragEnd();
  };

  const handleMouseDown = (e: React.MouseEvent, tabId: string) => {
    // Middle click to close
    if (e.button === 1) {
      e.preventDefault();
      onTabClose(tabId);
    }
  };

  const handleContextMenu = (e: React.MouseEvent, tabId: string) => {
    e.preventDefault();
    setContextMenu({ x: e.clientX, y: e.clientY, tabId });
  };

  const closeContextMenu = () => setContextMenu(null);

  const handleCloseOthers = (keepTabId: string) => {
    tabs.forEach(tab => {
      if (tab.id !== keepTabId) {
        onTabClose(tab.id);
      }
    });
  };

  const handleCloseToRight = (fromTabId: string) => {
    const fromIndex = tabs.findIndex(tab => tab.id === fromTabId);
    if (fromIndex !== -1) {
      tabs.slice(fromIndex + 1).forEach(tab => {
        onTabClose(tab.id);
      });
    }
  };

  const handleCloseAll = () => {
    tabs.forEach(tab => onTabClose(tab.id));
  };

  return (
    <div className="flex bg-gray-800 border-b border-gray-700 min-h-[40px] relative">
      <div 
        ref={tabsContainerRef}
        className="flex flex-1 overflow-x-auto scrollbar-none"
        style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
      >
        {tabs.map((tab, index) => (
          <div
            key={tab.id}
            draggable
            onDragStart={(e) => handleDragStart(e, tab.id, index)}
            onDragOver={(e) => handleDragOver(e, index)}
            onDragEnd={handleDragEnd}
            onDrop={(e) => handleDrop(e, index)}
            onMouseDown={(e) => handleMouseDown(e, tab.id)}
            onContextMenu={(e) => handleContextMenu(e, tab.id)}
            className={`group flex items-center px-3 py-2 border-r border-gray-700 cursor-pointer 
              min-w-[120px] max-w-[200px] relative transition-all duration-150
              ${tab.id === activeTabId 
                ? 'bg-gray-900 text-white border-t-2 border-t-blue-500' 
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
              }
              ${draggedTab === tab.id ? 'opacity-50' : ''}
              ${dragOverIndex === index ? 'bg-blue-900' : ''}`}
            onClick={() => onTabSelect(tab.id)}
          >
            {/* File Icon */}
            <span className="mr-2 text-sm">{getFileIcon(tab.name)}</span>
            
            {/* File Name */}
            <span className="truncate text-sm mr-2 flex-1">{tab.name}</span>
            
            {/* Modified Indicator */}
            {tab.modified && (
              <div 
                className="w-2 h-2 bg-white rounded-full mr-1 flex-shrink-0"
                title="Unsaved changes"
              />
            )}
            
            {/* Close Button */}
            <button
              className="opacity-0 group-hover:opacity-100 hover:bg-gray-600 rounded p-0.5 
                         flex-shrink-0 transition-opacity duration-150"
              onClick={(e) => {
                e.stopPropagation();
                onTabClose(tab.id);
              }}
              title="Close tab"
            >
              <X size={12} />
            </button>

            {/* Drag indicator */}
            {dragOverIndex === index && (
              <div className="absolute left-0 top-0 bottom-0 w-0.5 bg-blue-500" />
            )}
          </div>
        ))}
      </div>
      
      {/* New Tab Button */}
      <button
        className="px-3 py-2 text-gray-400 hover:text-white hover:bg-gray-700 
                   border-r border-gray-700 transition-colors duration-150"
        title="New tab"
      >
        <Plus size={16} />
      </button>

      {/* More options */}
      <button
        className="px-2 py-2 text-gray-400 hover:text-white hover:bg-gray-700 
                   transition-colors duration-150"
        title="More options"
      >
        <MoreHorizontal size={16} />
      </button>

      {/* Context Menu */}
      {contextMenu && (
        <TabContextMenu
          x={contextMenu.x}
          y={contextMenu.y}
          tabId={contextMenu.tabId}
          onClose={closeContextMenu}
          onCloseTab={onTabClose}
          onCloseOthers={handleCloseOthers}
          onCloseAll={handleCloseAll}
          onCloseToRight={handleCloseToRight}
        />
      )}
    </div>
  );
};
