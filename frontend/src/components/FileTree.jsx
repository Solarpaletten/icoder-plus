import React, { useState } from 'react'
import { ChevronRight, ChevronDown, File, Folder, Plus } from 'lucide-react'
import { getFileIcon } from '../utils/fileUtils'

const FileTree = ({ 
  fileTree = [], 
  searchQuery = '', 
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
  const [creating, setCreating] = useState(null) // NEW: inline creation

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

  // NEW: Inline file creation
  const startCreateFile = (parentId = null) => {
    setCreating({
      type: 'file',
      parentId,
      name: ''
    })
    closeContextMenu()
  }

  const startCreateFolder = (parentId = null) => {
    setCreating({
      type: 'folder', 
      parentId,
      name: ''
    })
    closeContextMenu()
  }

  const handleCreate = (e) => {
    if (e.key === 'Enter' && creating.name.trim()) {
      if (creating.type === 'file') {
        createFile(creating.parentId, creating.name.trim())
      } else {
        createFolder(creating.parentId, creating.name.trim())
      }
      setCreating(null)
    } else if (e.key === 'Escape') {
      setCreating(null)
    }
  }

  const renderTreeItem = (item, level = 0) => {
    const isSelected = selectedFileId === item.id
    const isRenaming = renaming?.id === item.id

    return (
      <div key={item.id}>
        <div
          className={`tree-item ${item.type} ${isSelected ? 'selected' : ''}`}
          style={{ paddingLeft: level * 16 + 8 }}
          onClick={() => {
            if (item.type === 'folder') {
              toggleFolder(item)
            } else {
              openFile(item)
            }
          }}
          onContextMenu={(e) => handleRightClick(e, item)}
        >
          {item.type === 'folder' && (
            <span className="tree-arrow">
              {item.expanded ? 
                <ChevronDown size={14} /> : 
                <ChevronRight size={14} />
              }
            </span>
          )}
          
          <span className="tree-icon">
            {item.type === 'folder' ? 
              <Folder size={16} className="text-blue-400" /> : 
              getFileIcon(item.name)
            }
          </span>
          
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
        
        {/* Inline creation input */}
        {creating && creating.parentId === item.id && item.type === 'folder' && item.expanded && (
          <div 
            className="tree-item creating"
            style={{ paddingLeft: (level + 1) * 16 + 8 }}
          >
            <span className="tree-icon">
              {creating.type === 'folder' ? 
                <Folder size={16} className="text-blue-400" /> : 
                <File size={16} className="text-gray-400" />
              }
            </span>
            <input
              type="text"
              className="tree-create-input"
              value={creating.name}
              onChange={(e) => setCreating({...creating, name: e.target.value})}
              onKeyDown={handleCreate}
              onBlur={() => setCreating(null)}
              placeholder={creating.type === 'file' ? 'filename.ext' : 'folder name'}
              autoFocus
            />
          </div>
        )}
        
        {item.type === 'folder' && item.expanded && item.children && (
          <div className="tree-children">
            {item.children.map(child => renderTreeItem(child, level + 1))}
          </div>
        )}

        {/* Root level creation */}
        {creating && !creating.parentId && fileTree.indexOf(item) === fileTree.length - 1 && (
          <div 
            className="tree-item creating"
            style={{ paddingLeft: 8 }}
          >
            <span className="tree-icon">
              {creating.type === 'folder' ? 
                <Folder size={16} className="text-blue-400" /> : 
                <File size={16} className="text-gray-400" />
              }
            </span>
            <input
              type="text"
              className="tree-create-input"
              value={creating.name}
              onChange={(e) => setCreating({...creating, name: e.target.value})}
              onKeyDown={handleCreate}
              onBlur={() => setCreating(null)}
              placeholder={creating.type === 'file' ? 'filename.ext' : 'folder name'}
              autoFocus
            />
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
      <div className="tree-header">
        <div style={{display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
          <span className="font-semibold text-sm text-gray-300">EXPLORER</span>
          <div style={{display: 'flex', alignItems: 'center', gap: '4px'}}>
            <button 
              className="tree-btn" 
              onClick={() => startCreateFile()}
              title="New File"
            >
              <Plus size={14} />
            </button>
            <button 
              className="tree-btn"
              onClick={() => startCreateFolder()}
              title="New Folder" 
            >
              <Folder size={14} />
            </button>
          </div>
        </div>
      </div>

      <div className="search-box">
        <input
          type="text"
          className="search-input"
          placeholder="Search files..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      <div className="tree-content">
        {filteredTree.length > 0 ? (
          filteredTree.map(item => renderTreeItem(item))
        ) : (
          <div className="text-gray-500 text-sm p-4">
            {searchQuery ? 'No files match your search' : 'No files in project'}
          </div>
        )}
      </div>

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
            <div className="context-menu-item" onClick={() => startCreateFile(contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              New File
            </div>
            <div className="context-menu-item" onClick={() => startCreateFolder(contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
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
