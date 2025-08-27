const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is healthy and running',
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'production',
    port: PORT,
    tech: 'Pure JavaScript - No TypeScript needed!'
  });
});

// Root endpoint  
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running',
    tech: 'JavaScript',
    endpoints: {
      health: '/health',
      aiAnalyze: '/api/ai/analyze',
      docs: 'https://github.com/Solarpaletten/icoder-plus'
    }
  });
});

// AI Analysis endpoint (placeholder)
app.post('/api/ai/analyze', (req, res) => {
  const { code, analysisType, fileName } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required',
      message: 'Please provide code to analyze'
    });
  }

  // Placeholder response - готово для интеграции с OpenAI
  res.status(200).json({
    success: true,
    message: 'AI analysis endpoint is working',
    data: {
      originalCode: code,
      analysisType: analysisType || 'basic',
      fileName: fileName || 'unnamed.js',
      result: 'AI analysis will be integrated soon',
      suggestions: [
        'Add error handling',
        'Consider using const/let instead of var',
        'Add JSDoc comments'
      ],
      timestamp: new Date().toISOString()
    }
  });
});

// Chat endpoint (placeholder)
app.post('/api/ai/chat', (req, res) => {
  const { message, code } = req.body;
  
  if (!message) {
    return res.status(400).json({
      error: 'Message is required'
    });
  }

  res.status(200).json({
    success: true,
    response: `You said: "${message}". AI chat will be integrated soon!`,
    timestamp: new Date().toISOString()
  });
});

// Fix endpoint (placeholder)
app.post('/api/ai/fix/apply', (req, res) => {
  const { code, fileName } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required'
    });
  }

  // Simple fix example
  const fixedCode = code
    .replace(/var /g, 'const ')
    .replace(/console\.log\(/g, '// console.log(');

  res.status(200).json({
    success: true,
    data: {
      originalCode: code,
      fixedCode: fixedCode,
      fileName: fileName || 'fixed.js',
      changes: ['Replaced var with const', 'Commented out console.log'],
      timestamp: new Date().toISOString()
    }
  });
});

// 404 handler
app.all('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Route ${req.method} ${req.path} does not exist`,
    availableRoutes: [
      'GET /',
      'GET /health', 
      'POST /api/ai/analyze',
      'POST /api/ai/chat',
      'POST /api/ai/fix/apply'
    ]
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 iCoder Plus Backend started successfully');
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log('⚡ Pure JavaScript - No TypeScript compilation needed!');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated gracefully');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('🛑 SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated gracefully');
    process.exit(0);
  });
});

process.on('uncaughtException', (err) => {
  console.error('💥 Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});
