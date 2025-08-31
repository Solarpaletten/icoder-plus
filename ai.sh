#!/bin/bash

echo "🔧 Fixing FolderCopy icon import error..."

# Replace FolderCopy with existing Folder icon in FileTree.jsx
sed -i '' 's/FolderCopy,//g' frontend/src/components/FileTree.jsx

# Replace FolderCopy usage with Folders icon
sed -i '' 's/<FolderCopy size={14} \/>/<Folder size={14} \/>/g' frontend/src/components/FileTree.jsx

echo "✅ Fixed FolderCopy import - using Folder icon instead"

echo "🔨 Building project..."
cd frontend
npm run build

echo "✅ Build completed successfully!"