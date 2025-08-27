import { useState, useEffect } from 'react'
import { healthAPI, testConnection } from '../services/apiClient'

export default function BackendStatus() {
  const [status, setStatus] = useState('checking')
  const [backendInfo, setBackendInfo] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkBackendStatus()
  }, [])

  const checkBackendStatus = async () => {
    try {
      setStatus('checking')
      setError(null)

      // Test basic connection
      const isConnected = await testConnection()
      
      if (!isConnected) {
        setStatus('error')
        setError('Cannot connect to backend')
        return
      }

      // Get health status
      const healthData = await healthAPI.check()
      setBackendInfo(healthData)
      setStatus('connected')

    } catch (err) {
      setStatus('error')
      setError(err.message)
    }
  }

  const getStatusColor = () => {
    switch (status) {
      case 'checking': return 'text-yellow-500'
      case 'connected': return 'text-green-500'
      case 'error': return 'text-red-500'
      default: return 'text-gray-500'
    }
  }

  const getStatusText = () => {
    switch (status) {
      case 'checking': return 'Checking connection...'
      case 'connected': return 'Backend connected ✅'
      case 'error': return 'Backend error ❌'
      default: return 'Unknown status'
    }
  }

  return (
    <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-white">Backend Status</h3>
        <button 
          onClick={checkBackendStatus}
          className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
        >
          Refresh
        </button>
      </div>
      
      <div className={`mt-2 font-medium ${getStatusColor()}`}>
        {getStatusText()}
      </div>

      {backendInfo && (
        <div className="mt-3 text-sm text-gray-300">
          <p>• Version: {backendInfo.version}</p>
          <p>• Environment: {backendInfo.environment}</p>
          <p>• Port: {backendInfo.port}</p>
          <p>• Tech: {backendInfo.tech}</p>
          <p className="text-xs text-gray-400 mt-1">
            {new Date(backendInfo.timestamp).toLocaleString()}
          </p>
        </div>
      )}

      {error && (
        <div className="mt-2 text-sm text-red-400 bg-red-900/20 p-2 rounded">
          Error: {error}
        </div>
      )}

      <div className="mt-3 text-xs text-gray-400">
        Backend URL: {import.meta.env.VITE_API_URL || 'https://icoder-plus.onrender.com'}
      </div>
    </div>
  )
}
