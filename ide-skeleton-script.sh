#!/bin/bash

echo "🚀 Скрипт #1: Создание каркаса IDE с панелями"
echo "================================================"
echo "Время: 8:30-11:00 (2.5 часа)"
echo "Задача: Topbar + Sidebar + Editor + Terminal + RightPanel placeholders"

# Проверка структуры проекта
if [ ! -d "frontend/src" ]; then
    echo "❌ Ошибка: frontend/src не найден. Запустите из корня проекта."
    exit 1
fi

cd frontend

echo "📦 Установка зависимостей для IDE каркаса..."
npm install lucide-react clsx

# === ГЛАВНЫЙ КОМПОНЕНТ IDE ===
cat > src/App.jsx << 'EOF'
import React, { useState } from 'react'
import { 
  PanelLeft, 
  Terminal as TerminalIcon, 
  Play, 
  MessageSquare,
  X,
  Menu,
  FileText,
  Settings
} from 'lucide-react'
import './App.css'

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(false)
  const [activeAgent, setActiveAgent] = useState('dashka')

  return (
    <div className="ide-container">
      {/* Topbar */}
      <header className="ide-topbar">
        <div className="topbar-left">
          <button 
            className="panel-toggle"
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            title="Toggle File Explorer"
          >
            <Menu size={16} />
          </button>
          <div className="project-info">
            <span className="project-name">iCoder Plus v2.2</span>
            <span className="project-status">IDE Shell</span>
          </div>
        </div>
        
        <div className="topbar-center">
          <span className="breadcrumb">Welcome.js</span>
        </div>
        
        <div className="topbar-right">
          <div className="agent-indicator">
            <div className={`agent-dot ${activeAgent}`}></div>
            <span>
              {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Code Gen)'}
            </span>
          </div>
          <button 
            className="panel-toggle"
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            title="Toggle AI Panel"
          >
            <MessageSquare size={16} />
          </button>
        </div>
      </header>

      {/* Main Layout */}
      <div className="ide-main">
        {/* Left Sidebar - File Explorer */}
        {leftPanelOpen && (
          <aside className="left-panel">
            <div className="panel-header">
              <span>EXPLORER</span>
              <button onClick={() => setLeftPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            <div className="file-explorer-placeholder">
              <div className="folder-item">
                <span>📁 src</span>
              </div>
              <div className="file-item">
                <span>📄 App.jsx</span>
              </div>
              <div className="file-item">
                <span>📄 index.js</span>
              </div>
              <div className="folder-item">
                <span>📁 components</span>
              </div>
            </div>
          </aside>
        )}

        {/* Center - Editor Area */}
        <main className="editor-area">
          <div className="editor-tabs">
            <div className="tab active">
              <FileText size={14} />
              <span>Welcome.js</span>
              <button className="tab-close">
                <X size={12} />
              </button>
            </div>
            <div className="tab">
              <FileText size={14} />
              <span>App.jsx</span>
              <button className="tab-close">
                <X size={12} />
              </button>
            </div>
          </div>
          
          <div className="editor-content">
            <div className="editor-placeholder">
              <div className="welcome-message">
                <h2>🚀 iCoder Plus v2.2 - IDE Shell</h2>
                <p>Minimalist Visual IDE - Monaco Editor will be here</p>
                <div className="placeholder-code">
                  <pre>{`// Welcome to iCoder Plus IDE Shell
console.log('Hello from IDE!');

function initIDE() {
  return {
    fileTree: true,
    editor: 'monaco',
    terminal: true,
    aiAgent: 'dual'
  };
}

export default initIDE;`}</pre>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Right Panel - AI/Preview */}
        {rightPanelOpen && (
          <aside className="right-panel">
            <div className="panel-header">
              <span>AI ASSISTANT</span>
              <button onClick={() => setRightPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            
            <div className="agent-selector">
              <button 
                className={`agent-btn ${activeAgent === 'dashka' ? 'active' : ''}`}
                onClick={() => setActiveAgent('dashka')}
              >
                🏗️ Dashka
              </button>
              <button 
                className={`agent-btn ${activeAgent === 'claudy' ? 'active' : ''}`}
                onClick={() => setActiveAgent('claudy')}
              >
                🤖 Claudy
              </button>
            </div>
            
            <div className="ai-placeholder">
              <p>AI Panel placeholder - будет чат с {activeAgent}</p>
            </div>
          </aside>
        )}
      </div>

      {/* Bottom Terminal */}
      {terminalOpen && (
        <div className="terminal-panel">
          <div className="terminal-header">
            <span>TERMINAL</span>
            <button onClick={() => setTerminalOpen(false)}>
              <X size={14} />
            </button>
          </div>
          <div className="terminal-content">
            <div className="terminal-line">$ npm run dev</div>
            <div className="terminal-line">🚀 iCoder Plus starting...</div>
            <div className="terminal-cursor">$_</div>
          </div>
        </div>
      )}

      {/* Bottom Action Bar */}
      <footer className="ide-statusbar">
        <div className="statusbar-left">
          <button 
            className={`status-btn ${terminalOpen ? 'active' : ''}`}
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal (Ctrl+`)"
          >
            <TerminalIcon size={14} />
            Terminal
          </button>
        </div>
        
        <div className="statusbar-right">
          <span className="status-info">JavaScript</span>
          <span className="status-info">UTF-8</span>
          <span className="status-info">Ln 1, Col 1</span>
        </div>
      </footer>
    </div>
  )
}

export default App
EOF

# === СТИЛИ IDE ===
cat > src/App.css << 'EOF'
/* IDE Shell - VS Code Style Layout */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

:root {
  /* VS Code Dark Theme Colors */
  --vscode-bg: #1e1e1e;
  --vscode-sidebar: #252526;
  --vscode-editor: #1e1e1e;
  --vscode-panel: #2d2d30;
  --vscode-border: #3e3e42;
  --vscode-text: #cccccc;
  --vscode-muted: #969696;
  --vscode-accent: #007acc;
  --vscode-tab: #2d2d30;
  --vscode-tab-active: #1e1e1e;
  --vscode-success: #4ec9b0;
  --vscode-warning: #ffcc02;
  --vscode-error: #f44747;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Consolas, 'Courier New', monospace;
  background: var(--vscode-bg);
  color: var(--vscode-text);
  font-size: 13px;
  overflow: hidden;
}

.ide-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

/* === TOPBAR === */
.ide-topbar {
  height: 35px;
  background: var(--vscode-panel);
  border-bottom: 1px solid var(--vscode-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  -webkit-app-region: drag;
}

.topbar-left, .topbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.topbar-center {
  flex: 1;
  text-align: center;
}

.panel-toggle {
  background: transparent;
  border: none;
  color: var(--vscode-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
  -webkit-app-region: no-drag;
}

.panel-toggle:hover {
  background: var(--vscode-border);
  color: var(--vscode-text);
}

.project-info {
  display: flex;
  flex-direction: column;
  font-size: 11px;
}

.project-name {
  font-weight: 600;
  color: var(--vscode-text);
}

.project-status {
  color: var(--vscode-muted);
  font-size: 10px;
}

.breadcrumb {
  font-size: 12px;
  color: var(--vscode-muted);
}

.agent-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: var(--vscode-muted);
}

.agent-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--vscode-accent);
}

.agent-dot.dashka {
  background: #ff6b35;
}

.agent-dot.claudy {
  background: #4ecdc4;
}

/* === MAIN LAYOUT === */
.ide-main {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* === LEFT PANEL === */
.left-panel {
  width: 240px;
  background: var(--vscode-sidebar);
  border-right: 1px solid var(--vscode-border);
  display: flex;
  flex-direction: column;
}

.panel-header {
  height: 35px;
  padding: 0 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  font-weight: 600;
  color: var(--vscode-muted);
  border-bottom: 1px solid var(--vscode-border);
}

.panel-header button {
  background: transparent;
  border: none;
  color: var(--vscode-muted);
  cursor: pointer;
  padding: 2px;
}

.panel-header button:hover {
  color: var(--vscode-text);
}

.file-explorer-placeholder {
  padding: 8px 0;
  flex: 1;
}

.folder-item, .file-item {
  padding: 4px 16px;
  cursor: pointer;
  font-size: 13px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.folder-item:hover, .file-item:hover {
  background: var(--vscode-border);
}

/* === EDITOR AREA === */
.editor-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: var(--vscode-editor);
}

.editor-tabs {
  height: 35px;
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
  display: flex;
  overflow-x: auto;
}

.tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 0 12px;
  height: 100%;
  background: var(--vscode-tab);
  border-right: 1px solid var(--vscode-border);
  cursor: pointer;
  font-size: 13px;
  color: var(--vscode-muted);
  min-width: 120px;
}

.tab.active {
  background: var(--vscode-tab-active);
  color: var(--vscode-text);
}

.tab:hover {
  color: var(--vscode-text);
}

.tab-close {
  background: transparent;
  border: none;
  color: inherit;
  cursor: pointer;
  padding: 2px;
  opacity: 0.6;
  border-radius: 2px;
}

.tab-close:hover {
  opacity: 1;
  background: var(--vscode-error);
  color: white;
}

.editor-content {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.editor-placeholder {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--vscode-editor);
}

.welcome-message {
  text-align: center;
  max-width: 600px;
  padding: 40px;
}

.welcome-message h2 {
  color: var(--vscode-accent);
  margin-bottom: 16px;
}

.welcome-message p {
  color: var(--vscode-muted);
  margin-bottom: 24px;
}

.placeholder-code {
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  border-radius: 4px;
  padding: 16px;
  text-align: left;
}

.placeholder-code pre {
  color: var(--vscode-success);
  font-family: 'Consolas', 'Courier New', monospace;
  font-size: 12px;
  line-height: 1.4;
}

/* === RIGHT PANEL === */
.right-panel {
  width: 300px;
  background: var(--vscode-sidebar);
  border-left: 1px solid var(--vscode-border);
  display: flex;
  flex-direction: column;
}

.agent-selector {
  display: flex;
  padding: 8px;
  gap: 4px;
}

.agent-btn {
  flex: 1;
  padding: 6px 12px;
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  color: var(--vscode-text);
  cursor: pointer;
  border-radius: 3px;
  font-size: 11px;
}

.agent-btn.active {
  background: var(--vscode-accent);
  border-color: var(--vscode-accent);
}

.ai-placeholder {
  padding: 16px;
  color: var(--vscode-muted);
  font-size: 12px;
}

/* === TERMINAL === */
.terminal-panel {
  height: 200px;
  background: var(--vscode-panel);
  border-top: 1px solid var(--vscode-border);
  display: flex;
  flex-direction: column;
}

.terminal-header {
  height: 35px;
  padding: 0 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  font-weight: 600;
  color: var(--vscode-muted);
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
}

.terminal-content {
  flex: 1;
  padding: 8px 12px;
  font-family: 'Consolas', 'Courier New', monospace;
  font-size: 12px;
  overflow-y: auto;
}

.terminal-line {
  color: var(--vscode-text);
  margin-bottom: 2px;
}

.terminal-cursor {
  color: var(--vscode-success);
}

/* === STATUSBAR === */
.ide-statusbar {
  height: 22px;
  background: var(--vscode-accent);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  font-size: 11px;
}

.statusbar-left, .statusbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-btn {
  background: transparent;
  border: none;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 2px 6px;
  border-radius: 2px;
}

.status-btn:hover, .status-btn.active {
  background: rgba(255, 255, 255, 0.1);
}

.status-info {
  color: rgba(255, 255, 255, 0.8);
  font-size: 11px;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .left-panel {
    width: 200px;
  }
  
  .right-panel {
    width: 250px;
  }
  
  .terminal-panel {
    height: 150px;
  }
}
EOF

# === MAIN.JSX (точка входа) ===
cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# === INDEX.HTML ===
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vscode-icon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>iCoder Plus v2.2 - IDE Shell</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

echo ""
echo "✅ Скрипт #1 выполнен успешно!"
echo ""
echo "📂 Созданы файлы:"
echo "   ✓ src/App.jsx - главный компонент IDE"  
echo "   ✓ src/App.css - стили в духе VS Code"
echo "   ✓ src/main.jsx - точка входа"
echo "   ✓ index.html - HTML шаблон"
echo ""
echo "🎯 Результат: Полный каркас IDE с панелями:"
echo "   ✓ Topbar с индикатором агента"
echo "   ✓ Сворачиваемый Sidebar (File Explorer)"  
echo "   ✓ Editor Area с табами"
echo "   ✓ Сворачиваемая правая панель (AI)"
echo "   ✓ Сворачиваемый Terminal внизу"
echo "   ✓ Statusbar как в VS Code"
echo ""
echo "🚀 Запуск:"
echo "   npm run dev"
echo ""
echo "⏰ Время выполнения: ~2.5 часа (8:30-11:00)"
echo "📋 Чек-лист: пункты 1-5 выполнены ✓"
echo ""
echo "👉 Следующий: Скрипт #2 (11:00-13:00) - File Tree CRUD"