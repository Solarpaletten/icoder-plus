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
