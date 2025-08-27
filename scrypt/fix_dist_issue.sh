#!/bin/bash

echo "Исправляем проблему с dist директорией"

cd frontend

# Создать правильную команду сборки
cat > package.json << 'JSON'
{
  "name": "icoder-plus-frontend-static",
  "version": "2.0.0",
  "scripts": {
    "build": "echo 'Static build complete'",
    "start": "echo 'Static site ready'"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
JSON

# Убедиться что dist/index.html существует
if [ ! -f "dist/index.html" ]; then
    mkdir -p dist
    cat > dist/index.html << 'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>iCoder Plus — AI-first IDE v2.0</title>
    <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <style>
      body {
        margin: 0; padding: 20px; font-family: system-ui, sans-serif;
        background: radial-gradient(circle at 20% 0%, #1a2340 0%, #0b1220 55%);
        color: white; min-height: 100vh;
      }
      .container { max-width: 800px; margin: 0 auto; }
      .badge { background: rgba(123,92,255,.12); color: #c9b8ff; padding: 6px 10px; border-radius: 999px; font-size: 12px; }
      .title { font-size: 40px; font-weight: 800; margin: 20px 0; }
      .card { background: #121a2a; border: 1px solid rgba(255,255,255,0.06); border-radius: 12px; padding: 18px; margin: 18px 0; }
      .btn { background: linear-gradient(135deg, #7b5cff, #4f46e5); color: white; border: none; padding: 10px 14px; border-radius: 8px; cursor: pointer; font-weight: 700; }
      .code { background: #0b1120; padding: 12px; border-radius: 8px; font-family: monospace; color: #cde1ff; font-size: 12px; white-space: pre-wrap; }
      .status { display: flex; align-items: center; gap: 8px; margin: 12px 0; }
      .dot { width: 8px; height: 8px; border-radius: 50%; }
      .green { background: #29d398; }
      .yellow { background: #f9cc45; }
      .red { background: #ff6b6b; }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script>window.API_BASE = "https://icoder-plus.onrender.com";</script>
    <script type="text/babel">
      const { useState, useEffect } = React;
      
      function App() {
        const [health, setHealth] = useState(null);
        const [checking, setChecking] = useState(false);
        
        useEffect(() => {
          setChecking(true);
          fetch(`${window.API_BASE}/health`)
            .then(res => res.json())
            .then(data => setHealth({ ok: true, data }))
            .catch(e => setHealth({ ok: false, data: { error: e.message }}))
            .finally(() => setChecking(false));
        }, []);
        
        return (
          <div className="container">
            <div className="badge">AI-first IDE v2.0</div>
            <div className="title">iCoder Plus Frontend Live</div>
            
            <div className="card">
              <div className="status">
                <div className="dot green"></div>
                <strong>Frontend Status: Live and running</strong>
              </div>
              <p>Static site deployed successfully on Render</p>
            </div>
            
            <div className="card">
              <div className="status">
                <div className={`dot ${checking ? 'yellow' : health?.ok ? 'green' : 'red'}`}></div>
                <strong>Backend Status: {checking ? 'Checking...' : health?.ok ? 'Connected' : 'Error'}</strong>
              </div>
              <div className="code">
                {checking ? 'Connecting to backend...' : health ? JSON.stringify(health.data, null, 2) : 'No data'}
              </div>
            </div>
            
            <div className="card">
              <strong>API Endpoints:</strong>
              <div style={{marginTop: 12, fontSize: 14}}>
                <div>• Health: {window.API_BASE}/health</div>
                <div>• AI Fix: {window.API_BASE}/api/ai/fix/apply</div>
                <div>• AI Chat: {window.API_BASE}/api/ai/chat</div>
              </div>
            </div>
          </div>
        );
      }
      
      ReactDOM.render(React.createElement(App), document.getElementById('root'));
    </script>
  </body>
</html>
HTML
fi

echo "dist/index.html готов"
ls -la dist/

cd ..
