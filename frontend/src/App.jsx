import { useState, useEffect } from 'react'
import BackendStatus from './components/BackendStatus'

function App() {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 1000)
    
    return () => clearTimeout(timer)
  }, [])

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center text-white">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <h2 className="text-xl font-semibold">Loading iCoder Plus...</h2>
          <p className="text-gray-400 mt-2">AI-first IDE</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <header className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">iC</span>
              </div>
              <div>
                <h1 className="text-xl font-bold">iCoder Plus</h1>
                <p className="text-sm text-gray-400">AI-first IDE v2.0</p>
              </div>
            </div>
            <div className="bg-green-800 px-3 py-1 rounded-full text-sm">
              ✅ Frontend on Render
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 py-8">
        {/* Welcome */}
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold mb-4">Welcome to iCoder Plus! 🚀</h2>
          <p className="text-gray-300 text-lg">Your AI-first IDE is now running on Render</p>
        </div>

        {/* Backend Status */}
        <div className="mb-8">
          <BackendStatus />
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <FeatureCard 
            icon="🤖"
            title="AI Analysis" 
            description="Smart code reviews powered by OpenAI"
          />
          <FeatureCard 
            icon="💬"
            title="AI Chat"
            description="Chat with AI about your code"
          />
          <FeatureCard 
            icon="🔧" 
            title="Auto Fix"
            description="Automatically fix coding issues"
          />
          <FeatureCard 
            icon="📝"
            title="Code Editor"
            description="Monaco editor with syntax highlighting"
          />
          <FeatureCard 
            icon="📊"
            title="Live Preview"
            description="See your changes in real-time"
          />
          <FeatureCard 
            icon="🌐"
            title="Cloud Ready"
            description="Deployed on Render with 99.9% uptime"
          />
        </div>

        {/* Footer */}
        <div className="text-center mt-12 pt-8 border-t border-gray-700">
          <p className="text-gray-400 mb-2">
            Backend API: <span className="text-blue-400">https://icoder-plus.onrender.com</span>
          </p>
          <p className="text-sm text-gray-500">
            Built with ❤️ by Solar IT Team
          </p>
        </div>
      </main>
    </div>
  )
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 hover:border-blue-500 transition-all duration-200">
      <div className="text-3xl mb-4">{icon}</div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-gray-400 text-sm">{description}</p>
    </div>
  )
}

export default App
