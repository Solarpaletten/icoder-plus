import { useState, useCallback } from 'react'
import JSZip from 'jszip'

export const useFileSystem = () => {
  const [isLoading, setIsLoading] = useState(false)

  // Create new project with template
  const createProject = useCallback((template = 'empty') => {
    const templates = {
      empty: [],
      react: [
        {
          id: 'src-folder',
          name: 'src',
          type: 'folder',
          expanded: true,
          children: [
            {
              id: 'app-jsx',
              name: 'App.jsx',
              type: 'file',
              content: `import React, { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <header className="app-header">
        <h1>React App</h1>
        <p>Edit this component to get started</p>
        <button onClick={() => setCount(count + 1)}>
          Count: {count}
        </button>
      </header>
    </div>
  )
}

export default App`
            },
            {
              id: 'app-css',
              name: 'App.css',
              type: 'file',
              content: `.app {
  text-align: center;
  padding: 2rem;
}

.app-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
  border-radius: 10px;
  color: white;
}

button {
  background: #4ecdc4;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  margin-top: 1rem;
}

button:hover {
  background: #45b7aa;
}`
            }
          ]
        },
        {
          id: 'index-html',
          name: 'index.html',
          type: 'file',
          content: `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>React App</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>`
        },
        {
          id: 'package-json',
          name: 'package.json',
          type: 'file',
          content: `{
  "name": "react-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "vite": "^4.4.0",
    "@vitejs/plugin-react": "^4.0.0"
  }
}`
        }
      ],
      html: [
        {
          id: 'index-html',
          name: 'index.html',
          type: 'file',
          content: `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Welcome to My Website</h1>
    </header>
    
    <main>
        <p>This is a simple HTML template.</p>
        <button onclick="greet()">Click Me</button>
    </main>
    
    <script src="script.js"></script>
</body>
</html>`
        },
        {
          id: 'style-css',
          name: 'style.css',
          type: 'file',
          content: `* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
}

header {
    text-align: center;
    padding: 2rem;
    color: white;
}

main {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    background: rgba(255, 255, 255, 0.9);
    border-radius: 10px;
    margin-top: 2rem;
}

button {
    background: #4ecdc4;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 16px;
    margin-top: 1rem;
}

button:hover {
    background: #45b7aa;
}`
        },
        {
          id: 'script-js',
          name: 'script.js',
          type: 'file',
          content: `function greet() {
    alert('Hello from iCoder Plus!')
    console.log('Button clicked at:', new Date().toLocaleTimeString())
}

// Initialize page
document.addEventListener('DOMContentLoaded', () => {
    console.log('Page loaded successfully!')
    
    // Add some interactivity
    const button = document.querySelector('button')
    if (button) {
        button.addEventListener('mouseenter', () => {
            button.style.transform = 'translateY(-2px)'
        })
        
        button.addEventListener('mouseleave', () => {
            button.style.transform = 'translateY(0)'
        })
    }
})`
        }
      ]
    }

    return templates[template] || templates.empty
  }, [])

  // Save project as ZIP
  const saveProjectAsZip = useCallback(async (fileTree, projectName = 'icoder-project') => {
    setIsLoading(true)
    try {
      const zip = new JSZip()
      
      const addToZip = (items, folder = zip) => {
        items.forEach(item => {
          if (item.type === 'file') {
            folder.file(item.name, item.content || '')
          } else if (item.type === 'folder' && item.children) {
            const subFolder = folder.folder(item.name)
            addToZip(item.children, subFolder)
          }
        })
      }

      addToZip(fileTree)
      
      const content = await zip.generateAsync({ type: 'blob' })
      
      // Download ZIP
      const url = URL.createObjectURL(content)
      const a = document.createElement('a')
      a.href = url
      a.download = `${projectName}.zip`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      
    } catch (error) {
      console.error('Error saving project:', error)
    } finally {
      setIsLoading(false)
    }
  }, [])

  // Load project from ZIP
  const loadProjectFromZip = useCallback(async (file) => {
    setIsLoading(true)
    try {
      const zip = new JSZip()
      const contents = await zip.loadAsync(file)
      
      const fileTree = []
      const folders = {}
      
      // First pass: create all folders
      Object.keys(contents.files).forEach(path => {
        const pathParts = path.split('/')
        pathParts.reduce((current, part, index) => {
          if (index === pathParts.length - 1 && !contents.files[path].dir) {
            return current // Skip files in first pass
          }
          
          const fullPath = pathParts.slice(0, index + 1).join('/')
          if (!folders[fullPath]) {
            const folder = {
              id: Math.random().toString(36).substr(2, 9),
              name: part,
              type: 'folder',
              expanded: false,
              children: []
            }
            folders[fullPath] = folder
            
            if (index === 0) {
              fileTree.push(folder)
            } else {
              const parentPath = pathParts.slice(0, index).join('/')
              folders[parentPath].children.push(folder)
            }
          }
          return folders[fullPath]
        }, null)
      })
      
      // Second pass: add files
      for (const [path, zipEntry] of Object.entries(contents.files)) {
        if (!zipEntry.dir) {
          const pathParts = path.split('/')
          const fileName = pathParts[pathParts.length - 1]
          const content = await zipEntry.async('text')
          
          const file = {
            id: Math.random().toString(36).substr(2, 9),
            name: fileName,
            type: 'file',
            content: content
          }
          
          if (pathParts.length === 1) {
            fileTree.push(file)
          } else {
            const parentPath = pathParts.slice(0, -1).join('/')
            if (folders[parentPath]) {
              folders[parentPath].children.push(file)
            }
          }
        }
      }
      
      return fileTree
      
    } catch (error) {
      console.error('Error loading project:', error)
      return []
    } finally {
      setIsLoading(false)
    }
  }, [])

  return {
    isLoading,
    createProject,
    saveProjectAsZip,
    loadProjectFromZip
  }
}
