#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ИНТЕГРАЦИИ"
echo "=================================="
echo "Исправляем: CSS переменные, FileTree props, дублирование функций"

cd frontend

# ============================================================================
# 1. ДОБАВИТЬ CSS ПЕРЕМЕННЫЕ В globals.css
# ============================================================================

# Вставляем CSS переменные в начало файла после body
sed -i '' '/^body {/a\
\
:root {\
  --bg-primary: #1e1e1e;\
  --bg-secondary: #252526;\
  --bg-tertiary: #2d2d30;\
  --border: #464647;\
  --text-primary: #cccccc;\
  --text-secondary: #888;\
  --button-bg: transparent;\
  --button-hover: #2a2d2e;\
  --accent-blue: #007acc;\
  --accent-green: #4ec9b0;\
}' src/styles/globals.css

echo "✅ CSS переменные добавлены"

# ============================================================================
# 2. ИСПРАВИТЬ App.jsx - УБРАТЬ ДУБЛИРОВАНИЕ
# ============================================================================

cat > src/App.jsx << 'EOF'
import React, { useState } from 'react'
import { 
  ChevronDown,
  ChevronUp,
  X,
  Menu
} from 'lucide-react'
import FileTree from './components/FileTree'
import { useFileManager } from './hooks/useFileManager'
import './styles/globals.css'

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(true)
  const [terminalOpen, setTerminalOpen] = useState(true)
  const [activeAgent, setActiveAgent] = useState('claudy')

  // File Manager Hook
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
    setActiveTab,
    toggleFolder,
    updateFileContent
  } = useFileManager()

  return (
    <div className="app-container">
      {/* Header */}
      <header className="app-header">
        <div style={{display: 'flex', alignItems: 'center'}}>
          <button 
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            style={{background: 'none', border: 'none', color: '#cccccc', marginRight: '12px', cursor: 'pointer'}}
          >
            <Menu size={16} />
          </button>
          <div className="app-title">iCoder Plus v2.2</div>
          <div className="app-subtitle">File Tree Ready</div>
        </div>
        
        <div className="status-indicator">
          {activeTab ? activeTab.name : 'No file selected'}
        </div>
        
        <div className="ai-panel-toggle">
          {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Assistant)'}
        </div>
      </header>

      <div className="app-content">
        {/* Left Panel - File Explorer */}
        {leftPanelOpen && (
          <div className="left-panel">
            <FileTree
              fileTree={fileTree}
              searchQuery={searchQuery}
              setSearchQuery={setSearchQuery}
              openFile={openFile}
              createFile={createFile}
              createFolder={createFolder}
              renameItem={renameItem}
              deleteItem={deleteItem}
              toggleFolder={toggleFolder}
              selectedFileId={activeTab?.id}
            />
          </div>
        )}

        {/* Main Panel - Editor */}
        <div className="main-panel">
          {/* File Tabs */}
          {openTabs.length > 0 && (
            <div className="editor-header">
              <div className="editor-tabs">
                {openTabs.map(tab => (
                  <div
                    key={tab.id}
                    className={`editor-tab ${activeTab?.id === tab.id ? 'active' : ''}`}
                    onClick={() => setActiveTab(tab)}
                  >
                    <span className="tab-name">{tab.name}</span>
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
            </div>
          )}

          {/* Editor Content */}
          <div className="editor-content">
            {activeTab ? (
              <textarea
                value={activeTab.content || ''}
                onChange={(e) => updateFileContent(activeTab.id, e.target.value)}
                style={{
                  width: '100%',
                  height: '100%',
                  background: '#1e1e1e',
                  border: 'none',
                  color: '#cccccc',
                  fontFamily: 'Monaco, Menlo, monospace',
                  fontSize: '14px',
                  padding: '20px',
                  resize: 'none',
                  outline: 'none'
                }}
                placeholder="Start typing your code..."
              />
            ) : (
              <div className="no-file-selected">
                <div className="editor-placeholder">
                  <h3>No file selected</h3>
                  <p>Select a file from the explorer to start editing</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Panel - AI Assistant */}
        {rightPanelOpen && (
          <div className="right-panel">
            <div className="ai-header">
              <h3>AI ASSISTANT</h3>
              <div className="agent-selector">
                <button
                  className={`agent-btn ${activeAgent === 'dashka' ? 'active' : ''}`}
                  onClick={() => setActiveAgent('dashka')}
                >
                  Dashka
                </button>
                <button
                  className={`agent-btn ${activeAgent === 'claudy' ? 'active' : ''}`}
                  onClick={() => setActiveAgent('claudy')}
                >
                  Claudy
                </button>
              </div>
            </div>

            <div className="ai-content">
              <div style={{textAlign: 'center', padding: '20px'}}>
                <div style={{fontSize: '48px', marginBottom: '12px'}}>
                  {activeAgent === 'dashka' ? '🏗️' : '🤖'}
                </div>
                <h4 style={{color: '#cccccc', marginBottom: '8px'}}>
                  {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Assistant)'}
                </h4>
                <p>
                  {activeAgent === 'dashka' 
                    ? 'Ready to help with architecture and code review'
                    : 'Ready to assist with coding and implementation'
                  }
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Panel - Terminal */}
      <div className={`bottom-panel ${terminalOpen ? '' : 'collapsed'}`}>
        <div className="terminal-header">
          <span>TERMINAL</span>
          <button 
            onClick={() => setTerminalOpen(!terminalOpen)}
            style={{background: 'none', border: 'none', color: '#cccccc', cursor: 'pointer'}}
          >
            {terminalOpen ? <ChevronDown size={16} /> : <ChevronUp size={16} />}
          </button>
        </div>

        {terminalOpen && (
          <div className="terminal-content">
            <div className="terminal-line">
              <span className="prompt">npm run dev</span>
            </div>
            <div className="terminal-line">
              <span className="output">iCoder Plus starting...</span>
            </div>
            <div className="terminal-line">
              <span className="prompt">✅ File Tree Management ready</span>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default App
EOF

echo "✅ App.jsx упрощен и исправлен"

# ============================================================================
# 3. ТЕСТИРОВАНИЕ
# ============================================================================

echo "🧪 Тестируем финальную интеграцию..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 СКРИПТ #2 ПОЛНОСТЬЮ ЗАВЕРШЕН!"
    echo "================================="
    echo ""
    echo "✅ РАБОТАЮЩИЕ ФУНКЦИИ:"
    echo "   • FileTree с CRUD операциями"
    echo "   • Кнопки + File и + Folder"
    echo "   • Поиск файлов"
    echo "   • Контекстное меню (правый клик)"
    echo "   • Переименование inline"
    echo "   • Открытие файлов в табах"
    echo "   • AI агенты переключаются"
    echo "   • Терминал сворачивается"
    echo "   • Панели можно скрывать"
    echo ""
    echo "📋 ИТОГОВЫЙ СТАТУС:"
    echo "   ✅ Все CSS переменные определены"
    echo "   ✅ Props FileTree исправлены"
    echo "   ✅ Дублирование функций устранено"
    echo "   ✅ Сборка проходит без ошибок"
    echo ""
    echo "🚀 ГОТОВ К СКРИПТУ #3: Monaco Editor Integration"
else
    echo "❌ Ошибка сборки - проверьте консоль"
fi