export const initialFiles = [
  {
    id: 'src',
    name: 'src',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'app-jsx',
        name: 'App.jsx',
        type: 'file',
        language: 'javascript',
        content: `import React from 'react'
import './App.css'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Welcome to iCoder Plus v2.2</h1>
        <p>Your AI-first IDE is ready!</p>
        <div className="features">
          <div className="feature">
            <h3>📂 File Tree</h3>
            <p>Full CRUD operations</p>
          </div>
          <div className="feature">
            <h3>🤖 Dual Agent AI</h3>
            <p>Dashka + Claudy system</p>
          </div>
          <div className="feature">
            <h3>⚡ Live Preview</h3>
            <p>Instant code execution</p>
          </div>
        </div>
      </header>
    </div>
  )
}

export default App`
      },
      {
        id: 'index-js',
        name: 'index.js',
        type: 'file',
        language: 'javascript',
        content: `import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

const root = ReactDOM.createRoot(document.getElementById('root'))
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)`
      },
      {
        id: 'components',
        name: 'components',
        type: 'folder',
        expanded: false,
        children: []
      }
    ]
  },
  {
    id: 'public',
    name: 'public',
    type: 'folder',
    expanded: false,
    children: [
      {
        id: 'index-html',
        name: 'index.html',
        type: 'file',
        language: 'html',
        content: `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>iCoder Plus v2.2</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>`
      }
    ]
  },
  {
    id: 'readme-md',
    name: 'README.md',
    type: 'file',
    language: 'markdown',
    content: `# iCoder Plus v2.2

AI-first IDE with File Tree Management

## Features

- ✅ File Tree CRUD operations
- ✅ Context menu (right-click)
- ✅ Drag & drop support
- ✅ Search functionality
- ✅ Auto-save to localStorage
- ✅ Multiple file tabs
- 🔄 Live preview (coming next)
- 🤖 Dual-Agent AI (Dashka + Claudy)

## Usage

1. Right-click in file tree for context menu
2. Create files and folders
3. Rename and delete items
4. Search files by name
5. Open multiple files in tabs

Built with React + Express by Solar IT Team
`
  }
]
