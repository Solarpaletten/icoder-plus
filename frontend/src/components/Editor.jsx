import React, { useState, useRef, useEffect } from 'react'
import { Editor as MonacoEditor } from '@monaco-editor/react'
import { X, Copy, Save, Play, RotateCcw } from 'lucide-react'

const Editor = ({ 
  openTabs = [], 
  activeTab, 
  setActiveTab, 
  closeTab, 
  updateFileContent,
  onRunCode 
}) => {
  const editorRef = useRef(null)
  const [unsavedChanges, setUnsavedChanges] = useState(new Set())

  const handleEditorMount = (editor, monaco) => {
    editorRef.current = editor
    
    // Configure Monaco theme
    monaco.editor.defineTheme('vs-dark-custom', {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: 'comment', foreground: '6A9955' },
        { token: 'keyword', foreground: '569CD6' },
        { token: 'string', foreground: 'CE9178' },
        { token: 'number', foreground: 'B5CEA8' },
      ],
      colors: {
        'editor.background': '#1e1e1e',
        'editor.foreground': '#d4d4d4',
        'editor.lineHighlightBackground': '#2d2d30',
        'editor.selectionBackground': '#264f78',
        'editor.inactiveSelectionBackground': '#3a3d41',
      }
    })
    
    monaco.editor.setTheme('vs-dark-custom')
    
    // Auto-save on change
    editor.onDidChangeModelContent(() => {
      if (activeTab) {
        const content = editor.getValue()
        setUnsavedChanges(prev => new Set(prev).add(activeTab.id))
        
        // Debounced auto-save
        setTimeout(() => {
          updateFileContent(activeTab.id, content)
          setUnsavedChanges(prev => {
            const newSet = new Set(prev)
            newSet.delete(activeTab.id)
            return newSet
          })
        }, 1000)
      }
    })

    // Keyboard shortcuts
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
      handleSave()
    })
    
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyR, () => {
      if (activeTab && canRunFile(activeTab)) {
        onRunCode(activeTab)
      }
    })
  }

  const handleEditorChange = (value) => {
    if (activeTab && value !== undefined) {
      updateFileContent(activeTab.id, value)
    }
  }

  const handleSave = () => {
    if (activeTab && editorRef.current) {
      const content = editorRef.current.getValue()
      updateFileContent(activeTab.id, content)
      setUnsavedChanges(prev => {
        const newSet = new Set(prev)
        newSet.delete(activeTab.id)
        return newSet
      })
      
      // Show save indicator
      console.log(`Saved: ${activeTab.name}`)
    }
  }

  const handleCopyContent = () => {
    if (editorRef.current) {
      const content = editorRef.current.getValue()
      navigator.clipboard.writeText(content)
      console.log('Content copied to clipboard')
    }
  }

  const canRunFile = (file) => {
    const ext = file.name.split('.').pop()?.toLowerCase()
    return ['html', 'js', 'jsx'].includes(ext)
  }

  const getLanguageFromFile = (file) => {
    if (!file) return 'javascript'
    return file.language || 'javascript'
  }

  // Update editor content when active tab changes
  useEffect(() => {
    if (editorRef.current && activeTab) {
      const currentContent = editorRef.current.getValue()
      if (currentContent !== activeTab.content) {
        editorRef.current.setValue(activeTab.content || '')
      }
    }
  }, [activeTab?.id])

  if (openTabs.length === 0) {
    return (
      <div className="editor-container">
        <div className="editor-empty">
          <div className="empty-state">
            <h3>No files open</h3>
            <p>Create a new file or open an existing one to start coding</p>
            <div className="empty-actions">
              <button className="btn-primary">Create New File</button>
              <button className="btn-secondary">Open File</button>
            </div>
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
          {openTabs.map(tab => (
            <div
              key={tab.id}
              className={`editor-tab ${activeTab?.id === tab.id ? 'active' : ''}`}
              onClick={() => setActiveTab(tab)}
            >
              <span className="tab-icon">
                {getFileIcon(tab.name)}
              </span>
              <span className="tab-name">{tab.name}</span>
              {unsavedChanges.has(tab.id) && (
                <span className="tab-unsaved">●</span>
              )}
              <button
                className="tab-close"
                onClick={(e) => {
                  e.stopPropagation()
                  closeTab(tab)
                }}
              >
                <X size={14} />
              </button>
            </div>
          ))}
        </div>
        
        {/* Editor Actions */}
        <div className="editor-actions">
          <button 
            className="action-btn" 
            onClick={handleCopyContent}
            title="Copy content"
          >
            <Copy size={16} />
          </button>
          <button 
            className="action-btn" 
            onClick={handleSave}
            title="Save (Ctrl+S)"
          >
            <Save size={16} />
          </button>
          {activeTab && canRunFile(activeTab) && (
            <button 
              className="action-btn run-btn" 
              onClick={() => onRunCode(activeTab)}
              title="Run code (Ctrl+R)"
            >
              <Play size={16} />
            </button>
          )}
        </div>
      </div>

      {/* Monaco Editor */}
      <div className="editor-content">
        {activeTab ? (
          <MonacoEditor
            language={getLanguageFromFile(activeTab)}
            value={activeTab.content || ''}
            onChange={handleEditorChange}
            onMount={handleEditorMount}
            theme="vs-dark-custom"
            options={{
              fontSize: 14,
              fontFamily: "'Fira Code', 'Cascadia Code', 'JetBrains Mono', monospace",
              fontLigatures: true,
              lineNumbers: 'on',
              roundedSelection: false,
              scrollBeyondLastLine: false,
              readOnly: false,
              theme: 'vs-dark-custom',
              minimap: { enabled: true },
              wordWrap: 'on',
              tabSize: 2,
              insertSpaces: true,
              detectIndentation: true,
              renderLineHighlight: 'line',
              selectOnLineNumbers: true,
              automaticLayout: true,
              bracketPairColorization: { enabled: true },
              guides: {
                bracketPairs: true,
                indentation: true,
              }
            }}
          />
        ) : (
          <div className="no-active-tab">
            <p>Select a tab to start editing</p>
          </div>
        )}
      </div>

      {/* Status Bar */}
      <div className="editor-status">
        {activeTab && (
          <div className="status-info">
            <span className="status-item">
              Language: {getLanguageFromFile(activeTab)}
            </span>
            <span className="status-item">
              {activeTab.content?.length || 0} characters
            </span>
            <span className="status-item">
              Lines: {(activeTab.content || '').split('\n').length}
            </span>
            {unsavedChanges.has(activeTab.id) && (
              <span className="status-item unsaved">
                ● Unsaved changes
              </span>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

// Helper function for file icons (import from utils if available)
const getFileIcon = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  const iconMap = {
    js: '🟨', jsx: '🔷', ts: '🔵', tsx: '🔹',
    html: '🟧', css: '🎨', json: '📄', md: '📝'
  }
  return iconMap[ext] || '📄'
}

export default Editor
