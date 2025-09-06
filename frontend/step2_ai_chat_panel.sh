#!/bin/bash

echo "🔧 ШАГ 2: AI CHAT PANEL"
echo "======================="
echo "Добавляем полнофункциональный чат под кнопками Dashka/Claudy"

# ============================================================================
# 1. СОЗДАТЬ AI CHAT КОМПОНЕНТ
# ============================================================================

cat > src/components/AIChat.tsx << 'EOF'
import { useState, useRef, useEffect } from 'react';
import { Send, Bot, Sparkles, User, Trash2, Copy, RotateCcw } from 'lucide-react';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  agent: 'dashka' | 'claudy' | 'both';
  timestamp: Date;
}

interface AIChatProps {
  activeAgent: 'dashka' | 'claudy' | 'both';
  onAgentChange: (agent: 'dashka' | 'claudy' | 'both') => void;
}

export function AIChat({ activeAgent, onAgentChange }: AIChatProps) {
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: '1',
      role: 'assistant',
      content: 'Привет! Я Dashka - ваш архитектор кода и ревьюер. Готова помочь с проектированием и анализом кода.',
      agent: 'dashka',
      timestamp: new Date()
    },
    {
      id: '2', 
      role: 'assistant',
      content: 'А я Claudy - помогу с генерацией кода и решением задач. Пишите ваши вопросы!',
      agent: 'claudy',
      timestamp: new Date()
    }
  ]);
  
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!inputMessage.trim() || isLoading) return;

    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: inputMessage,
      agent: activeAgent,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setIsLoading(true);

    // Симуляция ответа AI (в реальном проекте здесь будет API вызов)
    setTimeout(() => {
      const responses: ChatMessage[] = [];
      
      if (activeAgent === 'dashka' || activeAgent === 'both') {
        responses.push({
          id: `dashka-${Date.now()}`,
          role: 'assistant',
          content: generateDashkaResponse(inputMessage),
          agent: 'dashka',
          timestamp: new Date()
        });
      }
      
      if (activeAgent === 'claudy' || activeAgent === 'both') {
        responses.push({
          id: `claudy-${Date.now()}`,
          role: 'assistant', 
          content: generateClaudyResponse(inputMessage),
          agent: 'claudy',
          timestamp: new Date()
        });
      }

      setMessages(prev => [...prev, ...responses]);
      setIsLoading(false);
    }, 1000 + Math.random() * 2000);
  };

  const generateDashkaResponse = (userInput: string): string => {
    const input = userInput.toLowerCase();
    
    if (input.includes('архитектура') || input.includes('структура')) {
      return 'Рекомендую использовать модульную архитектуру с четким разделением компонентов. Каждый модуль должен иметь единственную ответственность.';
    } else if (input.includes('код') || input.includes('ревью')) {
      return 'При ревью кода обращаю внимание на: читаемость, производительность, безопасность и соответствие стандартам. Покажите код - проанализирую детально.';
    } else if (input.includes('производительность')) {
      return 'Для оптимизации производительности рекомендую: ленивую загрузку, мемоизацию, виртуализацию списков и code splitting.';
    } else {
      return `Интересный вопрос! Как архитектор, предлагаю подходить к решению системно. Расскажите больше деталей о вашей задаче.`;
    }
  };

  const generateClaudyResponse = (userInput: string): string => {
    const input = userInput.toLowerCase();
    
    if (input.includes('код') || input.includes('написать')) {
      return 'Готов сгенерировать код! Укажите технологию (React, TypeScript, Python) и опишите задачу - создам рабочий пример.';
    } else if (input.includes('компонент')) {
      return 'Создам React компонент. Нужен functional или class component? Какой функционал должен быть? Использовать хуки?';
    } else if (input.includes('функция')) {
      return 'Напишу функцию. Укажите входные параметры, ожидаемый результат и язык программирования.';
    } else if (input.includes('исправить') || input.includes('ошибка')) {
      return 'Покажите код с ошибкой - найду проблему и предложу исправление с объяснением.';
    } else {
      return `Понял задачу! Я специализируюсь на генерации кода. Опишите что нужно создать - напишу рабочее решение.`;
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const clearChat = () => {
    setMessages([]);
  };

  const copyMessage = (content: string) => {
    navigator.clipboard.writeText(content);
  };

  const getAgentIcon = (agent: 'dashka' | 'claudy') => {
    return agent === 'dashka' ? 
      <Bot size={16} className="text-blue-400" /> : 
      <Sparkles size={16} className="text-green-400" />;
  };

  const getAgentColor = (agent: 'dashka' | 'claudy') => {
    return agent === 'dashka' ? 'border-blue-500' : 'border-green-500';
  };

  return (
    <div className="h-full flex flex-col">
      {/* Agent Selector */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex space-x-1">
          <button
            onClick={() => onAgentChange('dashka')}
            className={`flex-1 px-3 py-2 rounded text-xs font-medium transition-colors flex items-center justify-center space-x-1 ${
              activeAgent === 'dashka'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            <Bot size={12} />
            <span>Dashka</span>
          </button>
          
          <button
            onClick={() => onAgentChange('claudy')}
            className={`flex-1 px-3 py-2 rounded text-xs font-medium transition-colors flex items-center justify-center space-x-1 ${
              activeAgent === 'claudy'
                ? 'bg-green-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            <Sparkles size={12} />
            <span>Claudy</span>
          </button>
          
          <button
            onClick={() => onAgentChange('both')}
            className={`flex-1 px-3 py-2 rounded text-xs font-medium transition-colors flex items-center justify-center space-x-1 ${
              activeAgent === 'both'
                ? 'bg-purple-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            <span>Both</span>
          </button>
        </div>
        
        {/* Status */}
        <div className="mt-2 text-xs text-gray-400 text-center">
          {activeAgent === 'both' ? 
            'Отправлю сообщение обоим ассистентам' : 
            `Активен: ${activeAgent === 'dashka' ? 'Dashka (Архитектор)' : 'Claudy (Генератор)'}`
          }
        </div>
      </div>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-3 space-y-3">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-xs lg:max-w-md px-3 py-2 rounded-lg text-sm ${
                message.role === 'user'
                  ? 'bg-blue-600 text-white'
                  : `bg-gray-700 text-gray-100 border-l-2 ${getAgentColor(message.agent)}`
              }`}
            >
              {message.role === 'assistant' && (
                <div className="flex items-center space-x-2 mb-1 text-xs opacity-75">
                  {getAgentIcon(message.agent)}
                  <span className="font-medium">
                    {message.agent === 'dashka' ? 'Dashka' : 'Claudy'}
                  </span>
                </div>
              )}
              
              <div className="whitespace-pre-wrap">{message.content}</div>
              
              <div className="flex items-center justify-between mt-2">
                <span className="text-xs opacity-50">
                  {message.timestamp.toLocaleTimeString()}
                </span>
                {message.role === 'assistant' && (
                  <button
                    onClick={() => copyMessage(message.content)}
                    className="p-1 hover:bg-gray-600 rounded"
                    title="Copy message"
                  >
                    <Copy size={10} />
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gray-700 text-gray-100 px-3 py-2 rounded-lg text-sm flex items-center space-x-2">
              <div className="flex space-x-1">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
              </div>
              <span className="text-xs">Thinking...</span>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      <div className="border-t border-gray-700 p-3">
        <div className="flex items-end space-x-2">
          <div className="flex-1">
            <textarea
              ref={textareaRef}
              value={inputMessage}
              onChange={(e) => setInputMessage(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder={`Сообщение для ${activeAgent === 'both' ? 'обоих ассистентов' : activeAgent}...`}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg text-sm text-gray-100 placeholder-gray-400 resize-none focus:outline-none focus:border-blue-500"
              rows={2}
              disabled={isLoading}
            />
          </div>
          
          <div className="flex flex-col space-y-1">
            <button
              onClick={handleSendMessage}
              disabled={!inputMessage.trim() || isLoading}
              className="p-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 disabled:cursor-not-allowed rounded-lg transition-colors"
              title="Send message (Enter)"
            >
              <Send size={16} className="text-white" />
            </button>
            
            <button
              onClick={clearChat}
              className="p-2 bg-gray-600 hover:bg-gray-700 rounded-lg transition-colors"
              title="Clear chat"
            >
              <Trash2 size={16} className="text-gray-300" />
            </button>
          </div>
        </div>
        
        <div className="mt-2 text-xs text-gray-500 text-center">
          Enter - отправить, Shift+Enter - новая строка
        </div>
      </div>
    </div>
  );
}
EOF

echo "✅ AIChat.tsx создан"

# ============================================================================
# 2. ОБНОВИТЬ RightPanel ДЛЯ ИСПОЛЬЗОВАНИЯ AI CHAT
# ============================================================================

cat > src/components/layout/RightPanel.tsx << 'EOF'
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
EOF

echo "✅ RightPanel.tsx обновлен с AI Chat"

# ============================================================================
# 3. ТЕСТИРОВАТЬ СБОРКУ
# ============================================================================

echo "🧪 Тестируем AI Chat Panel..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Шаг 2 завершен: AI Chat Panel создан!"
    echo "🎯 Теперь можно:"
    echo "   • Переключаться между Dashka, Claudy и Both"
    echo "   • Отправлять сообщения (Enter или кнопка)"
    echo "   • Копировать ответы ассистентов"
    echo "   • Очищать историю чата"
    echo "📝 Следующий шаг: Контекстное меню File Manager"
else
    echo "❌ Ошибки в сборке - проверьте консоль"
fi