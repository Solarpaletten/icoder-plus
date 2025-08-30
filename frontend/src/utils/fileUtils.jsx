import { 
  FileText, 
  Code, 
  Image, 
  FileJson, 
  FileCode2, 
  Palette,
  File as FileIcon
} from 'lucide-react'

export const getFileIcon = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  // Используем switch вместо объекта с JSX
  switch(ext) {
    // Code files
    case 'js':
      return <Code size={16} className="text-yellow-400" />
    case 'jsx':
      return <Code size={16} className="text-blue-400" />
    case 'ts':
      return <FileCode2 size={16} className="text-blue-500" />
    case 'tsx':
      return <FileCode2 size={16} className="text-blue-500" />
    case 'py':
      return <Code size={16} className="text-green-400" />
    
    // Web files
    case 'html':
      return <Code size={16} className="text-orange-400" />
    case 'css':
      return <Palette size={16} className="text-blue-300" />
    case 'scss':
      return <Palette size={16} className="text-pink-400" />
    
    // Data files
    case 'json':
      return <FileJson size={16} className="text-yellow-300" />
    case 'md':
      return <FileText size={16} className="text-gray-300" />
    case 'txt':
      return <FileText size={16} className="text-gray-400" />
    
    // Images
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
      return <Image size={16} className="text-green-400" />
    case 'svg':
      return <Image size={16} className="text-purple-400" />
    
    // Default
    default:
      return <FileIcon size={16} className="text-gray-400" />
  }
}

export const getLanguageFromExtension = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  
  const languageMap = {
    js: 'javascript',
    jsx: 'javascript', 
    ts: 'typescript',
    tsx: 'typescript',
    py: 'python',
    html: 'html',
    css: 'css',
    scss: 'scss',
    json: 'json',
    md: 'markdown',
    txt: 'text'
  }
  
  return languageMap[ext] || 'text'
}

export const isImageFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp'].includes(ext)
}

export const isExecutableFile = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  return ['html', 'js', 'jsx'].includes(ext)
}
