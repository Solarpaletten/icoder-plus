import React, { useState } from 'react'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import { useDualAgent } from './hooks/useDualAgent'
import { useFileSystem } from './hooks/useFileSystem'
import TopMenu from './components/TopMenu'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import LivePreview from './components/LivePreview'
import Terminal from './components/Terminal'
import { Menu, X, Eye } from 'lucide-react'
import './styles/globals.css'

function App() {
  const fileManager = useFileManager()
  const codeRunner = useCodeRunner()
  const { agent, setAgent } = useDualAgent()
  const fileSystem = useFileSystem()
  
  // Panel toggles
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(false)
  const [rightPanelOpen, setRightPanelOpen] = useState(true)
  const [previewPanelOpen, setPreviewPanelOpen] = useState(false)

  // File operations from TopMenu
  const handleOpenFile = (file) => {
    fileManager.openFile(file)
  }

  const handleOpenFolder = (folderStructure) => {
    fileManager.setFileTree(folderStructure)
    // Open first file if available
    const firstFile = findFirstFile(folderStructure)
    if (firstFile) {
      fileManager.openFile(firstFile)
    }
  }

  const findFirstFile = (items) => {
    for (const item of items) {
      if (item.type === 'file') return item
      if (item.children) {
        const found = findFirstFile(item.children)
        if (found) return found
      }
    }
    return null
  }

  const handleSaveProject = (format = 'localStorage') => {
    if (format === 'zip') {
      fileSystem.saveProjectAsZip(fileManager.fileTree)
    } else {
      // Save to localStorage (already handled by useFileManager)
      localStorage.setItem('icoder-project-v2.2', JSON.stringify(fileManager.fileTree))
      console.log('Project saved to localStorage')
    }
  }

  const handleNewProject = (type) => {
    if (type === 'file') {
      fileManager.createFile(null, 'untitled.js', '// New file\nconsole.log("Hello World!");')
    } else if (type === 'folder') {
      fileManager.createFolder(null, 'New Folder')
    }
  }

  const handleImportProject = async (zipFile) => {
    const folderStructure = await fileSystem.loadProjectFromZip(zipFile)
    if (folderStructure.length > 0) {
      fileManager.setFileTree(folderStructure)
      const firstFile = findFirstFile(folderStructure)
      if (firstFile) {
        fileManager.openFile(firstFile)
      }
    }
  }

  const handleTerminalOpenFile = (file) => {
    fileManager.openFile(file)
  }

  const handleTerminalBuild = () => {
    console.log('Building project via terminal...')
    // Trigger actual build if needed
    codeRunner.runCode({
      name: 'build-script.js',
      content: 'console.log("Project built successfully!")'
    })
  }

  return (
    <div className="app-container">
      {/* Top Menu Bar */}
      <TopMenu
        onOpenFile={handleOpenFile}
        onOpenFolder={handleOpenFolder}
        onSaveProject={handleSaveProject}
        onNewProject={handleNewProject}
        onImportProject={handleImportProject}
      />

      {/* Main Menu Bar */}
      <div className="menu-bar">
        <div className="menu-left">
          <button 
            className="menu-toggle"
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            title="Toggle Explorer"
          >
            <Menu size={16} />
          </button>
        </div>
        
        <div className="menu-right">
          <button 
            className={`menu-btn ${previewPanelOpen ? 'active' : ''}`}
            onClick={() => setPreviewPanelOpen(!previewPanelOpen)}
            title="Toggle Live Preview"
          >
            <Eye size={16} />
          </button>
          <button 
            className={`menu-btn ${terminalOpen ? 'active' : ''}`}
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal"
          >
            ⚡
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

        {/* Live Preview Panel */}
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
      <Terminal
        isOpen={terminalOpen}
        onToggle={() => setTerminalOpen(!terminalOpen)}
        fileTree={fileManager.fileTree}
        activeFile={fileManager.activeTab}
        onOpenFile={handleTerminalOpenFile}
        onRunBuild={handleTerminalBuild}
      />
    </div>
  )
}

export default App
