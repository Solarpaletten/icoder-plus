#!/bin/bash

# 🚀 iCoder Plus v2.0 - Migration to Frontend/Backend Structure
# This script reorganizes the project into clean frontend/backend separation

echo "🚀 Starting iCoder Plus v2.0 Migration..."
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Create new directory structure
create_structure() {
    print_info "Creating frontend/backend directory structure..."
    
    # Frontend structure
    mkdir -p frontend/public
    mkdir -p frontend/src/{components,services,utils,hooks,styles}
    
    # Backend structure  
    mkdir -p backend/src/{routes,services,middleware,types,utils}
    mkdir -p backend/logs
    
    print_status "Directory structure created"
}

# Backup current files
backup_files() {
    print_info "Creating backup of current files..."
    
    mkdir -p .backup/$(date +%Y%m%d_%H%M%S)
    cp -r . .backup/$(date +%Y%m%d_%H%M%S)/ 2>/