#!/bin/bash

echo "Starting iCoder Plus v2.1.1..."

# Kill existing processes
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

# Start backend
echo "Starting backend..."
cd backend
npm run dev &
BACKEND_PID=$!

# Start frontend  
echo "Starting frontend..."
cd ../frontend
npm run dev &
FRONTEND_PID=$!

echo ""
echo "Servers running:"
echo "  Backend:  http://localhost:3000"
echo "  Frontend: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop"

trap 'kill $BACKEND_PID $FRONTEND_PID; exit' INT
wait
