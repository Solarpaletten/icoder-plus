#!/bin/bash

echo "Исправляем недостающие файлы и функции"

cd frontend/src

# ============================================================================
# 1. СОЗДАТЬ НЕДОСТАЮЩИЙ utils/fileUtils.js
# ============================================================================

mkdir -p utils

cat > utils/fileUtils.js << 'EOF'
import { 
  FileText, 
  Code, 
  Image, 
  FileJson, 
  FileCode2, 
  Palette,
  File as FileIcon
} from 'lucide-react'
import React from 'react'

export const getFileIcon = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const iconMap = {
    // Code files
    js: React.createElement(Code, { size: 16, className: "text-yellow-400" }),
    jsx: React.createElement(Code, { size: 16, className: "text-blue-400" }),
    ts: React.createElement(FileCode2, { size: 16, className: "text-blue-500" }),
    tsx: React.createElement(FileCode2, { size: 16, className: "text-blue-500" }),
    py: React.createElement(Code, { size: 16, className: "text-green-400" }),
    
    // Web files
    html: React.createElement(Code, { size: 16, className: "text-orange-400" }),
    css: React.createElement(Palette, { size: 16, className: "text-blue-300" }),
    scss: React.createElement(Palette, { size: 16, className: "text-pink-400" }),
    
    // Data files
    json: React.createElement(FileJson, { size: 16, className: "text-yellow-300" }),
    md: React.createElement(FileText, { size: 16, className: "text-gray-300" }),
    txt: React.createElement(FileText, { size: 16, className: "text-gray-400" }),
    
    // Images
    png: React.createElement(Image, { size: 16, className: "text-green-400" }),
    jpg: React.createElement(Image, { size: 16, className: "text-green-400" }),
    jpeg: React.createElement(Image, { size: 16, className: "text-green-400" }),
    gif: React.createElement(Image, { size: 16, className: "text-green-400" }),
    svg: React.createElement(Image, { size: 16, className: "text-purple-400" })
  }
  
  return iconMap[ext] || React.createElement(FileIcon, { size: 16, className: "text-gray-400" })
}

export const getLanguageFromExtension = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const languageMap = {
    js: 'javascript',
    jsx: 'javascript', 
    ts: 'typescript',
    tsx: 'typescript',
    py: 'python',
    html: 'html',
    css: 'css',
    scss: 'scss',
    json: 'json',
    md: 'markdown',
    txt: 'text'
  }
  
  return languageMap[ext] || 'text'
}

export const isImageFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp'].includes(ext)
}

export const isExecutableFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['html', 'js', 'jsx'].includes(ext)
}
EOF

# ============================================================================
# 2. ОБНОВИТЬ FileTree.jsx - INLINE СОЗДАНИЕ ФАЙЛОВ
# ============================================================================

cat > components/FileTree.jsx << 'EOF'
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
EOF

# ============================================================================
# 3. ДОБАВИТЬ CSS ДЛЯ INLINE CREATION
# ============================================================================

cat >> styles/globals.css << 'EOF'

/* Inline Creation Styles */
.tree-item.creating {
  background: rgba(0, 122, 204, 0.1);
  border: 1px dashed #007acc;
}

.tree-create-input {
  flex: 1;
  background: #3c3c3c;
  border: 1px solid #007acc;
  border-radius: 3px;
  padding: 2px 6px;
  font-size: 13px;
  color: #cccccc;
  outline: none;
}

.tree-create-input::placeholder {
  color: #888;
  font-style: italic;
}
EOF

# ============================================================================
# 4. ОБНОВИТЬ App.jsx - ДОБАВИТЬ СОСТОЯНИЯ ПАНЕЛЕЙ
# ============================================================================

cat > App.jsx << 'EOF'
import React, { useState } from 'react'
import { useFileManager } from './hooks/useFileManager'
import FileTree from './components/FileTree'
import { ChevronLeft, ChevronRight, ChevronUp, ChevronDown } from 'lucide-react'
import './styles/globals.css'

function App() {
  const {
    fileTree,
    openTabs,
    activeTab,
    searchQuery,
    setSearchQuery,
    createFile,
    createFolder,
    renameItem,
    deleteItem,
    openFile,
    closeTab,
    setActiveTab,
    toggleFolder,
    updateFileContent
  } = useFileManager()

  // Panel states
  const [leftPanelCollapsed, setLeftPanelCollapsed] = useState(false)
  const [terminalCollapsed, setTerminalCollapsed] = useState(false)
  const [activeAgent, setActiveAgent] = useState('claudy')

  return (
    <div className="app-container">
      {/* Top Header */}
      <div className="app-header">
        <div className="app-title">
          <span>iCoder Plus v2.2</span>
          <span className="app-subtitle">IDE Shell</span>
        </div>
        <div className="app-controls">
          <span className="status-indicator">🟢 Dashka (Architect)</span>
          <span className="ai-panel-toggle">🤖 AI ASSISTANT</span>
        </div>
      </div>
      
      {/* Main Content */}
      <div className="app-content">
        {/* Left Panel - File Tree */}
        {!leftPanelCollapsed && (
          <div className="left-panel">
            <FileTree
              fileTree={fileTree}
              searchQuery={searchQuery}
              setSearchQuery={setSearchQuery}
              openFile={openFile}
              createFile={createFile}
              createFolder={createFolder}
              renameItem={renameItem}
              deleteItem={deleteItem}
              toggleFolder={toggleFolder}
              selectedFileId={activeTab?.id}
            />
          </div>
        )}

        {/* Collapse Toggle */}
        <div className="panel-toggle left-toggle">
          <button 
            onClick={() => setLeftPanelCollapsed(!leftPanelCollapsed)}
            className="toggle-btn"
            title={leftPanelCollapsed ? "Show Explorer" : "Hide Explorer"}
          >
            {leftPanelCollapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>
        </div>

        {/* Main Panel - Editor Area */}
        <div className="main-panel">
          <div className="editor-header">
            <div className="editor-tabs">
              {openTabs.map(tab => (
                <div
                  key={tab.id}
                  className={`editor-tab ${activeTab?.id === tab.id ? 'active' : ''}`}
                  onClick={() => setActiveTab(tab)}
                >
                  <span className="tab-name">{tab.name}</span>
                  <button 
                    className="tab-close"
                    onClick={(e) => {
                      e.stopPropagation()
                      closeTab(tab)
                    }}
                  >
                    ×
                  </button>
                </div>
              ))}
            </div>
          </div>
          
          <div className="editor-content">
            {activeTab ? (
              <div className="code-editor">
                <div className="editor-placeholder">
                  <h3>🚀 iCoder Plus v2.2 - IDE Shell</h3>
                  <p>Minimalist Visual IDE - Monaco Editor will be here</p>
                  <div className="code-preview">
                    <pre>{activeTab.content || '// Welcome to iCoder Plus IDE Shell\nconsole.log("Hello from IDE!");'}</pre>
                  </div>
                </div>
              </div>
            ) : (
              <div className="no-file-selected">
                <h3>No file selected</h3>
                <p>Select a file from the explorer to start editing</p>
              </div>
            )}
          </div>
        </div>

        {/* Right Panel - AI Assistant */}
        <div className="right-panel">
          <div className="ai-header">
            <h3>AI ASSISTANT</h3>
            <div className="agent-selector">
              <button 
                className={`agent-btn ${activeAgent === 'dashka' ? 'active' : ''}`}
                onClick={() => setActiveAgent('dashka')}
              >
                🏗️ Dashka
              </button>
              <button 
                className={`agent-btn ${activeAgent === 'claudy' ? 'active' : ''}`}
                onClick={() => setActiveAgent('claudy')}
              >
                🤖 Claudy
              </button>
            </div>
          </div>
          <div className="ai-content">
            <p>
              {activeAgent === 'dashka' 
                ? 'Dashka (Architect): Анализирую архитектуру и предлагаю улучшения кода.' 
                : 'Claudy (Code Gen): Генерирую код и помогаю с реализацией.'
              }
            </p>
          </div>
        </div>
      </div>

      {/* Bottom Terminal */}
      {!terminalCollapsed && (
        <div className="bottom-panel">
          <div className="terminal-header">
            <span>TERMINAL</span>
            <button 
              onClick={() => setTerminalCollapsed(true)}
              className="terminal-close"
              title="Hide Terminal"
            >
              <ChevronDown size={14} />
            </button>
          </div>
          <div className="terminal-content">
            <div className="terminal-line">
              <span className="prompt">$ npm run dev</span>
            </div>
            <div className="terminal-line">
              <span className="output">🚀 iCoder Plus starting...</span>
            </div>
          </div>
        </div>
      )}

      {/* Terminal Toggle */}
      {terminalCollapsed && (
        <div className="panel-toggle terminal-toggle">
          <button 
            onClick={() => setTerminalCollapsed(false)}
            className="toggle-btn"
            title="Show Terminal"
          >
            <ChevronUp size={16} />
          </button>
        </div>
      )}
    </div>
  )
}

export default App
EOF

# ============================================================================
# 5. ОБНОВИТЬ CSS - ДОБАВИТЬ ПАНЕЛЬНЫЕ ПЕРЕКЛЮЧАТЕЛИ
# ============================================================================

cat >> styles/globals.css << 'EOF'

/* Panel Toggles */
.panel-toggle {
  position: absolute;
  z-index: 100;
  background: #2d2d30;
  border: 1px solid #464647;
}

.left-toggle {
  left: leftPanelCollapsed ? 0 : 299px;
  top: 50%;
  transform: translateY(-50%);
  border-radius: 0 4px 4px 0;
}

.terminal-toggle {
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  border-radius: 4px 4px 0 0;
}

.toggle-btn {
  background: none;
  border: none;
  color: #cccccc;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
}

.toggle-btn:hover {
  background: #37373d;
}

.terminal-close {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
}

.terminal-close:hover {
  color: #cccccc;
}

.terminal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* Agent Selector Fix */
.agent-selector {
  display: flex;
  gap: 4px;
}

.agent-btn {
  padding: 4px 8px;
  background: transparent;
  border: 1px solid #464647;
  color: #cccccc;
  border-radius: 3px;
  cursor: pointer;
  font-size: 11px;
  transition: all 0.2s;
}

.agent-btn:hover {
  border-color: #007acc;
}

.agent-btn.active {
  background: #007acc;
  border-color: #007acc;
  color: white;
}
EOF

# ============================================================================
# 6. ТЕСТИРОВАТЬ ИСПРАВЛЕНИЯ
# ============================================================================

echo "Тестируем исправления..."

cd ..
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ВСЕ ИСПРАВЛЕНИЯ ПРИМЕНЕНЫ!"
    echo ""
    echo "ТЕПЕРЬ ДОЛЖНО РАБОТАТЬ:"
    echo "✅ Lucide иконки файлов"
    echo "✅ Inline создание файлов в дереве"
    echo "✅ Переключение Dashka ↔ Claudy" 
    echo "✅ Сворачивание левой панели"
    echo "✅ Сворачивание терминала"
    echo ""
    echo "ТЕСТИРУЙТЕ:"
    echo "- Клик + → inline ввод в дереве"
    echo "- Переключатель Dashka/Claudy"
    echo "- Кнопки сворачивания панелей"
    
else
    echo "❌ Build failed"
    exit 1
fi