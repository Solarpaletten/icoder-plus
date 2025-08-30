import React, { useState } from 'react'
import { 
  PanelLeft, 
  Terminal as TerminalIcon, 
  Play, 
  MessageSquare,
  X,
  Menu,
  FileText,
  Settings
} from 'lucide-react'
import './App.css'

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(false)
  const [activeAgent, setActiveAgent] = useState('dashka')

  return (
    <div className="ide-container">
      {/* Topbar */}
      <header className="ide-topbar">
        <div className="topbar-left">
          <button 
            className="panel-toggle"
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            title="Toggle File Explorer"
          >
            <Menu size={16} />
          </button>
          <div className="project-info">
            <span className="project-name">iCoder Plus v2.2</span>
            <span className="project-status">IDE Shell</span>
          </div>
        </div>
        
        <div className="topbar-center">
          <span className="breadcrumb">Welcome.js</span>
        </div>
        
        <div className="topbar-right">
          <div className="agent-indicator">
            <div className={`agent-dot ${activeAgent}`}></div>
            <span>
              {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Code Gen)'}
            </span>
          </div>
          <button 
            className="panel-toggle"
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            title="Toggle AI Panel"
          >
            <MessageSquare size={16} />
          </button>
        </div>
      </header>

      {/* Main Layout */}
      <div className="ide-main">
        {/* Left Sidebar - File Explorer */}
        {leftPanelOpen && (
          <aside className="left-panel">
            <div className="panel-header">
              <span>EXPLORER</span>
              <button onClick={() => setLeftPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            <div className="file-explorer-placeholder">
              <div className="folder-item">
                <span>📁 src</span>
              </div>
              <div className="file-item">
                <span>📄 App.jsx</span>
              </div>
              <div className="file-item">
                <span>📄 index.js</span>
              </div>
              <div className="folder-item">
                <span>📁 components</span>
              </div>
            </div>
          </aside>
        )}

        {/* Center - Editor Area */}
        <main className="editor-area">
          <div className="editor-tabs">
            <div className="tab active">
              <FileText size={14} />
              <span>Welcome.js</span>
              <button className="tab-close">
                <X size={12} />
              </button>
            </div>
            <div className="tab">
              <FileText size={14} />
              <span>App.jsx</span>
              <button className="tab-close">
                <X size={12} />
              </button>
            </div>
          </div>
          
          <div className="editor-content">
            <div className="editor-placeholder">
              <div className="welcome-message">
                <h2>🚀 iCoder Plus v2.2 - IDE Shell</h2>
                <p>Minimalist Visual IDE - Monaco Editor will be here</p>
                <div className="placeholder-code">
                  <pre>{`// Welcome to iCoder Plus IDE Shell
console.log('Hello from IDE!');

function initIDE() {
  return {
    fileTree: true,
    editor: 'monaco',
    terminal: true,
    aiAgent: 'dual'
  };
}

export default initIDE;`}</pre>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Right Panel - AI/Preview */}
        {rightPanelOpen && (
          <aside className="right-panel">
            <div className="panel-header">
              <span>AI ASSISTANT</span>
              <button onClick={() => setRightPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            
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
            
            <div className="ai-placeholder">
              <p>AI Panel placeholder - будет чат с {activeAgent}</p>
            </div>
          </aside>
        )}
      </div>

      {/* Bottom Terminal */}
      {terminalOpen && (
        <div className="terminal-panel">
          <div className="terminal-header">
            <span>TERMINAL</span>
            <button onClick={() => setTerminalOpen(false)}>
              <X size={14} />
            </button>
          </div>
          <div className="terminal-content">
            <div className="terminal-line">$ npm run dev</div>
            <div className="terminal-line">🚀 iCoder Plus starting...</div>
            <div className="terminal-cursor">$_</div>
          </div>
        </div>
      )}

      {/* Bottom Action Bar */}
      <footer className="ide-statusbar">
        <div className="statusbar-left">
          <button 
            className={`status-btn ${terminalOpen ? 'active' : ''}`}
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal (Ctrl+`)"
          >
            <TerminalIcon size={14} />
            Terminal
          </button>
        </div>
        
        <div className="statusbar-right">
          <span className="status-info">JavaScript</span>
          <span className="status-info">UTF-8</span>
          <span className="status-info">Ln 1, Col 1</span>
        </div>
      </footer>
    </div>
  )
}

export default App
