import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

// CORS configuration
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:5174', 'http://127.0.0.1:5173', '*'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true
}));

app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is running',
    timestamp: new Date().toISOString(),
    version: '2.1.1',
    port: PORT,
    environment: process.env.NODE_ENV || 'development'
  });
});

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API v2.1.1',
    status: 'running',
    endpoints: {
      health: 'GET /health',
      chat: 'POST /api/ai/chat',
      analyze: 'POST /api/ai/analyze'
    }
  });
});

// AI Chat endpoint - Dual Agent Support
app.post('/api/ai/chat', (req: Request, res: Response) => {
  const { message, agent, code, targetFile } = req.body;
  
  console.log('AI Chat request:', { 
    agent: agent || 'claudy', 
    messageLength: message?.length || 0,
    codeLength: code?.length || 0,
    targetFile: targetFile || 'none'
  });
  
  // Simulate AI response based on agent
  let response = '';
  let codeBlocks: any[] = [];
  
  if (agent === 'dashka') {
    response = `🏗️ Dashka (Архитект): Анализирую архитектуру вашего проекта.\n\n${message ? 'Ваш запрос: ' + message : ''}\n\nРекомендации:\n- Проверить модульность компонентов\n- Оптимизировать структуру файлов\n- Убедиться в правильности типизации`;
  } else {
    // Claudy mode - generate code
    response = `🤖 Claudy (Генератор кода): Создаю код для вашего запроса.\n\n${message ? 'Запрос: ' + message : ''}\n\nfile: ${targetFile || 'example.js'}\n\`\`\`javascript\n// Generated code example\nconst handleRequest = () => {\n  console.log('AI generated function');\n  return {\n    success: true,\n    message: 'Code generated successfully'\n  };\n};\n\nexport default handleRequest;\n\`\`\``;
    
    // Extract code blocks for proposals
    codeBlocks = [{
      id: Math.random().toString(36).substr(2, 9),
      title: `Generated code for ${targetFile || 'current file'}`,
      file: targetFile || 'example.js',
      kind: 'javascript',
      code: `// Generated code example\nconst handleRequest = () => {\n  console.log('AI generated function');\n  return {\n    success: true,\n    message: 'Code generated successfully'\n  };\n};\n\nexport default handleRequest;`
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
app.post('/api/ai/analyze', (req: Request, res: Response) => {
  const { code, fileName, analysisType } = req.body;
  
  console.log('AI Analyze request:', { 
    fileName: fileName || 'unknown', 
    codeLength: code?.length || 0,
    analysisType: analysisType || 'basic'
  });
  
  // Basic code analysis simulation
  const analysis = {
    issues: code ? [] : ['No code provided'],
    suggestions: [
      "Code structure looks good", 
      "Consider adding error handling",
      "Add TypeScript types for better maintainability"
    ],
    complexity: code?.length > 1000 ? "high" : code?.length > 500 ? "medium" : "low",
    performance: "good",
    maintainability: "good",
    security: "acceptable"
  };
  
  res.status(200).json({
    success: true,
    data: {
      analysis,
      fileName: fileName || 'unknown',
      analysisType: analysisType || 'basic',
      timestamp: new Date().toISOString()
    }
  });
});

// File operations endpoint
app.post('/api/files/save', (req: Request, res: Response) => {
  const { fileName, content } = req.body;
  
  console.log('File save request:', { fileName, contentLength: content?.length || 0 });
  
  res.status(200).json({
    success: true,
    message: `File ${fileName} saved successfully`,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req: Request, res: Response) => {
  res.status(404).json({
    error: 'Route not found',
    message: `${req.method} ${req.originalUrl} does not exist`,
    availableRoutes: [
      'GET /', 
      'GET /health', 
      'POST /api/ai/chat', 
      'POST /api/ai/analyze',
      'POST /api/files/save'
    ]
  });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Server error:', err.message);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server with proper error handling
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend v2.1.1 started successfully');
  console.log(`📡 Server running on http://localhost:${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`🤖 Dual-Agent AI system ready (Dashka + Claudy)`);
});

// Graceful shutdown handlers
const shutdown = (signal: string) => {
  console.log(`🛑 ${signal} received, shutting down gracefully`);
  server.close(() => {
    console.log('✅ Server closed successfully');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});
