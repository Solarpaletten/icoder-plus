// src/routes/aiRoutes.js
import express from 'express'
import { OpenAI } from 'openai'
import winston from 'winston'

const router = express.Router()

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.simple(),
  transports: [new winston.transports.Console()]
})

// Initialize OpenAI (if API key provided)
// ❌ [TS-annotation было]: let openai: OpenAI | null = null
// ✅ [JS-версия]:
let openai = null

if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_key_here') {
  openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
  })
}

// AI Chat endpoint
router.post('/chat', async (req, res) => {
  try {
    const { agent, message, code, fileName } = req.body

    if (!message) {
      return res.status(400).json({ error: 'Message is required' })
    }

    // If OpenAI is configured, use real AI
    if (openai) {
      const systemPrompt = agent === 'dashka'
        ? 'You are Dashka, an expert software architect. Analyze code architecture, suggest improvements, and provide structural advice.'
        : 'You are Claudy, a code generator assistant. Generate components, write code, and help with development tasks.'

      const userPrompt = code
        ? `File: ${fileName}\n\nCode:\n${code}\n\nQuestion: ${message}`
        : message

      const completion = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        max_tokens: 500,
        temperature: 0.7
      })

      const aiResponse = completion.choices[0]?.message?.content || 'Извините, не могу обработать запрос.'

      return res.json({
        success: true,
        data: { message: aiResponse }
      })
    }

    // Fallback responses when no API key
    // ❌ [TS-annotation было]: fallbackResponses[agent as keyof typeof fallbackResponses]
    // ✅ [JS-версия]: fallbackResponses[agent]
    const fallbackResponses = {
      dashka: generateDashkaResponse(message, code),
      claudy: generateClaudyResponse(message, code, fileName)
    }

    res.json({
      success: true,
      data: { message: fallbackResponses[agent] || '⚠️ Unsupported agent' }
    })

  } catch (error) {
    logger.error('AI Chat error:', error)
    res.status(500).json({
      success: false,
      error: 'AI service temporarily unavailable'
    })
  }
})

// Code analysis endpoint
router.post('/analyze', async (req, res) => {
  try {
    const { code } = req.body

    if (!code) {
      return res.status(400).json({ error: 'Code is required' })
    }

    // Basic code analysis
    const analysis = {
      lineCount: code.split('\n').length,
      characterCount: code.length,
      suggestions: [
        'Consider adding error handling',
        'Add TypeScript types for better maintainability',
        'Consider breaking down large functions'
      ],
      issues: [],
      score: 85
    }

    res.json({ success: true, data: analysis })

  } catch (error) {
    logger.error('Code analysis error:', error)
    res.status(500).json({
      success: false,
      error: 'Analysis service temporarily unavailable'
    })
  }
})

// Generate Dashka response
// ❌ [TS-annotation было]: function generateDashkaResponse(message: string, code?: string): string
// ✅ [JS-версия]:
function generateDashkaResponse(message, code) {
  const responses = [
    "🏗️ Архитектурный анализ: используйте SOLID.",
    "🔍 Анализ структуры: добавьте паттерны проектирования.",
    "⚡ Оптимизация: используйте мемоизацию и ленивую загрузку.",
    "🛠️ Улучшение архитектуры: разделите компоненты по SRP."
  ]

  if (message.includes('архитектур') || message.includes('структур')) {
    return responses[0]
  } else if (message.includes('производительность') || message.includes('оптимиз')) {
    return responses[2]
  } else {
    return responses[Math.floor(Math.random() * responses.length)]
  }
}

// Generate Claudy response
// ❌ [TS-annotation было]: function generateClaudyResponse(message: string, code?: string, fileName?: string): string
// ✅ [JS-версия]:
function generateClaudyResponse(message, code, fileName) {
  if (message.includes('компонент')) {
    const comp = fileName?.replace('.js', '') || 'NewComponent'
    return `🤖 Generated component:\n\nimport React from 'react'\n\nconst ${comp} = () => (\n  <div className="component">\n    <h2>Hello from ${comp}!</h2>\n  </div>\n)\n\nexport default ${comp}`
  }

  if (message.includes('стили') || message.includes('css')) {
    return `🎨 Generated CSS:\n\n.component {\n  display: flex;\n  flex-direction: column;\n  padding: 1rem;\n  border-radius: 8px;\n  background: #f8f9fa;\n  box-shadow: 0 2px 4px rgba(0,0,0,0.1);\n}\n\n.component h2 {\n  color: #2c3e50;\n  margin-bottom: 0.5rem;\n}`
  }

  return `🤖 Код для: "${message}"\n\nconsole.log('Hello from Claudy!')`
}

export { router as aiRouter }