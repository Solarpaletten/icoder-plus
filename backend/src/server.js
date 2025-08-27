const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(cors());
app.use(express.json());

// Health endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'iCoder Plus Backend is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Root endpoint  
app.get('/', (req, res) => {
  res.json({
    message: 'iCoder Plus Backend API',
    version: '2.0.0',
    status: 'running'
  });
});

// AI endpoint placeholder
app.post('/api/ai/analyze', (req, res) => {
  const { code } = req.body;
  
  if (!code) {
    return res.status(400).json({
      error: 'Code is required'
    });
  }

  res.json({
    success: true,
    message: 'AI analysis endpoint working',
    data: {
      code: code,
      result: 'Analysis placeholder'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌐 Health: http://localhost:${PORT}/health`);
});
