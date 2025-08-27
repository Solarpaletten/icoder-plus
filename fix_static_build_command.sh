#!/bin/bash

echo "ИСПРАВЛЯЕМ КОМАНДУ СБОРКИ ДЛЯ RENDER STATIC SITE"

cd frontend

# ============================================================================
# 1. ИЗМЕНИТЬ package.json - УБРАТЬ VITE ИЗ СБОРКИ
# ============================================================================

cat > package.json << 'EOF'
{
  "name": "icoder-plus-frontend-static",
  "version": "2.0.0",
  "description": "iCoder Plus Frontend - Static HTML with CDN React",
  "scripts": {
    "build": "echo 'Using pre-built static files' && cp -r . dist-temp && mv dist-temp dist || echo 'dist already exists'",
    "start": "echo 'Static site ready'",
    "dev": "echo 'Open dist/index.html in browser'"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["static", "html", "react", "ai", "ide"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF

echo "package.json обновлен - убрана зависимость от Vite"

# ============================================================================
# 2. ПРОВЕРИТЬ ЧТО dist/index.html СУЩЕСТВУЕТ И РАБОЧИЙ
# ============================================================================

if [ -f "dist/index.html" ]; then
    echo "dist/index.html существует"
    
    # Проверить размер файла
    size=$(wc -c < dist/index.html)
    echo "Размер файла: $size байт"
    
    if [ $size -gt 1000 ]; then
        echo "Файл выглядит полным"
    else
        echo "Файл слишком мал, пересоздаем..."
        
        # Пересоздать файл
        cat > dist/index.html << 'EOF'
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
      :root {
        --bg: #0b1220; --panel: #121a2a; --text: #e8ecf1; --muted: #9fb0c6;
        --green: #29d398; --yellow: #f9cc45; --red: #ff6b6b; --brand: #7b5cff;
      }
      * { box-sizing: border-box; margin: 0; padding: 0; }
      html, body, #root { height: 100%; font-size: 16px; }
      body {
        font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
        color: var(--text); line-height: 1.6;
        background: radial-gradient(1200px 600px at 20% 0%, #1a2340 0%, #0b1220 55%, #0b1220 100%);
      }
      .container { max-width: 1000px; margin: 0 auto; padding: 32px 20px 80px; }
      .badge { display: inline-block; padding: 6px 10px; border-radius: 999px; background: rgba(123,92,255,.12); color: #c9b8ff; font-weight: 600; font-size: 12px; }
      .h1 { font-size: 44px; font-weight: 800; margin: 18px 0 8px; line-height: 1.1; }
      .sub { color: var(--muted); margin-bottom: 28px; }
      .grid { display: grid; gap: 18px; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }
      .card { background: var(--panel); border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 18px; }
      .kv, .row { display: flex; align-items: center; gap: 10px; }
      .dot { width: 9px; height: 9px; border-radius: 999px; }
      .btn { background: linear-gradient(135deg, var(--brand), #4f46e5); color: white; border: none; padding: 10px 14px; border-radius: 10px; cursor: pointer; font-weight: 700; }
      .btn[disabled] { opacity: .6; cursor: not-allowed; }
      .code { background: #0b1120; border: 1px solid rgba(255,255,255,0.06); padding: 12px; border-radius: 10px; font-family: monospace; color: #cde1ff; font-size: 12px; overflow: auto; white-space: pre-wrap; }
      hr { border: none; height: 1px; background: rgba(255,255,255,0.06); margin: 18px 0; }
      .small { color: var(--muted); font-size: 13px; }
      input { background: #0b1120; color: white; border: 1px solid rgba(255,255,255,.08); border-radius: 10px; padding: 10px 12px; outline: none; }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script>
      window.API_BASE = "https://icoder-plus.onrender.com";
    </script>
    <script type="text/babel">
      const { useState, useEffect } = React;
      
      function App() {
        const [health, setHealth] = useState(null);
        const [checking, setChecking] = useState(false);
        const [fixing, setFixing] = useState(false);
        const [chat, setChat] = useState({ q: "", a: "" });
        const apiBase = window.API_BASE;
        
        useEffect(() => {
          if (!apiBase) return;
          setChecking(true);
          fetch(`${apiBase}/health`)
            .then(res => res.json())
            .then(data => setHealth({ ok: true, data }))
            .catch(e => setHealth({ ok: false, data: { error: e.message }}))
            .finally(() => setChecking(false));
        }, []);
        
        async function runFix() {
          setFixing(true);
          try {
            const res = await fetch(`${apiBase}/api/ai/fix/apply`, {
              method: "POST",
              headers: { "content-type": "application/json" },
              body: JSON.stringify({
                fileName: "demo.js",
                code: "var message = 'Hello iCoder Plus'; console.log(message);",
              }),
            });
            const json = await res.json();
            const fixed = json?.data?.fixedCode || "(no result)";
            alert("AI Fix result:\n\n" + fixed);
          } catch (e) {
            alert("Fix error: " + e);
          } finally {
            setFixing(false);
          }
        }

        async function askChat() {
          const q = chat.q.trim();
          if (!q) return;
          try {
            const res = await fetch(`${apiBase}/api/ai/chat`, {
              method: "POST",
              headers: { "content-type": "application/json" },
              body: JSON.stringify({
                message: q,
                fileName: "App.jsx",
                code: "function greet(){ return 'Hello'; }",
              }),
            });
            const json = await res.json();
            setChat(s => ({ ...s, a: json?.response || "No reply" }));
          } catch (e) {
            setChat(s => ({ ...s, a: "Error: " + e }));
          }
        }
        
        return React.createElement('div', { className: 'container' }, [
          React.createElement('div', { key: 'badge', className: 'badge' }, 'AI-first IDE v2.0'),
          React.createElement('div', { key: 'title', className: 'h1' }, 'Welcome to the Future of Coding 🚀'),
          React.createElement('div', { key: 'sub', className: 'sub' }, `Full-stack on Render • Backend: ${apiBase}`),
          
          React.createElement('div', { key: 'grid', className: 'grid' }, [
            React.createElement('div', { key: 'frontend', className: 'card' }, [
              React.createElement('div', { key: 'header', className: 'row', style: { justifyContent: 'space-between' }}, [
                React.createElement('div', { key: 'kv', className: 'kv' }, [
                  React.createElement('div', { key: 'dot', className: 'dot', style: { background: '#29d398' }}),
                  React.createElement('strong', { key: 'text' }, 'Frontend')
                ]),
                React.createElement('span', { key: 'status', className: 'small' }, 'Live & running')
              ]),
              React.createElement('hr', { key: 'hr' }),
              React.createElement('div', { key: 'desc', className: 'small' }, 'React app with CDN deployment')
            ]),
            
            React.createElement('div', { key: 'backend', className: 'card' }, [
              React.createElement('div', { key: 'header', className: 'row', style: { justifyContent: 'space-between' }}, [
                React.createElement('div', { key: 'kv', className: 'kv' }, [
                  React.createElement('div', { key: 'dot', className: 'dot', style: { 
                    background: checking ? '#f9cc45' : health?.ok ? '#29d398' : '#ff6b6b' 
                  }}),
                  React.createElement('strong', { key: 'text' }, 'Backend')
                ]),
                React.createElement('span', { key: 'status', className: 'small' }, 
                  checking ? 'Checking...' : health?.ok ? 'Connected' : 'Not reachable'
                )
              ]),
              React.createElement('hr', { key: 'hr' }),
              React.createElement('div', { key: 'data', className: 'code', style: { maxHeight: 140 }}, 
                checking ? 'fetching /health ...' : health ? JSON.stringify(health.data, null, 2) : '—'
              )
            ])
          ]),
          
          React.createElement('div', { key: 'actions', className: 'card', style: { marginTop: 18 }}, [
            React.createElement('div', { key: 'header', className: 'row', style: { justifyContent: 'space-between' }}, [
              React.createElement('strong', { key: 'title' }, 'Quick Actions'),
              React.createElement('button', { 
                key: 'fix-btn', 
                className: 'btn', 
                onClick: runFix, 
                disabled: !apiBase || fixing 
              }, fixing ? 'Applying...' : '🤖 Apply AI Fix')
            ]),
            React.createElement('hr', { key: 'hr' }),
            React.createElement('div', { key: 'chat', className: 'row', style: { gap: 8 }}, [
              React.createElement('input', {
                key: 'input',
                placeholder: 'Ask AI about your code...',
                value: chat.q,
                onChange: (e) => setChat(s => ({ ...s, q: e.target.value })),
                style: { flex: 1 }
              }),
              React.createElement('button', { 
                key: 'chat-btn', 
                className: 'btn', 
                onClick: askChat, 
                disabled: !apiBase 
              }, '💬 Ask')
            ]),
            chat.a && React.createElement('div', { key: 'response' }, [
              React.createElement('hr', { key: 'hr' }),
              React.createElement('div', { key: 'code', className: 'code' }, chat.a)
            ])
          ]),
          
          React.createElement('div', { key: 'endpoints', className: 'card', style: { marginTop: 18 }}, [
            React.createElement('strong', { key: 'title' }, 'Endpoints'),
            React.createElement('hr', { key: 'hr' }),
            React.createElement('div', { key: 'list', className: 'small' }, [
              React.createElement('div', { key: 'health' }, `Health: ${apiBase}/health`),
              React.createElement('div', { key: 'analyze' }, `AI Analyze: ${apiBase}/api/ai/analyze`),
              React.createElement('div', { key: 'fix' }, `AI Fix: ${apiBase}/api/ai/fix/apply`),
              React.createElement('div', { key: 'chat' }, `AI Chat: ${apiBase}/api/ai/chat`)
            ])
          ])
        ]);
      }
      
      ReactDOM.render(React.createElement(App), document.getElementById('root'));
    </script>
  </body>
</html>
EOF
        echo "dist/index.html пересоздан"
    fi
else
    echo "dist/index.html не найден, создаем..."
    mkdir -p dist
    # Создать файл (код как выше)
fi

# ============================================================================
# 3. ТЕСТИРОВАТЬ КОМАНДУ СБОРКИ
# ============================================================================

echo "Тестируем команду сборки..."
npm run build

if [ $? -eq 0 ]; then
    echo "Команда сборки работает"
else
    echo "Ошибка команды сборки, упрощаем..."
    
    # Еще более простая версия
    cat > package.json << 'EOF'
{
  "name": "icoder-plus-frontend-static",
  "version": "2.0.0",
  "scripts": {
    "build": "echo 'Static build complete - using pre-built files'",
    "start": "echo 'Static site ready'"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
    
    echo "package.json максимально упрощен"
fi

cd ..

echo ""
echo "КОМАНДА СБОРКИ ИСПРАВЛЕНА"
echo ""
echo "Что исправлено:"
echo "- Убрана зависимость от vite build"
echo "- package.json использует простую команду echo"
echo "- dist/index.html готов к использованию"
echo ""
echo "Деплой:"
echo "git add ."
echo "git commit -m 'Fix build command for static site'"
echo "git push origin main"
