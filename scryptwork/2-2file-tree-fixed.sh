#!/bin/bash

echo "🔧 File Tree Integration Fix - подключаем новые компоненты"

cd frontend/src

# ============================================================================
# 1. ОБНОВИТЬ ГЛАВНЫЙ App.jsx ДЛЯ ИСПОЛЬЗОВАНИЯ НОВЫХ КОМПОНЕНТОВ
# ============================================================================

cat > App.jsx << 'EOF'
import React from 'react'
import { useFileManager } from './hooks/useFileManager'
import FileTree from './components/FileTree'
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
              <button className="agent-btn">🏗️ Dashka</button>
              <button className="agent-btn active">🤖 Claudy</button>
            </div>
          </div>
          <div className="ai-content">
            <p>AI Panel placeholder - будет чат с Cloudy</p>
          </div>
        </div>
      </div>

      {/* Bottom Terminal */}
      <div className="bottom-panel">
        <div className="terminal-header">
          <span>TERMINAL</span>
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
    </div>
  )
}

export default App
EOF

# ============================================================================
# 2. СОЗДАТЬ НЕДОСТАЮЩИЙ useFileManager ХУК
# ============================================================================

mkdir -p hooks

cat > hooks/useFileManager.js << 'EOF'
import { useState, useEffect } from 'react'

const initialFiles = [
  {
    id: 'src',
    name: 'src',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'app-jsx',
        name: 'App.jsx',
        type: 'file',
        language: 'javascript',
        content: `import React from 'react'

function App() {
  return (
    <div className="App">
      <h1>Welcome to iCoder Plus v2.2</h1>
      <p>File Tree Management is working!</p>
    </div>
  )
}

export default App`
      },
      {
        id: 'components',
        name: 'components',
        type: 'folder',
        expanded: false,
        children: []
      }
    ]
  }
]

export const useFileManager = () => {
  const [fileTree, setFileTree] = useState(initialFiles)
  const [openTabs, setOpenTabs] = useState([])
  const [activeTab, setActiveTab] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  const generateId = () => Math.random().toString(36).substr(2, 9)

  const createFile = (parentId = null, name, content = '') => {
    const newFile = {
      id: generateId(),
      name,
      type: 'file',
      content,
      language: 'javascript'
    }

    if (parentId) {
      // Add to specific folder
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFile]
            return { ...item, children: sortItems(children) }
          }
          if (item.children) {
            return { ...item, children: addToTree(item.children) }
          }
          return item
        })
      }
      setFileTree(addToTree)
    } else {
      // Add to root
      setFileTree(tree => sortItems([...tree, newFile]))
    }

    // Auto-open new file
    openFile(newFile)
    return newFile
  }

  const createFolder = (parentId = null, name) => {
    const newFolder = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: true,
      children: []
    }

    if (parentId) {
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFolder]
            return { ...item, children: sortItems(children) }
          }
          if (item.children) {
            return { ...item, children: addToTree(item.children) }
          }
          return item
        })
      }
      setFileTree(addToTree)
    } else {
      setFileTree(tree => sortItems([...tree, newFolder]))
    }

    return newFolder
  }

  const renameItem = (item, newName) => {
    const updateInTree = (tree) => {
      return tree.map(treeItem => {
        if (treeItem.id === item.id) {
          return { ...treeItem, name: newName }
        }
        if (treeItem.children) {
          return { ...treeItem, children: updateInTree(treeItem.children) }
        }
        return treeItem
      })
    }
    setFileTree(updateInTree)

    // Update tabs
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === item.id ? { ...tab, name: newName } : tab
    ))
    
    if (activeTab?.id === item.id) {
      setActiveTab({ ...activeTab, name: newName })
    }
  }

  const deleteItem = (item) => {
    const removeFromTree = (tree) => {
      return tree.filter(treeItem => {
        if (treeItem.id === item.id) return false
        if (treeItem.children) {
          treeItem.children = removeFromTree(treeItem.children)
        }
        return true
      })
    }
    
    setFileTree(removeFromTree)
    setOpenTabs(tabs => tabs.filter(tab => tab.id !== item.id))
    
    if (activeTab?.id === item.id) {
      const remainingTabs = openTabs.filter(tab => tab.id !== item.id)
      setActiveTab(remainingTabs.length > 0 ? remainingTabs[0] : null)
    }
  }

  const openFile = (file) => {
    if (file.type !== 'file') return
    
    const existingTab = openTabs.find(tab => tab.id === file.id)
    if (existingTab) {
      setActiveTab(existingTab)
      return
    }

    const newTab = { ...file }
    setOpenTabs(prev => [...prev, newTab])
    setActiveTab(newTab)
  }

  const closeTab = (tab) => {
    const newTabs = openTabs.filter(t => t.id !== tab.id)
    setOpenTabs(newTabs)
    
    if (activeTab?.id === tab.id) {
      setActiveTab(newTabs.length > 0 ? newTabs[newTabs.length - 1] : null)
    }
  }

  const toggleFolder = (folder) => {
    const updateInTree = (tree) => {
      return tree.map(item => {
        if (item.id === folder.id) {
          return { ...item, expanded: !item.expanded }
        }
        if (item.children) {
          return { ...item, children: updateInTree(item.children) }
        }
        return item
      })
    }
    setFileTree(updateInTree)
  }

  const updateFileContent = (fileId, content) => {
    const updateInTree = (tree) => {
      return tree.map(item => {
        if (item.id === fileId) {
          return { ...item, content }
        }
        if (item.children) {
          return { ...item, children: updateInTree(item.children) }
        }
        return item
      })
    }
    
    setFileTree(updateInTree)
    
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === fileId ? { ...tab, content } : tab
    ))
    
    if (activeTab?.id === fileId) {
      setActiveTab({ ...activeTab, content })
    }
  }

  const sortItems = (items) => {
    return items.sort((a, b) => {
      if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
      return a.name.localeCompare(b.name)
    })
  }

  return {
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
  }
}
EOF

# ============================================================================
# 3. ОБНОВИТЬ CSS ДЛЯ ПОЛНОГО LAYOUT
# ============================================================================

cat > styles/globals.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #1e1e1e;
  color: #cccccc;
  overflow: hidden;
}

.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 35px;
}

.app-title {
  font-size: 14px;
  color: #cccccc;
}

.app-subtitle {
  font-size: 12px;
  color: #888;
  margin-left: 8px;
}

.status-indicator {
  font-size: 12px;
  color: #4ec9b0;
}

.ai-panel-toggle {
  font-size: 12px;
  color: #007acc;
}

.app-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.left-panel {
  width: 300px;
  border-right: 1px solid #464647;
  background: #252526;
  display: flex;
  flex-direction: column;
}

.main-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #1e1e1e;
}

.right-panel {
  width: 300px;
  border-left: 1px solid #464647;
  background: #252526;
}

.editor-header {
  border-bottom: 1px solid #464647;
  background: #2d2d30;
}

.editor-tabs {
  display: flex;
  overflow-x: auto;
}

.editor-tab {
  padding: 8px 12px;
  border-right: 1px solid #464647;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 100px;
  background: #2d2d30;
}

.editor-tab:hover {
  background: #37373d;
}

.editor-tab.active {
  background: #1e1e1e;
  border-bottom: 2px solid #007acc;
}

.tab-name {
  font-size: 13px;
  color: #cccccc;
}

.tab-close {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  font-size: 16px;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tab-close:hover {
  color: #cccccc;
  background: #464647;
  border-radius: 3px;
}

.editor-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.editor-placeholder {
  text-align: center;
  padding: 40px 20px;
}

.editor-placeholder h3 {
  color: #007acc;
  margin-bottom: 10px;
  font-size: 24px;
}

.editor-placeholder p {
  color: #888;
  margin-bottom: 20px;
}

.code-preview {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 16px;
  margin: 20px auto;
  max-width: 600px;
  text-align: left;
}

.code-preview pre {
  color: #c9d1d9;
  font-family: 'Fira Code', 'Cascadia Code', monospace;
  font-size: 14px;
  line-height: 1.5;
}

.no-file-selected {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #888;
}

.ai-header {
  padding: 12px 16px;
  border-bottom: 1px solid #464647;
  background: #2d2d30;
}

.ai-header h3 {
  font-size: 12px;
  color: #cccccc;
  margin-bottom: 8px;
}

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
}

.agent-btn:hover {
  border-color: #007acc;
}

.agent-btn.active {
  background: #007acc;
  border-color: #007acc;
}

.ai-content {
  padding: 16px;
  color: #888;
  font-size: 13px;
}

.bottom-panel {
  height: 150px;
  border-top: 1px solid #464647;
  background: #1e1e1e;
  display: flex;
  flex-direction: column;
}

.terminal-header {
  padding: 8px 16px;
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  font-size: 12px;
  color: #cccccc;
}

.terminal-content {
  flex: 1;
  padding: 12px 16px;
  font-family: 'Fira Code', 'Cascadia Code', monospace;
  font-size: 13px;
  color: #cccccc;
  overflow-y: auto;
}

.terminal-line {
  margin-bottom: 4px;
}

.prompt {
  color: #4ec9b0;
}

.output {
  color: #cccccc;
}

/* File Tree Styles */
.file-tree {
  height: 100%;
  display: flex;
  flex-direction: column;
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
# 4. ТЕСТИРОВАТЬ ИНТЕГРАЦИЮ
# ============================================================================

echo "Testing integration..."

cd ..
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ FILE TREE INTEGRATION УСПЕШНА!"
    echo ""
    echo "ТЕПЕРЬ ДОЛЖНО БЫТЬ ВИДНО:"
    echo "✅ Кнопки + File/Folder в заголовке EXPLORER"
    echo "✅ Поле поиска под заголовком"
    echo "✅ Контекстное меню по правому клику"
    echo "✅ Табы файлов с кнопками закрытия"
    echo "✅ Полный layout с тремя панелями"
    echo ""
    echo "ТЕСТЫ ДЛЯ ПРОВЕРКИ:"
    echo "1. Правый клик на src → должно появиться меню"
    echo "2. Клик + в заголовке → должен появиться prompt"
    echo "3. Поиск файлов в поле Search"
    echo "4. Открытие файлов в табах"
else
    echo "❌ Build failed"
    exit 1
fi