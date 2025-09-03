import React, { useState, useEffect } from 'react'
import { 
  PanelLeft, 
  MessageSquare,
  X,
  Menu,
  FileText,
  Settings,
  Terminal as TerminalIcon,
  Upload,
  Play,
  Download
} from 'lucide-react'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import LivePreview from './components/LivePreview'
import RealTerminal from './components/RealTerminal'
import AIAssistants from './components/AIAssistants'
import FileUpload from './components/FileUpload'
import TopMenu from './components/TopMenu'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import './styles/globals.css'

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(false)
  const [uploadModalOpen, setUploadModalOpen] = useState(false)
  
  const { 
    fileTree, 
    openTabs, 
    activeTab, 
    createFile, 
    createFolder, 
    deleteItem, 
    renameItem, 
    setActiveTab, 
    openFile, 
    closeTab, 
    updateFileContent,
    loadProject,
    exportProject
  } = useFileManager()
  
  const { runCode, output, isRunning } = useCodeRunner()

  const handleFilesLoaded = (files) => {
    files.forEach(file => {
      createFile(file.name, file.content)
      openFile(file.name)
    })
  }

  const handleProjectLoaded = (projectStructure) => {
    loadProject(projectStructure)
  }

  const handleRunCode = () => {
    if (activeTab) {
      const content = activeTab.content
      runCode(content, activeTab.name)
    }
  }

  const activeFile = activeTab

  return (
    <div className="ide-container">
      {/* Top Menu */}
      <TopMenu 
        onNewFile={() => createFile('untitled.js', '')}
        onOpenFile={() => setUploadModalOpen(true)}
        onSave={() => {/* Implement save */}}
        onExport={() => exportProject()}
      />

      {/* Main Header */}
      <header className="ide-header">
        <div className="header-left">
          <button 
            className="panel-toggle"
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            title="Toggle Explorer"
          >
            <Menu size={16} />
          </button>
          <div className="project-info">
            <span className="project-name">iCoder Plus v2.0</span>
            <span className="project-status">Final Production</span>
          </div>
        </div>
        
        <div className="header-center">
          <div className="quick-actions">
            <button 
              className="quick-btn"
              onClick={handleRunCode}
              disabled={!activeFile || isRunning}
              title="Run Code (Ctrl+R)"
            >
              <Play size={16} />
              {isRunning ? 'Running...' : 'Run'}
            </button>
            
            <button 
              className="quick-btn"
              onClick={() => setUploadModalOpen(true)}
              title="Upload Files"
            >
              <Upload size={16} />
              Upload
            </button>
          </div>
        </div>
        
        <div className="header-right">
          <button 
            className={`panel-toggle ${rightPanelOpen ? 'active' : ''}`}
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            title="Toggle AI Assistant"
          >
            <MessageSquare size={16} />
            AI
          </button>
        </div>
      </header>

      {/* Main Layout */}
      <div className="ide-main">
        {/* Left Panel - File Explorer */}
        {leftPanelOpen && (
          <aside className="left-panel">
            <div className="panel-header">
              <span>EXPLORER</span>
              <button onClick={() => setLeftPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            
            <FileTree 
              fileTree={fileTree}
              onCreateFile={createFile}
              onCreateFolder={createFolder}
              onDeleteItem={deleteItem}
              onRenameItem={renameItem}
              onFileSelect={openFile}
            />
          </aside>
        )}

        {/* Center - Editor Area */}
        <main className="editor-area">
          {/* Editor Tabs */}
          <div className="editor-tabs">
            {openTabs.map(tab => (
              <div 
                key={tab.id}
                className={`tab ${activeTab?.id === tab.id ? 'active' : ''}`}
                onClick={() => setActiveTab(tab.id)}
              >
                <FileText size={14} />
                <span>{tab.name}</span>
                <button 
                  className="tab-close"
                  onClick={(e) => {
                    e.stopPropagation()
                    closeTab(tab.id)
                  }}
                >
                  <X size={12} />
                </button>
              </div>
            ))}
          </div>
          
          {/* Editor Content */}
          <div className="editor-content">
            {activeTab ? (
              <Editor 
                file={activeTab}
                onChange={(content) => updateFileContent(activeTab.id, content)}
                onRun={handleRunCode}
              />
            ) : (
              <div className="editor-placeholder">
                <div className="welcome-message">
                  <h2>🚀 Welcome to iCoder Plus v2.0</h2>
                  <p>AI-powered IDE with real terminal and live preview</p>
                  <div className="quick-start">
                    <button 
                      className="start-btn"
                      onClick={() => setUploadModalOpen(true)}
                    >
                      <Upload size={20} />
                      Upload Project
                    </button>
                    <button 
                      className="start-btn"
                      onClick={() => createFile('demo.js', '// Hello from iCoder Plus!\nconsole.log("Ready to code!");')}
                    >
                      <FileText size={20} />
                      New File
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </main>

        {/* Right Panel - Live Preview */}
        <aside className="right-panel">
          <div className="panel-header">
            <span>LIVE PREVIEW</span>
            <button onClick={() => setRightPanelOpen(false)}>
              <X size={14} />
            </button>
          </div>
          
          <LivePreview 
            code={activeFile?.content || ''}
            fileName={activeFile?.name || ''}
            output={output}
          />
        </aside>
      </div>

      {/* Bottom Terminal */}
      {terminalOpen && (
        <RealTerminal 
          isOpen={terminalOpen}
          onClose={() => setTerminalOpen(false)}
        />
      )}

      {/* AI Assistant */}
      {rightPanelOpen && (
        <AIAssistants 
          activeFile={activeFile}
          fileContent={activeFile?.content}
        />
      )}

      {/* File Upload Modal */}
      {uploadModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h3>Upload Files or Project</h3>
              <button onClick={() => setUploadModalOpen(false)}>
                <X size={20} />
              </button>
            </div>
            
            <FileUpload 
              onFilesLoaded={handleFilesLoaded}
              onProjectLoaded={handleProjectLoaded}
            />
          </div>
        </div>
      )}

      {/* Bottom Status Bar */}
      <footer className="ide-statusbar">
        <div className="statusbar-left">
          <button 
            className={`status-btn ${terminalOpen ? 'active' : ''}`}
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal"
          >
            <TerminalIcon size={14} />
            Terminal
          </button>
          
          <span className="status-info">
            {activeFile ? activeFile.name : 'No file selected'}
          </span>
        </div>
        
        <div className="statusbar-right">
          <span className="status-info">
            {activeFile?.name.split('.').pop()?.toUpperCase() || 'PLAIN TEXT'}
          </span>
          <span className="status-info">UTF-8</span>
          <span className="status-info">
            Lines: {activeFile?.content.split('\n').length || 0}
          </span>
        </div>
      </footer>
    </div>
  )
}

export default App
