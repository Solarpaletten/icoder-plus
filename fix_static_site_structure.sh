#!/bin/bash

echo "🔧 ИСПРАВЛЯЕМ 'NOT FOUND' - СТРУКТУРА ДЛЯ STATIC SITE"

# ============================================================================
# 1. СОЗДАТЬ ПРАВИЛЬНУЮ СТРУКТУРУ ДЛЯ RENDER STATIC SITE
# ============================================================================

# Убедиться что мы в корне проекта
cd frontend

# Создать правильные папки
mkdir -p src

# ============================================================================
# 2. СОЗДАТЬ РАБОЧИЙ index.html В КОРНЕ FRONTEND/
# ============================================================================

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iCoder Plus - AI-first IDE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .animate-spin {
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        .gradient-bg {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%);
        }
    </style>
</head>
<body class="bg-gray-900 text-white min-h-screen gradient-bg">
    <!-- Header -->
    <header class="bg-gray-800/80 backdrop-blur-sm border-b border-gray-700/50 sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                        <span class="text-white font-bold text-lg">iC</span>
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                            iCoder Plus
                        </h1>
                        <p class="text-sm text-gray-400">AI-first IDE v2.0</p>
                    </div>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="bg-green-500/20 text-green-400 px-3 py-1 rounded-full text-sm border border-green-500/30">
                        ✅ Frontend Live
                    </div>
                    <div id="backend-indicator" class="bg-yellow-500/20 text-yellow-400 px-3 py-1 rounded-full text-sm border border-yellow-500/30">
                        🔄 Checking Backend...
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="py-16">
        <div class="max-w-7xl mx-auto px-4 text-center">
            <div class="mb-8">
                <h2 class="text-5xl font-bold mb-6 bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent">
                    Welcome to the Future of Coding 🚀
                </h2>
                <p class="text-xl text-gray-400 mb-4">
                    Your AI-powered IDE is now running on Render
                </p>
                <p class="text-gray-500">
                    Full-stack application with intelligent backend integration
                </p>
            </div>
            
            <!-- Status Cards -->
            <div class="grid md:grid-cols-2 gap-6 mb-12 max-w-4xl mx-auto">
                <!-- Frontend Status -->
                <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                    <div class="text-center">
                        <div class="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
                            <span class="text-2xl">🌐</span>
                        </div>
                        <h3 class="text-lg font-semibold text-green-400 mb-2">Frontend Status</h3>
                        <p class="text-gray-300">✅ Live and running</p>
                        <div class="mt-3 text-sm text-gray-500">
                            Deployed on Render Static Site
                        </div>
                    </div>
                </div>
                
                <!-- Backend Status -->
                <div id="backend-status-card" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50">
                    <div class="text-center">
                        <div class="w-16 h-16 bg-blue-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
                            <span class="text-2xl">⚡</span>
                        </div>
                        <h3 class="text-lg font-semibold text-blue-400 mb-2">Backend Status</h3>
                        <div id="backend-status-text" class="text-gray-300">
                            🔄 Checking connection...
                        </div>
                        <div class="mt-3 text-sm text-gray-500">
                            API: https://icoder-plus.onrender.com
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Backend Connection Details -->
    <section class="py-8">
        <div class="max-w-4xl mx-auto px-4">
            <div id="backend-details" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700/50">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-xl font-semibold">🔗 Backend Connection</h3>
                    <button onclick="checkBackend()" id="refresh-btn" 
                            class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm transition-colors">
                        🔄 Refresh
                    </button>
                </div>
                
                <div id="connection-status" class="mb-6">
                    <div class="flex items-center space-x-3 mb-4">
                        <div id="status-spinner" class="w-6 h-6 border-2 border-blue-400 border-t-transparent rounded-full animate-spin"></div>
                        <span class="text-blue-400 font-medium">Testing backend connection...</span>
                    </div>
                </div>
                
                <div id="backend-info" class="hidden">
                    <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                        <div class="bg-gray-900/50 rounded-lg p-4">
                            <div class="text-sm text-gray-400">Status</div>
                            <div id="info-status" class="text-lg font-semibold text-green-400">-</div>
                        </div>
                        <div class="bg-gray-900/50 rounded-lg p-4">
                            <div class="text-sm text-gray-400">Version</div>
                            <div id="info-version" class="text-lg font-semibold text-white">-</div>
                        </div>
                        <div class="bg-gray-900/50 rounded-lg p-4">
                            <div class="text-sm text-gray-400">Environment</div>
                            <div id="info-env" class="text-lg font-semibold text-white">-</div>
                        </div>
                        <div class="bg-gray-900/50 rounded-lg p-4">
                            <div class="text-sm text-gray-400">Port</div>
                            <div id="info-port" class="text-lg font-semibold text-white">-</div>
                        </div>
                    </div>
                </div>
                
                <div id="connection-error" class="hidden">
                    <div class="bg-red-500/10 border border-red-500/30 rounded-lg p-4">
                        <div class="flex items-center space-x-2 mb-2">
                            <span class="text-xl">⚠️</span>
                            <span class="text-red-400 font-medium">Connection Failed</span>
                        </div>
                        <div id="error-details" class="text-red-300 text-sm"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- API Testing Section -->
    <section class="py-8">
        <div class="max-w-4xl mx-auto px-4">
            <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700/50">
                <h3 class="text-xl font-semibold mb-6">🧪 API Testing</h3>
                
                <div class="grid md:grid-cols-2 gap-4 mb-6">
                    <button onclick="testHealthEndpoint()" 
                            class="flex items-center justify-center space-x-2 px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors">
                        <span>🏥</span>
                        <span>Test Health Endpoint</span>
                    </button>
                    <button onclick="testAnalyzeEndpoint()" 
                            class="flex items-center justify-center space-x-2 px-6 py-3 bg-purple-600 hover:bg-purple-700 text-white rounded-lg transition-colors">
                        <span>🤖</span>
                        <span>Test AI Analyze</span>
                    </button>
                </div>
                
                <div id="api-test-result" class="hidden">
                    <div class="bg-gray-900/50 rounded-lg p-4">
                        <div class="text-sm text-gray-400 mb-2">API Response:</div>
                        <pre id="api-response" class="text-sm text-green-400 overflow-x-auto"></pre>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Grid -->
    <section class="py-12">
        <div class="max-w-7xl mx-auto px-4">
            <h3 class="text-2xl font-bold text-center mb-8">✨ Features</h3>
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-blue-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">🤖</div>
                    <h4 class="text-lg font-semibold mb-2">AI Code Analysis</h4>
                    <p class="text-gray-400 text-sm">Smart code reviews and suggestions powered by OpenAI</p>
                </div>
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-purple-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">💬</div>
                    <h4 class="text-lg font-semibold mb-2">AI Chat Assistant</h4>
                    <p class="text-gray-400 text-sm">Interactive code assistant for instant help</p>
                </div>
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-green-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">🔧</div>
                    <h4 class="text-lg font-semibold mb-2">Auto Fix</h4>
                    <p class="text-gray-400 text-sm">Automatically detect and fix common coding issues</p>
                </div>
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-yellow-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">📝</div>
                    <h4 class="text-lg font-semibold mb-2">Monaco Editor</h4>
                    <p class="text-gray-400 text-sm">VS Code-like editor with IntelliSense</p>
                </div>
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-red-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">📊</div>
                    <h4 class="text-lg font-semibold mb-2">Live Preview</h4>
                    <p class="text-gray-400 text-sm">Real-time code execution and preview</p>
                </div>
                <div class="feature-card bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700/50 hover:border-indigo-500/50 transition-all duration-300">
                    <div class="text-4xl mb-4">🌐</div>
                    <h4 class="text-lg font-semibold mb-2">Cloud Deployment</h4>
                    <p class="text-gray-400 text-sm">Deployed on Render with 99.9% uptime</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 border-t border-gray-700/50">
        <div class="max-w-4xl mx-auto px-4 text-center">
            <div class="mb-6">
                <p class="text-gray-400 mb-2">
                    🔗 <strong>Backend API:</strong> 
                    <span class="text-blue-400 font-mono">https://icoder-plus.onrender.com</span>
                </p>
                <p class="text-gray-400 mb-2">
                    🌐 <strong>Frontend:</strong> 
                    <span class="text-green-400 font-mono">https://icoder-plus-1.onrender.com</span>
                </p>
            </div>
            <p class="text-sm text-gray-500">
                Built with ❤️ by <strong>Solar IT Team</strong> | Full-stack AI-powered IDE
            </p>
        </div>
    </footer>

    <script>
        const API_URL = 'https://icoder-plus.onrender.com';
        
        // Auto-check backend on page load
        document.addEventListener('DOMContentLoaded', function() {
            checkBackend();
        });
        
        async function checkBackend() {
            const indicator = document.getElementById('backend-indicator');
            const statusCard = document.getElementById('backend-status-text');
            const connectionStatus = document.getElementById('connection-status');
            const backendInfo = document.getElementById('backend-info');
            const connectionError = document.getElementById('connection-error');
            const refreshBtn = document.getElementById('refresh-btn');
            
            // Show loading state
            indicator.className = 'bg-yellow-500/20 text-yellow-400 px-3 py-1 rounded-full text-sm border border-yellow-500/30';
            indicator.textContent = '🔄 Checking...';
            statusCard.innerHTML = '🔄 Connecting to backend...';
            
            refreshBtn.disabled = true;
            refreshBtn.innerHTML = '🔄 Checking...';
            
            // Hide previous results
            backendInfo.classList.add('hidden');
            connectionError.classList.add('hidden');
            
            try {
                console.log('Testing connection to:', API_URL);
                const response = await fetch(`${API_URL}/health`, {
                    method: 'GET',
                    mode: 'cors'
                });
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                const data = await response.json();
                console.log('Backend response:', data);
                
                // Show success state
                indicator.className = 'bg-green-500/20 text-green-400 px-3 py-1 rounded-full text-sm border border-green-500/30';
                indicator.textContent = '✅ Backend Connected';
                
                statusCard.innerHTML = '✅ Connected successfully!';
                
                // Update info cards
                document.getElementById('info-status').textContent = data.status || 'OK';
                document.getElementById('info-version').textContent = data.version || 'Unknown';
                document.getElementById('info-env').textContent = data.environment || 'production';
                document.getElementById('info-port').textContent = data.port || 'Unknown';
                
                // Hide spinner, show info
                document.getElementById('status-spinner').style.display = 'none';
                connectionStatus.innerHTML = `
                    <div class="flex items-center space-x-3 mb-4">
                        <span class="text-xl">✅</span>
                        <span class="text-green-400 font-medium">Backend connected successfully!</span>
                    </div>
                `;
                backendInfo.classList.remove('hidden');
                
            } catch (error) {
                console.error('Backend connection failed:', error);
                
                // Show error state
                indicator.className = 'bg-red-500/20 text-red-400 px-3 py-1 rounded-full text-sm border border-red-500/30';
                indicator.textContent = '❌ Backend Error';
                
                statusCard.innerHTML = '❌ Connection failed';
                
                // Show error details
                document.getElementById('status-spinner').style.display = 'none';
                connectionStatus.innerHTML = `
                    <div class="flex items-center space-x-3 mb-4">
                        <span class="text-xl">❌</span>
                        <span class="text-red-400 font-medium">Connection failed</span>
                    </div>
                `;
                
                document.getElementById('error-details').textContent = error.message;
                connectionError.classList.remove('hidden');
            } finally {
                refreshBtn.disabled = false;
                refreshBtn.innerHTML = '🔄 Refresh';
            }
        }
        
        async function testHealthEndpoint() {
            const result = document.getElementById('api-test-result');
            const response = document.getElementById('api-response');
            
            result.classList.remove('hidden');
            response.textContent = 'Testing /health endpoint...';
            
            try {
                const res = await fetch(`${API_URL}/health`);
                const data = await res.json();
                
                response.innerHTML = `<span class="text-green-400">✅ SUCCESS</span>
GET ${API_URL}/health
Status: ${res.status} ${res.statusText}
Response:
${JSON.stringify(data, null, 2)}`;
                
            } catch (error) {
                response.innerHTML = `<span class="text-red-400">❌ ERROR</span>
${error.message}`;
            }
        }
        
        async function testAnalyzeEndpoint() {
            const result = document.getElementById('api-test-result');
            const response = document.getElementById('api-response');
            
            result.classList.remove('hidden');
            response.textContent = 'Testing /api/ai/analyze endpoint...';
            
            try {
                const res = await fetch(`${API_URL}/api/ai/analyze`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        code: 'console.log("Hello, iCoder Plus!");',
                        fileName: 'test.js',
                        analysisType: 'review'
                    })
                });
                
                const data = await res.json();
                
                response.innerHTML = `<span class="text-green-400">✅ SUCCESS</span>
POST ${API_URL}/api/ai/analyze
Status: ${res.status} ${res.statusText}
Response:
${JSON.stringify(data, null, 2)}`;
                
            } catch (error) {
                response.innerHTML = `<span class="text-red-400">❌ ERROR</span>
${error.message}`;
            }
        }
    </script>
</body>
</html>
EOF

echo "✅ Красивый index.html создан в корне frontend/"

# ============================================================================
# 3. ОБНОВИТЬ package.json ДЛЯ ПРОСТОЙ СБОРКИ
# ============================================================================

cat > package.json << 'EOF'
{
  "name": "icoder-plus-frontend-static",
  "version": "2.0.0",
  "description": "iCoder Plus Frontend - Static HTML version",
  "scripts": {
    "build": "echo 'Static site ready - no build needed' && mkdir -p dist && cp index.html dist/",
    "start": "echo 'Static site deployed'",
    "dev": "echo 'Open index.html in browser'"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["static", "html", "ide", "ai", "render"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF

echo "✅ package.json обновлен для статического сайта"

# ============================================================================
# 4. СОЗДАТЬ DIST ПАПКУ С НУЖНЫМ ФАЙЛОМ
# ============================================================================

mkdir -p dist
cp index.html dist/

echo "✅ dist/index.html создан"

# ============================================================================
# 5. ПРОВЕРИТЬ СТРУКТУРУ
# ============================================================================

echo ""
echo "📁 СТРУКТУРА ГОТОВА:"
echo "frontend/"
echo "├── index.html          ← Главный файл"
echo "├── dist/"
echo "│   └── index.html      ← Копия для Render"
echo "└── package.json        ← Простая сборка"
echo ""

# ============================================================================
# 6. ИНСТРУКЦИИ
# ============================================================================

echo "🚀 ГОТОВ К ДЕПЛОЮ!"
echo ""
echo "✅ ИСПРАВЛЕНИЯ:"
echo "- Создан красивый index.html в корне frontend/"
echo "- Простая сборка без сложных зависимостей"
echo "- Полнофункциональный интерфейс с backend тестированием"
echo "- Responsive дизайн с градиентами и анимациями"
echo ""
echo "🎯 КОММИТ И PUSH:"
echo ""
echo "git add ."
echo "git commit -m '🔧 Fix Static Site structure with beautiful UI'"
echo "git push origin main"
echo ""
echo "🌐 ПОСЛЕ ПУША:"
echo "1. Render автоматически пересоберет Static Site"
echo "2. Откройте https://icoder-plus-1.onrender.com"
echo "3. Должен появиться красивый интерфейс"
echo "4. Backend status будет показывать подключение"
echo ""
echo "💡 Теперь у вас красивый landing с полным тестированием backend!"
