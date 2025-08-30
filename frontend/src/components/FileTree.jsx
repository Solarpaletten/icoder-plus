import React, { useState } from 'react'
import { ChevronRight, ChevronDown, File, Folder, Plus, MoreVertical } from 'lucide-react'
import { getFileIcon } from '../utils/fileUtils'

const FileTree = ({ 
  fileTree, 
  searchQuery, 
  setSearchQuery, 
  openFile, 
  createFile,
  createFolder,
  renameItem,
  deleteItem,
  toggleFolder,
  selectedFileId 
}) => {
  const [contextMenu, setContextMenu] = useState(null)
  const [renaming, setRenaming] = useState(null)
  const [dragOver, setDragOver] = useState(null)

  const handleRightClick = (e, item) => {
    e.preventDefault()
    e.stopPropagation()
    setContextMenu({
      x: e.clientX,
      y: e.clientY,
      item: item
    })
  }

  const closeContextMenu = () => {
    setContextMenu(null)
  }

  const startRename = (item) => {
    setRenaming({ ...item, newName: item.name })
    closeContextMenu()
  }

  const handleRename = (e) => {
    if (e.key === 'Enter') {
      if (renaming.newName.trim() && renaming.newName !== renaming.name) {
        renameItem(renaming, renaming.newName.trim())
      }
      setRenaming(null)
    } else if (e.key === 'Escape') {
      setRenaming(null)
    }
  }

  const handleDelete = (item) => {
    if (window.confirm(`Delete ${item.type} "${item.name}"?`)) {
      deleteItem(item)
    }
    closeContextMenu()
  }

  const handleCreateFile = (parentId = null) => {
    const fileName = prompt("File name:")
    if (fileName) {
      createFile(parentId, fileName)
    }
    closeContextMenu()
  }

  const handleCreateFolder = (parentId = null) => {
    const folderName = prompt("Folder name:")
    if (folderName) {
      createFolder(parentId, folderName)
    }
    closeContextMenu()
  }

  const renderTreeItem = (item, level = 0) => {
    const isSelected = selectedFileId === item.id
    const isRenaming = renaming?.id === item.id
    const isDragOver = dragOver === item.id

    return (
      <div key={item.id} className="tree-item-container">
        <div
          className={`tree-item ${item.type} ${isSelected ? 'selected' : ''} ${isDragOver ? 'drag-over' : ''}`}
          style={{ paddingLeft: level * 16 + 8 }}
          onClick={() => {
            if (item.type === 'folder') {
              toggleFolder(item)
            } else {
              openFile(item)
            }
          }}
          onContextMenu={(e) => handleRightClick(e, item)}
          onDragOver={(e) => {
            if (item.type === 'folder') {
              e.preventDefault()
              setDragOver(item.id)
            }
          }}
          onDragLeave={() => setDragOver(null)}
          onDrop={(e) => {
            e.preventDefault()
            setDragOver(null)
            // TODO: Implement drag & drop logic
          }}
        >
          {/* Folder Arrow */}
          {item.type === 'folder' && (
            <span className="tree-arrow">
              {item.expanded ? 
                <ChevronDown size={14} /> : 
                <ChevronRight size={14} />
              }
            </span>
          )}
          
          {/* File/Folder Icon */}
          <span className="tree-icon">
            {item.type === 'folder' ? 
              <Folder size={16} className="text-blue-400" /> : 
              getFileIcon(item.name)
            }
          </span>
          
          {/* Name (editable when renaming) */}
          {isRenaming ? (
            <input
              type="text"
              className="tree-rename-input"
              value={renaming.newName}
              onChange={(e) => setRenaming({...renaming, newName: e.target.value})}
              onKeyDown={handleRename}
              onBlur={() => setRenaming(null)}
              autoFocus
            />
          ) : (
            <span className="tree-name">{item.name}</span>
          )}
        </div>
        
        {/* Children (for folders) */}
        {item.type === 'folder' && item.expanded && item.children && (
          <div className="tree-children">
            {item.children.map(child => renderTreeItem(child, level + 1))}
          </div>
        )}
      </div>
    )
  }

  const filteredTree = fileTree.filter(item => 
    !searchQuery || item.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div className="file-tree">
      {/* Header */}
      <div className="tree-header">
        <div className="flex items-center justify-between">
          <span className="font-semibold text-sm text-gray-300">EXPLORER</span>
          <div className="flex items-center gap-1">
            <button 
              className="tree-btn" 
              onClick={() => handleCreateFile()}
              title="New File"
            >
              <Plus size={14} />
            </button>
            <button 
              className="tree-btn"
              onClick={() => handleCreateFolder()}
              title="New Folder" 
            >
              <Folder size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* Search */}
      <div className="search-box">
        <input
          type="text"
          className="search-input"
          placeholder="Search files..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      {/* File Tree */}
      <div className="tree-content">
        {filteredTree.length > 0 ? (
          filteredTree.map(item => renderTreeItem(item))
        ) : (
          <div className="text-gray-500 text-sm p-4">
            {searchQuery ? 'No files match your search' : 'No files in project'}
          </div>
        )}
      </div>

      {/* Context Menu */}
      {contextMenu && (
        <>
          <div className="context-menu-overlay" onClick={closeContextMenu} />
          <div 
            className="context-menu"
            style={{ 
              left: contextMenu.x, 
              top: contextMenu.y 
            }}
          >
            <div className="context-menu-item" onClick={() => startRename(contextMenu.item)}>
              Rename
            </div>
            <div className="context-menu-item" onClick={() => handleDelete(contextMenu.item)}>
              Delete
            </div>
            <div className="context-menu-divider" />
            <div className="context-menu-item" onClick={() => handleCreateFile(contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              New File
            </div>
            <div className="context-menu-item" onClick={() => handleCreateFolder(contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              New Folder
            </div>
            {contextMenu.item.type === 'file' && (
              <>
                <div className="context-menu-divider" />
                <div className="context-menu-item">
                  Run in Preview
                </div>
              </>
            )}
          </div>
        </>
      )}
    </div>
  )
}

export default FileTree
