#!/bin/bash

echo "🏗️ МОДУЛЬНАЯ АРХИТЕКТУРА - App.tsx КАК КОНТЕЙНЕР"
echo "=============================================="
echo "Создаем отдельные компоненты с импортами"

# ============================================================================
# 1. СОЗДАТЬ ЧИСТЫЙ App.tsx КАК КОНТЕЙНЕР
# ============================================================================

cat > src/App.tsx << 'EOF'
import { useState } from 'react';
import type { AgentType } from './types';

// Layout Components
import { AppHeader } from './components/layout/AppHeader';
import { AppStatusBar } from './components/layout/AppStatusBar';

// Panel Components  
import { LeftSidebar } from './components/panels/LeftSidebar';
import { MainEditor } from './components/panels/MainEditor';
import { RightPanel } from './components/panels/RightPanel';
import { BottomTerminal } from './components/panels/BottomTerminal';

// Utility Components
import { ResizableLayout } from './components/utils/ResizableLayout';

// Hooks
import { useFileManager } from './hooks/useFileManager';
import { usePanelState } from './hooks/usePanelState';

/**
 * App.tsx - Clean Container
 * Только импорты и композиция компонентов
 * Каждый компонент живет отдельно и не затирается
 */
function App() {
  // Global State
  const [activeAgent, setActiveAgent] = useState<AgentType>('claudy');
  const [activeRightPanel, setActiveRightPanel] = useState<'ai' | 'preview'>('preview');
  
  // Custom Hooks
  const fileManager = useFileManager();
  const panelState = usePanelState();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white overflow-hidden">
      {/* Header - отдельный компонент */}
      <AppHeader 
        activeTab={fileManager.activeTab}
        onMenuToggle={() => panelState.toggleLeft()}
      />

      {/* Main Layout - resizable panels */}
      <ResizableLayout panelState={panelState}>
        {/* Left Sidebar */}
        <LeftSidebar 
          {...fileManager}
          isCollapsed={panelState.leftCollapsed}
          onToggle={panelState.toggleLeft}
        />

        {/* Main Editor */}
        <MainEditor {...fileManager} />

        {/* Right Panel */}
        <RightPanel
          activePanel={activeRightPanel}
          setActivePanel={setActiveRightPanel}
          activeAgent={activeAgent}
          setActiveAgent={setActiveAgent}
          activeTab={fileManager.activeTab}
          isCollapsed={panelState.rightCollapsed}
          onToggle={panelState.toggleRight}
        />

        {/* Bottom Terminal */}
        <BottomTerminal
          isCollapsed={panelState.terminalCollapsed}
          onToggle={panelState.toggleTerminal}
        />
      </ResizableLayout>

      {/* Status Bar - отдельный компонент */}
      <AppStatusBar
        activeTab={fileManager.activeTab}
        backendStatus="api.icoder.swapoil.de"
      />
    </div>
  );
}

export default App;
EOF

echo "✅ Чистый App.tsx создан"

# ============================================================================
# 2. СОЗДАТЬ ПАНЕЛЬНЫЙ ХУК
# ============================================================================

mkdir -p src/hooks

cat > src/hooks/usePanelState.ts << 'EOF'
import { useState } from 'react';

export function usePanelState() {
  const [leftCollapsed, setLeftCollapsed] = useState(false);
  const [rightCollapsed, setRightCollapsed] = useState(false);
  const [terminalCollapsed, setTerminalCollapsed] = useState(false);

  return {
    leftCollapsed,
    rightCollapsed,
    terminalCollapsed,
    toggleLeft: () => setLeftCollapsed(!leftCollapsed),
    toggleRight: () => setRightCollapsed(!rightCollapsed),
    toggleTerminal: () => setTerminalCollapsed(!terminalCollapsed),
  };
}
EOF

echo "✅ usePanelState хук создан"

# ============================================================================
# 3. СОЗДАТЬ LAYOUT КОМПОНЕНТЫ
# ============================================================================

mkdir -p src/components/layout

cat > src/components/layout/AppHeader.tsx << 'EOF'
import { Menu, Settings, Code } from 'lucide-react';
import type { TabItem } from '../../types';

interface AppHeaderProps {
  activeTab: TabItem | null;
  onMenuToggle: () => void;
}

export function AppHeader({ activeTab, onMenuToggle }: AppHeaderProps) {
  return (
    <header className="h-10 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4 flex-shrink-0">
      <div className="flex items-center space-x-4">
        <button onClick={onMenuToggle} className="p-1.5 hover:bg-gray-700 rounded">
          <Menu size={16} />
        </button>
        
        <div className="flex items-center space-x-3">
          <div className="w-4 h-4 bg-blue-500 rounded-sm flex items-center justify-center">
            <Code size={10} className="text-white" />
          </div>
          <span className="text-sm font-medium">iCoder Plus</span>
          <span className="text-xs text-gray-400">v2.2</span>
        </div>
      </div>

      <div className="flex items-center space-x-4">
        <div className="px-3 py-1 bg-blue-600 rounded text-xs font-medium">
          {activeTab?.name || 'Welcome'}
        </div>
        
        <button className="p-1.5 hover:bg-gray-700 rounded">
          <Settings size={14} />
        </button>
      </div>
    </header>
  );
}
EOF

cat > src/components/layout/AppStatusBar.tsx << 'EOF'
import type { TabItem } from '../../types';

interface AppStatusBarProps {
  activeTab: TabItem | null;
  backendStatus: string;
}

export function AppStatusBar({ activeTab, backendStatus }: AppStatusBarProps) {
  return (
    <div className="h-6 bg-blue-600 flex items-center justify-between px-4 text-xs flex-shrink-0">
      <div className="flex items-center space-x-4">
        <span>✅ Backend: {backendStatus}</span>
        <span>🔄 Ready</span>
      </div>
      <div className="flex items-center space-x-2">
        <span>{activeTab?.language || 'Text'}</span>
        <span>UTF-8</span>
      </div>
    </div>
  );
}
EOF

echo "✅ Layout компоненты созданы"

# ============================================================================
# 4. СОЗДАТЬ ПАНЕЛЬНЫЕ КОМПОНЕНТЫ
# ============================================================================

mkdir -p src/components/panels

cat > src/components/panels/LeftSidebar.tsx << 'EOF'
import { CollapsiblePanel } from '../utils/CollapsiblePanel';
import { FileTree } from '../FileTree';
import { FileUploader } from '../features/FileUploader';
import type { FileManagerState } from '../../types';

interface LeftSidebarProps extends FileManagerState {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: any) => void;
  toggleFolder: (folder: any) => void;
  setSearchQuery: (query: string) => void;
  isCollapsed: boolean;
  onToggle: () => void;
}

export function LeftSidebar(props: LeftSidebarProps) {
  if (props.isCollapsed) {
    return (
      <div className="w-8 bg-gray-800 border-r border-gray-700 flex flex-col items-center py-2">
        <button onClick={props.onToggle} className="p-2 hover:bg-gray-700 rounded">
          📁
        </button>
      </div>
    );
  }

  return (
    <div className="w-80 bg-gray-800 border-r border-gray-700 flex flex-col">
      <CollapsiblePanel
        direction="horizontal"
        isCollapsed={false}
        onToggle={props.onToggle}
        title="Explorer"
      >
        {/* File Uploader - отдельный компонент */}
        <FileUploader
          onFileUpload={(files) => console.log('Files uploaded:', files)}
          onFolderUpload={(folder) => console.log('Folder uploaded:', folder)}
        />
        
        {/* File Tree - существующий компонент */}
        <FileTree {...props} />
      </CollapsiblePanel>
    </div>
  );
}
EOF

cat > src/components/panels/MainEditor.tsx << 'EOF'
import { Editor } from '../Editor';
import type { FileManagerState } from '../../types';

interface MainEditorProps extends FileManagerState {
  closeTab: (tab: any) => void;
  setActiveTab: (tab: any) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function MainEditor(props: MainEditorProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <Editor {...props} />
    </div>
  );
}
EOF

cat > src/components/panels/RightPanel.tsx << 'EOF'
import { Play } from 'lucide-react';
import { CollapsiblePanel } from '../utils/CollapsiblePanel';
import { AIAssistant } from '../AIAssistant';
import { LivePreview } from '../LivePreview';
import type { AgentType, TabItem } from '../../types';

interface RightPanelProps {
  activePanel: 'ai' | 'preview';
  setActivePanel: (panel: 'ai' | 'preview') => void;
  activeAgent: AgentType;
  setActiveAgent: (agent: AgentType) => void;
  activeTab: TabItem | null;
  isCollapsed: boolean;
  onToggle: () => void;
}

export function RightPanel(props: RightPanelProps) {
  if (props.isCollapsed) {
    return (
      <div className="w-8 bg-gray-800 border-l border-gray-700 flex flex-col items-center py-2">
        <button onClick={props.onToggle} className="p-2 hover:bg-gray-700 rounded">
          {props.activePanel === 'preview' ? '▶' : '🤖'}
        </button>
      </div>
    );
  }

  return (
    <div className="w-96 bg-gray-800 border-l border-gray-700 flex flex-col">
      <CollapsiblePanel
        direction="horizontal"
        isCollapsed={false}
        onToggle={props.onToggle}
        title={props.activePanel === 'preview' ? 'Live Preview' : 'AI Assistant'}
      >
        {/* Panel Tabs */}
        <div className="flex border-b border-gray-700 bg-gray-800">
          <button
            onClick={() => props.setActivePanel('preview')}
            className={`flex-1 px-4 py-2 text-xs font-medium ${
              props.activePanel === 'preview'
                ? 'bg-gray-900 text-white border-b-2 border-blue-500'
                : 'text-gray-400 hover:text-white hover:bg-gray-700'
            }`}
          >
            <Play size={12} className="inline mr-2" />
            Live Preview
          </button>
          <button
            onClick={() => props.setActivePanel('ai')}
            className={`flex-1 px-4 py-2 text-xs font-medium ${
              props.activePanel === 'ai'
                ? 'bg-gray-900 text-white border-b-2 border-blue-500'
                : 'text-gray-400 hover:text-white hover:bg-gray-700'
            }`}
          >
            🤖 AI Assistant
          </button>
        </div>

        {/* Panel Content */}
        <div className="flex-1 overflow-hidden">
          {props.activePanel === 'preview' ? (
            <LivePreview activeTab={props.activeTab} />
          ) : (
            <AIAssistant
              activeAgent={props.activeAgent}
              setActiveAgent={props.setActiveAgent}
            />
          )}
        </div>
      </CollapsiblePanel>
    </div>
  );
}
EOF

cat > src/components/panels/BottomTerminal.tsx << 'EOF'
import { CollapsiblePanel } from '../utils/CollapsiblePanel';
import { Terminal } from '../Terminal';

interface BottomTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function BottomTerminal({ isCollapsed, onToggle }: BottomTerminalProps) {
  return (
    <div className={`border-t border-gray-700 bg-gray-900 transition-all duration-200 ${
      isCollapsed ? 'h-8' : 'h-48'
    }`}>
      <CollapsiblePanel
        direction="vertical"
        isCollapsed={isCollapsed}
        onToggle={onToggle}
        title="Terminal"
      >
        <Terminal />
      </CollapsiblePanel>
    </div>
  );
}
EOF

echo "✅ Panel компоненты созданы"

# ============================================================================
# 5. СОЗДАТЬ УТИЛИТЫ
# ============================================================================

mkdir -p src/components/utils

cat > src/components/utils/ResizableLayout.tsx << 'EOF'
import { ReactNode } from 'react';

interface ResizableLayoutProps {
  panelState: {
    leftCollapsed: boolean;
    rightCollapsed: boolean;
    terminalCollapsed: boolean;
  };
  children: ReactNode;
}

export function ResizableLayout({ children }: ResizableLayoutProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <div className="flex-1 flex overflow-hidden">
        {children}
      </div>
    </div>
  );
}
EOF

echo "✅ Utility компоненты созданы"

# ============================================================================
# 6. СОЗДАТЬ FEATURE КОМПОНЕНТЫ (ПРИМЕР UPLOADER)
# ============================================================================

mkdir -p src/components/features

cat > src/components/features/FileUploader.tsx << 'EOF'
import { useState, useRef } from 'react';
import { Upload, FolderPlus, FileText, Folder } from 'lucide-react';

interface FileUploaderProps {
  onFileUpload: (files: File[]) => void;
  onFolderUpload: (folder: FileList) => void;
}

/**
 * FileUploader - отдельный компонент
 * Не затирается при обновлениях App.tsx
 * Подключается через импорт
 */
export function FileUploader({ onFileUpload, onFolderUpload }: FileUploaderProps) {
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const folderInputRef = useRef<HTMLInputElement>(null);

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDragIn = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  };

  const handleDragOut = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    const files = Array.from(e.dataTransfer.files);
    if (files.length > 0) {
      onFileUpload(files);
    }
  };

  return (
    <div className="p-3 border-b border-gray-700">
      {/* Quick Actions */}
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-semibold text-gray-300 uppercase">Quick Actions</span>
        <div className="flex space-x-1">
          <button
            onClick={() => fileInputRef.current?.click()}
            className="p-1.5 bg-blue-600 hover:bg-blue-500 rounded text-white"
            title="Upload Files"
          >
            <FileText size={12} />
          </button>
          <button
            onClick={() => folderInputRef.current?.click()}
            className="p-1.5 bg-green-600 hover:bg-green-500 rounded text-white"
            title="Upload Folder"
          >
            <FolderPlus size={12} />
          </button>
        </div>
      </div>

      {/* Drop Zone */}
      <div
        className={`border-2 border-dashed rounded-lg p-4 text-center transition-colors ${
          isDragging
            ? 'border-blue-500 bg-blue-500/10'
            : 'border-gray-600 hover:border-gray-500'
        }`}
        onDragEnter={handleDragIn}
        onDragLeave={handleDragOut}
        onDragOver={handleDrag}
        onDrop={handleDrop}
      >
        <Upload size={24} className="mx-auto mb-2 text-gray-400" />
        <p className="text-xs text-gray-400">
          Drop files here or click upload
        </p>
      </div>

      {/* Hidden Inputs */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        className="hidden"
        onChange={(e) => {
          const files = Array.from(e.target.files || []);
          if (files.length > 0) onFileUpload(files);
        }}
      />
      <input
        ref={folderInputRef}
        type="file"
        // @ts-ignore
        webkitdirectory=""
        className="hidden"
        onChange={(e) => {
          const files = e.target.files;
          if (files) onFolderUpload(files);
        }}
      />
    </div>
  );
}
EOF

echo "✅ FileUploader компонент создан"

# ============================================================================
# 7. ТЕСТИРОВАНИЕ
# ============================================================================

echo "🔨 Тестируем модульную архитектуру..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "🏗️ МОДУЛЬНАЯ АРХИТЕКТУРА ГОТОВА!"
    echo "================================"
    echo ""
    echo "✅ СТРУКТУРА:"
    echo "   • App.tsx → чистый контейнер (только импорты)"
    echo "   • components/layout/ → AppHeader, AppStatusBar"
    echo "   • components/panels/ → LeftSidebar, MainEditor, RightPanel, BottomTerminal"
    echo "   • components/features/ → FileUploader (пример модуля)"
    echo "   • hooks/ → usePanelState, useFileManager"
    echo ""
    echo "✅ ПРИНЦИПЫ:"
    echo "   • Каждый компонент живет отдельно"
    echo "   • App.tsx не затирается - только импорты меняются"
    echo "   • Хочешь добавить функцию → создай компонент + добавь импорт"
    echo "   • Хочешь убрать → убери импорт (файл остается)"
    echo ""
    echo "📦 ПРИМЕР ИСПОЛЬЗОВАНИЯ:"
    echo "   • FileUploader уже подключен в LeftSidebar"
    echo "   • Можно легко отключить: закомментируй импорт"
    echo "   • Можно добавить новый: создай компонент + импорт"
    echo ""
    echo "💻 Запуск: npm run dev"
    echo "🎯 Теперь архитектура масштабируемая!"
else
    echo "❌ Ошибка сборки"
fi