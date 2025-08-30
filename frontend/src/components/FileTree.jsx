import React from 'react'
import { getFileIcon } from '../utils/fileUtils'

const FileTree = ({ 
  fileTree, 
  searchQuery, 
  setSearchQuery, 
  openFile, 
  toggleFolder, 
  onRightClick, 
  onExport,
  selectedFileId 
}) => {
  const renderTreeItem = (item, level = 0) => {
    const isSelected = selectedFileId === item.id

    return (
      <div key={item.id} style={{ marginLeft: level * 12 }}>
        <div
          className={`tree-item ${item.type} ${isSelected ? 'selected' : ''}`}
          onClick={() => {
            if (item.type === 'folder') {
              toggleFolder(item)
            } else {
              openFile(item)
            }
          }}
          onContextMenu={(e) => onRightClick(e, item)}
        >
          {item.type === 'folder' && (
            <span className={`tree-arrow ${item.expanded ? 'expanded' : ''}`}>
              ►
            </span>
          )}
          <span className="tree-icon">
            {item.type === 'folder' ? '📂' : getFileIcon(item.name)}
          </span>
          <span>{item.name}</span>
        </div>
        
        {item.type === 'folder' && item.expanded && item.children && (
          <div className="tree-children">
            {item.children.map(child => renderTreeItem(child, level + 1))}
          </div>
        )}
      </div>
    )
  }

  return (
    <div className="file-tree">
      <div className="tree-header">
        <span className="font-semibold text-sm">📁 Project Files</span>
        <div className="tree-controls">
          <button className="tree-btn" title="New Project">🆕</button>
          <button className="tree-btn" onClick={onExport} title="Export ZIP">📤</button>
        </div>
      </div>

      <div className="search-box">
        <input
          type="text"
          className="search-input"
          placeholder="🔍 Search files..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      <div className="tree-content">
        {fileTree.map(item => renderTreeItem(item))}
      </div>
    </div>
  )
}

export default FileTree
