#!/bin/bash

echo "🚀 Starting iCoder Plus v2.1.1 (Fixed)..."

# Kill processes on correct ports
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

echo "🔧 Backend starting on port 3000..."
cd backend
npm run dev &
BACKEND_PID=$!

echo "🎨 Frontend starting on port 5173..."
cd ../frontend
npm run dev &
FRONTEND_PID=$!

sleep 3
echo ""
echo "✅ Servers running:"
echo "   🔧 Backend:  http://localhost:3000"
echo "   🎨 Frontend: http://localhost:5173"
echo ""
echo "🧪 Test backend: curl http://localhost:3000/health"
echo "🛑 Press Ctrl+C to stop"

trap 'kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit' INT
wait
