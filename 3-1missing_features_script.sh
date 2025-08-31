#!/bin/bash

echo "🎯 СКРИПТ #3.1: НЕДОСТАЮЩИЕ ФУНКЦИИ IDE"

cd frontend/src

# ============================================================================
# 1. ДОБАВИТЬ AI ASSISTANT ПАНЕЛЬ В App.jsx
# ============================================================================

cat > App.jsx << 'EOF'
import React, { useState } from 'react'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import { useDualAgent } from './hooks/useDualAgent'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import { Menu, X, Terminal, Copy, FolderCopy } from 'lucide-react'
import './styles/globals.css'

function App() {
  const fileManager = useFileManager()
  const codeRunner = useCodeRunner()
  const { agent, setAgent } = useDualAgent()
  
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(true)

  return (
    <div className="app-container">
      {/* Menu Bar */}
      <div className="menu-bar">
        <div className="menu-left">
          <button 
            className="menu-toggle"
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            title="Toggle Explorer"
          >
            <Menu size={16} />
          </button>
          <span className="app-title">iCoder Plus v2.2</span>
          <span className="app-subtitle">AI IDE with Monaco Editor</span>
        </div>
        
        <div className="menu-right">
          <button 
            className="menu-btn"
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal"
          >
            <Terminal size={16} />
          </button>
          <button 
            className="menu-btn"
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            title="Toggle AI Assistant"
          >
            {rightPanelOpen ? <X size={16} /> : '🤖'}
          </button>
        </div>
      </div>
      
      <div className="app-content">
        {/* Left Panel - File Tree */}
        <div className={`left-panel ${sidebarCollapsed ? 'collapsed' : ''}`}>
          <FileTree
            fileTree={fileManager.fileTree}
            searchQuery={fileManager.searchQuery}
            setSearchQuery={fileManager.setSearchQuery}
            openFile={fileManager.openFile}
            createFile={fileManager.createFile}
            createFolder={fileManager.createFolder}
            renameItem={fileManager.renameItem}
            deleteItem={fileManager.deleteItem}
            toggleFolder={fileManager.toggleFolder}
            selectedFileId={fileManager.activeTab?.id}
          />
        </div>

        {/* Main Panel - Editor */}
        <div className="main-panel">
          <Editor
            openTabs={fileManager.openTabs}
            activeTab={fileManager.activeTab}
            setActiveTab={fileManager.setActiveTab}
            closeTab={fileManager.closeTab}
            updateFileContent={fileManager.updateFileContent}
            onRunCode={codeRunner.runCode}
          />
        </div>

        {/* Right Panel - AI Assistant */}
        {rightPanelOpen && (
          <div className="right-panel">
            <div className="right-panel-header">
              <h3>AI ASSISTANT</h3>
              <div className="agent-switcher">
                <button 
                  className={agent === 'dashka' ? 'active' : ''}
                  onClick={() => setAgent('dashka')}
                >
                  🏗️ Dashka
                </button>
                <button 
                  className={agent === 'claudy' ? 'active' : ''}
                  onClick={() => setAgent('claudy')}
                >
                  🤖 Claudy
                </button>
              </div>
            </div>
            <div className="ai-content">
              <div className="ai-chat-area">
                <div className="chat-messages">
                  <div className="welcome-message">
                    <h4>👋 {agent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Generator)'} готов к работе</h4>
                    <p>{agent === 'dashka' 
                      ? 'Анализирую архитектуру, планирую структуру, даю советы по коду'
                      : 'Генерирую компоненты, функции, помогаю с кодом'
                    }</p>
                  </div>
                </div>
                <div className="chat-input">
                  <textarea 
                    placeholder={`Спросите ${agent === 'dashka' ? 'Dashka' : 'Claudy'}...`}
                    rows="3"
                  />
                  <button className="send-btn">Отправить</button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Terminal */}
      {terminalOpen && (
        <div className="terminal-panel">
          <div className="terminal-header">
            <span>TERMINAL</span>
            <div className="terminal-actions">
              <button onClick={() => setTerminalOpen(false)}>
                <X size={14} />
              </button>
            </div>
          </div>
          <div className="terminal-content">
            <div className="terminal-line">
              <span className="prompt">icoderplus@localhost:~$</span>
              <span className="command"> npm run dev</span>
            </div>
            <div className="terminal-line">
              <span className="output">🚀 Local:   http://localhost:5173/</span>
            </div>
            <div className="terminal-line">
              <span className="success">✅ ready in 1.2s</span>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default App
EOF

# ============================================================================
# 2. РАСШИРИТЬ FileTree.jsx - ДОБАВИТЬ КОПИРОВАНИЕ ПАПОК
# ============================================================================

cat > components/FileTree.jsx << 'EOF'
import React, { useState } from 'react'
import { ChevronRight, ChevronDown, File, Folder, Plus, X, Copy, FolderCopy, Edit3, Trash2 } from 'lucide-react'
import { getFileIcon, getFolderIcon } from '../utils/fileUtils'

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
  const [creating, setCreating] = useState(null)

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

  const startInlineCreation = (type, parentId = null) => {
    setCreating({
      type: type,
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

  // NEW: Copy folder with all contents
  const copyFolder = (item) => {
    const copyToClipboard = (data) => {
      navigator.clipboard.writeText(JSON.stringify(data, null, 2))
      console.log(`Copied ${item.type} "${item.name}" to clipboard`)
    }
    
    if (item.type === 'folder') {
      copyToClipboard(item)
    } else {
      copyToClipboard({ name: item.name, content: item.content })
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
              getFolderIcon(item.name, item.expanded) : 
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
        
        {creating && creating.parentId === item.id && item.type === 'folder' && item.expanded && (
          <div 
            className="tree-item creating"
            style={{ paddingLeft: (level + 1) * 16 + 8 }}
          >
            <span className="tree-icon">
              {creating.type === 'folder' ? 
                <Folder size={16} style={{color: '#60a5fa'}} /> : 
                <File size={16} style={{color: '#9ca3af'}} />
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
        
        {item.type === 'folder' && item.expanded && item.children && (
          <div className="tree-children">
            {item.children.map(child => renderTreeItem(child, level + 1))}
          </div>
        )}
      </div>
    )
  }

  const renderRootCreation = () => {
    if (creating && creating.parentId === null) {
      return (
        <div className="tree-item creating" style={{ paddingLeft: 8 }}>
          <span className="tree-icon">
            {creating.type === 'folder' ? 
              <Folder size={16} style={{color: '#60a5fa'}} /> : 
              <File size={16} style={{color: '#9ca3af'}} />
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

      {/* РАСШИРЕННОЕ КОНТЕКСТНОЕ МЕНЮ */}
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
              <Edit3 size={14} />
              Rename
            </div>
            <div className="context-menu-item" onClick={() => handleDelete(contextMenu.item)}>
              <Trash2 size={14} />
              Delete
            </div>
            <div className="context-menu-divider" />
            
            {/* COPY OPERATIONS */}
            <div className="context-menu-item" onClick={() => copyFolder(contextMenu.item)}>
              {contextMenu.item.type === 'folder' ? (
                <>
                  <FolderCopy size={14} />
                  Copy Folder
                </>
              ) : (
                <>
                  <Copy size={14} />
                  Copy File
                </>
              )}
            </div>
            
            <div className="context-menu-divider" />
            <div className="context-menu-item" onClick={() => startInlineCreation('file', contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              <Plus size={14} />
              New File
            </div>
            <div className="context-menu-item" onClick={() => startInlineCreation('folder', contextMenu.item.type === 'folder' ? contextMenu.item.id : null)}>
              <Folder size={14} />
              New Folder
            </div>
            
            {contextMenu.item.type === 'file' && (
              <>
                <div className="context-menu-divider" />
                <div className="context-menu-item">
                  ▶️ Run in Preview
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
# 3. ДОБАВИТЬ CSS ДЛЯ НОВЫХ ФУНКЦИЙ
# ============================================================================

cat >> styles/globals.css << 'EOF'

/* Menu Bar Styles */
.menu-bar {
  height: 35px;
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  user-select: none;
}

.menu-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.menu-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.menu-toggle {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 6px;
  border-radius: 3px;
  display: flex;
  align-items: center;
}

.menu-toggle:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.menu-btn {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 6px;
  border-radius: 3px;
  display: flex;
  align-items: center;
  font-size: 12px;
}

.menu-btn:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.app-title {
  font-size: 14px;
  color: var(--text-primary);
  font-weight: 500;
}

.app-subtitle {
  font-size: 11px;
  color: var(--text-secondary);
}

/* Collapsible Panels */
.left-panel.collapsed {
  width: 0;
  overflow: hidden;
  border: none;
}

.right-panel {
  width: 350px;
  background: var(--bg-secondary);
  border-left: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

/* AI Assistant Styles */
.ai-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.ai-chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 16px;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 16px;
}

.welcome-message {
  background: var(--bg-tertiary);
  padding: 16px;
  border-radius: 8px;
  border-left: 3px solid var(--accent-blue);
}

.welcome-message h4 {
  color: var(--text-primary);
  margin-bottom: 8px;
  font-size: 14px;
}

.welcome-message p {
  color: var(--text-secondary);
  font-size: 12px;
  line-height: 1.4;
}

.chat-input {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.chat-input textarea {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 8px;
  color: var(--text-primary);
  font-size: 13px;
  resize: none;
  font-family: inherit;
}

.chat-input textarea:focus {
  outline: none;
  border-color: var(--accent-blue);
}

.chat-input textarea::placeholder {
  color: var(--text-secondary);
}

.send-btn {
  background: var(--accent-blue);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  align-self: flex-end;
}

.send-btn:hover {
  background: #4a9eff;
}

/* Enhanced Context Menu */
.context-menu-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  font-size: 13px;
  color: var(--text-primary);
  cursor: pointer;
}

.context-menu-item:hover {
  background: var(--accent-blue);
}

.context-menu-divider {
  height: 1px;
  background: var(--border-color);
  margin: 4px 0;
}

/* Terminal Enhancements */
.terminal-panel {
  height: 180px;
  background: var(--bg-secondary);
  border-top: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

.terminal-header {
  padding: 8px 16px;
  background: var(--bg-tertiary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--text-secondary);
}

.terminal-actions button {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
}

.terminal-actions button:hover {
  background: var(--bg-primary);
  color: var(--text-primary);
}
EOF

# ============================================================================
# 4. ТЕСТ ИНТЕГРАЦИИ
# ============================================================================

cd ..
echo "🧪 Тестируем расширенные функции..."

npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ СКРИПТ #3.1 ВЫПОЛНЕН!"
    echo ""
    echo "🎯 НОВЫЕ ФУНКЦИИ:"
    echo "✅ Menu bar с кнопками toggle панелей"
    echo "✅ AI Assistant панель справа"
    echo "✅ Terminal toggle (открыть/закрыть)"
    echo "✅ Copy folder/file в контекстном меню"
    echo "✅ Sidebar collapse/expand"
    echo "✅ Расширенное контекстное меню с иконками"
    echo ""
    echo "🚀 ГОТОВО К КОММИТУ:"
    echo "   git add ."
    echo "   git commit -m 'Add missing IDE features - AI panel, terminal toggle, copy operations'"
    echo "   git push origin main"
else
    echo "❌ Build failed"
fi