export const initialFiles = [
  {
    id: 'root',
    name: 'My Project',
    type: 'folder',
    expanded: true,
    children: [
      {
        id: 'index-html',
        name: 'index.html',
        type: 'file',
        content: `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iCoder Plus Demo</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #1f6feb; }
        .btn { padding: 12px 24px; background: #1f6feb; color: white; border: none; border-radius: 6px; cursor: pointer; }
        .btn:hover { background: #1557d0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 iCoder Plus v2.1.1</h1>
        <p>Welcome to your Dual-Agent AI IDE!</p>
        <button class="btn" onclick="showMessage()">Test Button</button>
        <div id="output"></div>
    </div>
    <script>
        function showMessage() {
            document.getElementById('output').innerHTML = '<p>✨ Hello from iCoder Plus!</p>';
            console.log('Button clicked successfully!');
        }
    </script>
</body>
</html>`
      },
      {
        id: 'app-js',
        name: 'app.js', 
        type: 'file',
        content: `// iCoder Plus v2.1.1 Demo
console.log('🚀 App loaded');

function initApp() {
    console.log('Initializing iCoder Plus...');
    
    // Add event listeners
    document.addEventListener('DOMContentLoaded', () => {
        console.log('DOM ready!');
    });
}

initApp();`
      },
      {
        id: 'styles-folder',
        name: 'styles',
        type: 'folder',
        expanded: false,
        children: [
          {
            id: 'main-css',
            name: 'main.css',
            type: 'file',
            content: `/* iCoder Plus Styles */
:root {
  --primary: #1f6feb;
  --bg: #ffffff;
  --text: #24292f;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, sans-serif;
  background: var(--bg);
  color: var(--text);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}`
          }
        ]
      }
    ]
  }
]
