import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'

export default function BackendStatus() {
  const [status, setStatus] = useState('checking')
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkBackend()
  }, [])

  const checkBackend = async () => {
    try {
      setStatus('checking')
      setError(null)

      const response = await fetch(`${API_URL}/health`)
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      
      const result = await response.json()
      setData(result)
      setStatus('connected')
      
    } catch (err) {
      setStatus('error')
      setError(err.message)
      console.error('Backend check failed:', err)
    }
  }

  const getStatusInfo = () => {
    switch (status) {
      case 'checking': 
        return { icon: '🔄', text: 'Checking...', color: 'text-yellow-400' }
      case 'connected': 
        return { icon: '✅', text: 'Backend Connected', color: 'text-green-400' }
      case 'error': 
        return { icon: '❌', text: 'Connection Error', color: 'text-red-400' }
      default: 
        return { icon: '❓', text: 'Unknown', color: 'text-gray-400' }
    }
  }

  const statusInfo = getStatusInfo()

  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold">Backend Status</h3>
        <button 
          onClick={checkBackend}
          className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded text-sm transition-colors"
          disabled={status === 'checking'}
        >
          {status === 'checking' ? 'Checking...' : 'Refresh'}
        </button>
      </div>

      <div className={`flex items-center space-x-2 mb-4 ${statusInfo.color}`}>
        <span className="text-xl">{statusInfo.icon}</span>
        <span className="font-medium">{statusInfo.text}</span>
      </div>

      {data && (
        <div className="space-y-2 text-sm">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <span className="text-gray-400">Version:</span>
              <span className="text-white ml-2">{data.version || 'Unknown'}</span>
            </div>
            <div>
              <span className="text-gray-400">Environment:</span>
              <span className="text-white ml-2">{data.environment || 'production'}</span>
            </div>
            <div>
              <span className="text-gray-400">Status:</span>
              <span className="text-white ml-2">{data.status || 'OK'}</span>
            </div>
            <div>
              <span className="text-gray-400">Tech:</span>
              <span className="text-white ml-2">{data.tech || 'JavaScript'}</span>
            </div>
          </div>
          
          <div className="pt-3 text-xs text-gray-500 border-t border-gray-700">
            Last updated: {new Date().toLocaleTimeString()}
          </div>
        </div>
      )}

      {error && (
        <div className="mt-4 p-3 bg-red-900 bg-opacity-20 border border-red-800 rounded">
          <div className="text-red-400 text-sm">
            <strong>Error:</strong> {error}
          </div>
        </div>
      )}

      <div className="mt-4 text-xs text-gray-500">
        API URL: <span className="text-blue-400">{API_URL}</span>
      </div>
    </div>
  )
}
