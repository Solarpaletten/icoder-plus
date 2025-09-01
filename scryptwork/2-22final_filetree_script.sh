#!/bin/bash

echo "🎯 ФИНАЛЬНЫЙ СКРИПТ FILE TREE - ИСПОЛЬЗУЕТ СУЩЕСТВУЮЩИЙ initialData.js"

cd frontend/src

# ============================================================================
# 1. ОБНОВИТЬ App.jsx С ПОЛНЫМ LAYOUT И КОРРЕКТНЫМИ ПРОПАМИ
# ============================================================================

cat > App.jsx << 'EOF'
import React from 'react'
import { useFileManager } from './hooks/useFileManager'
import { useDualAgent } from './hooks/useDualAgent'
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

  const {
    agent,
    setAgent
  } = useDualAgent()

  return (
    <div className="ide-layout">
      {/* Main IDE Content */}
      <div className="ide-main">
        {/* Left Sidebar - File Explorer */}
        <div className="ide-sidebar">
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

        {/* Main Editor Area */}
        <div className="ide-content">
          {/* Tabs */}
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
          
          {/* Editor Content */}
          <div className="editor-area">
            {activeTab ? (
              <div className="code-editor">
                <div className="editor-placeholder">
                  <h3>🚀 iCoder Plus v2.2 - IDE Shell</h3>
                  <p>Minimalist Visual IDE - Monaco Editor will be here</p>
                  
                  <div className="code-preview">
                    <div className="code-header">
                      <span className="filename">{activeTab.name}</span>
                      <span className="language">{activeTab.language || 'text'}</span>
                    </div>
                    <pre className="code-content">
{activeTab.content || `// Welcome to iCoder Plus IDE Shell
console.log('Hello from ${activeTab.name}!');

function initIDE() {
  return {
    fileTree: true,
    editor: 'monaco',
    terminal: true,
    aiAgent: 'dual'
  };
}

export default initIDE;`}
                    </pre>
                  </div>
                  
                  <div className="next-features">
                    <h4>📋 Next: Monaco Editor Integration</h4>
                    <ul>
                      <li>✅ Syntax highlighting</li>
                      <li>✅ Auto-completion</li>
                      <li>✅ Multiple cursors</li>
                      <li>✅ Hot keys (Ctrl+S, Ctrl+R)</li>
                    </ul>
                  </div>
                </div>
              </div>
            ) : (
              <div className="no-file-selected">
                <h3>No file selected</h3>
                <p>Select a file from the explorer to start editing</p>
                <div className="welcome-actions">
                  <button onClick={() => createFile(null, 'index.js')}>
                    📄 New File
                  </button>
                  <button onClick={() => createFolder(null, 'components')}>
                    📁 New Folder
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Panel - AI Assistant */}
        <div className="ide-right-panel">
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
            <p>AI Panel placeholder - будет чат с {agent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Generator)'}</p>
          </div>
        </div>
      </div>

      {/* Bottom Terminal */}
      <div className="terminal-panel">
        <div className="terminal-header">
          <span>TERMINAL</span>
          <div className="terminal-actions">
            <button>⚙️</button>
            <button>📋</button>
            <button>🗙</button>
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
            <span className="output">📡 Network: http://192.168.1.100:5173/</span>
          </div>
          <div className="terminal-line">
            <span className="success">✅ ready in 1.2s</span>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
EOF

# ============================================================================
# 2. ИСПРАВИТЬ useFileManager.js - ИСПОЛЬЗОВАТЬ СУЩЕСТВУЮЩИЙ initialData.js
# ============================================================================

cat > hooks/useFileManager.js << 'EOF'
import { useState, useEffect } from 'react'
import { initialFiles } from '../utils/initialData'

export const useFileManager = () => {
  const [fileTree, setFileTree] = useState(initialFiles)
  const [openTabs, setOpenTabs] = useState([])
  const [activeTab, setActiveTab] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  const generateId = () => Math.random().toString(36).substr(2, 9)

  // Find file by ID in tree structure
  const findFileById = (tree, id) => {
    for (const item of tree) {
      if (item.id === id) return item
      if (item.children) {
        const found = findFileById(item.children, id)
        if (found) return found
      }
    }
    return null
  }

  // Sort items (folders first, then files alphabetically)
  const sortTreeItems = (items) => {
    return items.sort((a, b) => {
      if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
      return a.name.localeCompare(b.name)
    })
  }

  // Get language from file extension
  const getLanguageFromExtension = (filename) => {
    const ext = filename.split('.').pop()?.toLowerCase()
    const languageMap = {
      js: 'javascript',
      jsx: 'javascript',
      ts: 'typescript',
      tsx: 'typescript',
      html: 'html',
      css: 'css',
      json: 'json',
      py: 'python',
      md: 'markdown'
    }
    return languageMap[ext] || 'text'
  }

  // Update file content
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
    
    // Update open tabs
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === fileId ? { ...tab, content } : tab
    ))
    
    // Update active tab if it's the file being updated
    if (activeTab?.id === fileId) {
      setActiveTab({ ...activeTab, content })
    }
  }

  // Create new file
  const createFile = (parentId = null, name, content = '') => {
    const newFile = {
      id: generateId(),
      name,
      type: 'file',
      content,
      language: getLanguageFromExtension(name)
    }

    if (parentId) {
      // Add to specific folder
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFile]
            return {
              ...item,
              children: sortTreeItems(children)
            }
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
      setFileTree(tree => sortTreeItems([...tree, newFile]))
    }

    // Auto-open the new file
    openFile(newFile)
    return newFile
  }

  // Create new folder
  const createFolder = (parentId = null, name) => {
    const newFolder = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: true,
      children: []
    }

    if (parentId) {
      // Add to specific folder
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFolder]
            return {
              ...item,
              children: sortTreeItems(children)
            }
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
      setFileTree(tree => sortTreeItems([...tree, newFolder]))
    }

    return newFolder
  }

  // Rename item
  const renameItem = (item, newName) => {
    const updateInTree = (tree) => {
      return tree.map(treeItem => {
        if (treeItem.id === item.id) {
          return { 
            ...treeItem, 
            name: newName,
            language: treeItem.type === 'file' ? getLanguageFromExtension(newName) : undefined
          }
        }
        if (treeItem.children) {
          return { ...treeItem, children: updateInTree(treeItem.children) }
        }
        return treeItem
      })
    }
    setFileTree(updateInTree)

    // Update open tabs
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === item.id ? { ...tab, name: newName } : tab
    ))
    
    // Update active tab
    if (activeTab?.id === item.id) {
      setActiveTab({ ...activeTab, name: newName })
    }
  }

  // Delete item
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
    
    // Close related tabs
    setOpenTabs(tabs => tabs.filter(tab => tab.id !== item.id))
    
    // Update active tab
    if (activeTab?.id === item.id) {
      const remainingTabs = openTabs.filter(tab => tab.id !== item.id)
      setActiveTab(remainingTabs.length > 0 ? remainingTabs[0] : null)
    }
  }

  // Open file in tab
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

  // Close tab
  const closeTab = (tab) => {
    const newTabs = openTabs.filter(t => t.id !== tab.id)
    setOpenTabs(newTabs)
    
    if (activeTab?.id === tab.id) {
      setActiveTab(newTabs.length > 0 ? newTabs[newTabs.length - 1] : null)
    }
  }

  // Toggle folder expanded state
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

  // Auto-save project to localStorage
  useEffect(() => {
    const projectData = {
      fileTree,
      openTabs: openTabs.map(tab => tab.id),
      activeTabId: activeTab?.id
    }
    localStorage.setItem('icoder-project-v2.2.0', JSON.stringify(projectData))
  }, [fileTree, openTabs, activeTab])

  // Load project from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('icoder-project-v2.2.0')
    if (saved) {
      try {
        const project = JSON.parse(saved)
        if (project.fileTree) {
          setFileTree(project.fileTree)
          
          // Restore open tabs
          if (project.openTabs) {
            const restoredTabs = project.openTabs
              .map(tabId => findFileById(project.fileTree, tabId))
              .filter(Boolean)
            setOpenTabs(restoredTabs)
            
            // Restore active tab
            if (project.activeTabId) {
              const activeFile = findFileById(project.fileTree, project.activeTabId)
              if (activeFile) setActiveTab(activeFile)
            }
          }
        }
      } catch (e) {
        console.warn('Failed to load project:', e)
      }
    }
  }, [])

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
    updateFileContent,
    findFileById
  }
}
EOF

# ============================================================================
# 3. ДОБАВИТЬ НЕДОСТАЮЩИЕ CSS СТИЛИ К СУЩЕСТВУЮЩЕМУ globals.css
# ============================================================================

cat >> styles/globals.css << 'EOF'

/* Editor Area Improvements */
.editor-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.code-editor {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.editor-placeholder {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  text-align: center;
}

.editor-placeholder h3 {
  color: var(--accent-blue);
  margin-bottom: 12px;
  font-size: 24px;
}

.editor-placeholder p {
  color: var(--text-secondary);
  margin-bottom: 24px;
}

.code-preview {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 8px;
  margin: 24px 0;
  max-width: 600px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
}

.code-header {
  background: #21262d;
  padding: 8px 16px;
  border-bottom: 1px solid #30363d;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
}

.filename {
  color: var(--text-primary);
  font-weight: 600;
}

.language {
  color: var(--text-secondary);
  text-transform: uppercase;
  font-size: 10px;
}

.code-content {
  padding: 16px;
  color: #c9d1d9;
  font-family: 'Fira Code', 'JetBrains Mono', monospace;
  font-size: 14px;
  line-height: 1.5;
  text-align: left;
  overflow-x: auto;
}

.next-features {
  margin-top: 32px;
  text-align: left;
  max-width: 400px;
}

.next-features h4 {
  color: var(--accent-green);
  margin-bottom: 12px;
  font-size: 16px;
}

.next-features ul {
  list-style: none;
  color: var(--text-secondary);
}

.next-features li {
  padding: 4px 0;
  font-size: 14px;
}

.no-file-selected {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  text-align: center;
  padding: 40px;
}

.no-file-selected h3 {
  color: var(--text-primary);
  margin-bottom: 8px;
}

.welcome-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.welcome-actions button {
  padding: 8px 16px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.welcome-actions button:hover {
  background: var(--accent-blue);
  border-color: var(--accent-blue);
}

/* Terminal Improvements */
.terminal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.terminal-actions {
  display: flex;
  gap: 8px;
}

.terminal-actions button {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
  font-size: 12px;
}

.terminal-actions button:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.terminal-line {
  margin-bottom: 4px;
  font-family: 'JetBrains Mono', monospace;
}

.prompt {
  color: var(--accent-green);
}

.command {
  color: var(--text-primary);
  margin-left: 8px;
}

.output {
  color: var(--text-secondary);
}

.success {
  color: var(--accent-green);
}

/* Agent Switcher Improvements */
.agent-switcher button {
  font-size: 11px;
  padding: 6px 10px;
}

.agent-switcher button.active {
  background: var(--accent-blue);
  color: white;
}
EOF