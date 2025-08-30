import React, { useState } from 'react'
import { ChevronRight, ChevronDown, File, Folder, Plus, X } from 'lucide-react'
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
  const [creating, setCreating] = useState(null) // NEW: inline creation state

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

  // VS CODE STYLE: Inline creation - появляется поле ввода прямо в дереве
  const startInlineCreation = (type, parentId = null) => {
    setCreating({
      type: type, // 'file' or 'folder'
      parentId: parentId,
      name: ''
    })
    closeContextMenu()
  }

  const handleInlineCreation = (e) => {
    if (e.key === 'Enter') {
      if (creating.name.trim()) {
        if (creating.type === 'file') {
          createFile(creating.parentId, creating.name.trim())
        } else {
          createFolder(creating.parentId, creating.name.trim())
        }
      }
      setCreating(null)
    } else if (e.key === 'Escape') {
      setCreating(null)
    }
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

  const renderTreeItem = (item, level = 0) => {
    const isSelected = selectedFileId === item.id
    const isRenaming = renaming?.id === item.id

    return (
      <div key={item.id} className="tree-item-container">
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
        
        {/* VS CODE STYLE: Inline creation field появляется прямо в дереве */}
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
              className="tree-creation-input"
              placeholder={creating.type === 'file' ? 'filename.js' : 'foldername'}
              value={creating.name}
              onChange={(e) => setCreating({...creating, name: e.target.value})}
              onKeyDown={handleInlineCreation}
              onBlur={() => setCreating(null)}
              autoFocus
            />
          </div>
        )}
        
        {/* Children (for folders) */}
        {item.type === 'folder' && item.expanded && item.children && (
          <div className="tree-children">
            {item.children.map(child => renderTreeItem(child, level + 1))}
            
            {/* Inline creation for root level if no parent */}
            {creating && creating.parentId === item.id && (
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
                  className="tree-creation-input"
                  placeholder={creating.type === 'file' ? 'filename.js' : 'foldername'}
                  value={creating.name}
                  onChange={(e) => setCreating({...creating, name: e.target.value})}
                  onKeyDown={handleInlineCreation}
                  onBlur={() => setCreating(null)}
                  autoFocus
                />
              </div>
            )}
          </div>
        )}
      </div>
    )
  }

  // Inline creation for root level
  const renderRootCreation = () => {
    if (creating && creating.parentId === null) {
      return (
        <div className="tree-item creating" style={{ paddingLeft: 8 }}>
          <span className="tree-icon">
            {creating.type === 'folder' ? 
              <Folder size={16} className="text-blue-400" /> : 
              <File size={16} className="text-gray-400" />
            }
          </span>
          <input
            type="text"
            className="tree-creation-input"
            placeholder={creating.type === 'file' ? 'filename.js' : 'foldername'}
            value={creating.name}
            onChange={(e) => setCreating({...creating, name: e.target.value})}
            onKeyDown={handleInlineCreation}
            onBlur={() => setCreating(null)}
            autoFocus
          />
        </div>
      )
    }
    return null
  }

  const filteredTree = fileTree.filter(item => 
    !searchQuery || item.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div className="file-tree">
      {/* Header with + buttons like VS Code */}
      <div className="tree-header">
        <div style={{display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
          <span className="font-semibold text-sm text-gray-300">EXPLORER</span>
          <div style={{display: 'flex', alignItems: 'center', gap: '4px'}}>
            <button 
              className="tree-btn" 
              onClick={() => startInlineCreation('file', null)}
              title="New File (Ctrl+N)"
            >
              <Plus size={14} />
            </button>
            <button 
              className="tree-btn"
              onClick={() => startInlineCreation('folder', null)}
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
          <>
            {filteredTree.map(item => renderTreeItem(item))}
            {renderRootCreation()}
          </>
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
            <div className="context-menu-item" onClick={() => startInlineCreation('file', contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              New File
            </div>
            <div className="context-menu-item" onClick={() => startInlineCreation('folder', contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
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
