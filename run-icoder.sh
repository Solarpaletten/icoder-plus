#!/bin/bash

echo "🚀 Starting iCoder Plus v2.1.1 Development Servers..."

# Check if we're in the right directory
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Kill any existing processes on these ports
echo "🧹 Cleaning up existing processes..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true

# Check if dependencies are installed
echo "🔍 Checking dependencies..."

if [ ! -d "backend/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd backend
    npm install
    cd ..
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
fi

# Check if .env exists for backend
if [ ! -f "backend/.env" ]; then
    echo "⚙️  Creating backend .env file..."
    cp backend/.env.example backend/.env
    echo "⚠️  Please add your API keys to backend/.env file"
fi

echo ""
echo "🔧 Starting backend server..."
cd backend
npm run dev > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

echo "🎨 Starting frontend server..."
cd frontend  
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Wait for servers to start
echo "⏳ Waiting for servers to start..."
sleep 5

# Check if servers are running
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Backend: http://localhost:3000 (healthy)"
else
    echo "⚠️  Backend: Starting... (check backend.log for details)"
fi

if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ Frontend: http://localhost:5173 (ready)"
else
    echo "⚠️  Frontend: Starting... (check frontend.log for details)"
fi

echo ""
echo "🎯 iCoder Plus v2.1.1 is running!"
echo ""
echo "📱 Open: http://localhost:5173"
echo "🔧 API:  http://localhost:3000"
echo ""
echo "📝 Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 Press Ctrl+C to stop both servers"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Wait for interrupt
wait