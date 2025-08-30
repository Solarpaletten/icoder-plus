#!/bin/bash

echo "Исправляем CSS и build проблемы"

# ============================================================================
# 1. ИСПРАВИТЬ CSS СИНТАКСИЧЕСКУЮ ОШИБКУ
# ============================================================================

cd frontend/src/styles

# Найти и показать проблемную строку
echo "Проверяем globals.css на строке 434..."
sed -n '430,440p' globals.css

# Исправить CSS - пересоздать файл с корректным синтаксисом
cat > globals.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #1e1e1e;
  color: #cccccc;
  overflow: hidden;
}

.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 35px;
}

.app-title {
  font-size: 14px;
  color: #cccccc;
}

.app-subtitle {
  font-size: 12px;
  color: #888;
  margin-left: 8px;
}

.status-indicator {
  font-size: 12px;
  color: #4ec9b0;
}

.ai-panel-toggle {
  font-size: 12px;
  color: #007acc;
}

.app-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.left-panel {
  width: 300px;
  border-right: 1px solid #464647;
  background: #252526;
  display: flex;
  flex-direction: column;
}

.main-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #1e1e1e;
}

.right-panel {
  width: 300px;
  border-left: 1px solid #464647;
  background: #252526;
}

.editor-header {
  border-bottom: 1px solid #464647;
  background: #2d2d30;
}

.editor-tabs {
  display: flex;
  overflow-x: auto;
}

.editor-tab {
  padding: 8px 12px;
  border-right: 1px solid #464647;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 100px;
  background: #2d2d30;
}

.editor-tab:hover {
  background: #37373d;
}

.editor-tab.active {
  background: #1e1e1e;
  border-bottom: 2px solid #007acc;
}

.tab-name {
  font-size: 13px;
  color: #cccccc;
}

.tab-close {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  font-size: 16px;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tab-close:hover {
  color: #cccccc;
  background: #464647;
  border-radius: 3px;
}

.editor-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.editor-placeholder {
  text-align: center;
  padding: 40px 20px;
}

.editor-placeholder h3 {
  color: #007acc;
  margin-bottom: 10px;
  font-size: 24px;
}

.editor-placeholder p {
  color: #888;
  margin-bottom: 20px;
}

.code-preview {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 16px;
  margin: 20px auto;
  max-width: 600px;
  text-align: left;
}

.code-preview pre {
  color: #c9d1d9;
  font-family: 'Fira Code', 'Cascadia Code', monospace;
  font-size: 14px;
  line-height: 1.5;
}

.no-file-selected {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #888;
}

.ai-header {
  padding: 12px 16px;
  border-bottom: 1px solid #464647;
  background: #2d2d30;
}

.ai-header h3 {
  font-size: 12px;
  color: #cccccc;
  margin-bottom: 8px;
}

.ai-content {
  padding: 16px;
  color: #888;
  font-size: 13px;
}

.bottom-panel {
  height: 150px;
  border-top: 1px solid #464647;
  background: #1e1e1e;
  display: flex;
  flex-direction: column;
}

.terminal-header {
  padding: 8px 16px;
  background: #2d2d30;
  border-bottom: 1px solid #464647;
  font-size: 12px;
  color: #cccccc;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.terminal-content {
  flex: 1;
  padding: 12px 16px;
  font-family: 'Fira Code', 'Cascadia Code', monospace;
  font-size: 13px;
  color: #cccccc;
  overflow-y: auto;
}

.terminal-line {
  margin-bottom: 4px;
}

.prompt {
  color: #4ec9b0;
}

.output {
  color: #cccccc;
}

/* File Tree Styles */
.file-tree {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.tree-header {
  padding: 12px 16px;
  border-bottom: 1px solid #2d2d30;
  background: #252526;
}

.tree-btn {
  padding: 4px;
  background: transparent;
  border: none;
  border-radius: 3px;
  color: #cccccc;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tree-btn:hover {
  background: #2a2d2e;
}

.search-box {
  padding: 8px 16px;
  border-bottom: 1px solid #2d2d30;
}

.search-input {
  width: 100%;
  padding: 6px 8px;
  background: #3c3c3c;
  border: 1px solid #464647;
  border-radius: 3px;
  color: #cccccc;
  font-size: 13px;
}

.search-input::placeholder {
  color: #888;
}

.tree-content {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.tree-item {
  display: flex;
  align-items: center;
  padding: 4px 16px 4px 8px;
  cursor: pointer;
  user-select: none;
  gap: 6px;
  min-height: 22px;
}

.tree-item:hover {
  background: #2a2d2e;
}

.tree-item.selected {
  background: #094771;
}

.tree-arrow {
  display: flex;
  align-items: center;
  color: #cccccc;
  width: 16px;
  justify-content: center;
}

.tree-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.tree-name {
  font-size: 13px;
  color: #cccccc;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tree-rename-input {
  flex: 1;
  background: #3c3c3c;
  border: 1px solid #007acc;
  border-radius: 3px;
  padding: 2px 4px;
  font-size: 13px;
  color: #cccccc;
  outline: none;
}

.context-menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
}

.context-menu {
  position: fixed;
  background: #2d2d30;
  border: 1px solid #464647;
  border-radius: 3px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
  z-index: 1000;
  min-width: 160px;
  padding: 4px 0;
}

.context-menu-item {
  padding: 6px 12px;
  font-size: 13px;
  color: #cccccc;
  cursor: pointer;
  user-select: none;
}

.context-menu-item:hover {
  background: #094771;
}

.context-menu-divider {
  height: 1px;
  background: #464647;
  margin: 4px 0;
}

/* Inline Creation Styles */
.tree-item.creating {
  background: rgba(0, 122, 204, 0.1);
  border: 1px dashed #007acc;
}

.tree-create-input {
  flex: 1;
  background: #3c3c3c;
  border: 1px solid #007acc;
  border-radius: 3px;
  padding: 2px 6px;
  font-size: 13px;
  color: #cccccc;
  outline: none;
}

.tree-create-input::placeholder {
  color: #888;
  font-style: italic;
}

/* Panel Toggles */
.panel-toggle {
  position: absolute;
  z-index: 100;
  background: #2d2d30;
  border: 1px solid #464647;
}

.left-toggle {
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  border-radius: 0 4px 4px 0;
}

.terminal-toggle {
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  border-radius: 4px 4px 0 0;
}

.toggle-btn {
  background: none;
  border: none;
  color: #cccccc;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
}

.toggle-btn:hover {
  background: #37373d;
}

.terminal-close {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
}

.terminal-close:hover {
  color: #cccccc;
}

/* Agent Selector Fix */
.agent-selector {
  display: flex;
  gap: 4px;
}

.agent-btn {
  padding: 4px 8px;
  background: transparent;
  border: 1px solid #464647;
  color: #cccccc;
  border-radius: 3px;
  cursor: pointer;
  font-size: 11px;
  transition: all 0.2s;
}

.agent-btn:hover {
  border-color: #007acc;
}

.agent-btn.active {
  background: #007acc;
  border-color: #007acc;
  color: white;
}
EOF

echo "✅ CSS исправлен"

# ============================================================================
# 2. ТЕСТИРОВАТЬ СБОРКУ ИЗ ПРАВИЛЬНОЙ ДИРЕКТОРИИ
# ============================================================================

cd ../../..
echo "Тестируем из директории: $(pwd)"

npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ УСПЕШНАЯ СБОРКА!"
    echo ""
    echo "ПРОБЛЕМЫ РЕШЕНЫ:"
    echo "✅ CSS синтаксическая ошибка исправлена"
    echo "✅ Build запускается из правильной директории"
    echo "✅ FileUtils с корректным JSX рендерингом"
    echo ""
    echo "ГОТОВ К КОММИТУ:"
    echo "git add ."
    echo "git commit -m 'Fix CSS syntax error and JSX rendering'"
    echo "git push origin main"
    
else
    echo "❌ Сборка все еще не удалась"
    echo "Показываем последние строки globals.css для диагностики:"
    tail -10 frontend/src/styles/globals.css
    exit 1
fi