cd frontend
mkdir -p dist
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
      body {
        margin: 0; padding: 20px; font-family: system-ui, sans-serif;
        background: radial-gradient(circle at 20% 0%, #1a2340 0%, #0b1220 55%);
        color: white; min-height: 100vh;
      }
      .container { max-width: 800px; margin: 0 auto; }
      .title { font-size: 40px; font-weight: 800; margin: 20px 0; }
      .card { background: #121a2a; border: 1px solid rgba(255,255,255,0.06); border-radius: 12px; padding: 18px; margin: 18px 0; }
      .status { display: flex; align-items: center; gap: 8px; margin: 12px 0; }
      .dot { width: 8px; height: 8px; border-radius: 50%; }
      .green { background: #29d398; }
      .code { background: #0b1120; padding: 12px; border-radius: 8px; font-family: monospace; color: #cde1ff; font-size: 12px; }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script>window.API_BASE = "https://icoder-plus.onrender.com";</script>
    <script type="text/babel">
      const { useState, useEffect } = React;
      
      function App() {
        const [health, setHealth] = useState(null);
        
        useEffect(() => {
          fetch(window.API_BASE + '/health')
            .then(res => res.json())
            .then(data => setHealth({ ok: true, data }))
            .catch(e => setHealth({ ok: false, data: { error: e.message }}));
        }, []);
        
        return (
          <div className="container">
            <div className="title">iCoder Plus Live</div>
            <div className="card">
              <div className="status">
                <div className="dot green"></div>
                <strong>Frontend: Running</strong>
              </div>
            </div>
            <div className="card">
              <div className="status">
                <div className={`dot ${health?.ok ? 'green' : 'red'}`}></div>
                <strong>Backend: {health?.ok ? 'Connected' : 'Error'}</strong>
              </div>
              <div className="code">
                {health ? JSON.stringify(health.data, null, 2) : 'Loading...'}
              </div>
            </div>
          </div>
        );
      }
      
      ReactDOM.render(React.createElement(App), document.getElementById('root'));
    </script>
  </body>
</html>
EOF

ls -la dist/
cd ..