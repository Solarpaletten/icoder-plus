import React, { useEffect, useRef, useState } from 'react'
import { Terminal as XTerm } from 'xterm'
import { FitAddon } from 'xterm-addon-fit'
import { WebLinksAddon } from 'xterm-addon-web-links'
import { X, Maximize2, Minus, Copy, Settings } from 'lucide-react'
import 'xterm/css/xterm.css'

const Terminal = ({ 
  isOpen, 
  onToggle,
  fileTree = [],
  activeFile = null,
  onOpenFile,
  onRunBuild 
}) => {
  const terminalRef = useRef(null)
  const xtermRef = useRef(null)
  const fitAddonRef = useRef(null)
  const [commandHistory, setCommandHistory] = useState([])
  const [historyIndex, setHistoryIndex] = useState(-1)
  const [currentInput, setCurrentInput] = useState('')

  // Terminal commands implementation
  const commands = {
    help: () => {
      return `Available commands:
  📁 ls                    - List files and folders
  👁️  cat <filename>       - Display file content
  ✏️  code <filename>      - Open file in editor
  📂 pwd                   - Show current directory
  🧹 clear                 - Clear terminal
  🔧 npm run build         - Build project
  🔧 npm run dev          - Development server info
  ❓ help                  - Show this help
  
Use ↑/↓ arrows for command history`
    },

    ls: () => {
      const formatTree = (items, indent = '') => {
        return items.map(item => {
          const icon = item.type === 'folder' ? '📁' : '📄'
          const result = `${indent}${icon} ${item.name}`
          if (item.type === 'folder' && item.children && item.expanded) {
            return result + '\n' + formatTree(item.children, indent + '  ')
          }
          return result
        }).join('\n')
      }
      
      return formatTree(fileTree)
    },

    pwd: () => {
      return '/workspace/icoder-plus'
    },

    cat: (filename) => {
      if (!filename) {
        return 'Usage: cat <filename>'
      }
      
      const findFile = (items, name) => {
        for (const item of items) {
          if (item.name === name && item.type === 'file') {
            return item
          }
          if (item.children) {
            const found = findFile(item.children, name)
            if (found) return found
          }
        }
        return null
      }

      const file = findFile(fileTree, filename)
      if (!file) {
        return `cat: ${filename}: No such file`
      }

      return file.content || '(empty file)'
    },

    code: (filename) => {
      if (!filename) {
        return 'Usage: code <filename>'
      }

      const findFile = (items, name) => {
        for (const item of items) {
          if (item.name === name && item.type === 'file') {
            return item
          }
          if (item.children) {
            const found = findFile(item.children, name)
            if (found) return found
          }
        }
        return null
      }

      const file = findFile(fileTree, filename)
      if (!file) {
        return `code: ${filename}: No such file`
      }

      onOpenFile && onOpenFile(file)
      return `Opening ${filename} in editor...`
    },

    clear: () => {
      xtermRef.current?.clear()
      return null
    },

    'npm run build': () => {
      onRunBuild && onRunBuild()
      return `🔨 Building project...
📦 Bundling assets...
✅ Build completed successfully!
📁 Output: dist/
🌐 Ready for deployment`
    },

    'npm run dev': () => {
      return `🚀 Development server running:
📡 Local:   http://localhost:5173/
🌍 Network: http://192.168.1.100:5173/
⚡ Hot reload enabled
✅ Ready in 1.2s`
    }
  }

  // Execute command
  const executeCommand = (input) => {
    const trimmed = input.trim()
    if (!trimmed) return

    // Add to history
    setCommandHistory(prev => [...prev, trimmed])
    setHistoryIndex(-1)

    // Parse command and args
    const parts = trimmed.split(' ')
    const command = parts[0]
    const args = parts.slice(1).join(' ')

    // Execute command
    if (commands[command]) {
      const result = commands[command](args)
      if (result) {
        xtermRef.current?.writeln('\r' + result)
      }
    } else if (commands[trimmed]) {
      const result = commands[trimmed]()
      if (result) {
        xtermRef.current?.writeln('\r' + result)
      }
    } else {
      xtermRef.current?.writeln(`\rCommand not found: ${command}`)
      xtermRef.current?.writeln('Type "help" for available commands')
    }

    // New prompt
    xtermRef.current?.write('\r\n$ ')
  }

  // Initialize terminal
  useEffect(() => {
    if (!terminalRef.current || xtermRef.current) return

    const terminal = new XTerm({
      theme: {
        background: '#0d1117',
        foreground: '#e6edf3',
        cursor: '#58a6ff',
        black: '#21262d',
        red: '#f85149',
        green: '#3fb950',
        yellow: '#ffa348',
        blue: '#58a6ff',
        magenta: '#bc8cff',
        cyan: '#76e3ea',
        white: '#e6edf3',
        brightBlack: '#30363d',
        brightRed: '#ff6b6b',
        brightGreen: '#4ecdc4',
        brightYellow: '#ffe66d',
        brightBlue: '#74b9ff',
        brightMagenta: '#fd79a8',
        brightCyan: '#81ecec',
        brightWhite: '#ffffff'
      },
      fontFamily: 'JetBrains Mono, monospace',
      fontSize: 13,
      fontWeight: 400,
      lineHeight: 1.2,
      cursorBlink: true,
      cursorStyle: 'block',
      scrollback: 1000,
      tabStopWidth: 4
    })

    const fitAddon = new FitAddon()
    const webLinksAddon = new WebLinksAddon()
    
    terminal.loadAddon(fitAddon)
    terminal.loadAddon(webLinksAddon)
    
    terminal.open(terminalRef.current)
    fitAddon.fit()

    // Welcome message
    terminal.writeln('🚀 iCoder Plus Terminal v2.2')
    terminal.writeln('Type "help" for available commands')
    terminal.write('$ ')

    // Handle input
    let currentLine = ''
    terminal.onData((data) => {
      const char = data.charCodeAt(0)

      if (char === 13) { // Enter
        executeCommand(currentLine)
        currentLine = ''
      } else if (char === 127) { // Backspace
        if (currentLine.length > 0) {
          currentLine = currentLine.slice(0, -1)
          terminal.write('\b \b')
        }
      } else if (char === 27) { // Escape sequences (arrows)
        // Handle arrow keys for command history
        if (data === '\u001b[A') { // Up arrow
          if (commandHistory.length > 0) {
            const newIndex = historyIndex === -1 
              ? commandHistory.length - 1 
              : Math.max(0, historyIndex - 1)
            setHistoryIndex(newIndex)
            
            // Clear current line
            terminal.write('\r$ ')
            for (let i = 0; i < currentLine.length; i++) {
              terminal.write(' ')
            }
            
            // Write historical command
            const historicalCmd = commandHistory[newIndex]
            terminal.write('\r$ ' + historicalCmd)
            currentLine = historicalCmd
          }
        } else if (data === '\u001b[B') { // Down arrow
          if (historyIndex > -1) {
            const newIndex = historyIndex + 1
            if (newIndex < commandHistory.length) {
              setHistoryIndex(newIndex)
              
              // Clear current line
              terminal.write('\r$ ')
              for (let i = 0; i < currentLine.length; i++) {
                terminal.write(' ')
              }
              
              // Write historical command
              const historicalCmd = commandHistory[newIndex]
              terminal.write('\r$ ' + historicalCmd)
              currentLine = historicalCmd
            } else {
              setHistoryIndex(-1)
              // Clear line
              terminal.write('\r$ ')
              for (let i = 0; i < currentLine.length; i++) {
                terminal.write(' ')
              }
              terminal.write('\r$ ')
              currentLine = ''
            }
          }
        }
      } else if (char >= 32) { // Printable characters
        currentLine += data
        terminal.write(data)
      }
    })

    xtermRef.current = terminal
    fitAddonRef.current = fitAddon

    // Resize on window resize
    const handleResize = () => {
      if (fitAddon && terminal) {
        setTimeout(() => fitAddon.fit(), 100)
      }
    }

    window.addEventListener('resize', handleResize)
    
    return () => {
      window.removeEventListener('resize', handleResize)
      terminal.dispose()
    }
  }, [isOpen])

  // Fit terminal when opened/closed
  useEffect(() => {
    if (isOpen && fitAddonRef.current) {
      setTimeout(() => {
        fitAddonRef.current.fit()
      }, 100)
    }
  }, [isOpen])

  if (!isOpen) return null

  return (
    <div className="terminal-panel">
      <div className="terminal-header">
        <div className="terminal-title">
          <span>⚡ TERMINAL</span>
        </div>
        <div className="terminal-controls">
          <button 
            className="terminal-control-btn"
            title="Copy"
          >
            <Copy size={14} />
          </button>
          <button 
            className="terminal-control-btn"
            title="Settings"
          >
            <Settings size={14} />
          </button>
          <button 
            className="terminal-control-btn"
            onClick={onToggle}
            title="Close Terminal"
          >
            <X size={14} />
          </button>
        </div>
      </div>
      
      <div 
        ref={terminalRef} 
        className="terminal-content"
        style={{ 
          width: '100%', 
          height: '100%',
          backgroundColor: '#0d1117'
        }}
      />
    </div>
  )
}

export default Terminal
