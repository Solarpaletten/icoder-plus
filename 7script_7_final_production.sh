#!/bin/bash

echo "🚀 СКРИПТ #7: FINAL PRODUCTION DEPLOY"
echo "===================================="
echo "Финальный скрипт: Real Terminal + AI Integration + File Upload + Deploy"
echo ""

# Проверка структуры
if [ ! -d "frontend" ]; then
    echo "❌ Ошибка: frontend/ не найден"
    exit 1
fi

cd frontend

echo "📦 Установка финальных зависимостей..."
npm install xterm xterm-addon-fit xterm-addon-web-links socket.io-client axios jszip

# ============================================================================
# 1. REAL TERMINAL COMPONENT С WEBSOCKET
# ============================================================================

echo "🖥️ Создаем реальный терминал с WebSocket..."

cat > src/components/RealTerminal.jsx << 'EOF'
import React, { useEffect, useRef, useState } from 'react'
import { Terminal } from 'xterm'
import { FitAddon } from 'xterm-addon-fit'
import { WebLinksAddon } from 'xterm-addon-web-links'
import io from 'socket.io-client'
import { X, Maximize2, Minus, Copy, Settings, Power } from 'lucide-react'

const RealTerminal = ({ isOpen, onClose }) => {
  const terminalRef = useRef(null)
  const xtermRef = useRef(null)
  const socketRef = useRef(null)
  const fitAddonRef = useRef(null)
  const [isConnected, setIsConnected] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (isOpen && terminalRef.current && !xtermRef.current) {
      // Создать terminal instance
      const terminal = new Terminal({
        theme: {
          background: '#0d1117',
          foreground: '#e6edf3',
          black: '#21262d',
          red: '#f85149',
          green: '#7ee787',
          yellow: '#f0883e',
          blue: '#58a6ff',
          magenta: '#bc8cff',
          cyan: '#39c5cf',
          white: '#b1bac4',
          brightBlack: '#6e7681',
          brightRed: '#ff7b72',
          brightGreen: '#56d364',
          brightYellow: '#e3b341',
          brightBlue: '#79c0ff',
          brightMagenta: '#d2a8ff',
          brightCyan: '#56d4dd',
          brightWhite: '#f0f6fc'
        },
        fontFamily: 'Consolas, "Courier New", monospace',
        fontSize: 14,
        lineHeight: 1.2,
        cursorBlink: true,
        cursorStyle: 'block',
        scrollback: 1000,
        tabStopWidth: 4
      })

      // Addons
      const fitAddon = new FitAddon()
      const webLinksAddon = new WebLinksAddon()
      
      terminal.loadAddon(fitAddon)
      terminal.loadAddon(webLinksAddon)
      
      // Открыть терминал
      terminal.open(terminalRef.current)
      fitAddon.fit()

      // Сохранить ссылки
      xtermRef.current = terminal
      fitAddonRef.current = fitAddon

      // WebSocket соединение с backend
      const BACKEND_URL = process.env.VITE_API_URL || 'http://localhost:3000'
      const socket = io(BACKEND_URL)
      socketRef.current = socket

      // События WebSocket
      socket.on('connect', () => {
        setIsConnected(true)
        setIsLoading(false)
        terminal.writeln('\r\n🚀 \x1b[32miCoder Plus Terminal v2.0\x1b[0m')
        terminal.writeln('Connected to backend server\r\n')
        terminal.write('$ ')
      })

      socket.on('disconnect', () => {
        setIsConnected(false)
        terminal.writeln('\r\n❌ \x1b[31mConnection lost\x1b[0m')
      })

      socket.on('terminal-output', (data) => {
        terminal.write(data)
      })

      socket.on('terminal-error', (error) => {
        terminal.writeln(`\r\n❌ \x1b[31mError: ${error}\x1b[0m\r\n`)
        terminal.write('$ ')
      })

      // Обработка ввода пользователя
      let currentLine = ''
      terminal.onData((data) => {
        switch (data) {
          case '\r': // Enter
            terminal.writeln('')
            if (currentLine.trim()) {
              // Отправить команду на backend
              socket.emit('terminal-command', {
                command: currentLine.trim(),
                cwd: process.cwd()
              })
              
              // История команд можно добавить здесь
            }
            currentLine = ''
            break
            
          case '\x7f': // Backspace
            if (currentLine.length > 0) {
              currentLine = currentLine.slice(0, -1)
              terminal.write('\b \b')
            }
            break
            
          case '\x03': // Ctrl+C
            terminal.writeln('^C')
            terminal.write('$ ')
            currentLine = ''
            break
            
          default:
            if (data >= ' ') {
              currentLine += data
              terminal.write(data)
            }
        }
      })

      // Resize handler
      const handleResize = () => {
        fitAddon.fit()
      }
      window.addEventListener('resize', handleResize)

      // Cleanup
      return () => {
        window.removeEventListener('resize', handleResize)
        socket.disconnect()
        terminal.dispose()
        xtermRef.current = null
        socketRef.current = null
        fitAddonRef.current = null
      }
    }
  }, [isOpen])

  const handleClear = () => {
    if (xtermRef.current) {
      xtermRef.current.clear()
      xtermRef.current.write('$ ')
    }
  }

  const handleCopy = async () => {
    if (xtermRef.current) {
      const selection = xtermRef.current.getSelection()
      if (selection) {
        await navigator.clipboard.writeText(selection)
      }
    }
  }

  if (!isOpen) return null

  return (
    <div className="terminal-container">
      <div className="terminal-header">
        <div className="terminal-title">
          <div className={`connection-dot ${isConnected ? 'connected' : 'disconnected'}`}></div>
          <span>TERMINAL</span>
          {isLoading && <span className="loading">Connecting...</span>}
        </div>
        <div className="terminal-actions">
          <button onClick={handleCopy} title="Copy Selection">
            <Copy size={14} />
          </button>
          <button onClick={handleClear} title="Clear Terminal">
            <Settings size={14} />
          </button>
          <button onClick={onClose} title="Close Terminal">
            <X size={14} />
          </button>
        </div>
      </div>
      <div ref={terminalRef} className="xterm-container" />
    </div>
  )
}

export default RealTerminal
EOF

# ============================================================================
# 2. AI ASSISTANTS С РЕАЛЬНЫМИ API CALLS
# ============================================================================

echo "🤖 Создаем реальных AI ассистентов..."

cat > src/components/AIAssistants.jsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react'
import { MessageCircle, Send, Copy, Trash2, User, Bot, Code2, Architecture } from 'lucide-react'
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
EOF

# ============================================================================
# 3. AI SERVICE ДЛЯ РЕАЛЬНЫХ API ВЫЗОВОВ
# ============================================================================

echo "🔌 Создаем AI Service..."

cat > src/services/aiService.js << 'EOF'
const API_BASE = process.env.VITE_API_URL || 'http://localhost:3000'

export const askAI = async ({ agent, message, code, fileName, context }) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        agent,
        message,
        code,
        fileName,
        context
      }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data.data || data
  } catch (error) {
    console.error('AI Service Error:', error)
    
    // Fallback ответы если API недоступен
    const fallbackResponses = {
      dashka: `🏗️ **Архитектурный анализ** (Fallback mode)\n\n${message.includes('архитектур') ? 'Рекомендую использовать модульную архитектуру с четким разделением ответственности.' : 'Код выглядит хорошо структурированным.'}`,
      claudy: `🤖 **Генерация кода** (Fallback mode)\n\n\`\`\`javascript\n// Сгенерированный код для: ${message}\nconst component = () => {\n  return <div>Hello from Claudy!</div>\n}\n\nexport default component\n\`\`\``
    }
    
    return { message: fallbackResponses[agent] || 'AI недоступен в данный момент.' }
  }
}

export const analyzeCode = async (code, fileName) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/analyze`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code, fileName }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Code Analysis Error:', error)
    return {
      suggestions: ['AI анализ недоступен'],
      issues: [],
      score: 85
    }
  }
}

export const generateCode = async (prompt, context) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ prompt, context }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Code Generation Error:', error)
    return {
      code: '// Генерация кода недоступна',
      explanation: 'AI сервис временно недоступен'
    }
  }
}
EOF

# ============================================================================
# 4. FILE UPLOAD SYSTEM С DRAG & DROP
# ============================================================================

echo "📁 Создаем систему загрузки файлов..."

cat > src/components/FileUpload.jsx << 'EOF'
import React, { useState, useRef } from 'react'
import { Upload, FolderPlus, File, X, Download } from 'lucide-react'
import JSZip from 'jszip'

const FileUpload = ({ onFilesLoaded, onProjectLoaded }) => {
  const [isDragOver, setIsDragOver] = useState(false)
  const [isUploading, setIsUploading] = useState(false)
  const fileInputRef = useRef(null)
  const folderInputRef = useRef(null)

  const handleDragOver = (e) => {
    e.preventDefault()
    setIsDragOver(true)
  }

  const handleDragLeave = (e) => {
    e.preventDefault()
    setIsDragOver(false)
  }

  const handleDrop = async (e) => {
    e.preventDefault()
    setIsDragOver(false)
    setIsUploading(true)

    const files = Array.from(e.dataTransfer.files)
    await processFiles(files)

    setIsUploading(false)
  }

  const handleFileSelect = async (e) => {
    const files = Array.from(e.target.files)
    setIsUploading(true)
    await processFiles(files)
    setIsUploading(false)
    e.target.value = ''
  }

  const handleFolderSelect = async (e) => {
    const files = Array.from(e.target.files)
    setIsUploading(true)
    await processProject(files)
    setIsUploading(false)
    e.target.value = ''
  }

  const processFiles = async (files) => {
    const processedFiles = []

    for (const file of files) {
      if (file.type.startsWith('text/') || 
          file.name.match(/\.(js|jsx|ts|tsx|css|html|json|md|txt|py|java|c|cpp)$/i)) {
        
        try {
          const content = await file.text()
          processedFiles.push({
            name: file.name,
            content: content,
            size: file.size,
            type: file.type,
            lastModified: file.lastModified
          })
        } catch (error) {
          console.error(`Error reading ${file.name}:`, error)
        }
      }
    }

    if (processedFiles.length > 0 && onFilesLoaded) {
      onFilesLoaded(processedFiles)
    }
  }

  const processProject = async (files) => {
    const projectStructure = {}

    for (const file of files) {
      if (file.webkitRelativePath) {
        const pathParts = file.webkitRelativePath.split('/')
        let current = projectStructure

        // Создать структуру папок
        for (let i = 0; i < pathParts.length - 1; i++) {
          const folderName = pathParts[i]
          if (!current[folderName]) {
            current[folderName] = { type: 'folder', children: {} }
          }
          current = current[folderName].children
        }

        // Добавить файл
        const fileName = pathParts[pathParts.length - 1]
        if (file.type.startsWith('text/') || 
            fileName.match(/\.(js|jsx|ts|tsx|css|html|json|md|txt|py|java|c|cpp)$/i)) {
          
          try {
            const content = await file.text()
            current[fileName] = {
              type: 'file',
              content: content,
              size: file.size,
              lastModified: file.lastModified
            }
          } catch (error) {
            console.error(`Error reading ${fileName}:`, error)
          }
        }
      }
    }

    if (Object.keys(projectStructure).length > 0 && onProjectLoaded) {
      onProjectLoaded(projectStructure)
    }
  }

  const exportProject = async (projectData) => {
    const zip = new JSZip()

    const addToZip = (obj, path = '') => {
      Object.entries(obj).forEach(([name, item]) => {
        const currentPath = path ? `${path}/${name}` : name
        
        if (item.type === 'folder') {
          addToZip(item.children, currentPath)
        } else if (item.type === 'file') {
          zip.file(currentPath, item.content)
        }
      })
    }

    addToZip(projectData)

    try {
      const blob = await zip.generateAsync({ type: 'blob' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'iCoder-Plus-Project.zip'
      a.click()
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Export error:', error)
    }
  }

  return (
    <>
      {/* Drag & Drop Overlay */}
      {isDragOver && (
        <div className="drag-overlay">
          <div className="drag-content">
            <Upload size={48} />
            <h3>Drop files or folders here</h3>
            <p>Support: JS, TS, HTML, CSS, JSON, MD, TXT</p>
          </div>
        </div>
      )}

      {/* Upload Zone */}
      <div
        className={`upload-zone ${isDragOver ? 'drag-over' : ''}`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <div className="upload-content">
          {isUploading ? (
            <div className="upload-loading">
              <div className="spinner"></div>
              <p>Uploading files...</p>
            </div>
          ) : (
            <>
              <Upload size={32} />
              <h3>Upload Files or Project</h3>
              <p>Drag & drop files here or click to browse</p>
              
              <div className="upload-actions">
                <button
                  className="upload-btn"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <File size={16} />
                  Select Files
                </button>
                
                <button
                  className="upload-btn"
                  onClick={() => folderInputRef.current?.click()}
                >
                  <FolderPlus size={16} />
                  Select Folder
                </button>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Hidden File Inputs */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        accept=".js,.jsx,.ts,.tsx,.css,.html,.json,.md,.txt,.py,.java,.c,.cpp"
        style={{ display: 'none' }}
        onChange={handleFileSelect}
      />

      <input
        ref={folderInputRef}
        type="file"
        webkitdirectory=""
        style={{ display: 'none' }}
        onChange={handleFolderSelect}
      />
    </>
  )
}

export default FileUpload
EOF

# ============================================================================
# 5. ENVIRONMENT VARIABLES SETUP
# ============================================================================

echo "🔧 Настраиваем environment variables..."

cat > .env.local << 'EOF'
# iCoder Plus Local Development
VITE_API_URL=http://localhost:3000
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
VITE_APP_DESCRIPTION=AI-first IDE with real terminal

# AI Configuration (добавьте ваши ключи)
VITE_OPENAI_API_KEY=your_openai_key_here
VITE_ANTHROPIC_API_KEY=your_anthropic_key_here

# Features
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_REAL_TERMINAL=true
VITE_ENABLE_FILE_UPLOAD=true
VITE_ENABLE_LIVE_PREVIEW=true
EOF

cat > .env.production << 'EOF'
# iCoder Plus Production
VITE_API_URL=https://icoder-plus-backend.vercel.app
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
VITE_APP_DESCRIPTION=AI-first IDE with real terminal

# Features
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_REAL_TERMINAL=true
VITE_ENABLE_FILE_UPLOAD=true
VITE_ENABLE_LIVE_PREVIEW=true
EOF


# ============================================================================
# 7. UPDATED APP.JSX С НОВЫМИ КОМПОНЕНТАМИ
# ============================================================================

echo "🔄 Обновляем главный App.jsx..."

cat > src/App.jsx << 'EOF'
import React, { useState, useEffect } from 'react'
import { 
  PanelLeft, 
  MessageSquare,
  X,
  Menu,
  FileText,
  Settings,
  Terminal as TerminalIcon,
  Upload,
  Play,
  Download
} from 'lucide-react'
import FileTree from './components/FileTree'
import Editor from './components/Editor'
import LivePreview from './components/LivePreview'
import RealTerminal from './components/RealTerminal'
import AIAssistants from './components/AIAssistants'
import FileUpload from './components/FileUpload'
import TopMenu from './components/TopMenu'
import { useFileManager } from './hooks/useFileManager'
import { useCodeRunner } from './hooks/useCodeRunner'
import './styles/globals.css'

function App() {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true)
  const [rightPanelOpen, setRightPanelOpen] = useState(false)
  const [terminalOpen, setTerminalOpen] = useState(false)
  const [uploadModalOpen, setUploadModalOpen] = useState(false)
  
  const { 
    fileTree, 
    openTabs, 
    activeTab, 
    createFile, 
    createFolder, 
    deleteItem, 
    renameItem, 
    setActiveTab, 
    openFile, 
    closeTab, 
    updateFileContent,
    loadProject,
    exportProject
  } = useFileManager()
  
  const { runCode, output, isRunning } = useCodeRunner()

  const handleFilesLoaded = (files) => {
    files.forEach(file => {
      createFile(file.name, file.content)
      openFile(file.name)
    })
  }

  const handleProjectLoaded = (projectStructure) => {
    loadProject(projectStructure)
  }

  const handleRunCode = () => {
    if (activeTab) {
      const content = activeTab.content
      runCode(content, activeTab.name)
    }
  }

  const activeFile = activeTab

  return (
    <div className="ide-container">
      {/* Top Menu */}
      <TopMenu 
        onNewFile={() => createFile('untitled.js', '')}
        onOpenFile={() => setUploadModalOpen(true)}
        onSave={() => {/* Implement save */}}
        onExport={() => exportProject()}
      />

      {/* Main Header */}
      <header className="ide-header">
        <div className="header-left">
          <button 
            className="panel-toggle"
            onClick={() => setLeftPanelOpen(!leftPanelOpen)}
            title="Toggle Explorer"
          >
            <Menu size={16} />
          </button>
          <div className="project-info">
            <span className="project-name">iCoder Plus v2.0</span>
            <span className="project-status">Final Production</span>
          </div>
        </div>
        
        <div className="header-center">
          <div className="quick-actions">
            <button 
              className="quick-btn"
              onClick={handleRunCode}
              disabled={!activeFile || isRunning}
              title="Run Code (Ctrl+R)"
            >
              <Play size={16} />
              {isRunning ? 'Running...' : 'Run'}
            </button>
            
            <button 
              className="quick-btn"
              onClick={() => setUploadModalOpen(true)}
              title="Upload Files"
            >
              <Upload size={16} />
              Upload
            </button>
          </div>
        </div>
        
        <div className="header-right">
          <button 
            className={`panel-toggle ${rightPanelOpen ? 'active' : ''}`}
            onClick={() => setRightPanelOpen(!rightPanelOpen)}
            title="Toggle AI Assistant"
          >
            <MessageSquare size={16} />
            AI
          </button>
        </div>
      </header>

      {/* Main Layout */}
      <div className="ide-main">
        {/* Left Panel - File Explorer */}
        {leftPanelOpen && (
          <aside className="left-panel">
            <div className="panel-header">
              <span>EXPLORER</span>
              <button onClick={() => setLeftPanelOpen(false)}>
                <X size={14} />
              </button>
            </div>
            
            <FileTree 
              fileTree={fileTree}
              onCreateFile={createFile}
              onCreateFolder={createFolder}
              onDeleteItem={deleteItem}
              onRenameItem={renameItem}
              onFileSelect={openFile}
            />
          </aside>
        )}

        {/* Center - Editor Area */}
        <main className="editor-area">
          {/* Editor Tabs */}
          <div className="editor-tabs">
            {openTabs.map(tab => (
              <div 
                key={tab.id}
                className={`tab ${activeTab?.id === tab.id ? 'active' : ''}`}
                onClick={() => setActiveTab(tab.id)}
              >
                <FileText size={14} />
                <span>{tab.name}</span>
                <button 
                  className="tab-close"
                  onClick={(e) => {
                    e.stopPropagation()
                    closeTab(tab.id)
                  }}
                >
                  <X size={12} />
                </button>
              </div>
            ))}
          </div>
          
          {/* Editor Content */}
          <div className="editor-content">
            {activeTab ? (
              <Editor 
                file={activeTab}
                onChange={(content) => updateFileContent(activeTab.id, content)}
                onRun={handleRunCode}
              />
            ) : (
              <div className="editor-placeholder">
                <div className="welcome-message">
                  <h2>🚀 Welcome to iCoder Plus v2.0</h2>
                  <p>AI-powered IDE with real terminal and live preview</p>
                  <div className="quick-start">
                    <button 
                      className="start-btn"
                      onClick={() => setUploadModalOpen(true)}
                    >
                      <Upload size={20} />
                      Upload Project
                    </button>
                    <button 
                      className="start-btn"
                      onClick={() => createFile('demo.js', '// Hello from iCoder Plus!\nconsole.log("Ready to code!");')}
                    >
                      <FileText size={20} />
                      New File
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </main>

        {/* Right Panel - Live Preview */}
        <aside className="right-panel">
          <div className="panel-header">
            <span>LIVE PREVIEW</span>
            <button onClick={() => setRightPanelOpen(false)}>
              <X size={14} />
            </button>
          </div>
          
          <LivePreview 
            code={activeFile?.content || ''}
            fileName={activeFile?.name || ''}
            output={output}
          />
        </aside>
      </div>

      {/* Bottom Terminal */}
      {terminalOpen && (
        <RealTerminal 
          isOpen={terminalOpen}
          onClose={() => setTerminalOpen(false)}
        />
      )}

      {/* AI Assistant */}
      {rightPanelOpen && (
        <AIAssistants 
          activeFile={activeFile}
          fileContent={activeFile?.content}
        />
      )}

      {/* File Upload Modal */}
      {uploadModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h3>Upload Files or Project</h3>
              <button onClick={() => setUploadModalOpen(false)}>
                <X size={20} />
              </button>
            </div>
            
            <FileUpload 
              onFilesLoaded={handleFilesLoaded}
              onProjectLoaded={handleProjectLoaded}
            />
          </div>
        </div>
      )}

      {/* Bottom Status Bar */}
      <footer className="ide-statusbar">
        <div className="statusbar-left">
          <button 
            className={`status-btn ${terminalOpen ? 'active' : ''}`}
            onClick={() => setTerminalOpen(!terminalOpen)}
            title="Toggle Terminal"
          >
            <TerminalIcon size={14} />
            Terminal
          </button>
          
          <span className="status-info">
            {activeFile ? activeFile.name : 'No file selected'}
          </span>
        </div>
        
        <div className="statusbar-right">
          <span className="status-info">
            {activeFile?.name.split('.').pop()?.toUpperCase() || 'PLAIN TEXT'}
          </span>
          <span className="status-info">UTF-8</span>
          <span className="status-info">
            Lines: {activeFile?.content.split('\n').length || 0}
          </span>
        </div>
      </footer>
    </div>
  )
}

export default App
EOF

# ============================================================================
# 8. ФИНАЛЬНЫЕ CSS СТИЛИ
# ============================================================================

echo "🎨 Добавляем финальные CSS стили..."

cat >> src/styles/globals.css << 'EOF'

/* ============================================================================
   FINAL PRODUCTION STYLES - SCRIPT #7
============================================================================ */

/* Real Terminal Styles */
.terminal-container {
  height: 300px;
  background: var(--vscode-panel);
  border-top: 1px solid var(--vscode-border);
  display: flex;
  flex-direction: column;
}

.terminal-header {
  height: 35px;
  padding: 0 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
}

.terminal-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
  font-weight: 600;
  color: var(--vscode-text);
}

.connection-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--vscode-error);
}

.connection-dot.connected {
  background: var(--vscode-success);
}

.terminal-actions {
  display: flex;
  gap: 4px;
}

.terminal-actions button {
  background: transparent;
  border: none;
  color: var(--vscode-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
}

.terminal-actions button:hover {
  color: var(--vscode-text);
  background: var(--vscode-hover);
}

.xterm-container {
  flex: 1;
  padding: 4px;
}

/* AI Assistant Styles */
.ai-toggle-btn {
  position: fixed;
  bottom: 20px;
  right: 20px;
  width: 60px;
  height: 60px;
  background: var(--vscode-accent);
  border: none;
  border-radius: 50%;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 1000;
}

.ai-assistant-panel {
  width: 350px;
  height: 100%;
  background: var(--vscode-sidebar);
  border-left: 1px solid var(--vscode-border);
  display: flex;
  flex-direction: column;
}

.ai-header {
  height: 40px;
  padding: 0 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
}

.ai-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
  font-weight: 600;
  color: var(--vscode-text);
}

.ai-actions {
  display: flex;
  gap: 4px;
}

.ai-actions button {
  background: transparent;
  border: none;
  color: var(--vscode-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
}

.ai-actions button:hover {
  color: var(--vscode-text);
  background: var(--vscode-hover);
}

.agent-selector {
  display: flex;
  padding: 8px;
  gap: 4px;
}

.agent-btn {
  flex: 1;
  padding: 8px;
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  color: var(--vscode-text);
  cursor: pointer;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 11px;
}

.agent-btn.active {
  background: var(--vscode-accent);
  border-color: var(--vscode-accent);
  color: white;
}

.chat-messages {
  flex: 1;
  padding: 12px;
  overflow-y: auto;
}

.welcome-message {
  text-align: center;
  padding: 20px 0;
}

.agent-avatar {
  width: 48px;
  height: 48px;
  background: var(--vscode-accent);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px;
  color: white;
}

.example-prompts {
  margin-top: 16px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.example-prompt {
  padding: 6px 12px;
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  border-radius: 4px;
  color: var(--vscode-text);
  cursor: pointer;
  text-align: left;
  font-size: 11px;
}

.example-prompt:hover {
  background: var(--vscode-hover);
}

.message {
  margin-bottom: 16px;
  padding: 8px;
  border-radius: 6px;
}

.message.user {
  background: var(--vscode-accent);
  color: white;
  margin-left: 20px;
}

.message.assistant {
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  margin-right: 20px;
}

.message.error {
  background: var(--vscode-error);
  color: white;
}

.message-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
  font-size: 10px;
  opacity: 0.7;
}

.message-avatar {
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.copy-btn {
  background: transparent;
  border: none;
  color: currentColor;
  cursor: pointer;
  opacity: 0.5;
  margin-left: auto;
}

.copy-btn:hover {
  opacity: 1;
}

.message-content {
  font-size: 12px;
  line-height: 1.4;
  white-space: pre-wrap;
}

.typing {
  opacity: 0.7;
}

.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 8px 0;
}

.typing-indicator .dot {
  width: 6px;
  height: 6px;
  background: var(--vscode-muted);
  border-radius: 50%;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator .dot:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator .dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.chat-input {
  padding: 12px;
  border-top: 1px solid var(--vscode-border);
  display: flex;
  gap: 8px;
}

.chat-input textarea {
  flex: 1;
  min-height: 36px;
  max-height: 100px;
  padding: 8px;
  background: var(--vscode-editor);
  border: 1px solid var(--vscode-border);
  border-radius: 4px;
  color: var(--vscode-text);
  font-size: 12px;
  resize: vertical;
  font-family: inherit;
}

.chat-input textarea:focus {
  outline: none;
  border-color: var(--vscode-accent);
}

.send-btn {
  background: var(--vscode-accent);
  border: none;
  border-radius: 4px;
  color: white;
  cursor: pointer;
  padding: 8px 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.send-btn:hover:not(:disabled) {
  background: var(--vscode-accent-hover);
}

/* File Upload Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--vscode-sidebar);
  border: 1px solid var(--vscode-border);
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  overflow: hidden;
}

.modal-header {
  padding: 16px;
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-header h3 {
  color: var(--vscode-text);
  font-size: 14px;
  font-weight: 600;
}

.modal-header button {
  background: transparent;
  border: none;
  color: var(--vscode-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 3px;
}

.modal-header button:hover {
  color: var(--vscode-text);
  background: var(--vscode-hover);
}

.drag-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(123, 92, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}

.drag-content {
  text-align: center;
  color: white;
  padding: 40px;
  border: 3px dashed rgba(255, 255, 255, 0.7);
  border-radius: 12px;
  background: rgba(0, 0, 0, 0.2);
}

.drag-content h3 {
  font-size: 24px;
  margin: 16px 0 8px;
}

.drag-content p {
  font-size: 16px;
  opacity: 0.9;
}

.upload-zone {
  padding: 40px;
  margin: 20px;
  border: 2px dashed var(--vscode-border);
  border-radius: 8px;
  text-align: center;
  transition: all 0.3s ease;
}

.upload-zone.drag-over {
  border-color: var(--vscode-accent);
  background: rgba(123, 92, 255, 0.1);
}

.upload-content h3 {
  color: var(--vscode-text);
  margin: 16px 0 8px;
}

.upload-content p {
  color: var(--vscode-muted);
  margin-bottom: 20px;
}

.upload-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.upload-btn {
  padding: 10px 16px;
  background: var(--vscode-accent);
  border: none;
  border-radius: 4px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
}

.upload-btn:hover {
  background: var(--vscode-accent-hover);
}

.upload-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  color: var(--vscode-text);
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--vscode-border);
  border-top: 3px solid var(--vscode-accent);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Header Updates */
.ide-header {
  height: 40px;
  background: var(--vscode-tab);
  border-bottom: 1px solid var(--vscode-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-center {
  display: flex;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.quick-actions {
  display: flex;
  gap: 8px;
}

.quick-btn {
  padding: 6px 12px;
  background: var(--vscode-panel);
  border: 1px solid var(--vscode-border);
  border-radius: 4px;
  color: var(--vscode-text);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
}

.quick-btn:hover:not(:disabled) {
  background: var(--vscode-hover);
}

.quick-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.panel-toggle.active {
  background: var(--vscode-accent);
  color: white;
}

/* Welcome Screen Updates */
.quick-start {
  margin-top: 24px;
  display: flex;
  gap: 16px;
  justify-content: center;
}

.start-btn {
  padding: 12px 20px;
  background: var(--vscode-accent);
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
}

.start-btn:hover {
  background: var(--vscode-accent-hover);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .ai-assistant-panel {
    width: 300px;
  }
  
  .right-panel {
    width: 300px;
  }
}

@media (max-width: 768px) {
  .left-panel {
    width: 250px;
  }
  
  .ai-assistant-panel {
    width: 280px;
  }
  
  .quick-actions {
    display: none;
  }
  
  .modal-content {
    width: 95%;
    margin: 20px;
  }
}

/* Loading and Error States */
.loading {
  color: var(--vscode-warning);
  font-size: 10px;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

/* Code syntax highlighting in messages */
.message-content code {
  background: var(--vscode-editor);
  padding: 2px 4px;
  border-radius: 3px;
  font-family: 'Consolas', 'Courier New', monospace;
  font-size: 11px;
}

.message-content pre {
  background: var(--vscode-editor);
  padding: 8px;
  border-radius: 4px;
  overflow-x: auto;
  margin: 8px 0;
}

.message-content pre code {
  background: none;
  padding: 0;
}
EOF

# ============================================================================
# 9. PACKAGE.JSON UPDATES
# ============================================================================

echo "📦 Обновляем package.json для production..."

cat > package.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "description": "AI-first IDE with real terminal and live preview",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "lucide-react": "^0.263.1",
    "clsx": "^2.0.0",
    "axios": "^1.4.0",
    "socket.io-client": "^4.7.2",
    "xterm": "^5.3.0",
    "xterm-addon-fit": "^0.8.0",
    "xterm-addon-web-links": "^0.9.0",
    "jszip": "^3.10.1",
    "@monaco-editor/react": "^4.5.1",
    "monaco-editor": "^0.44.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-react": "^7.32.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "vite": "^4.4.5",
    "vitest": "^0.34.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# ============================================================================
# 10. VITE CONFIG UPDATE
# ============================================================================

echo "⚙️ Обновляем Vite конфигурацию..."

cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@services': resolve(__dirname, './src/services'),
      '@utils': resolve(__dirname, './src/utils'),
      '@hooks': resolve(__dirname, './src/hooks'),
      '@styles': resolve(__dirname, './src/styles')
    }
  },
  define: {
    global: 'globalThis'
  },
  server: {
    port: 5173,
    host: true,
    open: true,
    proxy: {
      '/api': {
        target: process.env.NODE_ENV === 'production' 
          ? process.env.VITE_API_URL 
          : 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      },
      '/socket.io': {
        target: process.env.NODE_ENV === 'production'
          ? process.env.VITE_API_URL
          : 'http://localhost:3000',
        changeOrigin: true,
        ws: true
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: process.env.NODE_ENV !== 'production',
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          editor: ['monaco-editor', '@monaco-editor/react'],
          terminal: ['xterm', 'xterm-addon-fit', 'xterm-addon-web-links'],
          utils: ['axios', 'socket.io-client', 'jszip', 'clsx']
        },
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    },
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production',
        drop_debugger: true
      }
    }
  },
  optimizeDeps: {
    include: [
      'react', 
      'react-dom', 
      'lucide-react', 
      'axios',
      'socket.io-client',
      'xterm',
      'xterm-addon-fit',
      'xterm-addon-web-links',
      'jszip',
      'monaco-editor/esm/vs/language/typescript/ts.worker',
      'monaco-editor/esm/vs/language/json/json.worker',
      'monaco-editor/esm/vs/editor/editor.worker'
    ]
  }
})
EOF

