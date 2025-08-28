#!/bin/bash
echo "🚀 Setting up iCoder Plus v2.1.1..."

# Frontend setup
cd frontend
echo "📦 Installing frontend dependencies..."
npm install

# Backend setup  
cd ../backend
echo "📦 Installing backend dependencies..."
npm install

# Copy environment
cp .env.example .env
echo "✅ Environment template created"

echo "🎯 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Add your API keys to backend/.env"
echo "2. Run 'npm run dev' in both frontend/ and backend/ directories"
echo "3. Open http://localhost:5173"
echo ""
echo "🚀 Happy coding with Dual-Agent AI!"
