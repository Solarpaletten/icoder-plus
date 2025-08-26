import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// Middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));

app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Только для development логирование
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('combined'));
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'production',
    port: PORT
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'iCoder Plus Backend is running!',
    version: '2.0.0',
    endpoints: {
      health: '/health',
      ai: {
        analyze: '/api/ai/analyze',
        chat: '/api/ai/chat', 
        fix: '/api/ai/fix'
      }
    }
  });
});

// Basic AI endpoints with fallback responses
app.post('/api/ai/analyze', (req, res) => {
  const { code, fileName, analysisType } = req.body;
  
  res.status(200).json({
    success: true,
    analysis: {
      fileName: fileName || 'unknown.js',
      type: analysisType || 'review',
      issues: [
        {
          line: 1,
          type: 'suggestion',
          message: 'Consider using const instead of var for better scoping'
        }
      ],
      suggestions: [
        'Add error handling for better reliability',
        'Consider adding type annotations',
        'Use meaningful variable names'
      ],
      metrics: {
        complexity: 'low',
        maintainability: 'good',
        performance: 'acceptable'
      },
      score: 85
    },
    timestamp: new Date().toISOString()
  });
});

app.post('/api/ai/chat', (req, res) => {
  const { message, code, fileName } = req.body;
  
  res.status(200).json({
    success: true,
    response: `Based on your question "${message}" about ${fileName || 'your code'}, here are some suggestions: Consider improving error handling, adding comments for clarity, and following consistent naming conventions.`,
    suggestions: [
      'Add JSDoc comments',
      'Implement proper error boundaries',
      'Consider performance optimization'
    ],
    timestamp: new Date().toISOString()
  });
});

app.post('/api/ai/fix', (req, res) => {
  const { code, fileName } = req.body;
  
  // Simple fixes - replace var with const, add semicolons
  let fixedCode = code;
  if (typeof code === 'string') {
    fixedCode = code
      .replace(/var\s+/g, 'const ')
      .replace(/(?<!;)\n/g, ';\n')
      .trim();
  }
  
  res.status(200).json({
    success: true,
    fixedCode: fixedCode,
    changes: [
      'Replaced var declarations with const',
      'Added missing semicolons',
      'Improved code formatting'
    ],
    original: code,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`,
    availableRoutes: ['/health', '/api/ai/analyze', '/api/ai/chat', '/api/ai/fix']
  });
});

// Global error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Global error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 iCoder Plus Backend running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🌐 API endpoints available at /api/ai/*`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully'); 
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

export default app;
