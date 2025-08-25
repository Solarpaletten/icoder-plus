import axios from 'axios'

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Add API key if available
    const apiKey = import.meta.env.VITE_API_KEY
    if (apiKey) {
      config.headers['X-API-Key'] = apiKey
    }
    
    // Log request in development
    if (import.meta.env.DEV) {
      console.log('API Request:', {
        method: config.method?.toUpperCase(),
        url: config.url,
        data: config.data
      })
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
apiClient.interceptors.response.use(
  (response) => {
    // Log response in development
    if (import.meta.env.DEV) {
      console.log('API Response:', {
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
          console.error('Unauthorized: Check your API key')
          break
        case 403:
          console.error('Forbidden: Insufficient permissions')
          break
        case 429:
          console.error('Rate limited: Too many requests')
          break
        case 500:
          console.error('Server error: Please try again later')
          break
        default:
          console.error('API Error:', data?.message || error.message)
      }
    } else if (error.request) {
      console.error('Network error: Unable to reach server')
    } else {
      console.error('Request error:', error.message)
    }
    
    return Promise.reject(error)
  }
)

// AI Service API calls
export const aiAPI = {
  // Analyze code with AI
  analyze: async (code, fileName, analysisType = 'review', oldCode = null) => {
    const response = await apiClient.post('/ai/analyze', {
      code,
      fileName,
      analysisType,
      oldCode
    })
    return response.data
  },

  // Chat with AI
  chat: async (message, code = null, fileName = null, conversationId = null) => {
    const response = await apiClient.post('/ai/chat', {
      message,
      code,
      fileName,
      conversationId
    })
    return response.data
  },

  // Apply AI fixes
  applyFix: async (code, fileName) => {
    const response = await apiClient.post('/ai/fix/apply', {
      code,
      fileName
    })
    return response.data
  },

  // Get AI service status
  getStatus: async () => {
    const response = await apiClient.get('/ai/status')
    return response.data
  }
}

// Files Service API calls
export const filesAPI = {
  // Upload and process file
  upload: async (file, content) => {
    const response = await apiClient.post('/files/upload', {
      fileName: file.name,
      content,
      size: file.size,
      type: file.type
    })
    return response.data
  },

  // Generate diff between versions
  diff: async (oldContent, newContent, fileName) => {
    const response = await apiClient.post('/files/diff', {
      oldContent,
      newContent,
      fileName
    })
    return response.data
  }
}

// History Service API calls
export const historyAPI = {
  // Save version to history
  saveVersion: async (fileName, version, content, metadata = {}) => {
    const response = await apiClient.post('/history/save', {
      fileName,
      version,
      content,
      metadata
    })
    return response.data
  },

  // Get file history
  getHistory: async (fileName) => {
    const response = await apiClient.get(`/history/${encodeURIComponent(fileName)}`)
    return response.data
  },

  // Export history as JSON
  export: async (fileNames = []) => {
    const response = await apiClient.post('/history/export', {
      fileNames
    })
    return response.data
  },

  // Import history from JSON
  import: async (historyData) => {
    const response = await apiClient.post('/history/import', {
      historyData
    })
    return response.data
  }
}

// Generic API helper
export const api = {
  get: (url, params = {}) => apiClient.get(url, { params }),
  post: (url, data = {}) => apiClient.post(url, data),
  put: (url, data = {}) => apiClient.put(url, data),
  delete: (url) => apiClient.delete(url)
}

export default apiClient