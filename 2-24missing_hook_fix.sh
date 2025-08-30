#!/bin/bash

echo "🔧 ИСПРАВЛЯЕМ НЕДОСТАЮЩИЙ useDualAgent ХOOK"

cd frontend/src/hooks

# ============================================================================
# 1. СОЗДАТЬ НЕДОСТАЮЩИЙ useDualAgent.js
# ============================================================================

cat > useDualAgent.js << 'EOF'
import { useState } from 'react'

export const useDualAgent = () => {
  const [agent, setAgent] = useState('claudy') // По умолчанию Claudy активен

  return {
    agent,
    setAgent
  }
}
EOF

echo "✅ useDualAgent.js создан"

# ============================================================================
# 2. ПРОВЕРИТЬ ЧТО ФАЙЛ СОЗДАЛСЯ
# ============================================================================

if [ -f "useDualAgent.js" ]; then
    echo "✅ Файл существует: $(ls -la useDualAgent.js)"
else
    echo "❌ Ошибка создания файла"
    exit 1
fi

# ============================================================================
# 3. ПРОВЕРИТЬ ИМПОРТ В App.jsx
# ============================================================================

cd ../
echo "🔍 Проверяем импорт в App.jsx..."

if grep -q "useDualAgent" App.jsx; then
    echo "✅ Импорт useDualAgent найден в App.jsx"
else
    echo "⚠️ Импорт useDualAgent НЕ найден в App.jsx"
fi

# ============================================================================
# 4. ТЕСТ СБОРКИ
# ============================================================================

cd ../..
echo "🧪 Тестируем сборку..."

npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ СБОРКА УСПЕШНА!"
    echo ""
    echo "🎯 КОММИТИМ ИСПРАВЛЕНИЕ:"
    echo "   git add ."
    echo "   git commit -m 'Add missing useDualAgent hook - fix runtime errors'"
    echo "   git push origin main"
    echo ""
    echo "🚀 После коммита:"
    echo "   - Render автоматически пересоберет проект"
    echo "   - Черный экран исчезнет"
    echo "   - File Tree будет работать корректно"
else
    echo "❌ Сборка падает - проверьте другие ошибки"
fi