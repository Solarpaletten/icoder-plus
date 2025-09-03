const API_BASE = process.env.VITE_API_URL || 'http://localhost:3000'

export const askAI = async ({ agent, message, code, fileName, context }) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        agent,
        message,
        code,
        fileName,
        context
      }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data.data || data
  } catch (error) {
    console.error('AI Service Error:', error)
    
    // Fallback ответы если API недоступен
    const fallbackResponses = {
      dashka: `🏗️ **Архитектурный анализ** (Fallback mode)\n\n${message.includes('архитектур') ? 'Рекомендую использовать модульную архитектуру с четким разделением ответственности.' : 'Код выглядит хорошо структурированным.'}`,
      claudy: `🤖 **Генерация кода** (Fallback mode)\n\n\`\`\`javascript\n// Сгенерированный код для: ${message}\nconst component = () => {\n  return <div>Hello from Claudy!</div>\n}\n\nexport default component\n\`\`\``
    }
    
    return { message: fallbackResponses[agent] || 'AI недоступен в данный момент.' }
  }
}

export const analyzeCode = async (code, fileName) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/analyze`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code, fileName }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Code Analysis Error:', error)
    return {
      suggestions: ['AI анализ недоступен'],
      issues: [],
      score: 85
    }
  }
}

export const generateCode = async (prompt, context) => {
  try {
    const response = await fetch(`${API_BASE}/api/ai/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ prompt, context }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Code Generation Error:', error)
    return {
      code: '// Генерация кода недоступна',
      explanation: 'AI сервис временно недоступен'
    }
  }
}
