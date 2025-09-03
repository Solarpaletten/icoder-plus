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
      const BACKEND_URL = process.env.VITE_API_URL || 'http://localhost:3008'
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
