#!/bin/bash
# 🚀 iCoder Plus v2.1.1 - Instant Modular Structure Setup
# Распиливаем монолит на чистую модульную архитектуру за 30 секунд

echo "🚀 Creating iCoder Plus v2.1.1 Modular Structure..."

# Create directory structure
mkdir -p frontend/{src/{components,services,utils,hooks},public,styles}
mkdir -p backend/{src/{routes,services,middleware},tests}

echo "📂 Directories created"

# === FRONTEND FILES ===

# package.json
cat > frontend/package.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.1.1",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@monaco-editor/react": "^4.6.0",
    "monaco-editor": "^0.44.0",
    "jszip": "^3.10.1",
    "file-saver": "^2.0.5",
    "clsx": "^2.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.1.1",
    "vite": "^5.0.0",
    "tailwindcss": "^3.4.17",
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.6"
  }
}
EOF

# vite.config.js
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true
  },
  build: {
    outDir: 'dist',
    sourcemap: true
  }
})
EOF

# tailwind.config.js
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'ide-bg': '#0d1117',
        'ide-surface': '#161b22',
        'ide-panel': '#21262d',
        'ide-border': '#30363d',
        'ide-text': '#e6edf3',
        'ide-muted': '#7d8590',
        'agent-dashka': '#ff6b35',
        'agent-claudy': '#4ecdc4'
      }
    }
  },
  plugins: [],
}
EOF

# Main HTML entry point
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>iCoder Plus v2.1.1 - Dual-Agent AI IDE</title>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF

# Main entry point
cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './styles/index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Main App component
cat > frontend/src/App.jsx << 'EOF'
import React, { useState, useEffect } from 'react'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import RightPanel from './components/RightPanel'
import ContextMenu from './components/ContextMenu'
import ExportProgress from './components/ExportProgress'
import { useFileManager } from './hooks/useFileManager'
import { useDualAgent } from './hooks/useDualAgent'
import { exportService } from './services/exportService'

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
    toggleFolder,
    updateFileContent
  } = useFileManager()

  const {
    agent,
    setAgent,
    targetFile,
    setTargetFile,
    proposals,
    setProposals,
    chatInput,
    setChatInput,
    aiLoading,
    sendChatMessage,
    applyProposal
  } = useDualAgent({ activeTab, fileTree, updateFileContent, createFile })

  const [rightPanel, setRightPanel] = useState('ai-chat')
  const [contextMenu, setContextMenu] = useState(null)
  const [exportProgress, setExportProgress] = useState(null)

  // Handle export
  const handleExport = async () => {
    await exportService.exportAsZip(fileTree, setExportProgress)
  }

  // Handle context menu
  const handleRightClick = (e, item) => {
    e.preventDefault()
    setContextMenu({ x: e.pageX, y: e.pageY, item })
  }

  const handleContextAction = (action, item) => {
    setContextMenu(null)
    
    switch (action) {
      case 'add-file':
        const fileName = prompt('Enter file name:')
        if (fileName) createFile(item.id, fileName)
        break
      case 'add-folder':
        const folderName = prompt('Enter folder name:')
        if (folderName) createFolder(item.id, folderName)
        break
      case 'rename':
        const newName = prompt('Enter new name:', item.name)
        if (newName && newName !== item.name) renameItem(item, newName)
        break
      case 'delete':
        if (confirm(`Delete "${item.name}"?`)) deleteItem(item)
        break
      case 'run-preview':
        if (item.name.endsWith('.html')) setRightPanel('preview')
        break
    }
  }

  // Hide context menu on click
  useEffect(() => {
    const handleClick = () => setContextMenu(null)
    document.addEventListener('click', handleClick)
    return () => document.removeEventListener('click', handleClick)
  }, [])

  return (
    <div className="app">
      {/* Top Bar */}
      <header className="topbar">
        <div className="brand">
          <span className="text-xl font-semibold">⚡ iCoder Plus v2.1.1</span>
          <span className="badge">Dual-Agent AI IDE</span>
        </div>
        
        <div className="dual-agent-indicator">
          <div className={`agent-dot ${agent}`}></div>
          <span>Active: {agent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Code Gen)'}</span>
        </div>
      </header>

      <main className="main">
        {/* File Tree */}
        <FileTree
          fileTree={fileTree}
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          openFile={openFile}
          toggleFolder={toggleFolder}
          onRightClick={handleRightClick}
          onExport={handleExport}
          selectedFileId={activeTab?.id}
        />

        {/* Editor Area */}
        <Editor
          openTabs={openTabs}
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          closeTab={closeTab}
          updateFileContent={updateFileContent}
          setRightPanel={setRightPanel}
        />

        {/* Right Panel */}
        <RightPanel
          activePanel={rightPanel}
          setActivePanel={setRightPanel}
          agent={agent}
          setAgent={setAgent}
          targetFile={targetFile}
          setTargetFile={setTargetFile}
          proposals={proposals}
          setProposals={setProposals}
          chatInput={chatInput}
          setChatInput={setChatInput}
          aiLoading={aiLoading}
          sendChatMessage={sendChatMessage}
          applyProposal={applyProposal}
          activeTab={activeTab}
          fileTree={fileTree}
        />
      </main>

      {/* Context Menu */}
      {contextMenu && (
        <ContextMenu
          contextMenu={contextMenu}
          onAction={handleContextAction}
        />
      )}

      {/* Export Progress */}
      {exportProgress && (
        <ExportProgress progress={exportProgress} />
      )}
    </div>
  )
}

export default App
EOF

# === COMPONENTS ===

# FileTree component
cat > frontend/src/components/FileTree.jsx << 'EOF'
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
EOF

# Editor component
cat > frontend/src/components/Editor.jsx << 'EOF'
import React, { useRef, useEffect } from 'react'
import MonacoEditor from '@monaco-editor/react'
import { getFileIcon, getLanguageFromFilename } from '../utils/fileUtils'

const Editor = ({ 
  openTabs, 
  activeTab, 
  setActiveTab, 
  closeTab, 
  updateFileContent,
  setRightPanel 
}) => {
  const editorRef = useRef(null)

  const handleEditorDidMount = (editor, monaco) => {
    editorRef.current = editor
    
    // Auto-save on change
    editor.onDidChangeModelContent(() => {
      if (activeTab) {
        const content = editor.getValue()
        updateFileContent(activeTab.id, content)
        
        // Auto-preview HTML files
        if (activeTab.name.endsWith('.html')) {
          setRightPanel('preview')
        }
      }
    })
  }

  return (
    <div className="editor-area">
      {/* Editor Tabs */}
      <div className="editor-tabs">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`editor-tab ${activeTab?.id === tab.id ? 'active' : ''}`}
            onClick={() => setActiveTab(tab)}
          >
            <span className="tree-icon">{getFileIcon(tab.name)}</span>
            <span>{tab.name}</span>
            <span 
              className="tab-close"
              onClick={(e) => {
                e.stopPropagation()
                closeTab(tab)
              }}
            >
              ×
            </span>
          </div>
        ))}
        
        {openTabs.length === 0 && (
          <div className="p-3 text-ide-muted text-xs">
            👈 Open a file from the tree to start coding
          </div>
        )}
      </div>

      {/* Monaco Editor */}
      <div className="editor-container">
        {activeTab ? (
          <MonacoEditor
            value={activeTab.content || ''}
            language={getLanguageFromFilename(activeTab.name)}
            theme="vs-dark"
            options={{
              fontSize: 13,
              lineNumbers: 'on',
              minimap: { enabled: false },
              padding: { top: 16 },
              scrollBeyondLastLine: false,
              wordWrap: 'on'
            }}
            onMount={handleEditorDidMount}
          />
        ) : (
          <div className="flex items-center justify-center h-full text-ide-muted">
            Select a file to start editing
          </div>
        )}
      </div>
    </div>
  )
}

export default Editor
EOF

# Right Panel component
cat > frontend/src/components/RightPanel.jsx << 'EOF'
import React from 'react'
import DualAgentChat from './DualAgentChat'
import PreviewPanel from './PreviewPanel'

const RightPanel = ({ 
  activePanel, 
  setActivePanel,
  agent,
  setAgent,
  targetFile,
  setTargetFile,
  proposals,
  setProposals,
  chatInput,
  setChatInput,
  aiLoading,
  sendChatMessage,
  applyProposal,
  activeTab,
  fileTree
}) => {
  return (
    <div className="right-panel">
      <div className="panel-tabs">
        <div 
          className={`panel-tab ${activePanel === 'ai-chat' ? 'active' : ''}`}
          onClick={() => setActivePanel('ai-chat')}
        >
          🤖 Dual AI
        </div>
        <div 
          className={`panel-tab ${activePanel === 'preview' ? 'active' : ''}`}
          onClick={() => setActivePanel('preview')}
        >
          ▶ Preview
        </div>
      </div>

      <div className="panel-content">
        {activePanel === 'ai-chat' ? (
          <DualAgentChat
            agent={agent}
            setAgent={setAgent}
            targetFile={targetFile}
            setTargetFile={setTargetFile}
            proposals={proposals}
            setProposals={setProposals}
            chatInput={chatInput}
            setChatInput={setChatInput}
            aiLoading={aiLoading}
            sendChatMessage={sendChatMessage}
            applyProposal={applyProposal}
            activeTab={activeTab}
            fileTree={fileTree}
          />
        ) : (
          <PreviewPanel activeTab={activeTab} />
        )}
      </div>
    </div>
  )
}

export default RightPanel
EOF

# Dual Agent Chat component
cat > frontend/src/components/DualAgentChat.jsx << 'EOF'
import React from 'react'
import AgentSelector from './AgentSelector'
import ProposalsList from './ProposalsList'
import { getAllFilePaths } from '../utils/fileUtils'

const DualAgentChat = ({
  agent,
  setAgent,
  targetFile,
  setTargetFile,
  proposals,
  setProposals,
  chatInput,
  setChatInput,
  aiLoading,
  sendChatMessage,
  applyProposal,
  activeTab,
  fileTree
}) => {
  return (
    <div className="ai-chat-panel">
      {/* Agent Selector */}
      <AgentSelector agent={agent} setAgent={setAgent} />

      {/* Target File Selector */}
      <div className="target-selector mb-3">
        <label className="text-ide-muted text-xs">Target File:</label>
        <select 
          className="target-select"
          value={targetFile}
          onChange={(e) => setTargetFile(e.target.value)}
        >
          <option value="">(current: {activeTab?.name || 'none'})</option>
          {getAllFilePaths(fileTree).map(path => (
            <option key={path} value={path}>{path}</option>
          ))}
        </select>
      </div>

      {/* Chat Input */}
      <div className="chat-input-area">
        <textarea
          className="chat-input"
          placeholder={agent === 'dashka' 
            ? "Ask Dashka for architecture advice, code review, or planning..." 
            : "Ask Claudy to generate components, functions, or code snippets..."
          }
          value={chatInput}
          onChange={(e) => setChatInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
              sendChatMessage()
            }
          }}
        />
        <button 
          className="chat-send"
          onClick={sendChatMessage}
          disabled={aiLoading || !chatInput.trim()}
        >
          {aiLoading ? '⏳' : '🚀'}
        </button>
      </div>

      {/* Proposals */}
      <ProposalsList
        proposals={proposals}
        setProposals={setProposals}
        applyProposal={applyProposal}
        agent={agent}
      />
    </div>
  )
}

export default DualAgentChat
EOF

# Agent Selector component
cat > frontend/src/components/AgentSelector.jsx << 'EOF'
import React from 'react'

const AgentSelector = ({ agent, setAgent }) => {
  return (
    <div className="agent-selector">
      <div
        className={`agent-option dashka ${agent === 'dashka' ? 'active' : ''}`}
        onClick={() => setAgent('dashka')}
      >
        🏗️ Dashka<br/>
        <small>Architecture & Review</small>
      </div>
      <div
        className={`agent-option claudy ${agent === 'claudy' ? 'active' : ''}`}
        onClick={() => setAgent('claudy')}
      >
        🤖 Claudy<br/>
        <small>Code Generation</small>
      </div>
    </div>
  )
}

export default AgentSelector
EOF

# Proposals List component
cat > frontend/src/components/ProposalsList.jsx << 'EOF'
import React from 'react'

const ProposalsList = ({ proposals, setProposals, applyProposal, agent }) => {
  return (
    <div className="proposals-section">
      <div className="proposals-header">
        <span className="proposals-title">Code Proposals</span>
        {proposals.length > 0 && (
          <>
            <span className="proposals-count">{proposals.length}</span>
            <button 
              className="btn text-xs p-1 ml-2"
              onClick={() => setProposals([])}
              title="Clear all proposals"
            >
              🗑️
            </button>
          </>
        )}
      </div>

      {proposals.length === 0 ? (
        <div className="text-ide-muted text-center py-5 text-xs">
          {agent === 'dashka' 
            ? "💡 Dashka provides architecture guidance"
            : "🤖 Claudy generates code proposals. Try: 'Create a React component'"
          }
        </div>
      ) : (
        proposals.map(proposal => (
          <div key={proposal.id} className="proposal-item">
            <div className="proposal-header">
              <div>
                <div className="proposal-title">{proposal.title}</div>
                <div className="proposal-meta">
                  📁 {proposal.file || 'current'} • {proposal.language}
                </div>
              </div>
            </div>
            
            <div className="proposal-actions">
              <button 
                className="proposal-btn apply"
                onClick={() => applyProposal(proposal, 'apply')}
                title="Replace entire file"
              >
                Apply
              </button>
              <button 
                className="proposal-btn insert"
                onClick={() => applyProposal(proposal, 'insert')}
                title="Insert at cursor"
              >
                Insert
              </button>
              <button 
                className="proposal-btn create"
                onClick={() => applyProposal(proposal, 'create')}
                title="Create new file"
              >
                Create
              </button>
            </div>
          </div>
        ))
      )}
    </div>
  )
}

export default ProposalsList
EOF

# Preview Panel component
cat > frontend/src/components/PreviewPanel.jsx << 'EOF'
import React, { useRef, useEffect, useState } from 'react'

const PreviewPanel = ({ activeTab }) => {
  const [consoleOutput, setConsoleOutput] = useState([])
  const previewFrameRef = useRef(null)

  const updatePreview = (htmlContent) => {
    if (previewFrameRef.current) {
      const iframe = previewFrameRef.current
      const doc = iframe.contentDocument || iframe.contentWindow.document
      doc.open()
      doc.write(htmlContent)
      doc.close()
      
      // Capture console output
      iframe.contentWindow.console = {
        log: (...args) => {
          setConsoleOutput(prev => [...prev, { 
            type: 'log', 
            content: args.join(' '),
            timestamp: new Date().toLocaleTimeString()
          }])
        },
        error: (...args) => {
          setConsoleOutput(prev => [...prev, { 
            type: 'error', 
            content: args.join(' '),
            timestamp: new Date().toLocaleTimeString()
          }])
        }
      }
    }
  }

  useEffect(() => {
    if (activeTab?.name.endsWith('.html')) {
      updatePreview(activeTab.content || '')
    }
  }, [activeTab])

  return (
    <div className="preview-panel">
      <div className="flex justify-between items-center mb-3">
        <h3 className="text-sm font-semibold">⚡ Live Preview</h3>
        <button 
          className="btn text-xs p-1"
          onClick={() => {
            if (activeTab?.name.endsWith('.html')) {
              updatePreview(activeTab.content || '')
            }
          }}
        >
          🔄 Refresh
        </button>
      </div>
      
      <iframe 
        ref={previewFrameRef}
        className="preview-frame"
        title="Preview"
      />

      {consoleOutput.length > 0 && (
        <div className="console-output">
          <h4 className="text-xs font-semibold mb-2">📟 Console:</h4>
          {consoleOutput.map((log, i) => (
            <div key={i} className={`console-${log.type} text-xs`}>
              [{log.timestamp}] {log.content}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default PreviewPanel
EOF

# Context Menu component
cat > frontend/src/components/ContextMenu.jsx << 'EOF'
import React from 'react'

const ContextMenu = ({ contextMenu, onAction }) => {
  const { x, y, item } = contextMenu

  return (
    <div 
      className="context-menu"
      style={{ left: x, top: y }}
    >
      {item.type === 'folder' && (
        <>
          <div 
            className="context-item"
            onClick={() => onAction('add-file', item)}
          >
            📄 New File
          </div>
          <div 
            className="context-item"
            onClick={() => onAction('add-folder', item)}
          >
            📁 New Folder
          </div>
          <div className="context-divider"></div>
        </>
      )}
      
      {item.type === 'file' && item.name.endsWith('.html') && (
        <div 
          className="context-item"
          onClick={() => onAction('run-preview', item)}
        >
          ▶ Run in Preview
        </div>
      )}
      
      <div 
        className="context-item"
        onClick={() => onAction('rename', item)}
      >
        ✏️ Rename
      </div>
      <div 
        className="context-item"
        onClick={() => onAction('delete', item)}
      >
        🗑️ Delete
      </div>
    </div>
  )
}

export default ContextMenu
EOF

# Export Progress component
cat > frontend/src/components/ExportProgress.jsx << 'EOF'
import React from 'react'

const ExportProgress = ({ progress }) => {
  return (
    <div className="export-progress">
      <h3 className="text-sm font-semibold mb-2">Exporting Project...</h3>
      <p className="text-xs text-ide-muted mb-2">{progress.message}</p>
      <div className="progress-bar">
        <div 
          className="progress-fill"
          style={{ width: `${progress.progress}%` }}
        />
      </div>
      <p className="text-xs mt-2">{Math.round(progress.progress)}%</p>
    </div>
  )
}

export default ExportProgress
EOF

# === HOOKS ===

# File Manager hook
cat > frontend/src/hooks/useFileManager.js << 'EOF'
import { useState, useEffect } from 'react'
import { initialFiles } from '../utils/initialData'

export const useFileManager = () => {
  const [fileTree, setFileTree] = useState(initialFiles)
  const [openTabs, setOpenTabs] = useState([])
  const [activeTab, setActiveTab] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  const generateId = () => Math.random().toString(36).substr(2, 9)

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

  const createFile = (parentId, name, content = '') => {
    const newFile = {
      id: generateId(),
      name,
      type: 'file',
      content
    }

    const addToTree = (tree) => {
      return tree.map(item => {
        if (item.id === parentId) {
          const children = [...(item.children || []), newFile]
          return {
            ...item,
            children: children.sort((a, b) => {
              if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
              return a.name.localeCompare(b.name)
            })
          }
        }
        if (item.children) {
          return { ...item, children: addToTree(item.children) }
        }
        return item
      })
    }

    setFileTree(addToTree)
    openFile(newFile)
    return newFile
  }

  const createFolder = (parentId, name) => {
    const newFolder = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: true,
      children: []
    }

    const addToTree = (tree) => {
      return tree.map(item => {
        if (item.id === parentId) {
          const children = [...(item.children || []), newFolder]
          return {
            ...item,
            children: children.sort((a, b) => {
              if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
              return a.name.localeCompare(b.name)
            })
          }
        }
        if (item.children) {
          return { ...item, children: addToTree(item.children) }
        }
        return item
      })
    }

    setFileTree(addToTree)
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
    setOpenTabs([...openTabs, newTab])
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

  // Auto-save to localStorage
  useEffect(() => {
    localStorage.setItem('icoder-project-v2.1.1', JSON.stringify(fileTree))
  }, [fileTree])

  // Load from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('icoder-project-v2.1.1')
    if (saved) {
      try {
        const project = JSON.parse(saved)
        setFileTree(project)
      } catch (e) {
        console.error('AI Chat error:', error)
    res.status(500).json({ success: false, error: error.message })
  }
})

router.post('/analyze', async (req, res) => {
  try {
    const { code, fileName, analysisType } = req.body
    
    const analysis = await aiService.analyzeCode({
      code,
      fileName,
      type: analysisType
    })
    
    res.json({ success: true, data: analysis })
  } catch (error) {
    console.error('AI Analyze error:', error)
    res.status(500).json({ success: false, error: error.message })
  }
})

export default router
EOF

# AI Service
cat > backend/src/services/aiService.js << 'EOF'
import OpenAI from 'openai'
import Anthropic from '@anthropic-ai/sdk'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
})

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
})

export const aiService = {
  async processMessage({ agent, message, code, targetFile }) {
    const prompt = this.buildPrompt(agent, message, code, targetFile)
    
    try {
      if (process.env.ANTHROPIC_API_KEY) {
        return await this.callClaude(prompt)
      } else if (process.env.OPENAI_API_KEY) {
        return await this.callOpenAI(prompt)
      } else {
        throw new Error('No AI API keys configured')
      }
    } catch (error) {
      console.error('AI Service error:', error)
      return `Error: ${error.message}`
    }
  },

  buildPrompt(agent, message, code, targetFile) {
    const agentContext = agent === 'dashka' 
      ? 'You are Dashka, an AI architect focused on code structure, best practices, and strategic guidance.'
      : 'You are Claudy, an AI code generator. Generate ready-to-use code with file: path syntax.'
    
    return `${agentContext}

User Request: ${message}
Target File: ${targetFile || 'current'}
Current Code: ${code ? `\n\`\`\`\n${code}\n\`\`\`` : 'No current code'}

${agent === 'claudy' ? 'Respond with code blocks using file: syntax when creating new files.' : 'Focus on architecture advice and code review.'}
`
  },

  async callClaude(prompt) {
    const response = await anthropic.messages.create({
      model: 'claude-3-sonnet-20240229',
      max_tokens: 1000,
      messages: [{ role: 'user', content: prompt }]
    })
    return response.content[0].text
  },

  async callOpenAI(prompt) {
    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 1000
    })
    return response.choices[0].message.content
  },

  async analyzeCode({ code, fileName, type }) {
    const prompt = `Analyze this ${type} for file ${fileName}:
    
\`\`\`
${code}
\`\`\`

Provide suggestions for improvements, potential issues, and optimizations.`

    return await this.processMessage({
      agent: 'dashka',
      message: prompt,
      code,
      targetFile: fileName
    })
  }
}
EOF

# Environment template
cat > backend/.env.example << 'EOF'
# AI Configuration
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Server Configuration
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173

# Logging
LOG_LEVEL=info
EOF

# === SETUP SCRIPT ===

cat > setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up iCoder Plus v2.1.1..."

# Frontend setup
cd frontend
echo "📦 Installing frontend dependencies..."
npm install

# Backend setup  
cd ../backend
echo "📦 Installing backend dependencies..."
npm install

# Copy environment
cp .env.example .env
echo "✅ Environment template created"

echo "🎯 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Add your API keys to backend/.env"
echo "2. Run 'npm run dev' in both frontend/ and backend/ directories"
echo "3. Open http://localhost:5173"
echo ""
echo "🚀 Happy coding with Dual-Agent AI!"
EOF

chmod +x setup.sh

# === README ===

cat > README.md << 'EOF'
# 🚀 iCoder Plus v2.1.1 - Dual-Agent AI IDE

Modern modular AI-first IDE with clean frontend/backend separation.

## ⚡ Quick Start

```bash
# Run setup script
./setup.sh

# Start development servers
cd frontend && npm run dev &
cd backend && npm run dev &
```

## 📂 Structure

```
iCoder-Plus-v2.1.1/
├── frontend/              # React + Vite + Tailwind
│   ├── src/
│   │   ├── components/    # UI Components
│   │   ├── hooks/         # Custom hooks
│   │   ├── services/      # API clients
│   │   ├── utils/         # Utilities
│   │   └── styles/        # Global styles
│   └── package.json
├── backend/               # Express + TypeScript  
│   ├── src/
│   │   ├── routes/        # API endpoints
│   │   ├── services/      # Business logic
│   │   └── middleware/    # Express middleware
│   └── package.json
.warn('Failed to load project:', e)
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
    updateFileContent
  }
}
EOF

# Dual Agent hook
cat > frontend/src/hooks/useDualAgent.js << 'EOF'
import { useState } from 'react'
import { aiService } from '../services/aiService'
import { extractProposalsFromText } from '../utils/aiUtils'

export const useDualAgent = ({ activeTab, fileTree, updateFileContent, createFile }) => {
  const [agent, setAgent] = useState('dashka')
  const [targetFile, setTargetFile] = useState('')
  const [proposals, setProposals] = useState([])
  const [chatInput, setChatInput] = useState('')
  const [aiLoading, setAiLoading] = useState(false)

  const sendChatMessage = async () => {
    if (!chatInput.trim() || aiLoading) return

    const agentPrefix = agent === 'dashka' ? '[AGENT:DASHKA]' : '[AGENT:CLAUDY]'
    const targetPath = targetFile || activeTab?.name || ''

    setChatInput('')
    setAiLoading(true)

    try {
      const response = await aiService.sendMessage(agentPrefix, chatInput, targetPath)
      
      if (agent === 'claudy') {
        const newProposals = extractProposalsFromText(response, targetPath)
        setProposals(prev => [...newProposals, ...prev])
      }

    } catch (error) {
      console.error('AI Chat error:', error)
    } finally {
      setAiLoading(false)
    }
  }

  const applyProposal = (proposal, action) => {
    const targetPath = proposal.file || activeTab?.name || ''
    
    if (action === 'apply') {
      // Find and update existing file
      const findFileByPath = (tree, path) => {
        for (const item of tree) {
          if (item.type === 'file' && item.name === path) return item
          if (item.children) {
            const found = findFileByPath(item.children, path)
            if (found) return found
          }
        }
        return null
      }

      const file = findFileByPath(fileTree, targetPath)
      if (file) {
        updateFileContent(file.id, proposal.code)
      } else {
        const parentId = fileTree[0]?.id
        createFile(parentId, targetPath, proposal.code)
      }
    }
    
    setProposals(prev => prev.filter(p => p.id !== proposal.id))
  }

  return {
    agent,
    setAgent,
    targetFile,
    setTargetFile,
    proposals,
    setProposals,
    chatInput,
    setChatInput,
    aiLoading,
    sendChatMessage,
    applyProposal
  }
}
EOF

# === SERVICES ===

# AI Service
cat > frontend/src/services/aiService.js << 'EOF'
export const aiService = {
  async sendMessage(agentPrefix, message, targetPath, code = '') {
    // Simulate AI response - replace with real API call
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    if (agentPrefix.includes('DASHKA')) {
      return generateDashkaResponse(message, code)
    } else {
      return generateClaudyResponse(message, targetPath)
    }
  }
}

const generateDashkaResponse = (message, code) => {
  return `🏗️ **Architecture Analysis**

Analyzing: "${message}"

**Code Structure Assessment:**
- Consider modular component design
- Implement proper error boundaries
- Use custom hooks for state logic
- Follow consistent naming patterns

**Performance Recommendations:**
- Use React.memo for optimization
- Implement code splitting
- Add proper loading states

**Best Practices:**
- Add TypeScript for better DX
- Implement proper testing
- Use proper state management

Need specific implementation guidance?`
}

const generateClaudyResponse = (message, targetPath) => {
  if (message.toLowerCase().includes('component')) {
    return `🤖 **Component Generation**

file: ${targetPath || 'components/GeneratedComponent.jsx'}
\`\`\`jsx
import React, { useState } from 'react'

const GeneratedComponent = ({ title = "New Component" }) => {
  const [active, setActive] = useState(false)

  return (
    <div className={\`component \${active ? 'active' : ''}\`}>
      <h2>{title}</h2>
      <button onClick={() => setActive(!active)}>
        {active ? 'Deactivate' : 'Activate'}
      </button>
    </div>
  )
}

export default GeneratedComponent
\`\`\`

file: ${targetPath ? targetPath.replace('.jsx', '.css') : 'components/GeneratedComponent.css'}
\`\`\`css
.component {
  padding: 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  transition: all 0.3s;
}

.component.active {
  border-color: #4ecdc4;
  background: rgba(78, 205, 196, 0.1);
}
\`\`\``
  }
  
  return `🤖 **Claudy Ready**

I can generate:
- React components
- Utility functions  
- CSS styles
- API services

What would you like me to create?`
}
EOF

# Export Service
cat > frontend/src/services/exportService.js << 'EOF'
import JSZip from 'jszip'
import { saveAs } from 'file-saver'

export const exportService = {
  async exportAsZip(fileTree, setProgress) {
    setProgress({ message: 'Preparing export...', progress: 0 })

    try {
      const zip = new JSZip()
      let fileCount = 0
      let processedCount = 0

      const countFiles = (tree) => {
        tree.forEach(item => {
          if (item.type === 'file') fileCount++
          if (item.children) countFiles(item.children)
        })
      }
      countFiles(fileTree)

      const addToZip = (tree, folder = zip) => {
        tree.forEach(item => {
          if (item.type === 'file') {
            folder.file(item.name, item.content || '')
            processedCount++
            setProgress({
              message: `Adding ${item.name}...`,
              progress: (processedCount / fileCount) * 90
            })
          } else if (item.type === 'folder' && item.children) {
            const subFolder = folder.folder(item.name)
            addToZip(item.children, subFolder)
          }
        })
      }

      addToZip(fileTree)

      setProgress({ message: 'Generating ZIP...', progress: 95 })
      const content = await zip.generateAsync({ type: 'blob' })
      
      setProgress({ message: 'Download starting...', progress: 100 })
      const projectName = fileTree[0]?.name || 'iCoder-Project'
      saveAs(content, `${projectName}-${new Date().toISOString().split('T')[0]}.zip`)

      setTimeout(() => setProgress(null), 1000)

    } catch (error) {
      console.error('Export failed:', error)
      alert('Export failed: ' + error.message)
      setProgress(null)
    }
  }
}
EOF

# === UTILS ===

# File utilities
cat > frontend/src/utils/fileUtils.js << 'EOF'
export const getFileIcon = (name) => {
  const ext = name.split('.').pop()?.toLowerCase()
  const icons = {
    html: '🟥', htm: '🟥',
    js: '🟦', jsx: '🟦', mjs: '🟦',
    ts: '🟨', tsx: '🟨',
    css: '🟪', scss: '🟪', less: '🟪',
    json: '🟩', jsonc: '🟩',
    md: '📝', txt: '📝',
    png: '🖼️', jpg: '🖼️', gif: '🖼️', svg: '🖼️'
  }
  return icons[ext] || '📄'
}

export const getLanguageFromFilename = (filename) => {
  const ext = filename.split('.').pop()?.toLowerCase()
  const langMap = {
    html: 'html', htm: 'html',
    js: 'javascript', jsx: 'javascript',
    ts: 'typescript', tsx: 'typescript',
    css: 'css', scss: 'scss',
    json: 'json', md: 'markdown'
  }
  return langMap[ext] || 'plaintext'
}

export const getAllFilePaths = (tree, path = '') => {
  let paths = []
  for (const item of tree) {
    const currentPath = path ? `${path}/${item.name}` : item.name
    if (item.type === 'file') {
      paths.push(currentPath)
    }
    if (item.children) {
      paths = paths.concat(getAllFilePaths(item.children, currentPath))
    }
  }
  return paths
}
EOF

# AI utilities
cat > frontend/src/utils/aiUtils.js << 'EOF'
export const extractProposalsFromText = (text, targetPath) => {
  const proposals = []
  const generateId = () => Math.random().toString(36).substr(2, 9)
  
  // Match file-specific blocks
  const fileBlockRegex = /(?:^|\n)file:\s*([^\n]+)\n```(\w+)?\n([\s\S]*?)```/gi
  let match
  
  while ((match = fileBlockRegex.exec(text)) !== null) {
    const [, filePath, language, code] = match
    proposals.push({
      id: generateId(),
      title: `Update ${filePath}`,
      file: filePath.trim(),
      language: language || 'text',
      code: code.trim(),
      type: 'file-specific'
    })
  }

  // Match general code blocks
  const codeBlockRegex = /```(\w+)?\n([\s\S]*?)```/gi
  while ((match = codeBlockRegex.exec(text)) !== null) {
    const [, language, code] = match
    if (!proposals.some(p => p.code === code.trim())) {
      proposals.push({
        id: generateId(),
        title: `Code snippet (${language || 'text'})`,
        file: targetPath || '',
        language: language || 'text',
        code: code.trim(),
        type: 'code-block'
      })
    }
  }

  return proposals
}
EOF

# Initial data
cat > frontend/src/utils/initialData.js << 'EOF'
export const initialFiles = [
  {
    id: 'root',
    name: 'My Project',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'index-html',
        name: 'index.html',
        type: 'file',
        content: `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iCoder Plus Demo</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #1f6feb; }
        .btn { padding: 12px 24px; background: #1f6feb; color: white; border: none; border-radius: 6px; cursor: pointer; }
        .btn:hover { background: #1557d0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 iCoder Plus v2.1.1</h1>
        <p>Welcome to your Dual-Agent AI IDE!</p>
        <button class="btn" onclick="showMessage()">Test Button</button>
        <div id="output"></div>
    </div>
    <script>
        function showMessage() {
            document.getElementById('output').innerHTML = '<p>✨ Hello from iCoder Plus!</p>';
            console.log('Button clicked successfully!');
        }
    </script>
</body>
</html>`
      },
      {
        id: 'app-js',
        name: 'app.js', 
        type: 'file',
        content: `// iCoder Plus v2.1.1 Demo
console.log('🚀 App loaded');

function initApp() {
    console.log('Initializing iCoder Plus...');
    
    // Add event listeners
    document.addEventListener('DOMContentLoaded', () => {
        console.log('DOM ready!');
    });
}

initApp();`
      },
      {
        id: 'styles-folder',
        name: 'styles',
        type: 'folder',
        expanded: false,
        children: [
          {
            id: 'main-css',
            name: 'main.css',
            type: 'file',
            content: `/* iCoder Plus Styles */
:root {
  --primary: #1f6feb;
  --bg: #ffffff;
  --text: #24292f;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, sans-serif;
  background: var(--bg);
  color: var(--text);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}`
          }
        ]
      }
    ]
  }
]
EOF

# === STYLES ===

# Main CSS
cat > frontend/src/styles/index.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

:root {
  --bg: #0d1117;
  --surface: #161b22;
  --panel: #21262d;
  --border: #30363d;
  --text: #e6edf3;
  --muted: #7d8590;
  --primary: #238636;
  --accent: #1f6feb;
  --warning: #f85149;
  --success: #28a745;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
  margin: 0;
  overflow: hidden;
}

/* App Layout */
.app {
  @apply flex flex-col h-screen;
}

.topbar {
  @apply flex justify-between items-center px-4 py-2 min-h-[50px];
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}

.brand {
  @apply flex items-center gap-3 font-semibold;
}

.badge {
  @apply px-2 py-1 rounded text-xs;
  background: var(--panel);
  color: var(--muted);
}

.dual-agent-indicator {
  @apply flex items-center gap-2 px-2 py-1 rounded text-xs;
  background: var(--panel);
}

.agent-dot {
  @apply w-2 h-2 rounded-full;
}

.agent-dot.dashka { background: #ff6b35; }
.agent-dot.claudy { background: #4ecdc4; }

.main {
  @apply flex flex-1 overflow-hidden;
}

/* File Tree */
.file-tree {
  @apply w-70 flex flex-col;
  background: var(--surface);
  border-right: 1px solid var(--border);
}

.tree-header {
  @apply flex justify-between items-center p-3;
  border-bottom: 1px solid var(--border);
}

.tree-controls {
  @apply flex gap-1;
}

.tree-btn {
  @apply px-2 py-1 rounded cursor-pointer text-xs transition-all;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.tree-btn:hover {
  background: var(--accent);
}

.search-box {
  @apply p-3;
  border-bottom: 1px solid var(--border);
}

.search-input {
  @apply w-full px-2 py-1 rounded text-xs;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.tree-content {
  @apply flex-1 overflow-y-auto p-2;
}

.tree-item {
  @apply flex items-center px-2 py-1 m-0.5 rounded cursor-pointer text-xs select-none transition-all;
}

.tree-item:hover {
  background: var(--panel);
}

.tree-item.selected {
  background: var(--accent);
  color: white;
}

.tree-item.folder {
  @apply font-medium;
}

.tree-icon {
  @apply mr-1.5 text-sm;
}

.tree-arrow {
  @apply mr-1 text-xs transition-transform;
}

.tree-arrow.expanded {
  transform: rotate(90deg);
}

.tree-children {
  @apply ml-4;
}

/* Editor */
.editor-area {
  @apply flex-1 flex flex-col;
}

.editor-tabs {
  @apply flex overflow-x-auto;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}

.editor-tab {
  @apply flex items-center gap-2 px-3 py-2 cursor-pointer text-xs min-w-[120px] transition-all;
  border-right: 1px solid var(--border);
}

.editor-tab:hover {
  background: var(--panel);
}

.editor-tab.active {
  background: var(--bg);
  border-bottom: 2px solid var(--accent);
}

.tab-close {
  @apply px-0.5 rounded opacity-60 transition-all text-xs;
}

.tab-close:hover {
  @apply opacity-100;
  background: var(--warning);
  color: white;
}

.editor-container {
  @apply flex-1 relative;
}

/* Right Panel */
.right-panel {
  @apply w-96 flex flex-col;
  background: var(--surface);
  border-left: 1px solid var(--border);
}

.panel-tabs {
  @apply flex;
  border-bottom: 1px solid var(--border);
}

.panel-tab {
  @apply flex-1 p-2 text-center cursor-pointer text-xs font-medium transition-all;
  background: var(--panel);
  border-right: 1px solid var(--border);
}

.panel-tab:last-child {
  border-right: none;
}

.panel-tab.active {
  background: var(--surface);
  border-bottom: 2px solid var(--accent);
}

.panel-content {
  @apply flex-1 p-3 overflow-y-auto;
}

/* Agent UI */
.agent-selector {
  @apply grid grid-cols-2 gap-2 mb-3;
}

.agent-option {
  @apply p-2 rounded cursor-pointer text-center text-xs font-medium transition-all;
  border: 1px solid var(--border);
}

.agent-option.dashka {
  border-color: #ff6b35;
  color: #ff6b35;
}

.agent-option.claudy {
  border-color: #4ecdc4;
  color: #4ecdc4;
}

.agent-option.active.dashka {
  background: #ff6b35;
  color: white;
}

.agent-option.active.claudy {
  background: #4ecdc4;
  color: white;
}

.target-selector {
  @apply mb-3;
}

.target-select {
  @apply w-full px-2 py-1 rounded text-xs;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.chat-input-area {
  @apply flex gap-2 mb-3;
}

.chat-input {
  @apply flex-1 p-2 rounded text-xs resize-y min-h-[60px];
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.chat-send {
  @apply px-3 py-2 rounded text-xs h-fit cursor-pointer;
  background: var(--primary);
  color: white;
}

.chat-send:disabled {
  @apply opacity-50 cursor-not-allowed;
}

/* Proposals */
.proposals-section {
  @apply pt-3;
  border-top: 1px solid var(--border);
}

.proposals-header {
  @apply flex justify-between items-center mb-2;
}

.proposals-title {
  @apply text-xs font-semibold;
  color: var(--muted);
}

.proposals-count {
  @apply text-xs px-1.5 py-0.5 rounded-full;
  background: var(--accent);
  color: white;
}

.proposal-item {
  @apply p-2 mb-2 rounded cursor-pointer transition-all;
  background: var(--panel);
  border-left: 3px solid var(--accent);
}

.proposal-item:hover {
  background: var(--border);
}

.proposal-title {
  @apply text-xs font-semibold;
}

.proposal-meta {
  @apply text-xs;
  color: var(--muted);
}

.proposal-actions {
  @apply flex gap-1 mt-2;
}

.proposal-btn {
  @apply px-2 py-1 rounded cursor-pointer text-xs transition-all;
  border: 1px solid var(--border);
  background: var(--panel);
  color: var(--text);
}

.proposal-btn.apply { 
  border-color: var(--success); 
  color: var(--success); 
}

.proposal-btn.insert { 
  border-color: var(--accent); 
  color: var(--accent); 
}

.proposal-btn.create { 
  border-color: var(--warning); 
  color: var(--warning); 
}

.proposal-btn:hover.apply { 
  background: var(--success); 
  color: white; 
}

.proposal-btn:hover.insert { 
  background: var(--accent); 
  color: white; 
}

.proposal-btn:hover.create { 
  background: var(--warning); 
  color: white; 
}

/* Context Menu */
.context-menu {
  @apply absolute rounded shadow-lg z-50 min-w-[140px] p-1;
  background: var(--panel);
  border: 1px solid var(--border);
}

.context-item {
  @apply px-3 py-2 cursor-pointer rounded text-xs transition-all flex items-center gap-2;
}

.context-item:hover {
  background: var(--accent);
}

.context-divider {
  @apply h-px my-1;
  background: var(--border);
}

/* Preview */
.preview-frame {
  @apply w-full rounded;
  height: 300px;
  border: 1px solid var(--border);
  background: white;
}

.console-output {
  @apply mt-3 p-2 rounded text-xs max-h-[150px] overflow-y-auto;
  background: var(--bg);
  font-family: Monaco, Menlo, monospace;
}

.console-log { color: var(--text); }
.console-error { color: var(--warning); }
.console-warn { color: #ffa500; }

/* Export Progress */
.export-progress {
  @apply fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 p-5 rounded text-center z-50;
  background: var(--panel);
  border: 1px solid var(--border);
  box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}

.progress-bar {
  @apply w-48 h-1 rounded my-2 overflow-hidden;
  background: var(--border);
}

.progress-fill {
  @apply h-full rounded transition-all;
  background: var(--accent);
}

/* Scrollbars */
::-webkit-scrollbar {
  @apply w-1.5 h-1.5;
}

::-webkit-scrollbar-track {
  background: var(--panel);
}

::-webkit-scrollbar-thumb {
  background: var(--border);
  @apply rounded;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--muted);
}
EOF

# === BACKEND FILES ===

# Backend package.json
cat > backend/package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.1.1",
  "type": "module",
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node src/server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "openai": "^4.20.1",
    "@anthropic-ai/sdk": "^0.9.1",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0"
  }
}
EOF

# Express server
cat > backend/src/server.js << 'EOF'
import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import aiRoutes from './routes/aiRoutes.js'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

// Routes
app.use('/api/ai', aiRoutes)

app.get('/health', (req, res) => {
  res.json({ status: 'OK', version: '2.1.1' })
})

app.listen(PORT, () => {
  console.log(`🚀 iCoder Plus Backend v2.1.1 running on port ${PORT}`)
})
EOF

# AI Routes
cat > backend/src/routes/aiRoutes.js << 'EOF'
import express from 'express'
import { aiService } from '../services/aiService.js'

const router = express.Router()

router.post('/chat', async (req, res) => {
  try {
    const { agent, message, code, targetFile } = req.body
    
    const response = await aiService.processMessage({
      agent,
      message,
      code,
      targetFile
    })
    
    res.json({ success: true, data: response })
  } catch (error) {
    console
  EOF