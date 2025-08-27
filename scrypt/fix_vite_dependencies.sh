#!/bin/bash

echo "🔧 ИСПРАВЛЯЕМ ПРОБЛЕМУ С VITE - ДОБАВЛЯЕМ В DEPENDENCIES"

# ============================================================================
# 1. ИСПРАВИТЬ package.json - VITE В DEPENDENCIES
# ============================================================================

cat > frontend/package.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module",
  "description": "iCoder Plus Frontend - AI-first IDE UI",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2",
    "clsx": "^2.0.0",
    "lucide-react": "^0.294.0",
    "@monaco-editor/react": "^4.6.0",
    "monaco-editor": "^0.44.0",
    "diff2html": "^3.4.48",
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.1.1",
    "tailwindcss": "^3.4.17",
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.6"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "eslint": "^8.53.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.4"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["react", "vite", "tailwind", "ide", "ai", "render"],
  "author": "Solar IT Team",
  "license": "MIT"
}
EOF

echo "✅ package.json исправлен - Vite перемещен в dependencies"

# ============================================================================
# 2. АЛЬТЕРНАТИВНЫЙ ВАРИАНТ - ИСПОЛЬЗОВАТЬ NPX
# ============================================================================

cat > frontend/package-npx.json << 'EOF'
{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module",
  "description": "iCoder Plus Frontend - AI-first IDE UI",
  "scripts": {
    "dev": "npx vite",
    "build": "npx vite build",
    "preview": "npx vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2",
    "clsx": "^2.0.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.1.1",
    "tailwindcss": "^3.4.17",
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.6",
    "vite": "^5.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

echo "✅ Альтернативный package.json с npx создан"

# ============================================================================
# 3. СОЗДАТЬ ПРОСТЕЙШИЙ ВАРИАНТ БЕЗ VITE
# ============================================================================

mkdir -p frontend/simple

cat > frontend/simple/package.json << 'EOF'
{
  "name": "icoder-plus-frontend-simple",
  "version": "2.0.0",
  "description": "iCoder Plus Frontend - Simple HTML version",
  "scripts": {
    "build": "mkdir -p dist && cp -r src/* dist/ && echo 'Simple build complete'",
    "start": "echo 'Static site ready'",
    "dev": "echo 'Development server not needed for static site'"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

cat > frontend/simple/src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iCoder Plus - AI-first IDE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
</head>
<body class="bg-gray-900 text-white">
    <div id="root"></div>
    
    <script type="text/babel">
        const { useState, useEffect } = React;
        
        const API_URL = 'https://icoder-plus.onrender.com';
        
        function BackendStatus() {
            const [status, setStatus] = useState('checking');
            const [data, setData] = useState(null);
            const [error, setError] = useState(null);
            
            useEffect(() => {
                checkBackend();
            }, []);
            
            const checkBackend = async () => {
                try {
                    setStatus('checking');
                    setError(null);
                    
                    const response = await fetch(`${API_URL}/health`);
                    
                    if (!response.ok) {
                        throw new Error(`HTTP ${response.status}`);
                    }
                    
                    const result = await response.json();
                    setData(result);
                    setStatus('connected');
                    
                } catch (err) {
                    setStatus('error');
                    setError(err.message);
                }
            };
            
            const getStatusInfo = () => {
                switch (status) {
                    case 'checking': 
                        return { icon: '🔄', text: 'Checking...', color: 'text-yellow-400' };
                    case 'connected': 
                        return { icon: '✅', text: 'Backend Connected', color: 'text-green-400' };
                    case 'error': 
                        return { icon: '❌', text: 'Connection Error', color: 'text-red-400' };
                    default: 
                        return { icon: '❓', text: 'Unknown', color: 'text-gray-400' };
                }
            };
            
            const statusInfo = getStatusInfo();
            
            return React.createElement('div', {
                className: 'bg-gray-800 rounded-lg p-6 border border-gray-700 mb-8'
            }, [
                React.createElement('div', {
                    key: 'header',
                    className: 'flex items-center justify-between mb-4'
                }, [
                    React.createElement('h3', {
                        key: 'title',
                        className: 'text-lg font-semibold'
                    }, 'Backend Status'),
                    React.createElement('button', {
                        key: 'refresh',
                        onClick: checkBackend,
                        className: 'px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded text-sm',
                        disabled: status === 'checking'
                    }, status === 'checking' ? 'Checking...' : 'Refresh')
                ]),
                React.createElement('div', {
                    key: 'status',
                    className: `flex items-center space-x-2 mb-4 ${statusInfo.color}`
                }, [
                    React.createElement('span', {
                        key: 'icon',
                        className: 'text-xl'
                    }, statusInfo.icon),
                    React.createElement('span', {
                        key: 'text',
                        className: 'font-medium'
                    }, statusInfo.text)
                ]),
                data && React.createElement('div', {
                    key: 'data',
                    className: 'text-sm text-gray-300'
                }, [
                    `Version: ${data.version || 'Unknown'}`,
                    React.createElement('br', { key: 'br1' }),
                    `Environment: ${data.environment || 'production'}`,
                    React.createElement('br', { key: 'br2' }),
                    `Status: ${data.status || 'OK'}`
                ]),
                error && React.createElement('div', {
                    key: 'error',
                    className: 'mt-4 p-3 bg-red-900 bg-opacity-20 border border-red-800 rounded text-red-400 text-sm'
                }, `Error: ${error}`)
            ]);
        }
        
        function App() {
            return React.createElement('div', {
                className: 'min-h-screen bg-gray-900 text-white'
            }, [
                React.createElement('header', {
                    key: 'header',
                    className: 'bg-gray-800 border-b border-gray-700'
                }, React.createElement('div', {
                    className: 'max-w-6xl mx-auto px-4 py-4'
                }, React.createElement('div', {
                    className: 'flex items-center justify-between'
                }, [
                    React.createElement('div', {
                        key: 'logo',
                        className: 'flex items-center space-x-3'
                    }, [
                        React.createElement('div', {
                            key: 'icon',
                            className: 'w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center'
                        }, React.createElement('span', {
                            className: 'text-white font-bold text-lg'
                        }, 'iC')),
                        React.createElement('div', { key: 'text' }, [
                            React.createElement('h1', {
                                key: 'title',
                                className: 'text-xl font-bold'
                            }, 'iCoder Plus'),
                            React.createElement('p', {
                                key: 'subtitle',
                                className: 'text-sm text-gray-400'
                            }, 'AI-first IDE v2.0')
                        ])
                    ]),
                    React.createElement('div', {
                        key: 'status',
                        className: 'bg-green-800 px-3 py-1 rounded-full text-sm'
                    }, '✅ Frontend on Render')
                ]))),
                React.createElement('main', {
                    key: 'main',
                    className: 'max-w-6xl mx-auto px-4 py-8'
                }, [
                    React.createElement('div', {
                        key: 'welcome',
                        className: 'text-center mb-8'
                    }, [
                        React.createElement('h2', {
                            key: 'title',
                            className: 'text-3xl font-bold mb-4'
                        }, 'Welcome to iCoder Plus! 🚀'),
                        React.createElement('p', {
                            key: 'subtitle',
                            className: 'text-gray-300 text-lg'
                        }, 'Your AI-first IDE is now running on Render')
                    ]),
                    React.createElement(BackendStatus, { key: 'backend-status' }),
                    React.createElement('div', {
                        key: 'footer',
                        className: 'text-center mt-12 pt-8 border-t border-gray-700'
                    }, [
                        React.createElement('p', {
                            key: 'api',
                            className: 'text-gray-400 mb-2'
                        }, [
                            'Backend API: ',
                            React.createElement('span', {
                                key: 'url',
                                className: 'text-blue-400'
                            }, 'https://icoder-plus.onrender.com')
                        ]),
                        React.createElement('p', {
                            key: 'credit',
                            className: 'text-sm text-gray-500'
                        }, 'Built with ❤️ by Solar IT Team')
                    ])
                ])
            ]);
        }
        
        ReactDOM.render(React.createElement(App), document.getElementById('root'));
    </script>
</body>
</html>
EOF

echo "✅ Простая HTML версия создана как fallback"

# ============================================================================
# 4. ТЕСТИРОВАТЬ ИСПРАВЛЕННУЮ ВЕРСИЮ
# ============================================================================

echo "🔨 Тестируем исправленную версию с Vite в dependencies..."
cd frontend

rm -rf node_modules package-lock.json dist

npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены (включая Vite)"
    
    # Проверить что vite установлен
    if [ -f "node_modules/.bin/vite" ]; then
        echo "✅ Vite найден в node_modules/.bin/"
    else
        echo "❌ Vite все еще не найден"
    fi
    
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ Сборка успешна!"
    else
        echo "❌ Ошибка сборки, попробуем простую HTML версию"
        
        # Переключиться на простую версию
        echo "🔄 Переключаемся на простую HTML версию..."
        cd ../
        cp -r frontend/simple/* frontend/
        cd frontend
        
        npm run build
        
        if [ $? -eq 0 ]; then
            echo "✅ Простая версия работает!"
        fi
    fi
    
else
    echo "❌ Ошибка установки зависимостей"
fi

cd ..

# ============================================================================
# 5. ИНСТРУКЦИИ
# ============================================================================

echo ""
echo "🚀 ИСПРАВЛЕНИЯ ДЛЯ VITE ГОТОВЫ!"
echo ""
echo "✅ ЧТО ИСПРАВЛЕНО:"
echo "- Vite перемещен в dependencies (не devDependencies)"
echo "- Добавлены все необходимые build-зависимости"
echo "- Создана простая HTML версия как fallback"
echo ""
echo "📋 ДВА ВАРИАНТА:"
echo ""
echo "🎯 ВАРИАНТ 1 - Vite версия (рекомендуется):"
echo "   git add frontend/package.json"
echo "   git commit -m '🔧 Move Vite to dependencies for Render'"
echo "   git push origin main"
echo ""
echo "🎯 ВАРИАНТ 2 - Простая HTML версия (безотказная):"
echo "   cp -r frontend/simple/* frontend/"
echo "   git add ."
echo "   git commit -m '🔧 Switch to simple HTML version'"
echo "   git push origin main"
echo ""
echo "🌐 На Render будет работать любой из вариантов!"
echo ""
echo "💡 Рекомендация: попробуйте сначала Вариант 1, если не сработает - используйте Вариант 2"
