import React, { useState, useRef, useEffect } from 'react'
import { MessageCircle, Send, Copy, Trash2, User, Bot, Code2, Building } from 'lucide-react'
import { askAI } from '../services/aiService'

const AIAssistants = ({ activeFile, fileContent }) => {
  const [isOpen, setIsOpen] = useState(false)
  const [activeAgent, setActiveAgent] = useState('dashka')
  const [messages, setMessages] = useState([])
  const [input, setInput] = useState('')
  const [isTyping, setIsTyping] = useState(false)
  const messagesEndRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSendMessage = async () => {
    if (!input.trim() || isTyping) return

    const userMessage = {
      id: Date.now(),
      role: 'user',
      content: input,
      timestamp: new Date().toLocaleTimeString()
    }

    setMessages(prev => [...prev, userMessage])
    setInput('')
    setIsTyping(true)

    try {
      const response = await askAI({
        agent: activeAgent,
        message: input,
        code: fileContent,
        fileName: activeFile?.name,
        context: {
          fileType: activeFile?.name?.split('.').pop(),
          lineCount: fileContent?.split('\n').length || 0
        }
      })

      const aiMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        agent: activeAgent,
        content: response.message || response,
        timestamp: new Date().toLocaleTimeString()
      }

      setMessages(prev => [...prev, aiMessage])
    } catch (error) {
      const errorMessage = {
        id: Date.now() + 1,
        role: 'error',
        content: `❌ Ошибка: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }
      setMessages(prev => [...prev, errorMessage])
    }

    setIsTyping(false)
  }

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage()
    }
  }

  const copyMessage = async (content) => {
    try {
      await navigator.clipboard.writeText(content)
    } catch (err) {
      console.error('Failed to copy:', err)
    }
  }

  const clearChat = () => {
    setMessages([])
  }

  const examplePrompts = {
    dashka: [
      "Как улучшить архитектуру этого кода?",
      "Есть ли проблемы с производительностью?",
      "Какие паттерны проектирования применить?",
      "Как оптимизировать структуру проекта?"
    ],
    claudy: [
      "Создай компонент для кнопки",
      "Напиши тесты для этой функции",
      "Добавь TypeScript типы",
      "Создай CSS стили для этого компонента"
    ]
  }

  if (!isOpen) {
    return (
      <button
        className="ai-toggle-btn"
        onClick={() => setIsOpen(true)}
        title="Open AI Assistant"
      >
        <MessageCircle size={20} />
      </button>
    )
  }

  return (
    <div className="ai-assistant-panel">
      <div className="ai-header">
        <div className="ai-title">
          <MessageCircle size={16} />
          <span>AI ASSISTANT</span>
        </div>
        <div className="ai-actions">
          <button onClick={clearChat} title="Clear Chat">
            <Trash2 size={14} />
          </button>
          <button onClick={() => setIsOpen(false)} title="Close">
            <X size={14} />
          </button>
        </div>
      </div>

      <div className="agent-selector">
        <button
          className={`agent-btn ${activeAgent === 'dashka' ? 'active' : ''}`}
          onClick={() => setActiveAgent('dashka')}
        >
          <Architecture size={16} />
          <div>
            <div>Dashka</div>
            <small>Architect</small>
          </div>
        </button>
        <button
          className={`agent-btn ${activeAgent === 'claudy' ? 'active' : ''}`}
          onClick={() => setActiveAgent('claudy')}
        >
          <Code2 size={16} />
          <div>
            <div>Claudy</div>
            <small>Generator</small>
          </div>
        </button>
      </div>

      <div className="chat-messages">
        {messages.length === 0 && (
          <div className="welcome-message">
            <div className="agent-avatar">
              {activeAgent === 'dashka' ? <Architecture size={24} /> : <Code2 size={24} />}
            </div>
            <h3>
              {activeAgent === 'dashka' ? 'Dashka (Architect)' : 'Claudy (Generator)'}
            </h3>
            <p>
              {activeAgent === 'dashka' 
                ? 'Анализирую архитектуру, планирую структуру, даю советы по коду'
                : 'Генерирую компоненты, создаю код, помогаю с разработкой'
              }
            </p>
            <div className="example-prompts">
              {examplePrompts[activeAgent].map((prompt, index) => (
                <button
                  key={index}
                  className="example-prompt"
                  onClick={() => setInput(prompt)}
                >
                  {prompt}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((message) => (
          <div key={message.id} className={`message ${message.role}`}>
            <div className="message-header">
              <div className="message-avatar">
                {message.role === 'user' ? (
                  <User size={16} />
                ) : message.role === 'error' ? (
                  <span>❌</span>
                ) : message.agent === 'dashka' ? (
                  <Architecture size={16} />
                ) : (
                  <Code2 size={16} />
                )}
              </div>
              <span className="message-time">{message.timestamp}</span>
              <button
                className="copy-btn"
                onClick={() => copyMessage(message.content)}
                title="Copy message"
              >
                <Copy size={12} />
              </button>
            </div>
            <div className="message-content">
              {message.content}
            </div>
          </div>
        ))}

        {isTyping && (
          <div className="message assistant typing">
            <div className="message-header">
              <div className="message-avatar">
                {activeAgent === 'dashka' ? <Architecture size={16} /> : <Code2 size={16} />}
              </div>
              <span>Typing...</span>
            </div>
            <div className="typing-indicator">
              <div className="dot"></div>
              <div className="dot"></div>
              <div className="dot"></div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      <div className="chat-input">
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={handleKeyPress}
          placeholder={`Спросите ${activeAgent === 'dashka' ? 'Dashka' : 'Claudy'} о коде...`}
          disabled={isTyping}
        />
        <button
          onClick={handleSendMessage}
          disabled={!input.trim() || isTyping}
          className="send-btn"
        >
          <Send size={16} />
        </button>
      </div>
    </div>
  )
}

export default AIAssistants
