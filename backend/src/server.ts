import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';

// Загрузить переменные окружения
dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '10000', 10);

// Базовые middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false
}));

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req: any, res: any) => {
  res.status(200).json({
    status: 'OK',
    message: 'iCoder Plus Backend is healthy',
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'production',
    port: PORT
  });
});

// Root endpoint
app.get('/', (req: any, res: any) => {
  res.status(200).json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      docs: 'https://github.com/Solarpaletten/icoder-plus'
    }
  });
});

// API endpoint for AI analysis (placeholder)
app.post('/api/ai/analyze', (req: any, res: any) => {
  const { code, analysisType } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required',
      message: 'Please provide code to analyze'
    });
  }

  // Placeholder response
  res.status(200).json({
    success: true,
    message: 'AI analysis endpoint is working',
    data: {
      originalCode: code,
      analysisType: analysisType || 'basic',
      result: 'AI analysis will be implemented soon',
      timestamp: new Date().toISOString()
    }
  });
});

// Catch all other routes
app.all('*', (req: any, res: any) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Route ${req.method} ${req.path} does not exist`,
    availableRoutes: ['GET /', 'GET /health', 'POST /api/ai/analyze']
  });
});

// Error handler
app.use((err: any, req: any, res: any, next: any) => {
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
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('🛑 SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Process terminated');
    process.exit(0);
  });
});
