#!/bin/bash

echo "💻 Скрипт #3: Monaco Editor Integration (13:00-17:00)"

cd frontend

# ============================================================================
# 1. УСТАНОВИТЬ MONACO EDITOR ЗАВИСИМОСТИ
# ============================================================================

echo "📦 Устанавливаем Monaco Editor..."

# Добавить в package.json если еще нет
npm install @monaco-editor/react monaco-editor @monaco-editor/loader

# ============================================================================
# 2. СОЗДАТЬ MONACO EDITOR КОМПОНЕНТ
# ============================================================================

cat > src/components/Editor.jsx << 'EOF'
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
EOF

# ============================================================================
# 3. ДОБАВИТЬ CSS СТИЛИ ДЛЯ РЕДАКТОРА
# ============================================================================

cat >> src/styles/globals.css << 'EOF'

/* Editor Styles */
.editor-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #1e1e1e;
}

.editor-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: #1e1e1e;
}

.empty-state {
  text-align: center;
  color: #cccccc;
  max-width: 400px;
  padding: 2rem;
}

.empty-state h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  color: #ffffff;
}

.empty-state p {
  margin-bottom: 2rem;
  color: #888;
}

.empty-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.btn-primary {
  padding: 8px 16px;
  background: #007acc;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary:hover {
  background: #106ebe;
}

.btn-secondary {
  padding: 8px 16px;
  background: transparent;
  color: #cccccc;
  border: 1px solid #464647;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-secondary:hover {
  border-color: #007acc;
  color: #007acc;
}

/* Tab Bar */
.editor-tabs {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  padding: 0;
  min-height: 35px;
}

.tabs-list {
  display: flex;
  overflow-x: auto;
  flex: 1;
}

.editor-tab {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: #2d2d30;
  border-right: 1px solid #464647;
  cursor: pointer;
  user-select: none;
  gap: 6px;
  min-width: 120px;
  max-width: 200px;
}

.editor-tab:hover {
  background: #37373d;
}

.editor-tab.active {
  background: #1e1e1e;
  border-bottom: 2px solid #007acc;
}

.tab-icon {
  flex-shrink: 0;
  font-size: 14px;
}

.tab-name {
  flex: 1;
  font-size: 13px;
  color: #cccccc;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tab-unsaved {
  color: #ffffff;
  font-weight: bold;
  flex-shrink: 0;
}

.tab-close {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  padding: 2px;
  border-radius: 3px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tab-close:hover {
  background: #464647;
  color: #cccccc;
}

/* Editor Actions */
.editor-actions {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 0 12px;
}

.action-btn {
  background: none;
  border: none;
  color: #cccccc;
  cursor: pointer;
  padding: 6px;
  border-radius: 3px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn:hover {
  background: #37373d;
}

.run-btn {
  color: #4ec9b0;
}

.run-btn:hover {
  background: #37373d;
  color: #6fddbc;
}

/* Editor Content */
.editor-content {
  flex: 1;
  position: relative;
}

.no-active-tab {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #888;
  font-size: 14px;
}

/* Status Bar */
.editor-status {
  background: #007acc;
  border-top: 1px solid #464647;
  padding: 4px 12px;
  font-size: 12px;
  color: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.status-info {
  display: flex;
  gap: 16px;
}

.status-item {
  color: white;
}

.status-item.unsaved {
  color: #ffcc02;
  font-weight: bold;
}

/* Monaco Editor Overrides */
.monaco-editor {
  background: #1e1e1e !important;
}

.monaco-editor .margin {
  background: #1e1e1e !important;
}

.monaco-editor-background {
  background: #1e1e1e !important;
}
EOF

# ============================================================================
# 4. СОЗДАТЬ ХУК ДЛЯ КОДА ВЫПОЛНЕНИЯ
# ============================================================================

cat > src/hooks/useCodeRunner.js << 'EOF'
import { useState, useCallback } from 'react'

export const useCodeRunner = () => {
  const [previewContent, setPreviewContent] = useState('')
  const [consoleOutput, setConsoleOutput] = useState([])
  const [isRunning, setIsRunning] = useState(false)

  const runCode = useCallback(async (file) => {
    if (!file) return

    setIsRunning(true)
    setConsoleOutput([])

    try {
      const ext = file.name.split('.').pop()?.toLowerCase()
      
      if (ext === 'html') {
        // Run HTML directly
        setPreviewContent(file.content)
        setConsoleOutput([{
          type: 'info',
          message: `HTML file "${file.name}" loaded in preview`,
          timestamp: new Date().toLocaleTimeString()
        }])
      } 
      else if (ext === 'js' || ext === 'jsx') {
        // Run JavaScript
        await runJavaScript(file.content, file.name)
      }
      else {
        setConsoleOutput([{
          type: 'warn',
          message: `File type "${ext}" cannot be executed`,
          timestamp: new Date().toLocaleTimeString()
        }])
      }
    } catch (error) {
      setConsoleOutput(prev => [...prev, {
        type: 'error',
        message: `Runtime error: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } finally {
      setIsRunning(false)
    }
  }, [])

  const runJavaScript = async (code, fileName) => {
    // Create a sandboxed environment for JS execution
    const originalConsole = window.console
    const logs = []

    // Override console methods
    const mockConsole = {
      log: (...args) => logs.push({ type: 'log', args, timestamp: new Date().toLocaleTimeString() }),
      error: (...args) => logs.push({ type: 'error', args, timestamp: new Date().toLocaleTimeString() }),
      warn: (...args) => logs.push({ type: 'warn', args, timestamp: new Date().toLocaleTimeString() }),
      info: (...args) => logs.push({ type: 'info', args, timestamp: new Date().toLocaleTimeString() })
    }

    try {
      // Replace console temporarily
      window.console = mockConsole

      // Create function and execute
      const func = new Function('console', code)
      const result = func(mockConsole)

      // If there's a return value, log it
      if (result !== undefined) {
        logs.push({
          type: 'return',
          args: [result],
          timestamp: new Date().toLocaleTimeString()
        })
      }

      // Convert logs to console output format
      const output = logs.map(log => ({
        type: log.type,
        message: log.args.map(arg => 
          typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
        ).join(' '),
        timestamp: log.timestamp
      }))

      setConsoleOutput(output)

    } catch (error) {
      setConsoleOutput([{
        type: 'error',
        message: `Execution error in "${fileName}": ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } finally {
      // Restore original console
      window.console = originalConsole
    }
  }

  const clearConsole = () => {
    setConsoleOutput([])
  }

  const clearPreview = () => {
    setPreviewContent('')
  }

  return {
    previewContent,
    consoleOutput,
    isRunning,
    runCode,
    clearConsole,
    clearPreview
  }
}
EOF

# ============================================================================
# 5. ОБНОВИТЬ ГЛАВНЫЙ APP КОМПОНЕНТ
# ============================================================================

cat > src/App.jsx << 'EOF'
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
EOF

# ============================================================================
# 6. ОБНОВИТЬ CSS ДЛЯ APP LAYOUT
# ============================================================================

cat >> src/styles/globals.css << 'EOF'

/* App Layout */
.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #1e1e1e;
  color: #cccccc;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.app-header {
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.app-title h1 {
  font-size: 16px;
  margin: 0;
  color: #cccccc;
  font-weight: 500;
}

.app-subtitle {
  font-size: 12px;
  color: #888;
  margin-left: 12px;
}

.app-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.left-panel {
  width: 300px;
  min-width: 200px;
  max-width: 500px;
  border-right: 1px solid #464647;
  background: #252526;
  display: flex;
  flex-direction: column;
}

.main-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* Responsive */
@media (max-width: 768px) {
  .left-panel {
    width: 250px;
  }
}

@media (max-width: 640px) {
  .app-content {
    flex-direction: column;
  }
  
  .left-panel {
    width: 100%;
    height: 200px;
  }
}
EOF

# ============================================================================
# 7. ТЕСТИРОВАТЬ MONACO EDITOR
# ============================================================================

echo "🔨 Тестируем Monaco Editor интеграцию..."

npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ СКРИПТ #3 ВЫПОЛНЕН УСПЕШНО!"
    echo ""
    echo "💻 Monaco Editor Integration готов:"
    echo "   - ✅ Monaco Editor с темой VS Code Dark"
    echo "   - ✅ Синтаксическая подсветка"
    echo "   - ✅ Автодополнение и IntelliSense"
    echo "   - ✅ Табы для открытых файлов"
    echo "   - ✅ Автосохранение с индикатором"
    echo "   - ✅ Горячие клавиши (Ctrl+S, Ctrl+R)"
    echo "   - ✅ Копирование и запуск кода"
    echo "   - ✅ Статус-бар с информацией"
    echo "   - ✅ Поддержка font ligatures"
    echo "   - ✅ Minimap и руководства отступов"
    echo ""
    echo "⏰ Время: 13:00-17:00 (4 часа)"
    echo ""
    echo "🚀 ГОТОВ К КОММИТУ:"
    echo "   git add ."
    echo "   git commit -m 'Add Monaco Editor with full IDE features'"
    echo "   git push origin main"
    echo ""
    echo "📋 ПЕРЕХОДИМ К СКРИПТУ #4: Tabs & Auto-save (17:00-21:00)"
    
else
    echo "❌ Ошибка сборки Monaco Editor"
    exit 1
fi

cd ..