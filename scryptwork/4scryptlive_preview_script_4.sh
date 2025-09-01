#!/bin/bash

echo "🚀 СКРИПТ #4: LIVE PREVIEW INTEGRATION (17:00-20:00)"
echo "==============================================="

cd frontend

# ============================================================================
# 1. ОБНОВИТЬ USECODERRUNNER HOOK - ДОБАВИТЬ LIVE PREVIEW
# ============================================================================

cat > src/hooks/useCodeRunner.js << 'EOF'
import { useState, useCallback, useRef } from 'react'

export const useCodeRunner = () => {
  const [isRunning, setIsRunning] = useState(false)
  const [previewMode, setPreviewMode] = useState(false) // Editor / Preview toggle
  const [output, setOutput] = useState('')
  const [consoleLog, setConsoleLog] = useState([])
  const previewFrameRef = useRef(null)

  // Execute JavaScript code
  const runJavaScript = useCallback((code, filename = 'script.js') => {
    setConsoleLog([])
    const logs = []
    
    try {
      // Capture console.log
      const originalLog = console.log
      const originalError = console.error
      const originalWarn = console.warn
      
      console.log = (...args) => {
        const message = args.map(arg => 
          typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
        ).join(' ')
        logs.push({ type: 'log', message, timestamp: new Date().toLocaleTimeString() })
        originalLog(...args)
      }
      
      console.error = (...args) => {
        const message = args.join(' ')
        logs.push({ type: 'error', message, timestamp: new Date().toLocaleTimeString() })
        originalError(...args)
      }
      
      console.warn = (...args) => {
        const message = args.join(' ')
        logs.push({ type: 'warn', message, timestamp: new Date().toLocaleTimeString() })
        originalWarn(...args)
      }

      // Execute code in isolated scope
      const executeCode = new Function('console', code)
      executeCode(console)
      
      // Restore original console
      console.log = originalLog
      console.error = originalError
      console.warn = originalWarn
      
      if (logs.length === 0) {
        logs.push({ 
          type: 'success', 
          message: '✅ Code executed successfully with no output',
          timestamp: new Date().toLocaleTimeString()
        })
      }
    } catch (error) {
      logs.push({ 
        type: 'error', 
        message: `❌ ${error.name}: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      })
    }
    
    setConsoleLog(logs)
    setOutput(logs.map(log => `[${log.timestamp}] ${log.message}`).join('\n'))
    return logs
  }, [])

  // Render HTML in iframe
  const runHTML = useCallback((htmlContent, filename = 'index.html') => {
    if (!previewFrameRef.current) return

    const iframe = previewFrameRef.current
    
    try {
      // Enhanced HTML template with console capture
      const enhancedHTML = `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live Preview - ${filename}</title>
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background: #ffffff;
                    color: #333;
                }
                pre { 
                    background: #f5f5f5; 
                    padding: 10px; 
                    border-radius: 4px; 
                    overflow-x: auto;
                }
            </style>
        </head>
        <body>
            ${htmlContent}
            <script>
                // Capture console output and send to parent
                const originalLog = console.log;
                const originalError = console.error;
                
                console.log = (...args) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'log',
                        message: args.join(' '),
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                    originalLog(...args);
                };
                
                console.error = (...args) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'error',
                        message: args.join(' '),
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                    originalError(...args);
                };
                
                // Catch runtime errors
                window.onerror = (message, source, lineno, colno, error) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'error',
                        message: \`Runtime Error: \${message} at line \${lineno}\`,
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                };
            </script>
        </body>
        </html>
      `

      const doc = iframe.contentDocument || iframe.contentWindow.document
      doc.open()
      doc.write(enhancedHTML)
      doc.close()
      
      setConsoleLog([{
        type: 'success',
        message: `🌐 HTML rendered successfully: ${filename}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } catch (error) {
      setConsoleLog([{
        type: 'error',
        message: `❌ HTML Render Error: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    }
  }, [])

  // Main run function - detects file type and runs accordingly
  const runCode = useCallback(async (file) => {
    if (!file || !file.content) return

    setIsRunning(true)
    const fileName = file.name || 'untitled'
    const content = file.content

    if (fileName.endsWith('.js') || fileName.endsWith('.jsx')) {
      runJavaScript(content, fileName)
    } else if (fileName.endsWith('.html') || fileName.endsWith('.htm')) {
      runHTML(content, fileName)
      setPreviewMode(true) // Auto-switch to preview for HTML
    } else if (fileName.endsWith('.css')) {
      // CSS Preview
      const cssPreview = `
        <style>${content}</style>
        <div class="css-demo">
          <h1>CSS Preview</h1>
          <p>Your styles are applied to this demo content.</p>
          <button>Sample Button</button>
          <div class="box">Sample Box</div>
        </div>
      `
      runHTML(cssPreview, fileName)
      setPreviewMode(true)
    } else {
      setConsoleLog([{
        type: 'warn',
        message: `⚠️ File type not supported for preview: ${fileName}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    }

    // Simulate execution delay for UX
    setTimeout(() => setIsRunning(false), 500)
  }, [runJavaScript, runHTML])

  // Listen for iframe console messages
  const handleIframeMessage = useCallback((event) => {
    if (event.data?.type === 'console') {
      setConsoleLog(prev => [...prev, {
        type: event.data.level,
        message: event.data.message,
        timestamp: event.data.timestamp
      }])
    }
  }, [])

  // Setup iframe message listener
  useState(() => {
    window.addEventListener('message', handleIframeMessage)
    return () => window.removeEventListener('message', handleIframeMessage)
  }, [handleIframeMessage])

  const clearConsole = () => {
    setConsoleLog([])
    setOutput('')
  }

  const togglePreview = () => {
    setPreviewMode(!previewMode)
  }

  return {
    isRunning,
    previewMode,
    output,
    consoleLog,
    previewFrameRef,
    runCode,
    clearConsole,
    togglePreview,
    setPreviewMode
  }
}
EOF

# ============================================================================
# 2. СОЗДАТЬ КОМПОНЕНТ LIVE PREVIEW PANEL
# ============================================================================

cat > src/components/LivePreview.jsx << 'EOF'
import React from 'react'
import { Play, Eye, Code, RotateCcw, Trash2, Maximize2 } from 'lucide-react'

const LivePreview = ({ 
  activeTab, 
  isRunning, 
  previewMode, 
  consoleLog, 
  previewFrameRef,
  onRunCode,
  onTogglePreview,
  onClearConsole 
}) => {
  const getFileTypeIcon = (fileName) => {
    if (fileName?.endsWith('.html') || fileName?.endsWith('.htm')) return '🌐'
    if (fileName?.endsWith('.js') || fileName?.endsWith('.jsx')) return '🟨'
    if (fileName?.endsWith('.css')) return '🎨'
    return '📄'
  }

  const getConsoleIcon = (type) => {
    switch (type) {
      case 'error': return '❌'
      case 'warn': return '⚠️'
      case 'success': return '✅'
      default: return '📝'
    }
  }

  return (
    <div className="live-preview-panel">
      {/* Header */}
      <div className="preview-header">
        <div className="preview-title">
          <span>{getFileTypeIcon(activeTab?.name)} Live Preview</span>
          {activeTab?.name && (
            <span className="preview-filename">{activeTab.name}</span>
          )}
        </div>
        
        <div className="preview-actions">
          <button 
            className="action-btn run-btn"
            onClick={() => onRunCode(activeTab)}
            disabled={!activeTab || isRunning}
            title="Run Code (Ctrl+R)"
          >
            <Play size={16} />
            {isRunning ? 'Running...' : 'Run'}
          </button>
          
          <button
            className="action-btn"
            onClick={onTogglePreview}
            title="Toggle Preview Mode"
          >
            {previewMode ? <Code size={16} /> : <Eye size={16} />}
            {previewMode ? 'Code' : 'Preview'}
          </button>
          
          <button
            className="action-btn"
            onClick={onClearConsole}
            title="Clear Console"
          >
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="preview-content">
        {!activeTab ? (
          <div className="preview-empty">
            <Code size={48} style={{color: '#666'}} />
            <h3>No File Selected</h3>
            <p>Select a file from the explorer to preview it here</p>
          </div>
        ) : previewMode ? (
          /* Preview Mode - Show iframe */
          <div className="preview-iframe-container">
            <iframe 
              ref={previewFrameRef}
              className="preview-iframe"
              title={`Preview: ${activeTab.name}`}
              sandbox="allow-scripts allow-same-origin allow-forms"
            />
          </div>
        ) : (
          /* Console Mode - Show output */
          <div className="console-output">
            <div className="console-header">
              <span>📟 Console Output</span>
              <span className="console-count">
                {consoleLog.length} {consoleLog.length === 1 ? 'entry' : 'entries'}
              </span>
            </div>
            
            <div className="console-logs">
              {consoleLog.length === 0 ? (
                <div className="console-empty">
                  <span>No output yet. Click "Run" to execute your code.</span>
                </div>
              ) : (
                consoleLog.map((log, index) => (
                  <div key={index} className={`console-log console-${log.type}`}>
                    <span className="console-icon">{getConsoleIcon(log.type)}</span>
                    <span className="console-timestamp">[{log.timestamp}]</span>
                    <span className="console-message">{log.message}</span>
                  </div>
                ))
              )}
            </div>
          </div>
        )}
      </div>

      {/* Footer with file info */}
      {activeTab && (
        <div className="preview-footer">
          <span className="file-info">
            Language: {activeTab.name?.split('.').pop()?.toUpperCase() || 'Unknown'}
          </span>
          <span className="file-size">
            {activeTab.content?.length || 0} characters
          </span>
        </div>
      )}
    </div>
  )
}

export default LivePreview
EOF

# ============================================================================
# 3. ОБНОВИТЬ EDITOR КОМПОНЕНТ - ДОБАВИТЬ КНОПКУ RUN
# ============================================================================

cat > src/components/Editor.jsx << 'EOF'
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
EOF

# ============================================================================
# 4. ОБНОВИТЬ APP.JSX - ДОБАВИТЬ LIVE PREVIEW PANEL
# ============================================================================

cat > src/App.jsx << 'EOF'
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
EOF

# ============================================================================
# 5. ДОБАВИТЬ СТИЛИ ДЛЯ LIVE PREVIEW В GLOBALS.CSS
# ============================================================================

cat >> src/styles/globals.css << 'EOF'

/* ============================================================================
   LIVE PREVIEW PANEL STYLES
   ============================================================================ */

.preview-panel {
  width: 400px;
  background: var(--bg-secondary);
  border-left: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  min-width: 300px;
  max-width: 600px;
}

.live-preview-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* Preview Header */
.preview-header {
  padding: 8px 16px;
  background: var(--bg-tertiary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  user-select: none;
}

.preview-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary);
}

.preview-filename {
  color: var(--text-secondary);
  font-weight: 400;
  font-style: italic;
}

.preview-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* Preview Content */
.preview-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;