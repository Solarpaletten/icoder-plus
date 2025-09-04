#!/bin/bash

echo "🏗️ ФИНАЛЬНАЯ АРХИТЕКТУРА - APP SHELL"
echo "===================================="
echo "Фиксируем дизайн как в 4-м скриншоте навсегда"

# ============================================================================
# 1. СОЗДАТЬ ГЛАВНЫЙ APP SHELL КОМПОНЕНТ
# ============================================================================

cat > src/components/AppShell.tsx << 'EOF'
import { useState } from 'react';
import { AppHeader } from './layout/AppHeader';
import { FileSidebar } from './layout/FileSidebar';
import { EditorArea } from './layout/EditorArea';
import { RightPanel } from './layout/RightPanel';
import { BottomTerminal } from './layout/BottomTerminal';
import { StatusBar } from './layout/StatusBar';
import { useFileManager } from '../hooks/useFileManager';
import { usePanelState } from '../hooks/usePanelState';

export function AppShell() {
  const fileManager = useFileManager();
  const panelState = usePanelState();
  
  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white">
      {/* Header с меню */}
      <AppHeader />
      
      {/* Основная область */}
      <div className="flex-1 flex min-h-0">
        {/* Left Sidebar - File Explorer */}
        {!panelState.isLeftCollapsed && (
          <div 
            className="bg-gray-800 border-r border-gray-700 flex-shrink-0"
            style={{ width: panelState.leftWidth }}
          >
            <FileSidebar 
              {...fileManager}
              onToggle={() => panelState.toggleLeft()}
            />
          </div>
        )}
        
        {/* Collapsed Left Button */}
        {panelState.isLeftCollapsed && (
          <button
            onClick={() => panelState.toggleLeft()}
            className="w-8 bg-gray-800 border-r border-gray-700 flex items-center justify-center hover:bg-gray-700"
            title="Show Explorer"
          >
            <span className="text-gray-400 text-xs writing-mode-vertical">EXPLORER</span>
          </button>
        )}
        
        {/* Center - Editor Area */}
        <div className="flex-1 flex flex-col min-w-0">
          <EditorArea {...fileManager} />
          
          {/* Bottom Terminal */}
          <BottomTerminal 
            isCollapsed={panelState.isBottomCollapsed}
            onToggle={() => panelState.toggleBottom()}
            height={panelState.bottomHeight}
            onResize={(height) => panelState.setBottomHeight(height)}
          />
        </div>
        
        {/* Right Panel - AI Assistants */}
        {!panelState.isRightCollapsed && (
          <div 
            className="bg-gray-800 border-l border-gray-700 flex-shrink-0"
            style={{ width: panelState.rightWidth }}
          >
            <RightPanel 
              onToggle={() => panelState.toggleRight()}
            />
          </div>
        )}
        
        {/* Collapsed Right Button */}
        {panelState.isRightCollapsed && (
          <button
            onClick={() => panelState.toggleRight()}
            className="w-8 bg-gray-800 border-l border-gray-700 flex items-center justify-center hover:bg-gray-700"
            title="Show AI Assistant"
          >
            <span className="text-gray-400 text-xs writing-mode-vertical">AI</span>
          </button>
        )}
      </div>
      
      {/* Status Bar - синяя полоса */}
      <StatusBar 
        isCollapsed={panelState.isStatusCollapsed}
        onToggle={() => panelState.toggleStatus()}
      />
    </div>
  );
}
EOF

echo "✅ AppShell.tsx создан"

# ============================================================================
# 2. СОЗДАТЬ APP HEADER С МЕНЮ
# ============================================================================

cat > src/components/layout/AppHeader.tsx << 'EOF'
import { useState } from 'react';
import { Menu, X, FolderOpen, Settings, HelpCircle } from 'lucide-react';

export function AppHeader() {
  const [activeMenu, setActiveMenu] = useState<string | null>(null);

  const menus = {
    File: ['New File', 'New Folder', 'Open File', 'Save', 'Save All', 'Close'],
    Edit: ['Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Find', 'Replace'],
    View: ['Explorer', 'Terminal', 'AI Assistant', 'Command Palette'],
    Help: ['Documentation', 'Shortcuts', 'About']
  };

  return (
    <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center px-4 text-xs">
      {/* Logo */}
      <div className="flex items-center mr-6">
        <span className="font-semibold text-blue-400">iCoder Plus v2.2</span>
        <span className="ml-2 text-gray-500 text-xs">IDE Shell</span>
      </div>
      
      {/* Menu Items */}
      <div className="flex space-x-1">
        {Object.keys(menus).map(menuName => (
          <div key={menuName} className="relative">
            <button
              className={`px-2 py-1 hover:bg-gray-700 rounded text-gray-300 ${
                activeMenu === menuName ? 'bg-gray-700' : ''
              }`}
              onClick={() => setActiveMenu(activeMenu === menuName ? null : menuName)}
            >
              {menuName}
            </button>
            
            {activeMenu === menuName && (
              <div className="absolute top-full left-0 mt-1 bg-gray-700 border border-gray-600 rounded shadow-lg z-50">
                {menus[menuName as keyof typeof menus].map(item => (
                  <button
                    key={item}
                    className="block w-full text-left px-3 py-1 hover:bg-gray-600 text-gray-300 text-xs"
                    onClick={() => setActiveMenu(null)}
                  >
                    {item}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
      
      {/* Right Side Info */}
      <div className="ml-auto flex items-center space-x-4 text-gray-400">
        <span className="text-xs">Backend: Online</span>
        <span className="text-xs">Branch: main</span>
      </div>
    </div>
  );
}
EOF

echo "✅ AppHeader.tsx создан"

# ============================================================================
# 3. СОЗДАТЬ FILE SIDEBAR
# ============================================================================

cat > src/components/layout/FileSidebar.tsx << 'EOF'
import { useState } from 'react';
import { ChevronRight, ChevronDown, File, Folder, FolderOpen, Plus, Search, X } from 'lucide-react';
import type { FileItem, FileManagerState } from '../../types';

interface FileSidebarProps extends FileManagerState {
  createFile: (parentId: string | null, name: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  onToggle: () => void;
}

export function FileSidebar({ 
  fileTree, 
  createFile, 
  createFolder, 
  openFile, 
  onToggle 
}: FileSidebarProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const renderFileItem = (item: FileItem, depth = 0): React.ReactNode => {
    const isFolder = item.type === 'folder';
    const hasChildren = item.children && item.children.length > 0;

    return (
      <div key={item.id} className="select-none">
        <div
          className="flex items-center py-1 px-2 hover:bg-gray-700 cursor-pointer text-xs"
          style={{ paddingLeft: `${8 + depth * 16}px` }}
          onClick={() => isFolder ? undefined : openFile(item)}
        >
          {isFolder && (
            <button className="flex items-center justify-center w-4 h-4 mr-1">
              {item.expanded ? (
                <ChevronDown size={10} className="text-gray-400" />
              ) : (
                <ChevronRight size={10} className="text-gray-400" />
              )}
            </button>
          )}
          
          {isFolder ? (
            item.expanded ? <FolderOpen size={14} className="text-blue-400 mr-2" /> : <Folder size={14} className="text-blue-400 mr-2" />
          ) : (
            <File size={14} className="text-gray-400 mr-2" />
          )}
          
          <span className="flex-1 truncate text-gray-300">{item.name}</span>
        </div>

        {isFolder && item.expanded && hasChildren && (
          <div>
            {item.children?.map(child => renderFileItem(child, depth + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="h-8 flex items-center justify-between px-3 bg-gray-750 border-b border-gray-700">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
          Explorer
        </span>
        <div className="flex items-center space-x-1">
          <button
            onClick={() => createFile(null, 'Untitled.js')}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="New File"
          >
            <Plus size={12} />
          </button>
          <button
            onClick={() => createFolder(null, 'New Folder')}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="New Folder"
          >
            <Folder size={12} />
          </button>
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            title="Hide Explorer"
          >
            <X size={12} />
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="p-2 border-b border-gray-700">
        <div className="relative">
          <Search size={12} className="absolute left-2 top-2 text-gray-400" />
          <input
            type="text"
            placeholder="Search files..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-6 pr-2 py-1 bg-gray-700 border border-gray-600 rounded text-xs text-gray-300 placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
        </div>
      </div>

      {/* File Tree */}
      <div className="flex-1 overflow-y-auto">
        {fileTree.length > 0 ? (
          fileTree.map(item => renderFileItem(item))
        ) : (
          <div className="p-4 text-center text-gray-500 text-xs">
            <FolderOpen className="mx-auto mb-2 opacity-50" size={24} />
            <p>No files yet</p>
            <p className="mt-1">Create your first file</p>
          </div>
        )}
      </div>
    </div>
  );
}
EOF

echo "✅ FileSidebar.tsx создан"

# ============================================================================
# 4. СОЗДАТЬ EDITOR AREA
# ============================================================================

cat > src/components/layout/EditorArea.tsx << 'EOF'
import { X } from 'lucide-react';
import { SmartCodeEditor } from '../SmartCodeEditor';
import type { FileManagerState, TabItem } from '../../types';

interface EditorAreaProps extends FileManagerState {
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function EditorArea({ 
  openTabs, 
  activeTab, 
  closeTab, 
  setActiveTab, 
  updateFileContent 
}: EditorAreaProps) {
  if (openTabs.length === 0) {
    return (
      <div className="flex-1 flex items-center justify-center bg-gray-900">
        <div className="text-center">
          <div className="text-4xl mb-4">🚀</div>
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2 - IDE Shell</h2>
          <p className="text-gray-400 mb-4">Minimalist Visual IDE - Monaco Editor will be here</p>
          <div className="text-sm text-gray-500 font-mono">
            <p>// Welcome to iCoder Plus IDE Shell</p>
            <p>console.log('Hello from IDE!');</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col bg-gray-900">
      {/* Tab Bar */}
      <div className="flex bg-gray-800 border-b border-gray-700 overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-4 py-2 border-r border-gray-700 cursor-pointer min-w-32 ${
              activeTab?.id === tab.id 
                ? 'bg-gray-900 text-white border-b-2 border-blue-500' 
                : 'hover:bg-gray-700 text-gray-300'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            <span className="text-sm truncate flex-1">{tab.name}</span>
            {tab.isDirty && <span className="ml-2 w-2 h-2 bg-orange-400 rounded-full"></span>}
            <button
              onClick={(e) => { e.stopPropagation(); closeTab(tab); }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Editor Content */}
      {activeTab && (
        <div className="flex-1 overflow-hidden">
          <SmartCodeEditor
            content={activeTab.content}
            onChange={(content) => updateFileContent(activeTab.id, content)}
            language={activeTab.language}
          />
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ EditorArea.tsx создан"

# ============================================================================
# 5. СОЗДАТЬ RIGHT PANEL (AI ASSISTANTS)
# ============================================================================

cat > src/components/layout/RightPanel.tsx << 'EOF'
import { useState } from 'react';
import { Bot, MessageSquare, X, Sparkles } from 'lucide-react';

interface RightPanelProps {
  onToggle: () => void;
}

export function RightPanel({ onToggle }: RightPanelProps) {
  const [activeAgent, setActiveAgent] = useState<'dashka' | 'claudy'>('dashka');
  
  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="h-8 flex items-center justify-between px-3 bg-gray-750 border-b border-gray-700">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
          AI Assistant
        </span>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
          title="Hide AI Assistant"
        >
          <X size={12} />
        </button>
      </div>

      {/* Agent Selector */}
      <div className="p-2 border-b border-gray-700">
        <div className="flex space-x-1">
          <button
            onClick={() => setActiveAgent('dashka')}
            className={`flex-1 px-3 py-1 rounded text-xs font-medium transition-colors ${
              activeAgent === 'dashka'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            <Bot size={12} className="inline mr-1" />
            Dashka
          </button>
          <button
            onClick={() => setActiveAgent('claudy')}
            className={`flex-1 px-3 py-1 rounded text-xs font-medium transition-colors ${
              activeAgent === 'claudy'
                ? 'bg-green-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            <Sparkles size={12} className="inline mr-1" />
            Claudy
          </button>
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 p-3">
        <div className="text-center text-gray-400 text-xs">
          <MessageSquare size={24} className="mx-auto mb-2 opacity-50" />
          <p>AI Panel placeholder - будет чат с {activeAgent}</p>
          <p className="mt-2 text-xs">
            {activeAgent === 'dashka' 
              ? 'Architect & Code Reviewer' 
              : 'Code Generator & Assistant'
            }
          </p>
        </div>
      </div>
    </div>
  );
}
EOF

echo "✅ RightPanel.tsx создан"

# ============================================================================
# 6. СОЗДАТЬ STATUS BAR (синяя полоса)
# ============================================================================

cat > src/components/layout/StatusBar.tsx << 'EOF'
import { ChevronUp, ChevronDown, Circle, GitBranch, Wifi } from 'lucide-react';

interface StatusBarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function StatusBar({ isCollapsed, onToggle }: StatusBarProps) {
  if (isCollapsed) {
    return (
      <div 
        className="h-1 bg-blue-600 cursor-pointer hover:bg-blue-500 transition-colors"
        onClick={onToggle}
        title="Expand Status Bar"
      />
    );
  }

  return (
    <div className="h-6 bg-blue-600 flex items-center justify-between px-3 text-xs text-white">
      {/* Left Side */}
      <div className="flex items-center space-x-4">
        <div className="flex items-center">
          <Circle size={8} className="text-green-400 fill-current mr-1" />
          <span>Backend Connected</span>
        </div>
        
        <div className="flex items-center">
          <GitBranch size={12} className="mr-1" />
          <span>main</span>
        </div>
        
        <div className="flex items-center">
          <Wifi size={12} className="mr-1" />
          <span>API Ready</span>
        </div>
      </div>

      {/* Center */}
      <div className="flex items-center space-x-4">
        <span>JavaScript</span>
        <span>UTF-8</span>
        <span>Ln 1, Col 1</span>
      </div>

      {/* Right Side */}
      <div className="flex items-center space-x-2">
        <span>iCoder Plus starting...</span>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-blue-500 rounded"
          title="Collapse Status Bar"
        >
          <ChevronDown size={10} />
        </button>
      </div>
    </div>
  );
}
EOF

echo "✅ StatusBar.tsx создан"

# ============================================================================
# 7. ОБНОВИТЬ usePanelState ДЛЯ УПРАВЛЕНИЯ ПАНЕЛЯМИ
# ============================================================================

cat > src/hooks/usePanelState.ts << 'EOF'
import { useState, useCallback } from 'react';

interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
}

export function usePanelState() {
  const [panelState, setPanelState] = useState<PanelState>({
    leftWidth: 280,
    rightWidth: 350,
    bottomHeight: 200,
    isLeftCollapsed: false,
    isRightCollapsed: false,
    isBottomCollapsed: false,
    isStatusCollapsed: false,
  });

  const toggleLeft = useCallback(() => {
    setPanelState(prev => ({ ...prev, isLeftCollapsed: !prev.isLeftCollapsed }));
  }, []);

  const toggleRight = useCallback(() => {
    setPanelState(prev => ({ ...prev, isRightCollapsed: !prev.isRightCollapsed }));
  }, []);

  const toggleBottom = useCallback(() => {
    setPanelState(prev => ({ ...prev, isBottomCollapsed: !prev.isBottomCollapsed }));
  }, []);

  const toggleStatus = useCallback(() => {
    setPanelState(prev => ({ ...prev, isStatusCollapsed: !prev.isStatusCollapsed }));
  }, []);

  const setBottomHeight = useCallback((height: number) => {
    setPanelState(prev => ({ ...prev, bottomHeight: Math.max(80, Math.min(400, height)) }));
  }, []);

  const setLeftWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(500, width)) }));
  }, []);

  const setRightWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(500, width)) }));
  }, []);

  return {
    ...panelState,
    toggleLeft,
    toggleRight,
    toggleBottom,
    toggleStatus,
    setBottomHeight,
    setLeftWidth,
    setRightWidth,
  };
}
EOF

echo "✅ usePanelState.ts обновлен"

# ============================================================================
# 8. СОЗДАТЬ ДИРЕКТОРИИ И ОБНОВИТЬ APP.TSX
# ============================================================================

# Создать директории
mkdir -p src/components/layout

# Обновить App.tsx
cat > src/App.tsx << 'EOF'
import { AppShell } from './components/AppShell';

function App() {
  return <AppShell />;
}

export default App;
EOF

echo "✅ App.tsx обновлен (только AppShell импорт)"

# Проверить сборку
echo "🧪 Тестируем финальную архитектуру..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Финальная архитектура создана успешно!"
    echo "🎯 Теперь интерфейс зафиксирован и можно только совершенствовать модули"
else
    echo "❌ Ошибки в сборке - проверьте консоль"
fi