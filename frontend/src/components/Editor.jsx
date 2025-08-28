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
