#!/bin/bash

# 🚀 iCoder Plus v2.0 - Automated Setup Script
# This script sets up the complete development environment

echo "🚀 iCoder Plus v2.0 - Automated Setup Starting..."
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Node.js is installed
check_node() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_status "Node.js found: $NODE_VERSION"
        
        # Check if version is >= 18
        MAJOR_VERSION=$(echo $NODE_VERSION | sed 's/v//' | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 18 ]; then
            print_status "Node.js version is compatible"
        else
            print_warning "Node.js version should be >= 18. Current: $NODE_VERSION"
        fi
    else
        print_error "Node.js not found. Please install Node.js 18+ from https://nodejs.org"
        exit 1
    fi
}

# Check if npm is installed
check_npm() {
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_status "npm found: $NPM_VERSION"
    else
        print_error "npm not found. Please install npm"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    print_info "Installing project dependencies..."
    
    if npm install; then
        print_status "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Create .env file if it doesn't exist
setup_environment() {
    if [ ! -f ".env" ]; then
        print_info "Creating .env file..."
        
        cat > .env << EOL
# iCoder Plus v2.0 Environment Configuration
# Add your actual API keys below

# OpenAI Configuration
VITE_OPENAI_API_KEY=your_openai_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Anthropic Claude Configuration  
VITE_ANTHROPIC_API_KEY=your_anthropic_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# App Configuration
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
VITE_APP_DESCRIPTION=AI-first IDE in a bottom sheet

# Development Settings
NODE_ENV=development
VITE_DEV_MODE=true

# Feature Flags
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_LIVE_PREVIEW=true
VITE_ENABLE_FILE_SYSTEM_API=true
VITE_ENABLE_ANALYTICS=false
EOL

        print_status ".env file created"
        print_warning "Please add your OpenAI API key to .env file to enable AI features"
    else
        print_status ".env file already exists"
    fi
}

# Create missing directories
create_directories() {
    print_info "Creating project directories..."
    
    mkdir -p public
    mkdir -p src/components
    mkdir -p src/services  
    mkdir -p src/utils
    mkdir -p styles
    
    print_status "Directory structure created"
}

# Create PostCSS config
create_postcss_config() {
    if [ ! -f "postcss.config.js" ]; then
        print_info "Creating PostCSS configuration..."
        
        cat > postcss.config.js << EOL
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOL
        print_status "PostCSS config created"
    fi
}

# Create ESLint config
create_eslint_config() {
    if [ ! -f ".eslintrc.js" ]; then
        print_info "Creating ESLint configuration..."
        
        cat > .eslintrc.js << EOL
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    '@eslint/js/recommended',
    'plugin:react/recommended',
    'plugin:react/jsx-runtime',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.js'],
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module' },
  settings: { react: { version: '18.2' } },
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
  },
}
EOL
        print_status "ESLint config created"
    fi
}

# Update gitignore
update_gitignore() {
    if [ ! -f ".gitignore" ]; then
        print_info "Creating .gitignore..."
    else
        print_info "Updating .gitignore..."
    fi
    
    cat > .gitignore << EOL
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
*.local

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor directories and files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Temporary folders
tmp/
temp/

# Cache
.cache/
.parcel-cache/
.vite/

# ESLint cache
.eslintcache

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env.test

# Storybook build outputs
.out
.storybook-out
storybook-static/

# Temporary files
*.tmp
*.temp
EOL
    
    print_status ".gitignore updated"
}

# Test development server
test_dev_server() {
    print_info "Testing development server startup..."
    
    # Start dev server in background and test if it works
    npm run dev &
    SERVER_PID=$!
    
    # Wait a few seconds for server to start
    sleep 5
    
    # Check if server is running on port 5173
    if curl -s http://localhost:5173 > /dev/null; then
        print_status "Development server started successfully"
        print_info "Server running at: http://localhost:5173"
    else
        print_warning "Development server may not be responding yet"
    fi
    
    # Kill the test server
    kill $SERVER_PID 2>/dev/null
    
    print_info "Stopped test server"
}

# Main setup sequence
main() {
    echo "Starting iCoder Plus v2.0 setup..."
    echo ""
    
    # System checks
    check_node
    check_npm
    echo ""
    
    # Project setup
    create_directories
    setup_environment
    create_postcss_config
    create_eslint_config
    update_gitignore
    echo ""
    
    # Install dependencies
    install_dependencies
    echo ""
    
    # Test setup
    test_dev_server
    echo ""
    
    # Success message
    echo "================================================"
    print_status "iCoder Plus v2.0 setup completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "1. Add your OpenAI API key to .env file"
    echo "2. Run: npm run dev"
    echo "3. Open: http://localhost:5173"
    echo ""
    print_info "Available commands:"
    echo "• npm run dev     - Start development server"
    echo "• npm run build   - Build for production"
    echo "• npm run preview - Preview production build"
    echo "• npm run test    - Run tests"
    echo "• npm run lint    - Check code style"
    echo ""
    print_status "Happy coding with iCoder Plus! 🚀"
}

# Run main function
main "$@"