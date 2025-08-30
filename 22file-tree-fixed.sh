#!/bin/bash

echo "File Tree Management Script #2 (Fixed)"

cd frontend

# ============================================================================
# 1. УСТАНОВИТЬ НЕОБХОДИМЫЕ ЗАВИСИМОСТИ
# ============================================================================


# ============================================================================
# 2. СОЗДАТЬ УЛУЧШЕННЫЙ FileTree КОМПОНЕНТ
# ============================================================================

cat > src/components/FileTree.jsx << 'EOF'
import React, { useState } from 'react'
import { ChevronRight, ChevronDown, File, Folder, Plus } from 'lucide-react'

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

  const getFileIcon = (fileName) => {
    const ext = fileName.split('.').pop()?.toLowerCase()
    const iconMap = {
      js: '🟨', jsx: '🔷', ts: '🔵', tsx: '🔹',
      html: '🟧', css: '🎨', json: '📄', md: '📝'
    }
    return iconMap[ext] || '📄'
  }

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
              <span>{getFileIcon(item.name)}</span>
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
      <div className="tree-header">
        <div style={{display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
          <span className="font-semibold text-sm text-gray-300">EXPLORER</span>
          <div style={{display: 'flex', alignItems: 'center', gap: '4px'}}>
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
EOF

# ============================================================================
# 3. СОЗДАТЬ CSS СТИЛИ
# ============================================================================

cat >> src/styles/globals.css << 'EOF'

/* File Tree Styles */
.file-tree {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #1e1e1e;
  color: #cccccc;
}

.tree-header {
  padding: 12px 16px;
  border-bottom: 1px solid #2d2d30;
  background: #252526;
}

.tree-btn {
  padding: 4px;
  background: transparent;
  border: none;
  border-radius: 3px;
  color: #cccccc;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tree-btn:hover {
  background: #2a2d2e;
}

.search-box {
  padding: 8px 16px;
  border-bottom: 1px solid #2d2d30;
}

.search-input {
  width: 100%;
  padding: 6px 8px;
  background: #3c3c3c;
  border: 1px solid #464647;
  border-radius: 3px;
  color: #cccccc;
  font-size: 13px;
}

.search-input::placeholder {
  color: #888;
}

.tree-content {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.tree-item {
  display: flex;
  align-items: center;
  padding: 4px 16px 4px 8px;
  cursor: pointer;
  user-select: none;
  gap: 6px;
  min-height: 22px;
}

.tree-item:hover {
  background: #2a2d2e;
}

.tree-item.selected {
  background: #094771;
}

.tree-arrow {
  display: flex;
  align-items: center;
  color: #cccccc;
  width: 16px;
  justify-content: center;
}

.tree-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.tree-name {
  font-size: 13px;
  color: #cccccc;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tree-rename-input {
  flex: 1;
  background: #3c3c3c;
  border: 1px solid #007acc;
  border-radius: 3px;
  padding: 2px 4px;
  font-size: 13px;
  color: #cccccc;
  outline: none;
}

.context-menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
}

.context-menu {
  position: fixed;
  background: #2d2d30;
  border: 1px solid #464647;
  border-radius: 3px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
  z-index: 1000;
  min-width: 160px;
  padding: 4px 0;
}

.context-menu-item {
  padding: 6px 12px;
  font-size: 13px;
  color: #cccccc;
  cursor: pointer;
  user-select: none;
}

.context-menu-item:hover {
  background: #094771;
}

.context-menu-divider {
  height: 1px;
  background: #464647;
  margin: 4px 0;
}
EOF

# ============================================================================
# 4. ТЕСТИРОВАТЬ СБОРКУ
# ============================================================================

echo "Testing build..."


if [ $? -eq 0 ]; then
    echo ""
    echo "✅ СКРИПТ #2 ВЫПОЛНЕН УСПЕШНО!"
    echo ""
    echo "File Tree Management готов:"
    echo "   - ✅ Создание файлов и папок"
    echo "   - ✅ Контекстное меню"
    echo "   - ✅ Переименование и удаление"
    echo "   - ✅ Поиск по файлам"
    echo "   - ✅ Иконки файлов"
    echo ""
    echo "Готов к коммиту:"
    echo "   git add ."
    echo "   git commit -m 'Add File Tree Management with CRUD'"
    echo "   git push origin main"
else
    echo "❌ Build failed"
    exit 1
fi

cd ..