import { useState } from 'react'
import BottomSheet from '@components/BottomSheet'
import './styles/index.css'

// Sample data for demo
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

function App() {
  const [files, setFiles] = useState(initialFiles)

  return (
    <div className="min-h-screen bg-gradient-to-br from-midnight to-gray-900 text-white">
      {/* Header */}
      <header className="p-8 text-center">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-neon-blue to-cyber-purple bg-clip-text text-transparent">
          ⚡ iCoder Plus v2.0
        </h1>
        <p className="text-gray-300 mt-2">AI-first IDE in a bottom sheet</p>
        <p className="text-gray-400 text-sm mt-4">
          Drag files below or interact with the demo ⬇
        </p>
      </header>

      {/* Main Content Area */}
      <main className="flex-1">
        {/* Bottom Sheet Component */}
        <BottomSheet 
          initialFiles={files}
          onFilesChange={setFiles}
        />
      </main>

      {/* Footer */}
      <footer className="fixed bottom-2 left-4 text-xs text-gray-500">
        v{__APP_VERSION__} | Built with ❤️ by Solar IT Team
      </footer>
    </div>
  )
}

export default App