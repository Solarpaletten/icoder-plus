#!/bin/bash

echo "🎯 СОЗДАЕМ globals.css С НУЛЯ - ПОЛНАЯ ВЕРСИЯ"

cd frontend/src/styles

# ============================================================================
# 1. СОЗДАТЬ ПОЛНЫЙ globals.css (НЕ ДОПОЛНЯТЬ, А СОЗДАТЬ)
# ============================================================================

cat > globals.css << 'EOF'
/* iCoder Plus v2.2 - Глобальные стили */
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap');

:root {
  /* Цветовая схема IDE */
  --bg-primary: #0d1117;
  --bg-secondary: #161b22;
  --bg-tertiary: #21262d;
  --border-color: #30363d;
  --text-primary: #e6edf3;
  --text-secondary: #7d8590;
  --accent-blue: #58a6ff;
  --accent-green: #3fb950;
  --accent-orange: #ffa348;
  --accent-red: #f85149;
  --agent-dashka: #ff6b35;
  --agent-claudy: #4ecdc4;
}

/* Базовые стили */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg-primary);
  color: var(--text-primary);
}

#root {
  height: 100vh;
  overflow: hidden;
}

/* Layout стили для трехпанельного интерфейса */
.ide-layout {
  display: flex;
  height: 100vh;
  flex-direction: column;
}

.ide-main {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.ide-sidebar {
  width: 280px;
  background: var(--bg-secondary);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

.ide-sidebar.collapsed {
  width: 0;
  overflow: hidden;
}

.ide-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: var(--bg-primary);
}

.ide-right-panel {
  width: 320px;
  background: var(--bg-secondary);
  border-left: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

/* File Tree стили */
.file-tree-header {
  padding: 12px 16px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--text-secondary);
}

.file-tree-actions {
  display: flex;
  gap: 6px;
}

.file-tree-action {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
}

.file-tree-action:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.file-tree-search {
  padding: 8px 16px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
}

.file-tree-search input {
  width: 100%;
  padding: 6px 8px;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  color: var(--text-primary);
  font-size: 12px;
}

.file-tree-search input:focus {
  outline: none;
  border-color: var(--accent-blue);
}

.file-tree-search input::placeholder {
  color: var(--text-secondary);
}

/* File Tree элементы */
.file-tree-item {
  display: flex;
  align-items: center;
  padding: 4px 16px 4px 8px;
  cursor: pointer;
  font-size: 13px;
  color: var(--text-primary);
  user-select: none;
  position: relative;
}

.file-tree-item:hover {
  background: var(--bg-tertiary);
}

.file-tree-item.active {
  background: rgba(88, 166, 255, 0.1);
  color: var(--accent-blue);
}

.file-tree-item.editing {
  background: var(--bg-tertiary);
}

.file-tree-item .indent {
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 4px;
}

.file-tree-item .icon {
  width: 16px;
  height: 16px;
  margin-right: 8px;
  flex-shrink: 0;
}

.file-tree-item .name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-tree-item .edit-input {
  flex: 1;
  background: var(--bg-primary);
  border: 1px solid var(--accent-blue);
  border-radius: 3px;
  padding: 2px 6px;
  color: var(--text-primary);
  font-size: 13px;
  font-family: inherit;
}

.file-tree-item .edit-input:focus {
  outline: none;
}

/* Tabs стили */
.editor-tabs {
  display: flex;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  overflow-x: auto;
  min-height: 35px;
}

.editor-tab {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: var(--bg-secondary);
  border-right: 1px solid var(--border-color);
  cursor: pointer;
  font-size: 13px;
  color: var(--text-secondary);
  white-space: nowrap;
  min-width: 120px;
  position: relative;
}

.editor-tab.active {
  background: var(--bg-primary);
  color: var(--text-primary);
}

.editor-tab:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.editor-tab .tab-name {
  flex: 1;
  margin-right: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.editor-tab .tab-close {
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3px;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.2s;
}

.editor-tab:hover .tab-close {
  opacity: 1;
}

.editor-tab .tab-close:hover {
  background: var(--bg-tertiary);
}

.editor-tab.modified::after {
  content: '';
  position: absolute;
  top: 50%;
  right: 6px;
  width: 6px;
  height: 6px;
  background: var(--accent-orange);
  border-radius: 50%;
  transform: translateY(-50%);
}

/* Right Panel стили */
.right-panel-header {
  padding: 12px 16px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.agent-switcher {
  display: flex;
  background: var(--bg-primary);
  border-radius: 6px;
  overflow: hidden;
}

.agent-switcher button {
  padding: 6px 12px;
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  transition: all 0.2s;
}

.agent-switcher button.active {
  background: var(--accent-blue);
  color: white;
}

.agent-switcher button:hover:not(.active) {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

/* Terminal стили */
.terminal-panel {
  height: 200px;
  background: var(--bg-secondary);
  border-top: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
}

.terminal-panel.collapsed {
  height: 35px;
}

.terminal-header {
  padding: 8px 16px;
  background: var(--bg-tertiary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--text-secondary);
}

.terminal-content {
  flex: 1;
  padding: 16px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: var(--text-secondary);
  overflow-y: auto;
}

/* Context Menu стили */
.context-menu {
  position: fixed;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 4px 0;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
  z-index: 1000;
  min-width: 160px;
}

.context-menu-item {
  padding: 6px 12px;
  font-size: 13px;
  color: var(--text-primary);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.context-menu-item:hover {
  background: var(--accent-blue);
}

.context-menu-separator {
  height: 1px;
  background: var(--border-color);
  margin: 4px 0;
}

/* Scrollbar стили */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--bg-secondary);
}

::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--text-secondary);
}

/* Анимации */
.fade-in {
  animation: fadeIn 0.2s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.slide-in-right {
  animation: slideInRight 0.3s ease-out;
}

@keyframes slideInRight {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}

/* Утилиты */
.flex { display: flex; }
.flex-1 { flex: 1; }
.hidden { display: none; }
.pointer-events-none { pointer-events: none; }

/* Responsive */
@media (max-width: 768px) {
  .ide-sidebar {
    width: 100%;
    position: absolute;
    z-index: 100;
    height: 100%;
  }
  
  .ide-right-panel {
    display: none;
  }
}
EOF

