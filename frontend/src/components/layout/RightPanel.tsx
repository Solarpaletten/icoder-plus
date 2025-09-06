import { useState } from 'react';
import { X, MessageSquare } from 'lucide-react';
import { AIChat } from '../AIChat';

interface RightPanelProps {
  onToggle: () => void;
}

export function RightPanel({ onToggle }: RightPanelProps) {
  const [activeAgent, setActiveAgent] = useState<'dashka' | 'claudy' | 'both'>('dashka');
  
  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="h-8 flex items-center justify-between px-3 bg-gray-750 border-b border-gray-700">
        <div className="flex items-center space-x-2">
          <MessageSquare size={14} className="text-gray-300" />
          <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">
            AI Assistant
          </span>
        </div>
        <button
          onClick={onToggle}
          className="p-1 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
          title="Hide AI Assistant"
        >
          <X size={12} />
        </button>
      </div>

      {/* AI Chat */}
      <div className="flex-1 overflow-hidden">
        <AIChat 
          activeAgent={activeAgent}
          onAgentChange={setActiveAgent}
        />
      </div>
    </div>
  );
}
