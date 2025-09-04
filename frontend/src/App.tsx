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
