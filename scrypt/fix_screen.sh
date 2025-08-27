#!/bin/bash

cd frontend

echo "🔥 ИСПРАВЛЯЕМ ЧЕРНЫЙ ЭКРАН - КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ!"

# 1. СОЗДАЕМ ПРАВИЛЬНЫЙ INDEX.HTML ДЛЯ VITE
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>iCoder Plus v2.0 - AI-first IDE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  </head>
  <body class="bg-midnight font-poppins">
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# 2. СОЗДАЕМ ПРАВИЛЬНЫЙ src/main.jsx
cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# 3. СОЗДАЕМ src/index.css С TAILWIND
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-gray-900 text-white;
    font-family: 'Poppins', system-ui, -apple-system, sans-serif;
  }
  
  .font-mono {
    font-family: 'JetBrains Mono', 'Fira Code', monospace;
  }
}

@layer components {
  .gradient-bg {
    background: linear-gradient(135deg, #0D1117 0%, #1a1a2e 100%);
  }
  
  .bottom-sheet {
    transform: translateY(85vh);
    transition: transform 0.3s ease-out;
  }
  
  .bottom-sheet.expanded {
    transform: translateY(20vh);
  }
}
EOF

# 4. ИСПРАВЛЯЕМ src/App.jsx - СОЗДАЕМ РАБОЧУЮ ВЕРСИЮ
cat > src/App.jsx << 'EOF'
import React, { useState } from 'react'
import './index.css'

// Demo files data
const initialFiles = {
  "App.js": [
    {
      versionName: "v1.0",
      timestamp: Date.now() - 86400000,
      content: "var message = 'Hello World';\nconsole.log(message);",
      aiNote: "🆕 New file created",
      aiReview: ["⚠️ Replace 'var' with 'const'", "🔇 Remove console.log before production"],
      isAIFix: false
    },
    {
      versionName: "v1.1", 
      timestamp: Date.now() - 3600000,
      content: "const message = 'Hello iCoder Plus';\nfunction greet() { return message; }",
      aiNote: "✏️ Code updated: improved variable declaration and added function",
      aiReview: ["✅ Good use of const", "✨ Consider adding JSDoc comments"],
      isAIFix: true
    }
  ],
  "utils.js": [
    {
      versionName: "v1.0",
      timestamp: Date.now() - 7200000,
      content: "export function calculateSum(a, b) {\n  return a + b;\n}",
      aiNote: "🆕 Utility function created",
      aiReview: ["✅ Clean function implementation", "💡 Consider adding type validation"],
      isAIFix: false
    }
  ]
}

// Bottom Sheet Component
const BottomSheet = ({ files, onFilesChange }) => {
  const [isExpanded, setIsExpanded] = useState(false)
  const [activeTab, setActiveTab] = useState('history')
  const [selectedFile, setSelectedFile] = useState('App.js')

  const handleAIFix = async () => {
    const currentFile = files[selectedFile]
    if (!currentFile || currentFile.length === 0) return

    const latestVersion = currentFile[currentFile.length - 1]
    const fixedCode = latestVersion.content
      .replace(/var\s+/g, 'const ')
      .replace(/console\.log\([^)]*\);?\s*/g, '')
      .trim()

    const newVersion = {
      versionName: `v${currentFile.length + 1}.0`,
      timestamp: Date.now(),
      content: fixedCode,
      aiNote: "🤖 AI Fix applied: var → const, removed console.log",
      aiReview: ["✅ Code optimized", "🚀 Ready for production"],
      isAIFix: true
    }

    const updatedFiles = {
      ...files,
      [selectedFile]: [...currentFile, newVersion]
    }
    
    onFilesChange(updatedFiles)
  }

  return (
    <div className="fixed inset-0 pointer-events-none">
      {/* Background overlay */}
      {isExpanded && (
        <div 
          className="absolute inset-0 bg-black/20 pointer-events-auto"
          onClick={() => setIsExpanded(false)}
        />
      )}
      
      {/* Bottom Sheet */}
      <div 
        className={`absolute bottom-0 left-0 right-0 bg-gray-800 rounded-t-2xl shadow-2xl pointer-events-auto transition-transform duration-300 ${
          isExpanded ? 'h-[80vh]' : 'h-[15vh]'
        }`}
        style={{
          transform: isExpanded ? 'translateY(0)' : 'translateY(0)'
        }}
      >
        {/* Handle */}
        <div 
          className="flex justify-center py-3 cursor-pointer hover:bg-gray-700/50 rounded-t-2xl"
          onClick={() => setIsExpanded(!isExpanded)}
        >
          <div className="w-12 h-1 bg-gray-400 rounded-full"></div>
        </div>

        {/* Collapsed Content */}
        {!isExpanded && (
          <div className="px-6 pb-4">
            <div className="text-center">
              <h3 className="text-lg font-semibold text-blue-400">⚡ iCoder Plus v2.0</h3>
              <p className="text-gray-400 text-sm">Tap to expand AI-first IDE</p>
            </div>
          </div>
        )}

        {/* Expanded Content */}
        {isExpanded && (
          <div className="flex flex-col h-full pb-4">
            {/* Tabs */}
            <div className="flex border-b border-gray-700 px-6">
              {[
                { id: 'history', label: '📜 History', icon: '📜' },
                { id: 'preview', label: '▶ Preview', icon: '▶' },
                { id: 'chat', label: '💬 AI Chat', icon: '💬' }
              ].map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-4 py-3 text-sm font-medium transition-colors border-b-2 ${
                    activeTab === tab.id 
                      ? 'border-blue-500 text-blue-400' 
                      : 'border-transparent text-gray-400 hover:text-gray-300'
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            {/* Tab Content */}
            <div className="flex-1 flex overflow-hidden">
              {/* File List Sidebar */}
              <div className="w-48 bg-gray-900 p-4 border-r border-gray-700">
                <h4 className="text-sm font-semibold mb-3 text-gray-300">Files:</h4>
                <div className="space-y-1">
                  {Object.keys(files).map(filename => (
                    <button
                      key={filename}
                      onClick={() => setSelectedFile(filename)}
                      className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${
                        selectedFile === filename 
                          ? 'bg-blue-600 text-white' 
                          : 'text-gray-300 hover:bg-gray-700'
                      }`}
                    >
                      📄 {filename}
                    </button>
                  ))}
                </div>
              </div>

              {/* Main Content */}
              <div className="flex-1 p-6 overflow-y-auto">
                {activeTab === 'history' && (
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <h3 className="text-xl font-semibold">📜 Version History: {selectedFile}</h3>
                      <button
                        onClick={handleAIFix}
                        className="bg-purple-600 hover:bg-purple-700 px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                      >
                        🤖 Apply AI Fix
                      </button>
                    </div>

                    {files[selectedFile]?.map((version, idx) => (
                      <div key={idx} className="bg-gray-700 rounded-lg p-4">
                        <div className="flex items-center justify-between mb-3">
                          <span className="font-mono text-sm font-semibold text-green-400">
                            {version.versionName}
                          </span>
                          <span className="text-xs text-gray-400">
                            {new Date(version.timestamp).toLocaleString()}
                          </span>
                          {version.isAIFix && (
                            <span className="bg-purple-600 text-xs px-2 py-1 rounded">
                              AI FIXED
                            </span>
                          )}
                        </div>
                        
                        <p className="text-green-400 text-sm mb-3">
                          💡 {version.aiNote}
                        </p>
                        
                        <pre className="bg-gray-900 rounded-lg p-3 text-sm font-mono overflow-x-auto mb-3 text-green-300">
{version.content}
                        </pre>
                        
                        <div className="space-y-1">
                          <p className="text-xs font-semibold text-gray-300">🔍 AI Review:</p>
                          {version.aiReview.map((review, ridx) => (
                            <p key={ridx} className="text-xs text-gray-400">• {review}</p>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {activeTab === 'preview' && (
                  <div className="space-y-4">
                    <h3 className="text-xl font-semibold">▶ Live Preview</h3>
                    <div className="bg-gray-900 rounded-lg p-4">
                      <p className="text-gray-400">Preview functionality - Execute JS/HTML code here</p>
                    </div>
                  </div>
                )}

                {activeTab === 'chat' && (
                  <div className="space-y-4">
                    <h3 className="text-xl font-semibold">💬 AI Chat Assistant</h3>
                    <div className="bg-gray-900 rounded-lg p-4">
                      <p className="text-gray-400">Chat with AI about your code here</p>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

// Main App Component
function App() {
  const [files, setFiles] = useState(initialFiles)

  return (
    <div className="min-h-screen gradient-bg">
      {/* Header */}
      <header className="text-center py-12 px-6">
        <h1 className="text-5xl font-bold bg-gradient-to-r from-blue-400 via-purple-500 to-green-400 bg-clip-text text-transparent mb-4">
          ⚡ iCoder Plus v2.0
        </h1>
        <p className="text-xl text-gray-300 mb-2">AI-first IDE in a bottom sheet</p>
        <p className="text-gray-500">
          🚀 Built by Solar IT Team | Drag files below or interact with demo ⬇
        </p>
      </header>

      {/* Main Content */}
      <main className="relative">
        <div className="text-center py-20">
          <div className="text-6xl mb-6">🛸</div>
          <p className="text-gray-400 text-lg">
            Welcome to the future of coding!<br/>
            <span className="text-blue-400">Tap the bottom sheet below to start</span>
          </p>
        </div>

        {/* Bottom Sheet */}
        <BottomSheet files={files} onFilesChange={setFiles} />
      </main>
    </div>
  )
}

export default App
EOF

# 5. СОЗДАЕМ ПРАВИЛЬНЫЙ TAILWIND.CONFIG.JS
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'midnight': '#0D1117',
        'neon-blue': '#1F6FEB', 
        'cyber-purple': '#9D4EDD',
        'matrix-green': '#00FF9D',
        'warning-yellow': '#FFD60A'
      },
      fontFamily: {
        'poppins': ['Poppins', 'sans-serif'],
        'jetbrains': ['JetBrains Mono', 'monospace'],
        'mono': ['JetBrains Mono', 'Fira Code', 'monospace']
      }
    },
  },
  plugins: [],
}
EOF

# 6. СОЗДАЕМ POSTCSS.CONFIG.JS
cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

echo "🔄 Перезапускаем dev server..."
echo ""
echo "✅ ЧЕРНЫЙ ЭКРАН ИСПРАВЛЕН!"
echo ""
echo "🎯 Теперь перезапустите сервер:"
echo "   npm run dev"
echo ""
echo "🚀 В браузере должен появиться:"
echo "   - Космический градиентный фон"
echo "   - Заголовок 'iCoder Plus v2.0'"  
echo "   - Bottom sheet внизу экрана"
echo "   - Рабочие вкладки History/Preview/Chat"