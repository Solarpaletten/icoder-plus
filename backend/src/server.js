const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const { createServer } = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const aiRoutes = require('./routes/aiRoutes');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: ['http://localhost:5173', 'https://icoder-solar.onrender.com'],
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3008;

// ============================================================================
// LOGGING SETUP
// ============================================================================
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'icoder-plus-backend' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// ============================================================================
// SECURITY & MIDDLEWARE
// ============================================================================
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: {
    error: 'Too many requests from this IP',
    retryAfter: '15 minutes'
  }
});
app.use('/api/', limiter);

app.use(cors({
  origin: ['http://localhost:5173', 'https://icoder-solar.onrender.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  });
  next();
});

// ============================================================================
// HEALTH CHECK ENDPOINTS
// ============================================================================
app.get('/health', (req, res) => {
  const healthData = {
    status: 'OK',
    service: 'iCoder Plus Backend',
    version: '2.1.1',
    port: PORT,
    timestamp: new Date().toISOString(),
    uptime: Math.round(process.uptime()),
    memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
    node: process.version,
    environment: process.env.NODE_ENV || 'development',
    features: {
      terminal: 'active',
      ai: process.env.OPENAI_API_KEY ? 'ready' : 'no-api-key',
      websocket: 'active',
      logging: 'winston'
    }
  };

  logger.info('Health check requested', healthData);
  res.json(healthData);
});

app.get('/', (req, res) => {
  res.json({
    message: 'iCoder Plus Backend API v2.1.1',
    status: 'running',
    endpoints: {
      health: 'GET /health',
      terminal: 'POST /api/terminal/*',
      ai: 'POST /api/ai/*',
      websocket: 'WS connection available'
    },
    documentation: 'https://github.com/Solarpaletten/icoder-plus'
  });
});

// ============================================================================
// TERMINAL API ENDPOINTS
// ============================================================================
app.post('/api/terminal/execute', (req, res) => {
  const { command } = req.body;

  if (!command) {
    return res.status(400).json({
      success: false,
      error: 'Command is required'
    });
  }

  const cmd = command.trim().toLowerCase();
  let output = '';
  let exitCode = 0;

  try {
    logger.info(`Terminal execute: ${command}`);

    if (cmd === 'ls' || cmd === 'ls -la') {
      output = 'backend/\nfrontend/\npackage.json\nREADME.md\n.gitignore\nnode_modules/\n.env\nsrc/';
    } else if (cmd === 'pwd') {
      output = process.cwd();
    } else if (cmd === 'whoami') {
      output = process.env.USER || process.env.USERNAME || 'user';
    } else if (cmd === 'date') {
      output = new Date().toString();
    } else if (cmd.startsWith('echo ')) {
      output = cmd.substring(5);
    } else if (cmd === 'node --version' || cmd === 'node -v') {
      output = process.version;
    } else if (cmd === 'npm --version') {
      try {
        const { execSync } = require('child_process');
        output = execSync('npm --version', {
          encoding: 'utf8',
          timeout: 3000
        }).trim();
      } catch (error) {
        output = 'npm command not available';
        exitCode = 1;
      }
    } else if (cmd === 'backend status' || cmd === 'status') {
      const memoryUsage = process.memoryUsage();
      output =
        `iCoder Plus Backend Status:\n` +
        `Server: Running on port ${PORT}\n` +
        `Node.js: ${process.version}\n` +
        `Memory: ${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB / ${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB\n` +
        `Uptime: ${Math.round(process.uptime())}s\n` +
        `Environment: ${process.env.NODE_ENV || 'development'}\n` +
        `PID: ${process.pid}\n\n` +
        `APIs:\n` +
        `Terminal API: Active\n` +
        `WebSocket: Active (Socket.IO)\n` +
        `AI API: ${process.env.OPENAI_API_KEY ? 'Ready (OpenAI)' : 'No API key'}\n` +
        `Logging: Winston\n` +
        `Security: Helmet + Rate Limiting`;
    } else if (cmd === 'help' || cmd === '--help') {
      output =
        `iCoder Plus Terminal Commands:\n\n` +
        `File System:\n  ls, ls -la         List files and directories\n  pwd                Show current directory\n\n` +
        `System:\n  whoami             Show current user\n  date               Show current date/time\n  node --version     Show Node.js version\n  npm --version      Show npm version\n\n` +
        `iCoder Plus:\n  backend status     Show detailed backend status\n  help               Show this help message\n\n` +
        `Utilities:\n  echo <text>        Echo text back\n  clear              Clear terminal (frontend)`;
    } else if (cmd === 'clear') {
      output = '[Terminal cleared]';
    } else {
      output =
        `bash: ${cmd}: command not found\n\n` +
        `Available commands: ls, pwd, whoami, date, backend status, help\n` +
        `Try 'help' for full command list`;
      exitCode = 1;
    }

    res.json({
      success: true,
      command,
      output,
      exitCode,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Terminal execution error', { command, error: error.message });
    res.status(500).json({
      success: false,
      error: 'Command execution failed',
      message: error.message,
      command,
      timestamp: new Date().toISOString()
    });
  }
});

app.get('/api/terminal/status', (req, res) => {
  res.json({
    status: 'online',
    service: 'Terminal API',
    version: '1.0.0',
    availableCommands: ['ls', 'pwd', 'whoami', 'date', 'echo', 'node --version', 'npm --version', 'backend status', 'help'],
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// AI API ROUTES
// ============================================================================
app.use('/api/ai', aiRoutes);

// ============================================================================
// WEBSOCKET SETUP FOR REAL-TIME TERMINAL
// ============================================================================
io.on('connection', (socket) => {
  logger.info('WebSocket client connected', { socketId: socket.id });

  socket.emit('connected', {
    message: 'Connected to iCoder Plus Terminal',
    socketId: socket.id,
    timestamp: new Date().toISOString()
  });

  socket.on('terminal_command', (data) => {
    const { command } = data;
    logger.info('WebSocket terminal command', { command, socketId: socket.id });

    socket.emit('terminal_output', {
      command,
      output: `Executed: ${command}\n[WebSocket terminal ready - node-pty integration pending]`,
      timestamp: new Date().toISOString()
    });
  });

  socket.on('disconnect', () => {
    logger.info('WebSocket client disconnected', { socketId: socket.id });
  });
});

// ============================================================================
// ERROR HANDLING
// ============================================================================
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
    availableEndpoints: [
      'GET /health',
      'POST /api/terminal/execute',
      'GET /api/terminal/status',
      'POST /api/ai/chat',
      'GET /api/ai/status'
    ]
  });
});

// ============================================================================
// SERVER STARTUP
// ============================================================================
server.listen(PORT, '0.0.0.0', () => {
  logger.info('iCoder Plus Backend started', {
    port: PORT,
    environment: process.env.NODE_ENV || 'development',
    node: process.version,
    pid: process.pid
  });

  console.log('🚀 iCoder Plus Backend started successfully');
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`💻 Terminal API: http://localhost:${PORT}/api/terminal/*`);
  console.log(`🤖 AI API: http://localhost:${PORT}/api/ai/* (mock mode)`);
  console.log(`🔌 WebSocket: ws://localhost:${PORT}`);
});

module.exports = { app, server, io };