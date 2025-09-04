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
