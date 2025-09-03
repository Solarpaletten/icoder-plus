import React from 'react';
import type { AgentType } from '../types';

interface AIAssistantProps {
  activeAgent: AgentType;
  setActiveAgent: (agent: AgentType) => void;
}

export function AIAssistant({ activeAgent, setActiveAgent }: AIAssistantProps) {
  return (
    <div className="h-full flex flex-col">
      <div className="p-3 border-b border-border">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs uppercase font-semibold text-gray-300">AI Assistant</span>
        </div>
        
        <div className="flex gap-1">
          <button
            onClick={() => setActiveAgent('dashka')}
            className={`px-2 py-1 text-xs rounded ${
              activeAgent === 'dashka' 
                ? 'bg-primary text-white' 
                : 'bg-gray-700 hover:bg-gray-600'
            }`}
          >
            Dashka
          </button>
          <button
            onClick={() => setActiveAgent('claudy')}
            className={`px-2 py-1 text-xs rounded ${
              activeAgent === 'claudy' 
                ? 'bg-primary text-white' 
                : 'bg-gray-700 hover:bg-gray-600'
            }`}
          >
            Claudy
          </button>
        </div>
      </div>
      
      <div className="flex-1 p-4 text-center">
        <div className="text-4xl mb-3">
          {activeAgent === 'dashka' ? '🏗️' : '🤖'}
        </div>
        <h4 className="text-sm font-semibold mb-2">
          {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Assistant)'}
        </h4>
        <p className="text-xs text-gray-400 mb-4">
          {activeAgent === 'dashka' 
            ? 'Architecture and code review specialist' 
            : 'Coding and implementation assistant'
          }
        </p>
        
        <div className="bg-gray-800 p-3 rounded text-xs">
          <div className="text-secondary">✅ Backend: api.icoder.swapoil.de</div>
          <div className="text-gray-400 mt-1">🔄 Ready for requests</div>
        </div>
      </div>
    </div>
  );
}
