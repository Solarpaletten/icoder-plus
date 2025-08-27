import React, { useEffect, useMemo, useState } from "react";

const apiBase =
  import.meta.env.VITE_API_URL?.replace(/\/$/, "") ||
  (typeof window !== "undefined" && window.API_BASE) ||
  "";

export default function App() {
  const [health, setHealth] = useState(null);
  const [checking, setChecking] = useState(false);
  const [fixing, setFixing] = useState(false);
  const [chat, setChat] = useState({ q: "", a: "" });
  const reachable = useMemo(() => Boolean(apiBase), []);

  useEffect(() => {
    if (!reachable) return;
    (async () => {
      setChecking(true);
      try {
        const res = await fetch(`${apiBase}/health`, { cache: "no-store" });
        const json = await res.json();
        setHealth({ ok: res.ok, data: json });
      } catch (e) {
        setHealth({ ok: false, data: { error: String(e) } });
      } finally {
        setChecking(false);
      }
    })();
  }, [reachable]);

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
      const fixed = json?.data?.fixedCode ?? "(no result)";
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
      setChat((s) => ({ ...s, a: json?.response || json?.data?.message || "No reply" }));
    } catch (e) {
      setChat((s) => ({ ...s, a: "Error: " + e }));
    }
  }

  return (
    <div className="container">
      <div className="badge">AI-first IDE v2.0</div>
      <div className="h1">Welcome to the Future of Coding 🚀</div>
      <div className="sub">Full-stack on Render • Backend: {apiBase || "– not set –"}</div>

      <div className="grid">
        <div className="card">
          <div className="row" style={{ justifyContent: "space-between" }}>
            <div className="kv">
              <div className="dot" style={{ background: "#29d398" }} />
              <strong>Frontend</strong>
            </div>
            <span className="small">Live & running</span>
          </div>
          <hr />
          <div className="small">This is the React app deployed on Render Static Site.</div>
        </div>

        <div className="card">
          <div className="row" style={{ justifyContent: "space-between" }}>
            <div className="kv">
              <div
                className="dot"
                style={{ background: checking ? "#f9cc45" : health?.ok ? "#29d398" : "#ff6b6b" }}
              />
              <strong>Backend</strong>
            </div>
            <span className="small">
              {checking ? "Checking…" : health?.ok ? "Connected" : "Not reachable"}
            </span>
          </div>
          <hr />
          <div className="code" style={{ maxHeight: 140 }}>
            {checking && "fetching /health …"}
            {!checking && health && JSON.stringify(health.data, null, 2)}
            {!checking && !health && "—"}
          </div>
          <div style={{ marginTop: 12 }} className="small">
            Health: <code>{apiBase ? `${apiBase}/health` : "—"}</code>
          </div>
        </div>
      </div>

      <div className="card" style={{ marginTop: 18 }}>
        <div className="row" style={{ justifyContent: "space-between" }}>
          <strong>Quick Actions</strong>
          <button className="btn" onClick={runFix} disabled={!reachable || fixing}>
            {fixing ? "Applying…" : "🤖 Apply AI Fix"}
          </button>
        </div>
        <hr />
        <div className="row" style={{ gap: 8 }}>
          <input
            placeholder="Ask AI about your code…"
            value={chat.q}
            onChange={(e) => setChat((s) => ({ ...s, q: e.target.value }))}
            style={{
              flex: 1,
              background: "#0b1120",
              color: "white",
              border: "1px solid rgba(255,255,255,.08)",
              borderRadius: 10,
              padding: "10px 12px",
              outline: "none",
            }}
          />
          <button className="btn" onClick={askChat} disabled={!reachable}>
            💬 Ask
          </button>
        </div>
        {chat.a && (
          <>
            <hr />
            <div className="code">{chat.a}</div>
          </>
        )}
      </div>

      <div className="card" style={{ marginTop: 18 }}>
        <strong>Endpoints</strong>
        <hr />
        <div className="small">
          <div>Health: <code>{apiBase}/health</code></div>
          <div>AI Analyze: <code>{apiBase}/api/ai/analyze</code></div>
          <div>AI Fix: <code>{apiBase}/api/ai/fix/apply</code></div>
          <div>AI Chat: <code>{apiBase}/api/ai/chat</code></div>
        </div>
      </div>

      <div className="card" style={{ marginTop: 18 }}>
        <strong>🚀 Deployment Status</strong>
        <hr />
        <div className="small">
          <div>✅ Frontend: Render Static Site</div>
          <div>✅ Backend: Render Web Service</div>
          <div>✅ API Connection: {health?.ok ? "Active" : "Testing..."}</div>
          <div>⚡ Version: 2.0.0</div>
        </div>
      </div>
    </div>
  );
}
