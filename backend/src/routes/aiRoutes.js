//src/routes/aiRoutes.ts
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
let openai: OpenAI | null = null
if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_key_here') {
  openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
  })
}

// AI Chat endpoint
router.post('/chat', async (req, res) => {
  try {
    const { agent, message, code, fileName, context } = req.body

    if (!message) {
      return res.status(400).json({ error: 'Message is required' })
    }

    // If OpenAI is configured, use real AI
    if (openai) {
      const systemPrompt = agent === 'dashka' 
        ? 'You are Dashka, an expert software architect. Analyze code architecture, suggest improvements, and provide structural advice. Respond in Russian when asked in Russian.'
        : 'You are Claudy, a code generator assistant. Generate components, write code, and help with development tasks. Respond in Russian when asked in Russian.'

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
    const fallbackResponses = {
      dashka: generateDashkaResponse(message, code),
      claudy: generateClaudyResponse(message, code, fileName)
    }

    res.json({
      success: true,
      data: { message: fallbackResponses[agent as keyof typeof fallbackResponses] }
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
    const { code, fileName } = req.body

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
function generateDashkaResponse(message: string, code?: string): string {
  const responses = [
    "🏗️ **Архитектурный анализ**\n\nРекомендую использовать принципы SOLID для лучшей структуры кода.",
    "🔍 **Анализ структуры**\n\nКод выглядит хорошо организованным. Рассмотрите возможность добавления паттернов проектирования.",
    "⚡ **Оптимизация производительности**\n\nДля улучшения производительности рекомендую использовать мемоизацию и ленивую загрузку.",
    "🛠️ **Улучшение архитектуры**\n\nПредлагаю разделить компоненты по принципу единой ответственности."
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
function generateClaudyResponse(message: string, code?: string, fileName?: string): string {
  if (message.includes('компонент') || message.includes('component')) {
    return `🤖 **Генерация компонента**\n\n\`\`\`javascript\nimport React from 'react'\n\nconst ${fileName?.replace('.js', '') || 'NewComponent'} = () => {\n  return (\n    <div className="component">\n      <h2>Hello from ${fileName?.replace('.js', '') || 'NewComponent'}!</h2>\n    </div>\n  )\n}\n\nexport default ${fileName?.replace('.js', '') || 'NewComponent'}\n\`\`\``
  }

  if (message.includes('стили') || message.includes('css')) {
    return `🎨 **Генерация CSS**\n\n\`\`\`css\n.component {\n  display: flex;\n  flex-direction: column;\n  padding: 1rem;\n  border-radius: 8px;\n  background: #f8f9fa;\n  box-shadow: 0 2px 4px rgba(0,0,0,0.1);\n}\n\n.component h2 {\n  color: #2c3e50;\n  margin-bottom: 0.5rem;\n}\n\`\`\``
  }

  return `🤖 **Код для: "${message}"**\n\n\`\`\`javascript\n// Сгенерированный код\nconsole.log('Hello from Claudy!')\n\n// TODO: Implement ${message}\n\`\`\``
}

export { router as aiRouter }