#!/bin/bash

echo “🧹 Очистка backend от TypeScript артефактов”
echo “==========================================”
echo “Цель: оставить только .js файлы в CommonJS стиле”

cd backend

# ============================================================================

# 1. УДАЛЕНИЕ TYPESCRIPT КОНФИГУРАЦИИ И АРТЕФАКТОВ

# ============================================================================

echo “📂 Удаляем TypeScript файлы и папки…”

# TypeScript конфигурация

if [ -f “tsconfig.json” ]; then
rm tsconfig.json
echo “✅ tsconfig.json удален”
fi

# Папка с типами

if [ -d “types/” ]; then
rm -rf types/
echo “✅ types/ папка удалена”
fi

# Скомпилированные файлы

if [ -d “dist/” ]; then
rm -rf dist/
echo “✅ dist/ папка удалена”
fi

# Vercel serverless API (дублирует Express)

if [ -d “api/” ]; then
rm -rf api/
echo “✅ api/ папка удалена”
fi

# Дублированный package.json

if [ -f “package-js.json” ]; then
rm package-js.json
echo “✅ package-js.json удален”
fi

# Тесты (если они на TS)

if [ -d “tests/” ]; then
echo “⚠️  tests/ найдена - проверяем содержимое…”
if find tests/ -name “*.ts” -type f | grep -q .; then
echo “❓ В tests/ найдены .ts файлы. Удалить tests/? (y/n)”
read -r answer
if [ “$answer” = “y” ]; then
rm -rf tests/
echo “✅ tests/ удалена”
else
echo “⚠️  tests/ оставлена (проверьте .ts файлы вручную)”
fi
else
echo “✅ tests/ содержит только .js файлы - оставляем”
fi
fi

# ============================================================================

# 2. ПРОВЕРКА src/ НА НАЛИЧИЕ .ts ФАЙЛОВ

# ============================================================================

echo “”
echo “🔍 Проверяем src/ на наличие .ts файлов…”

if find src/ -name “*.ts” -type f 2>/dev/null | grep -q .; then
echo “❌ Найдены .ts файлы в src/:”
find src/ -name “*.ts” -type f
echo “”
echo “❓ Удалить все .ts файлы из src/? (y/n)”
read -r answer
if [ “$answer” = “y” ]; then
find src/ -name “*.ts” -type f -delete
echo “✅ Все .ts файлы удалены из src/”
else
echo “⚠️  .ts файлы оставлены - нужно конвертировать в .js вручную”
fi
else
echo “✅ В src/ нет .ts файлов”
fi

# ============================================================================

# 3. ПРОВЕРКА СТРУКТУРЫ И ФАЙЛОВ

# ============================================================================

echo “”
echo “📋 Текущая структура backend:”
tree -I ‘node_modules’ -L 3 2>/dev/null || find . -type d -not -path “./node_modules*” | head -20

echo “”
echo “📄 JavaScript файлы в src/:”
find src/ -name “*.js” -type f 2>/dev/null || echo “❌ Нет .js файлов в src/”

# ============================================================================

# 4. ПРОВЕРКА package.json

# ============================================================================

echo “”
echo “🔧 Проверяем package.json…”

if [ -f “package.json” ]; then
# Проверяем type: commonjs
if grep -q ‘“type”.*“commonjs”’ package.json; then
echo “✅ package.json содержит "type": "commonjs"”
elif grep -q ’“type”.*“module”’ package.json; then
echo “⚠️  package.json содержит "type": "module" - нужно изменить на "commonjs"”
else
echo “⚠️  package.json не содержит "type" - добавьте "type": "commonjs"”
fi

```
# Проверяем main файл
if grep -q '"main".*"src/server.js"' package.json; then
    echo "✅ package.json правильно указывает на src/server.js"
else
    echo "⚠️  Проверьте \"main\" в package.json - должен быть \"src/server.js\""
fi

# Проверяем scripts
if grep -q '"dev".*"nodemon src/server.js"' package.json; then
    echo "✅ npm run dev правильно настроен"
else
    echo "⚠️  Проверьте \"scripts.dev\" - должен быть \"nodemon src/server.js\""
fi
```

else
echo “❌ package.json не найден!”
fi

# ============================================================================

# 5. ИТОГОВАЯ ПРОВЕРКА

# ============================================================================

echo “”
echo “🎯 ИТОГИ ОЧИСТКИ:”
echo “==================”

echo “✅ Удалены TypeScript артефакты:”
echo “   - tsconfig.json”
echo “   - types/ папка”  
echo “   - dist/ папка”
echo “   - api/ папка (Vercel serverless)”
echo “   - package-js.json дублик”

echo “”
echo “📂 Финальная структура backend:”
echo “backend/”
echo “├── src/”
echo “│   ├── server.js”
echo “│   └── routes/”
echo “│       └── aiRoutes.js”
echo “├── node_modules/”
echo “├── package.json”
echo “├── package-lock.json”
echo “└── README.md”

echo “”
echo “🚀 ГОТОВНОСТЬ К ЗАПУСКУ:”
if [ -f “src/server.js” ] && [ -f “package.json” ]; then
echo “✅ Backend готов к запуску:”
echo “   cd backend”
echo “   npm install”
echo “   npm run dev”
else
echo “❌ Отсутствуют ключевые файлы:”
[ ! -f “src/server.js” ] && echo “   - src/server.js”
[ ! -f “package.json” ] && echo “   - package.json”
fi

echo “”
echo “📝 НАПОМИНАНИЕ:”
echo “   - Все файлы теперь только .js (CommonJS)”
echo “   - Импорты: const express = require(‘express’)”
echo “   - Экспорты: module.exports = …”
echo “   - Никаких import/export (ES6 modules)”

cd ..