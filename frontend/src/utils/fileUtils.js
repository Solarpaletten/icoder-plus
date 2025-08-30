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
  
  const iconMap = {
    // Code files
    js: <Code size={16} className="text-yellow-400" />,
    jsx: <Code size={16} className="text-blue-400" />,
    ts: <FileCode2 size={16} className="text-blue-500" />,
    tsx: <FileCode2 size={16} className="text-blue-500" />,
    py: <Code size={16} className="text-green-400" />,
    
    // Web files
    html: <Code size={16} className="text-orange-400" />,
    css: <Palette size={16} className="text-blue-300" />,
    scss: <Palette size={16} className="text-pink-400" />,
    
    // Data files
    json: <FileJson size={16} className="text-yellow-300" />,
    md: <FileText size={16} className="text-gray-300" />,
    txt: <FileText size={16} className="text-gray-400" />,
    
    // Images
    png: <Image size={16} className="text-green-400" />,
    jpg: <Image size={16} className="text-green-400" />,
    jpeg: <Image size={16} className="text-green-400" />,
    gif: <Image size={16} className="text-green-400" />,
    svg: <Image size={16} className="text-purple-400" />,
  }
  
  return iconMap[ext] || <FileIcon size={16} className="text-gray-400" />
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
