#!/bin/bash

git add .

git commit -m "🚀 Backend Setup Progress — iCoder Plus" \
  -m "Мы за один день собрали и настроили основу iCoder Plus Backend 💪" \
  -m "✅ Что сделано:
- Настроен TypeScript (strict, paths, алиасы)
- Подключены middleware: helmet, compression, morgan, rate-limiter-flexible, Joi
- Созданы рабочие роуты: /api/ai, /api/files, /api/history, /health
- Вынесены типы в src/types/ai.ts, добавлена строгая типизация
- Настроены скрипты npm run build, npm run dev, npm start
- Убраны implicit any и дублирующие импорты
- AI-сервис интегрирован через OpenAI SDK (commit notes, review, auto-fix, chat, optimization)" \
  -m "⚠️ Текущая проблема:
При запуске npm run dev получаем:
TypeError [ERR_UNKNOWN_FILE_EXTENSION]: Unknown file extension \".ts\"

Причина — конфликт ESM vs CommonJS:
- package.json → \"type\": \"module\"
- tsconfig.json → \"module\": \"CommonJS\"" \
  -m "❓ Вопросы для обсуждения:
1. Какой режим выбрать для проекта: ESM или CommonJS?
2. Какие изменения внести в package.json и tsconfig.json, чтобы стабилизировать запуск?
3. Как правильно оформить финальный dev-скрипт для локального запуска (ts-node)?
4. Для деплоя на Render лучше использовать собранный dist/ или запуск через ts-node?" \
  -m "🎯 Цель:
- Добиться стабильного запуска backend без ошибок
- Проверить работу эндпоинта /health
- Подготовить backend к деплою на Render" \
  -m "🛰️ Мы уже как космический корабль на старте — остаётся включить двигатель! 🚀🔥"
