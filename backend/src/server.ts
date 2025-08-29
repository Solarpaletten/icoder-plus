const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
require('dotenv').config();

const app = express();
const PORT = parseInt(process.env.PORT || '10000', 10);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? true : ['http://localhost:5173','http://localhost:5174','http://127.0.0.1:5173','https://icoder-solar.onrender.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: false
}));

app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging
if (process.env.NODE_ENV !== 'production') {
  app.use((req: any, res: any, next: any) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
  });
}

// Health check endpoint
app.get('/health', (req: any, res: any) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is healthy',
    timestamp: new Date().toISOString(),
    version: '2.1.1',
    port: PORT,
    environment: process.env.NODE_ENV || 'production',
    uptime: process.uptime()
  });
});

// Root endpoint
app.get('/', (req: any, res: any) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API v2.1.1',
    status: 'running',
    environment: process.env.NODE_ENV || 'production',
    endpoints: {
      health: 'GET /health',
      chat: 'POST /api/ai/chat',
      analyze: 'POST /api/ai/analyze'
    },
    documentation: 'https://github.com/Solarpaletten/icoder-plus'
  });
});

// AI Chat endpoint - Dual Agent Support
app.post('/api/ai/chat', (req: any, res: any) => {
  const { message, agent, code, targetFile } = req.body;
  
  if (process.env.NODE_ENV !== 'production') {
    console.log('AI Chat request:', { 
      agent: agent || 'claudy', 
      messageLength: message?.length || 0,
      targetFile: targetFile || 'none'
    });
  }
  
  // Validate input
  if (!message || typeof message !== 'string') {
    return res.status(400).json({
      success: false,
      error: 'Message is required and must be a string'
    });
  }
  
  // Simulate AI response based on agent
  let response = '';
  let codeBlocks: any[] = [];
  
  if (agent === 'dashka') {
    response = `Dashka (Архитект): Анализирую архитектуру проекта.\n\n${message}\n\nРекомендации:\n- Проверить модульность компонентов\n- Оптимизировать структуру файлов\n- Убедиться в правильности типизации`;
  } else {
    // Claudy mode - generate code
    const fileName = targetFile || 'generated.js';
    const codeExample = `// Generated code for: ${message}\nconst solution = () => {\n  // Implementation here\n  console.log('Generated solution');\n  return { success: true };\n};\n\nmodule.exports = solution;`;
    
    response = `Claudy: Создаю код для вашего запроса.\n\n${message}\n\nfile: ${fileName}\n\`\`\`javascript\n${codeExample}\n\`\`\``;
    
    codeBlocks = [{
      id: Math.random().toString(36).substr(2, 9),
      title: `Generated code for ${fileName}`,
      file: fileName,
      kind: 'javascript',
      code: codeExample
    }];
  }
  
  res.status(200).json({
    success: true,
    data: {
      message: response,
      agent: agent || 'claudy',
      codeBlocks: codeBlocks,
      timestamp: new Date().toISOString()
    }
  });
});

// AI Analyze endpoint  
app.post('/api/ai/analyze', (req: any, res: any) => {
  const { code, fileName } = req.body;
  
  if (!code || typeof code !== 'string') {
    return res.status(400).json({
      success: false,
      error: 'Code is required and must be a string'
    });
  }
  
  // Basic code analysis simulation
  const analysis = {
    issues: [],
    suggestions: [
      "Code structure appears well-organized", 
      "Consider adding error handling",
      "Add documentation for better maintainability"
    ],
    complexity: code.length > 1000 ? "high" : code.length > 500 ? "medium" : "low",
    performance: "acceptable",
    maintainability: "good",
    security: "review recommended"
  };
  
  res.status(200).json({
    success: true,
    data: {
      analysis,
      fileName: fileName || 'unknown',
      timestamp: new Date().toISOString()
    }
  });
});

// 404 handler
app.use('*', (req: any, res: any) => {
  res.status(404).json({
    error: 'Route not found',
    message: `${req.method} ${req.originalUrl} does not exist`,
    availableEndpoints: [
      'GET /', 
      'GET /health', 
      'POST /api/ai/chat', 
      'POST /api/ai/analyze'
    ]
  });
});

// Global error handler
app.use((err: any, req: any, res: any, next: any) => {
  console.error('Server error:', err.message);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend v2.1.1 started');
  console.log(`📡 Server: http://localhost:${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`💚 Health: http://localhost:${PORT}/health`);
});

// Graceful shutdown
const shutdown = (signal: string) => {
  console.log(`🛑 ${signal} received, shutting down...`);
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

process.on('uncaughtException', (err: any) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason: any) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});
