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
