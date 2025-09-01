import express from 'express'
import { createServer } from 'http'
import { Server } from 'socket.io'
import cors from 'cors'
import helmet from 'helmet'
import dotenv from 'dotenv'
import pty from 'node-pty'
import winston from 'winston'
import { aiRouter } from './routes/ai.js'
import { terminalRouter } from './routes/terminal.js'

dotenv.config()

const app = express()
const server = createServer(app)
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "*",
    methods: ["GET", "POST"]
  }
})

// Logger setup
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
})

// Middleware
app.use(helmet())
app.use(cors())
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
  })
})

// API Routes
app.use('/api/ai', aiRouter)
app.use('/api/terminal', terminalRouter)

// Terminal WebSocket handling
const terminals: Map<string, any> = new Map()

io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`)

  socket.on('terminal-command', ({ command, cwd }) => {
    try {
      // Create new terminal session if doesn't exist
      if (!terminals.has(socket.id)) {
        const term = pty.spawn(process.platform === 'win32' ? 'cmd.exe' : 'bash', [], {
          name: 'xterm-color',
          cols: 80,
          rows: 24,
          cwd: cwd || process.cwd(),
          env: process.env
        })

        // Handle terminal output
        term.on('data', (data: string) => {
          socket.emit('terminal-output', data)
        })

        // Handle terminal exit
        term.on('exit', (code: number) => {
          terminals.delete(socket.id)
          socket.emit('terminal-output', `\r\n\x1b[31mProcess exited with code ${code}\x1b[0m\r\n`)
          socket.emit('terminal-output', '$ ')
        })

        terminals.set(socket.id, term)
      }

      const terminal = terminals.get(socket.id)
      if (terminal) {
        // Execute built-in commands
        switch (command.toLowerCase()) {
          case 'clear':
            socket.emit('terminal-output', '\x1b[2J\x1b[3J\x1b[H')
            socket.emit('terminal-output', '$ ')
            break
          
          case 'help':
            socket.emit('terminal-output', '\r\n\x1b[32mAvailable commands:\x1b[0m\r\n')
            socket.emit('terminal-output', '  ls      - List files\r\n')
            socket.emit('terminal-output', '  cat     - Display file content\r\n')
            socket.emit('terminal-output', '  pwd     - Current directory\r\n')
            socket.emit('terminal-output', '  clear   - Clear terminal\r\n')
            socket.emit('terminal-output', '  npm     - Node package manager\r\n')
            socket.emit('terminal-output', '  git     - Git commands\r\n')
            socket.emit('terminal-output', '\r\n$ ')
            break
          
          default:
            // Execute command in terminal
            terminal.write(command + '\r')
        }
      }
    } catch (error) {
      logger.error('Terminal command error:', error)
      socket.emit('terminal-error', error.message)
    }
  })

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`)
    // Clean up terminal session
    if (terminals.has(socket.id)) {
      const terminal = terminals.get(socket.id)
      terminal.kill()
      terminals.delete(socket.id)
    }
  })
})

const PORT = process.env.PORT || 3000

server.listen(PORT, () => {
  logger.info(`🚀 iCoder Plus Backend v2.0.0 running on port ${PORT}`)
  logger.info(`🌐 Health check: http://localhost:${PORT}/health`)
})
