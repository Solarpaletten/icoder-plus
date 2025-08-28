#!/bin/bash

echo "🔧 Quick fixing iCoder Plus v2.1.1 issues..."

# Stop any running servers
echo "🛑 Stopping servers..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

# Fix frontend dependencies
echo "📦 Installing missing frontend dependencies..."
cd frontend

# Install missing packages
npm install @monaco-editor/react monaco-editor jszip file-saver tailwindcss autoprefixer postcss

# Fix package.json to ensure correct dependencies
cat > package.json << 'EOF'
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

# Fix useFileManager.js syntax error
cat > src/hooks/useFileManager.js << 'EOF'
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
    updateFileContent
  }
}
EOF

# Fix CSS to not use Tailwind imports (use pure CSS instead)
cat > src/styles/index.css << 'EOF'
/* iCoder Plus v2.1.1 - Pure CSS (no Tailwind imports) */
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

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
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
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  min-height: 50px;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
}

.badge {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  background: var(--panel);
  color: var(--muted);
}

.dual-agent-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  background: var(--panel);
}

.agent-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.agent-dot.dashka { background: #ff6b35; }
.agent-dot.claudy { background: #4ecdc4; }

.main {
  display: flex;
  flex: 1;
  overflow: hidden;
}

/* File Tree */
.file-tree {
  width: 280px;
  display: flex;
  flex-direction: column;
  background: var(--surface);
  border-right: 1px solid var(--border);
}

.tree-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid var(--border);
}

.tree-controls {
  display: flex;
  gap: 4px;
}

.tree-btn {
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 11px;
  transition: all 0.2s;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.tree-btn:hover {
  background: var(--accent);
}

.search-box {
  padding: 12px;
  border-bottom: 1px solid var(--border);
}

.search-input {
  width: 100%;
  padding: 6px 8px;
  border-radius: 4px;
  font-size: 12px;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.tree-content {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.tree-item {
  display: flex;
  align-items: center;
  padding: 4px 8px;
  margin: 1px 0;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  user-select: none;
  transition: all 0.15s;
}

.tree-item:hover {
  background: var(--panel);
}

.tree-item.selected {
  background: var(--accent);
  color: white;
}

.tree-item.folder {
  font-weight: 500;
}

.tree-icon {
  margin-right: 6px;
  font-size: 14px;
}

.tree-arrow {
  margin-right: 4px;
  font-size: 10px;
  transition: transform 0.2s;
}

.tree-arrow.expanded {
  transform: rotate(90deg);
}

.tree-children {
  margin-left: 16px;
}

/* Editor */
.editor-area {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.editor-tabs {
  display: flex;
  overflow-x: auto;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
}

.editor-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 12px;
  min-width: 120px;
  transition: all 0.2s;
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
  padding: 2px;
  border-radius: 2px;
  opacity: 0.6;
  transition: all 0.2s;
  font-size: 10px;
}

.tab-close:hover {
  opacity: 1;
  background: var(--warning);
  color: white;
}

.editor-container {
  flex: 1;
  position: relative;
}

/* Right Panel */
.right-panel {
  width: 400px;
  display: flex;
  flex-direction: column;
  background: var(--surface);
  border-left: 1px solid var(--border);
}

.panel-tabs {
  display: flex;
  border-bottom: 1px solid var(--border);
}

.panel-tab {
  flex: 1;
  padding: 8px;
  text-align: center;
  cursor: pointer;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.2s;
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
  flex: 1;
  padding: 12px;
  overflow-y: auto;
}

/* Agent UI */
.agent-selector {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-bottom: 12px;
}

.agent-option {
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  text-align: center;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.2s;
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
  margin-bottom: 12px;
}

.target-select {
  width: 100%;
  padding: 6px 8px;
  border-radius: 4px;
  font-size: 11px;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.chat-input-area {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.chat-input {
  flex: 1;
  padding: 8px;
  border-radius: 4px;
  font-size: 12px;
  resize: vertical;
  min-height: 60px;
  background: var(--panel);
  border: 1px solid var(--border);
  color: var(--text);
}

.chat-send {
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  color: white;
  cursor: pointer;
  font-size: 12px;
  height: fit-content;
  background: var(--primary);
}

.chat-send:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Proposals */
.proposals-section {
  padding-top: 12px;
  border-top: 1px solid var(--border);
}

.proposals-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.proposals-title {
  font-size: 12px;
  font-weight: 600;
  color: var(--muted);
}

.proposals-count {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  background: var(--accent);
  color: white;
}

.proposal-item {
  padding: 8px;
  margin-bottom: 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
  background: var(--panel);
  border-left: 3px solid var(--accent);
}

.proposal-item:hover {
  background: var(--border);
}

.proposal-title {
  font-size: 12px;
  font-weight: 600;
}

.proposal-meta {
  font-size: 10px;
  color: var(--muted);
}

.proposal-actions {
  display: flex;
  gap: 4px;
  margin-top: 8px;
}

.proposal-btn {
  padding: 4px 8px;
  border-radius: 3px;
  cursor: pointer;
  font-size: 10px;
  transition: all 0.2s;
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
  position: absolute;
  border-radius: 6px;
  z-index: 50;
  min-width: 140px;
  padding: 4px;
  background: var(--panel);
  border: 1px solid var(--border);
  box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}

.context-item {
  padding: 8px 12px;
  cursor: pointer;
  border-radius: 4px;
  font-size: 12px;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.context-item:hover {
  background: var(--accent);
}

.context-divider {
  height: 1px;
  margin: 4px 0;
  background: var(--border);
}

/* Preview */
.preview-frame {
  width: 100%;
  height: 300px;
  border-radius: 4px;
  border: 1px solid var(--border);
  background: white;
}

.console-output {
  margin-top: 12px;
  padding: 8px;
  border-radius: 4px;
  font-size: 10px;
  max-height: 150px;
  overflow-y: auto;
  background: var(--bg);
  font-family: Monaco, Menlo, monospace;
}

.console-log { color: var(--text); }
.console-error { color: var(--warning); }
.console-warn { color: #ffa500; }

/* Utilities */
.btn {
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s;
  border: 1px solid var(--border);
  background: var(--panel);
  color: var(--text);
}

.btn:hover {
  background: var(--accent);
  color: white;
}

.muted { 
  color: var(--muted); 
  font-size: 11px; 
}

.hidden { 
  display: none !important; 
}

/* Responsive */
@media (max-width: 768px) {
  .main {
    flex-direction: column;
  }
  
  .file-tree,
  .right-panel {
    width: 100%;
  }
}
EOF

# Fix postcss.config.js
cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cd ..

# Fix backend - install nodemon
echo "🔧 Installing backend dependencies..."
cd backend

npm install nodemon express cors dotenv

# Fix backend package.json
cat > package.json << 'EOF'
{
  "name": "icoder-plus-backend",
  "version": "2.1.1",
  "type": "module",
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
EOF

# Create working server.js
cat > src/server.js << 'EOF'
import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    version: '2.1.1',
    timestamp: new Date().toISOString()
  })
})

// AI Chat endpoint
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { agent, message, code, targetFile } = req.body
    
    // Simulate AI response
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const response = agent === 'dashka' 
      ? `🏗️ Architecture advice for: "${message}"\n\nConsider modular design patterns and proper error handling.`
      : `🤖 Code generated for: "${message}"\n\nfile: ${targetFile || 'new-file.js'}\n\`\`\`javascript\nconsole.log('Hello from Claudy!');\n\`\`\``
    
    res.json({ 
      success: true, 
      data: { message: response }
    })
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    })
  }
})

app.listen(PORT, () => {
  console.log(`🚀 iCoder Plus Backend v2.1.1 running on port ${PORT}`)
  console.log(`🌐 Health check: http://localhost:${PORT}/health`)
})
EOF

cd ..

echo ""
echo "✅ All issues fixed!"
echo ""
echo "🚀 Run the servers:"
echo "   ./run-dev.sh"
echo ""
echo "Or manually:"
echo "   Terminal 1: cd backend && npm run dev"  
echo "   Terminal 2: cd frontend && npm run dev"