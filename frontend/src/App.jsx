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
