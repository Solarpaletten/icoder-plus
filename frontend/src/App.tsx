import { useState } from 'react';
import { 
  Menu, 
  ChevronDown, 
  ChevronUp, 
  Play, 
  Code, 
  Eye,
  MessageSquare,
  Settings,
  Search,
  Plus,
  Folder,
  X
} from 'lucide-react';
import { FileTree } from './components/FileTree';
import { Editor } from './components/Editor';
import { AIAssistant } from './components/AIAssistant';
import { Terminal } from './components/Terminal';
import { LivePreview } from './components/LivePreview';
import { useFileManager } from './hooks/useFileManager';
import type { AgentType } from './types';

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true);
  const [rightPanelOpen, setRightPanelOpen] = useState(true);
  const [terminalOpen, setTerminalOpen] = useState(true);
  const [activeAgent, setActiveAgent] = useState<AgentType>('claudy');
  const [activeRightPanel, setActiveRightPanel] = useState<'ai' | 'preview'>('preview');

  const fileManager = useFileManager();

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white">
      {/* IDE Header */}
      <header className="h-10 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4">
        <div className="flex items-center space-x-4">
          <button 
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            className="p-1.5 hover:bg-gray-700 rounded"
          >
            <Menu size={16} />
          </button>
          
          <div className="flex items-center space-x-2">
            <span className="text-sm font-semibold text-blue-400">iCoder Plus v2.2</span>
            <span className="text-xs text-gray-400">AI IDE with Live Preview</span>
          </div>
        </div>

        <div className="flex items-center space-x-4">
          <div className="text-sm text-green-400">
            {fileManager.activeTab ? fileManager.activeTab.name : 'No file selected'}
          </div>
          
          <button 
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            className="text-xs text-blue-400 hover:text-blue-300 px-2 py-1 rounded hover:bg-gray-700"
          >
            {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Assistant)'}
          </button>
        </div>
      </header>

      {/* Main IDE Content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left Sidebar */}
        {leftPanelOpen && (
          <div className="w-80 bg-gray-800 border-r border-gray-700 flex flex-col">
            {/* Explorer Header */}
            <div className="h-8 bg-gray-750 border-b border-gray-700 flex items-center justify-between px-3">
              <span className="text-xs uppercase font-semibold text-gray-300 tracking-wide">Explorer</span>
              <div className="flex space-x-1">
                <button 
                  onClick={() => fileManager.createFile(null, 'untitled.js', '// New JavaScript file\nconsole.log("Hello World!");')}
                  className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                  title="New File"
                >
                  <Plus size={12} />
                </button>
                <button 
                  onClick={() => fileManager.createFolder(null, 'New Folder')}
                  className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
                  title="New Folder"
                >
                  <Folder size={12} />
                </button>
              </div>
            </div>
            
            {/* Search */}
            <div className="p-2 border-b border-gray-700">
              <div className="relative">
                <Search size={12} className="absolute left-2 top-2 text-gray-500" />
                <input
                  type="text"
                  placeholder="Search files..."
                  value={fileManager.searchQuery}
                  onChange={(e) => fileManager.setSearchQuery(e.target.value)}
                  className="w-full pl-7 pr-2 py-1.5 text-xs bg-gray-900 border border-gray-600 rounded focus:border-blue-500 focus:outline-none"
                />
              </div>
            </div>

            {/* File Tree */}
            <div className="flex-1 overflow-y-auto">
              <FileTree {...fileManager} />
            </div>
          </div>
        )}

        {/* Center - Editor Area */}
        <div className="flex-1 flex flex-col">
          <Editor {...fileManager} />
        </div>

        {/* Right Panel */}
        {rightPanelOpen && (
          <div className="w-96 bg-gray-800 border-l border-gray-700 flex flex-col">
            {/* Right Panel Tabs */}
            <div className="h-8 bg-gray-750 border-b border-gray-700 flex">
              <button
                onClick={() => setActiveRightPanel('preview')}
                className={`flex-1 px-3 py-1 text-xs font-medium border-r border-gray-700 ${
                  activeRightPanel === 'preview' 
                    ? 'bg-gray-900 text-white' 
                    : 'text-gray-400 hover:text-white hover:bg-gray-700'
                }`}
              >
                <Eye size={12} className="inline mr-1" />
                Live Preview
              </button>
              <button
                onClick={() => setActiveRightPanel('ai')}
                className={`flex-1 px-3 py-1 text-xs font-medium ${
                  activeRightPanel === 'ai' 
                    ? 'bg-gray-900 text-white' 
                    : 'text-gray-400 hover:text-white hover:bg-gray-700'
                }`}
              >
                <MessageSquare size={12} className="inline mr-1" />
                AI Assistant
              </button>
            </div>

            {/* Panel Content */}
            <div className="flex-1 overflow-hidden">
              {activeRightPanel === 'preview' ? (
                <LivePreview activeTab={fileManager.activeTab} />
              ) : (
                <AIAssistant 
                  activeAgent={activeAgent}
                  setActiveAgent={setActiveAgent}
                />
              )}
            </div>
          </div>
        )}
      </div>

      {/* Bottom Terminal */}
      <div className={`border-t border-gray-700 bg-gray-900 transition-all duration-200 ${
        terminalOpen ? 'h-48' : 'h-8'
      }`}>
        <div className="h-8 bg-gray-800 flex items-center justify-between px-3 border-b border-gray-700">
          <span className="text-xs uppercase font-semibold text-gray-300 tracking-wide">Terminal</span>
          <button 
            onClick={() => setTerminalOpen(!terminalOpen)}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
          >
            {terminalOpen ? <ChevronDown size={14} /> : <ChevronUp size={14} />}
          </button>
        </div>
        {terminalOpen && (
          <div className="flex-1 overflow-hidden">
            <Terminal />
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
