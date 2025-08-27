import axios from 'axios'

// API Base URL - автоматически определяется из environment variables
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'

console.log('🔗 API Base URL:', API_BASE_URL)

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Log request in development
    if (import.meta.env.DEV) {
      console.log('🚀 API Request:', {
        method: config.method?.toUpperCase(),
        url: `${config.baseURL}${config.url}`,
        data: config.data
      })
    }
    
    return config
  },
  (error) => {
    console.error('❌ Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor
apiClient.interceptors.response.use(
  (response) => {
    // Log response in development
    if (import.meta.env.DEV) {
      console.log('✅ API Response:', {
        status: response.status,
        url: response.config.url,
        data: response.data
      })
    }
    
    return response
  },
  (error) => {
    // Handle common errors
    if (error.response) {
      const { status, data } = error.response
      
      switch (status) {
        case 401:
          console.error('🔐 Unauthorized: Check your API key')
          break
        case 403:
          console.error('🚫 Forbidden: Insufficient permissions')
          break
        case 429:
          console.error('🐌 Rate limited: Too many requests')
          break
        case 500:
          console.error('💥 Server error: Please try again later')
          break
        default:
          console.error('⚠️ API Error:', data?.message || error.message)
      }
    } else if (error.request) {
      console.error('🌐 Network error: Unable to reach server at', API_BASE_URL)
    } else {
      console.error('❌ Request error:', error.message)
    }
    
    return Promise.reject(error)
  }
)

// AI Service API calls
export const aiAPI = {
  // Analyze code with AI
  analyze: async (code, fileName, analysisType = 'review', oldCode = null) => {
    const response = await apiClient.post('/api/ai/analyze', {
      code,
      fileName,
      analysisType,
      oldCode
    })
    return response.data
  },

  // Chat with AI
  chat: async (message, code = null, fileName = null) => {
    const response = await apiClient.post('/api/ai/chat', {
      message,
      code,
      fileName
    })
    return response.data
  },

  // Apply AI fixes
  applyFix: async (code, fileName) => {
    const response = await apiClient.post('/api/ai/fix/apply', {
      code,
      fileName
    })
    return response.data
  }
}

// Health check
export const healthAPI = {
  check: async () => {
    const response = await apiClient.get('/health')
    return response.data
  }
}

// Test connection
export const testConnection = async () => {
  try {
    const response = await apiClient.get('/')
    console.log('✅ Backend connection successful:', response.data)
    return true
  } catch (error) {
    console.error('❌ Backend connection failed:', error.message)
    return false
  }
}

export default apiClient
