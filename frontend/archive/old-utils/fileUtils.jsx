import React from 'react'
import { 
  FileText, 
  Code, 
  Image, 
  FileJson, 
  FileCode2, 
  Palette,
  File as FileIcon,
  Folder
} from 'lucide-react'

export const getFileIcon = (fileName) => {
  if (!fileName) {
    return <FileIcon size={16} style={{color: '#9ca3af'}} />
  }

  const ext = fileName.split('.').pop()?.toLowerCase()
  
  if (!ext || ext === fileName.toLowerCase()) {
    return <FileIcon size={16} style={{color: '#9ca3af'}} />
  }
  
  switch(ext) {
    // JavaScript files - YELLOW
    case 'js':
      return <Code size={16} style={{color: '#fbbf24'}} />
    case 'jsx':
      return <Code size={16} style={{color: '#60a5fa'}} />
    case 'ts':
      return <FileCode2 size={16} style={{color: '#3b82f6'}} />
    case 'tsx':
      return <FileCode2 size={16} style={{color: '#3b82f6'}} />
    case 'mjs':
      return <Code size={16} style={{color: '#fde047'}} />
    
    // Web files - ORANGE & PINK
    case 'html':
    case 'htm':
      return <Code size={16} style={{color: '#fb923c'}} />
    case 'css':
      return <Palette size={16} style={{color: '#93c5fd'}} />
    case 'scss':
    case 'sass':
      return <Palette size={16} style={{color: '#f472b6'}} />
    case 'less':
      return <Palette size={16} style={{color: '#60a5fa'}} />
    
    // Data files - GREEN & YELLOW
    case 'json':
      return <FileJson size={16} style={{color: '#fde047'}} />
    case 'xml':
      return <FileCode2 size={16} style={{color: '#4ade80'}} />
    case 'yaml':
    case 'yml':
      return <FileText size={16} style={{color: '#a855f7'}} />
    
    // Documentation - BLUE
    case 'md':
    case 'markdown':
      return <FileText size={16} style={{color: '#93c5fd'}} />
    case 'txt':
      return <FileText size={16} style={{color: '#9ca3af'}} />
    case 'readme':
      return <FileText size={16} style={{color: '#4ade80'}} />
    
    // Images - GREEN & PURPLE
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
    case 'bmp':
      return <Image size={16} style={{color: '#4ade80'}} />
    case 'svg':
      return <Image size={16} style={{color: '#a855f7'}} />
    case 'ico':
      return <Image size={16} style={{color: '#60a5fa'}} />
    
    // Config files - GRAY
    case 'config':
    case 'conf':
      return <FileCode2 size={16} style={{color: '#6b7280'}} />
    case 'env':
      return <FileText size={16} style={{color: '#eab308'}} />
    
    default:
      return <FileIcon size={16} style={{color: '#9ca3af'}} />
  }
}

export const getFolderIcon = (folderName, expanded = false) => {
  return <Folder size={16} style={{color: expanded ? '#60a5fa' : '#93c5fd'}} />
}

export const getLanguageFromExtension = (fileName) => {
  if (!fileName) return 'text'
  
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const languageMap = {
    js: 'javascript',
    jsx: 'javascript', 
    mjs: 'javascript',
    ts: 'typescript',
    tsx: 'typescript',
    py: 'python',
    html: 'html',
    htm: 'html',
    css: 'css',
    scss: 'scss',
    sass: 'scss',
    less: 'less',
    json: 'json',
    xml: 'xml',
    yaml: 'yaml',
    yml: 'yaml',
    md: 'markdown',
    markdown: 'markdown',
    txt: 'text'
  }
  
  return languageMap[ext] || 'text'
}

export const isImageFile = (fileName) => {
  if (!fileName) return false
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp', 'ico'].includes(ext)
}

export const isExecutableFile = (fileName) => {
  if (!fileName) return false
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['html', 'js', 'jsx', 'mjs', 'ts', 'tsx'].includes(ext)
}
