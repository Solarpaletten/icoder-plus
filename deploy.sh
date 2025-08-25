#!/bin/bash

echo "🚀 ДЕПЛОИМ iCoder Plus НА VERCEL!"

# Frontend деплой
echo "📤 Деплоим Frontend..."
cd frontend
npx vercel --prod

# Backend деплой  
echo "📤 Деплоим Backend..."
cd ../backend
npx vercel --prod

echo "✅ Деплой завершён!"
echo "🌐 Frontend: https://icoder-plus-frontend.vercel.app"
echo "🔧 Backend: https://icoder-plus-backend.vercel.app"
