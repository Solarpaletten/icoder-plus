import React, { useState } from 'react';
import { Bot, Sparkles, MessageSquare, Copy, Trash2 } from 'lucide-react';
import type { AgentType } from '../../types';

export const RightPanel: React.FC = () => {
  const [activeAgent, setActiveAgent] = useState<AgentType>('dashka');
  const [messages, setMessages] = useState<Array<{
    id: string;
    text: string;
    agent: AgentType;
    timestamp: Date;
    isUser: boolean;
  }>>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const sendMessage = async () => {
    if (!input.trim()) return;

    const userMessage = {
      id: Date.now().toString(),
      text: input,
      agent: activeAgent,
      timestamp: new Date(),
      isUser: true,
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    // Simulate AI response
    setTimeout(() => {
      const response = {
        id: (Date.now() + 1).toString(),
        text: getAgentResponse(activeAgent, input),
        agent: activeAgent,
        timestamp: new Date(),
        isUser: false,
      };
      setMessages(prev => [...prev, response]);
      setIsLoading(false);
    }, 1000 + Math.random() * 2000);
  };

  const getAgentResponse = (agent: AgentType, input: string): string => {
    const responses = {
      dashka: [
        "I'll analyze the architecture patterns in your codebase...",
        "Consider implementing a more modular structure here.",
        "This code could benefit from dependency injection patterns.",
        "Let me review the performance implications of this approach.",
      ],
      claudy: [
        "I can help generate that component for you!",
        "Here's an optimized version of your function:",
        "Let me create a TypeScript interface for this data structure.",
        "I'll build a responsive design for this component.",
      ],
      both: [
        "Dashka: From an architecture perspective... \nClaudy: And for implementation...",
        "Both agents are analyzing your request...",
      ]
    };
    
    const agentResponses = responses[agent];
    return agentResponses[Math.floor(Math.random() * agentResponses.length)];
  };

  const getAgentColor = (agent: AgentType) => {
    switch (agent) {
      case 'dashka': return 'border-l-blue-500';
      case 'claudy': return 'border-l-green-500';
      case 'both': return 'border-l-purple-500';
    }
  };

  const getAgentIcon = (agent: AgentType) => {
    switch (agent) {
      case 'dashka': return <Bot size={16} className="text-blue-400" />;
      case 'claudy': return <Sparkles size={16} className="text-green-400" />;
      case 'both': return <MessageSquare size={16} className="text-purple-400" />;
    }
  };

  return (
    <div className="w-80 bg-gray-900 border-l border-gray-700 flex flex-col h-full">
      {/* AI Agent Selector */}
      <div className="p-4 border-b border-gray-700">
        <h3 className="text-sm font-medium text-gray-300 mb-3">AI ASSISTANTS</h3>
        <div className="flex gap-1">
          {(['dashka', 'claudy', 'both'] as AgentType[]).map((agent) => (
            <button
              key={agent}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded transition-colors
                ${activeAgent === agent 
                  ? 'bg-blue-600 text-white' 
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                }`}
              onClick={() => setActiveAgent(agent)}
            >
              {agent === 'dashka' ? 'Dashka' : agent === 'claudy' ? 'Claudy' : 'Both'}
            </button>
          ))}
        </div>
        <div className="text-xs text-gray-400 mt-2">
          Active: {activeAgent === 'dashka' ? '🔵 Architect' : activeAgent === 'claudy' ? '🟢 Generator' : '🟣 Multi-Agent'}
        </div>
      </div>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex gap-3 ${message.isUser ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] p-3 rounded-lg text-sm
                ${message.isUser 
                  ? 'bg-blue-600 text-white' 
                  : `bg-gray-700 text-gray-100 border-l-2 ${getAgentColor(message.agent)}`
                }`}
            >
              {!message.isUser && (
                <div className="flex items-center gap-2 mb-1">
                  {getAgentIcon(message.agent)}
                  <span className="text-xs font-medium">
                    {message.agent === 'dashka' ? 'Dashka' : message.agent === 'claudy' ? 'Claudy' : 'Multi-Agent'}
                  </span>
                </div>
              )}
              <div className="whitespace-pre-wrap">{message.text}</div>
              <div className="text-xs opacity-60 mt-1">
                {message.timestamp.toLocaleTimeString()}
              </div>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="flex gap-3">
            <div className="bg-gray-700 text-gray-100 p-3 rounded-lg text-sm border-l-2 border-l-gray-500">
              <div className="flex items-center gap-2 mb-1">
                {getAgentIcon(activeAgent)}
                <span className="text-xs font-medium">Thinking...</span>
              </div>
              <div className="flex gap-1">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Input Area */}
      <div className="p-4 border-t border-gray-700">
        <div className="flex gap-2">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={`Ask ${activeAgent === 'dashka' ? 'Dashka' : activeAgent === 'claudy' ? 'Claudy' : 'both assistants'}...`}
            className="flex-1 bg-gray-700 text-gray-100 rounded px-3 py-2 text-sm resize-none"
            rows={2}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
              }
            }}
          />
          <button
            onClick={sendMessage}
            disabled={!input.trim() || isLoading}
            className="px-3 py-2 bg-blue-600 text-white rounded text-sm font-medium 
                     disabled:opacity-50 disabled:cursor-not-allowed hover:bg-blue-700"
          >
            Send
          </button>
        </div>
        
        <div className="flex gap-2 mt-2">
          <button
            onClick={() => setMessages([])}
            className="text-xs text-gray-400 hover:text-gray-200 flex items-center gap-1"
          >
            <Trash2 size={12} />
            Clear
          </button>
        </div>
      </div>
    </div>
  );
};
