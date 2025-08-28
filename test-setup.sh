#!/bin/bash

echo "🧪 Testing iCoder Plus v2.1.1 Setup..."

# Test frontend
cd frontend
if [ -f "package.json" ] && [ -d "src/components" ]; then
    echo "✅ Frontend structure: OK"
else
    echo "❌ Frontend structure: MISSING"
fi

# Test backend
cd ../backend
if [ -f "package.json" ] && [ -d "src/routes" ]; then
    echo "✅ Backend structure: OK"
else
    echo "❌ Backend structure: MISSING"
fi

# Test dependencies
cd ../frontend
if [ -d "node_modules" ]; then
    echo "✅ Frontend deps: INSTALLED"
else
    echo "⚠️ Frontend deps: RUN 'npm install'"
fi

cd ../backend  
if [ -d "node_modules" ]; then
    echo "✅ Backend deps: INSTALLED"
else
    echo "⚠️ Backend deps: RUN 'npm install'"
fi

cd ..
echo ""
echo "🎯 Ready to run: ./run-dev.sh"
