import React, { useState } from 'react'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import { useDualAgent } from './hooks/useDualAgent'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import LivePreview from './components/LivePreview'
import { Menu, X, Terminal, Eye } from 'lucide-react'
import './styles/globals.css'

function App() {
  const fileManager = useFileManager()
  const codeRunner = useCodeRunner()
  const { agent, setAgent } = useDualAgent()
  
  // Panel toggles
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(true)
  const [previewPanelOpen, setPreviewPanelOpen] = useState(false) // NEW: Preview panel toggle

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
          <span className="app-subtitle">AI IDE with Live Preview</span>
        </div>
        
        <div className="menu-right">
          <button 
            className="menu-btn"
            onClick={() => setPreviewPanelOpen(!previewPanelOpen)}
            title="Toggle Live Preview"
          >
            <Eye size={16} />
          </button>
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
            previewMode={codeRunner.previewMode}
            onTogglePreview={codeRunner.togglePreview}
          />
        </div>

        {/* NEW: Live Preview Panel (conditionally rendered) */}
        {previewPanelOpen && (
          <div className="preview-panel">
            <LivePreview
              activeTab={fileManager.activeTab}
              isRunning={codeRunner.isRunning}
              previewMode={codeRunner.previewMode}
              consoleLog={codeRunner.consoleLog}
              previewFrameRef={codeRunner.previewFrameRef}
              onRunCode={codeRunner.runCode}
              onTogglePreview={codeRunner.togglePreview}
              onClearConsole={codeRunner.clearConsole}
            />
          </div>
        )}

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
              <span className="output">📡 Network: http://192.168.1.100:5173/</span>
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
