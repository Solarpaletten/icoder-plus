import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3007

app.use(cors())
app.use(express.json())

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    version: '2.1.1',
    timestamp: new Date().toISOString()
  })
})

// AI Chat endpoint
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { agent, message, code, targetFile } = req.body
    
    // Simulate AI response
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const response = agent === 'dashka' 
      ? `🏗️ Architecture advice for: "${message}"\n\nConsider modular design patterns and proper error handling.`
      : `🤖 Code generated for: "${message}"\n\nfile: ${targetFile || 'new-file.js'}\n\`\`\`javascript\nconsole.log('Hello from Claudy!');\n\`\`\``
    
    res.json({ 
      success: true, 
      data: { message: response }
    })
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    })
  }
})

app.listen(PORT, () => {
  console.log(`🚀 iCoder Plus Backend v2.1.1 running on port ${PORT}`)
  console.log(`🌐 Health check: http://localhost:${PORT}/health`)
})
