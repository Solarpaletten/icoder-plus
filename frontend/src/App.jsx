import React from 'react'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import './styles/globals.css'

function App() {
  const fileManager = useFileManager()
  const codeRunner = useCodeRunner()

  return (
    <div className="app-container">
      <div className="app-header">
        <div className="app-title">
          <h1>iCoder Plus v2.2</h1>
          <span className="app-subtitle">AI IDE with Monaco Editor</span>
        </div>
      </div>
      
      <div className="app-content">
        {/* Left Panel - File Tree */}
        <div className="left-panel">
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
          />
        </div>
      </div>
    </div>
  )
}

export default App
