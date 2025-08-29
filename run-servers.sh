#!/bin/bash

echo "🚀 Starting iCoder Plus v2.1.1..."

# Kill existing processes
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

echo "Starting backend on port 3000..."
cd backend && npm run dev &
BACKEND_PID=$!

echo "Starting frontend on port 5173..."
cd ../frontend && npm run dev &
FRONTEND_PID=$!

echo ""
echo "✅ Servers running:"
echo "   Backend:  http://localhost:3000"
echo "   Frontend: http://localhost:5173" 
echo ""
echo "Press Ctrl+C to stop all servers"

trap 'kill $BACKEND_PID $FRONTEND_PID; echo "Servers stopped"; exit' INT
wait
