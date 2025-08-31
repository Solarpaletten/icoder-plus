import React, { useState, useRef, useEffect } from 'react'
import { Editor as MonacoEditor } from '@monaco-editor/react'
import { X, Copy, Save, Play, RotateCcw, Eye, Code } from 'lucide-react'

const Editor = ({ 
  openTabs = [], 
  activeTab, 
  setActiveTab, 
  closeTab, 
  updateFileContent, 
  onRunCode,
  previewMode = false,
  onTogglePreview 
}) => {
  const [unsavedChanges, setUnsavedChanges] = useState({})
  const editorRef = useRef(null)

  const getLanguage = (fileName) => {
    if (!fileName) return 'javascript'
    const ext = fileName.split('.').pop()?.toLowerCase()
    const langMap = {
      js: 'javascript', jsx: 'javascript', ts: 'typescript', tsx: 'typescript',
      html: 'html', htm: 'html', css: 'css', scss: 'scss', sass: 'scss',
      json: 'json', md: 'markdown', txt: 'plaintext', py: 'python',
      php: 'php', rb: 'ruby', go: 'go', rs: 'rust', cpp: 'cpp', c: 'c'
    }
    return langMap[ext] || 'plaintext'
  }

  const handleEditorChange = (value) => {
    if (!activeTab || value === activeTab.content) return
    
    setUnsavedChanges(prev => ({ ...prev, [activeTab.id]: true }))
    
    // Auto-save with debounce
    const timeoutId = setTimeout(() => {
      updateFileContent(activeTab.id, value)
      setUnsavedChanges(prev => ({ ...prev, [activeTab.id]: false }))
    }, 1000)

    return () => clearTimeout(timeoutId)
  }

  const handleSaveFile = () => {
    if (!activeTab || !editorRef.current) return
    
    const value = editorRef.current.getValue()
    updateFileContent(activeTab.id, value)
    setUnsavedChanges(prev => ({ ...prev, [activeTab.id]: false }))
  }

  const handleRunFile = () => {
    if (!activeTab) return
    
    // Save before running
    if (unsavedChanges[activeTab.id] && editorRef.current) {
      const value = editorRef.current.getValue()
      updateFileContent(activeTab.id, value)
      setUnsavedChanges(prev => ({ ...prev, [activeTab.id]: false }))
    }
    
    onRunCode(activeTab)
  }

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.ctrlKey || e.metaKey) {
        if (e.key === 's') {
          e.preventDefault()
          handleSaveFile()
        } else if (e.key === 'r') {
          e.preventDefault()
          handleRunFile()
        }
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [activeTab, unsavedChanges])

  if (openTabs.length === 0) {
    return (
      <div className="editor-empty">
        <div className="empty-state">
          <Code size={64} style={{color: '#666', marginBottom: '16px'}} />
          <h3>Welcome to iCoder Plus v2.2</h3>
          <p>Create a new file or open an existing one to start coding</p>
          <div className="empty-actions">
            <button className="btn-primary">
              📄 New File
            </button>
            <button className="btn-secondary">
              📂 Open Folder
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="editor-container">
      {/* Tab Bar */}
      <div className="editor-tabs">
        <div className="tabs-list">
          {openTabs.map((tab) => (
            <div
              key={tab.id}
              className={`editor-tab ${activeTab?.id === tab.id ? 'active' : ''}`}
              onClick={() => setActiveTab(tab)}
            >
              <span className="tab-icon">
                {tab.name?.endsWith('.html') ? '🌐' :
                 tab.name?.endsWith('.js') || tab.name?.endsWith('.jsx') ? '🟨' :
                 tab.name?.endsWith('.css') ? '🎨' :
                 tab.name?.endsWith('.json') ? '🟩' : '📄'}
              </span>
              <span className="tab-name">{tab.name}</span>
              {unsavedChanges[tab.id] && (
                <span className="tab-unsaved">●</span>
              )}
              <button
                className="tab-close"
                onClick={(e) => {
                  e.stopPropagation()
                  closeTab(tab)
                }}
              >
                <X size={12} />
              </button>
            </div>
          ))}
        </div>
        
        {/* Editor Actions */}
        <div className="editor-actions">
          <button
            className="action-btn"
            onClick={handleSaveFile}
            title="Save File (Ctrl+S)"
            disabled={!activeTab}
          >
            <Save size={16} />
          </button>
          
          <button
            className="action-btn run-btn"
            onClick={handleRunFile}
            title="Run Code (Ctrl+R)"
            disabled={!activeTab}
          >
            <Play size={16} />
          </button>
          
          {onTogglePreview && (
            <button
              className="action-btn"
              onClick={onTogglePreview}
              title="Toggle Preview"
            >
              {previewMode ? <Code size={16} /> : <Eye size={16} />}
            </button>
          )}
        </div>
      </div>

      {/* Editor Content */}
      {activeTab ? (
        <div className="editor-content">
          <MonacoEditor
            height="100%"
            language={getLanguage(activeTab.name)}
            theme="vs-dark"
            value={activeTab.content || ''}
            onChange={handleEditorChange}
            onMount={(editor) => {
              editorRef.current = editor
            }}
            options={{
              fontSize: 14,
              fontFamily: 'JetBrains Mono, Fira Code, monospace',
              lineNumbers: 'on',
              minimap: { enabled: true },
              wordWrap: 'on',
              automaticLayout: true,
              scrollBeyondLastLine: false,
              folding: true,
              bracketMatching: 'always',
              autoIndent: 'full',
              formatOnPaste: true,
              formatOnType: true,
              suggestOnTriggerCharacters: true,
              acceptSuggestionOnEnter: 'on',
              tabCompletion: 'on'
            }}
          />
        </div>
      ) : (
        <div className="no-active-tab">
          <span>Select a tab to start editing</span>
        </div>
      )}

      {/* Status Bar */}
      {activeTab && (
        <div className="editor-status">
          <div className="status-info">
            <span className="status-item">
              Language: {getLanguage(activeTab.name)}
            </span>
            <span className="status-item">
              {activeTab.content?.length || 0} characters
            </span>
            <span className="status-item">
              Lines: {(activeTab.content?.match(/\n/g) || []).length + 1}
            </span>
          </div>
          
          <div className="status-actions">
            {unsavedChanges[activeTab.id] && (
              <span className="status-item unsaved">Unsaved Changes</span>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

export default Editor
