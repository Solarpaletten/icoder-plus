export const initialFiles = [
  {
    id: 'root-src',
    name: 'src',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'components-folder',
        name: 'components',
        type: 'folder',
        expanded: false,
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
        <h1>🚀 iCoder Plus Demo</h1>
        <p>Edit this file and see changes in real-time!</p>
        <div className="counter">
          <p>Count: {count}</p>
          <button onClick={() => setCount(count + 1)}>
            Increment
          </button>
          <button onClick={() => setCount(count - 1)}>
            Decrement
          </button>
          <button onClick={() => setCount(0)}>
            Reset
          </button>
        </div>
      </header>
    </div>
  )
}

export default App`
          }
        ]
      },
      {
        id: 'demo-folder',
        name: 'demo',
        type: 'folder',
        expanded: true,
        children: [
          {
            id: 'demo-html',
            name: 'demo.html',
            type: 'file',
            content: `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Preview Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1 { text-align: center; margin-bottom: 30px; }
        .demo-button {
            background: #4ecdc4;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            margin: 10px;
            transition: all 0.3s;
        }
        .demo-button:hover {
            background: #45b7aa;
            transform: translateY(-2px);
        }
        .counter {
            font-size: 24px;
            text-align: center;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 iCoder Plus Live Preview</h1>
        <p>This HTML file demonstrates the live preview functionality!</p>
        
        <div class="counter">
            Counter: <span id="count">0</span>
        </div>
        
        <div style="text-align: center;">
            <button class="demo-button" onclick="increment()">➕ Increment</button>
            <button class="demo-button" onclick="reset()">🔄 Reset</button>
            <button class="demo-button" onclick="logMessage()">📝 Log Message</button>
        </div>
    </div>

    <script>
        let counter = 0;
        const countEl = document.getElementById('count');
        
        function increment() {
            counter++;
            countEl.textContent = counter;
            console.log('Counter:', counter);
        }
        
        function reset() {
            counter = 0;
            countEl.textContent = counter;
            console.log('Counter reset');
        }
        
        function logMessage() {
            console.log('Hello from iCoder Plus!', new Date().toLocaleTimeString());
        }
        
        console.log('🚀 Live Preview Demo loaded!');
    </script>
</body>
</html>`
          },
          {
            id: 'demo-js',
            name: 'demo.js',
            type: 'file',
            content: `// 🚀 iCoder Plus JavaScript Demo
console.log('🎉 Welcome to iCoder Plus Live Preview!');

// Basic calculations
const numbers = [1, 2, 3, 4, 5];
const sum = numbers.reduce((a, b) => a + b, 0);
const average = sum / numbers.length;

console.log('📊 Array:', numbers);
console.log('➕ Sum:', sum);
console.log('📈 Average:', average);

// Object manipulation
const user = {
    name: 'Developer',
    age: 25,
    skills: ['JavaScript', 'React', 'Node.js']
};

console.log('👤 User Info:', user);
console.log('🔧 Skills:', user.skills.join(', '));

// Function demonstration
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

const fibSequence = [];
for (let i = 0; i < 8; i++) {
    fibSequence.push(fibonacci(i));
}

console.log('🔢 Fibonacci Sequence:', fibSequence);

console.log('🏁 JavaScript demo completed!');`
          }
        ]
      }
    ]
  },
  {
    id: 'public-folder',
    name: 'public',
    type: 'folder',
    expanded: false,
    children: [
      {
        id: 'index-html',
        name: 'index.html',
        type: 'file',
        content: `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>iCoder Plus v2.2</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>`
      }
    ]
  },
  {
    id: 'readme-md',
    name: 'README.md',
    type: 'file',
    content: `# 🚀 iCoder Plus v2.2

AI-powered IDE with Live Preview functionality.

## Features

- ✅ Monaco Editor with syntax highlighting
- ✅ File Tree with VS Code behavior  
- ✅ Live Preview for HTML, CSS, JavaScript
- ✅ AI Assistant (Dashka & Claudy)
- ✅ Real-time console output
- ✅ Professional dark theme

## Usage

1. Create or open files in the File Tree
2. Edit code in the Monaco Editor
3. Click the ▶ Run button to execute
4. View results in the Live Preview panel

## Demo Files

Try these demo files to test Live Preview:
- \`src/demo/demo.html\` - Interactive HTML demo
- \`src/demo/demo.js\` - JavaScript execution demo

Enjoy coding! 🎉`
  }
]
