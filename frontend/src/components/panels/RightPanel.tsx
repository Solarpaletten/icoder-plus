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
