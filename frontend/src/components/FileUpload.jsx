import React, { useState, useRef } from 'react'
import { Upload, FolderPlus, File, X, Download } from 'lucide-react'
import JSZip from 'jszip'

const FileUpload = ({ onFilesLoaded, onProjectLoaded }) => {
  const [isDragOver, setIsDragOver] = useState(false)
  const [isUploading, setIsUploading] = useState(false)
  const fileInputRef = useRef(null)
  const folderInputRef = useRef(null)

  const handleDragOver = (e) => {
    e.preventDefault()
    setIsDragOver(true)
  }

  const handleDragLeave = (e) => {
    e.preventDefault()
    setIsDragOver(false)
  }

  const handleDrop = async (e) => {
    e.preventDefault()
    setIsDragOver(false)
    setIsUploading(true)

    const files = Array.from(e.dataTransfer.files)
    await processFiles(files)

    setIsUploading(false)
  }

  const handleFileSelect = async (e) => {
    const files = Array.from(e.target.files)
    setIsUploading(true)
    await processFiles(files)
    setIsUploading(false)
    e.target.value = ''
  }

  const handleFolderSelect = async (e) => {
    const files = Array.from(e.target.files)
    setIsUploading(true)
    await processProject(files)
    setIsUploading(false)
    e.target.value = ''
  }

  const processFiles = async (files) => {
    const processedFiles = []

    for (const file of files) {
      if (file.type.startsWith('text/') || 
          file.name.match(/\.(js|jsx|ts|tsx|css|html|json|md|txt|py|java|c|cpp)$/i)) {
        
        try {
          const content = await file.text()
          processedFiles.push({
            name: file.name,
            content: content,
            size: file.size,
            type: file.type,
            lastModified: file.lastModified
          })
        } catch (error) {
          console.error(`Error reading ${file.name}:`, error)
        }
      }
    }

    if (processedFiles.length > 0 && onFilesLoaded) {
      onFilesLoaded(processedFiles)
    }
  }

  const processProject = async (files) => {
    const projectStructure = {}

    for (const file of files) {
      if (file.webkitRelativePath) {
        const pathParts = file.webkitRelativePath.split('/')
        let current = projectStructure

        // Создать структуру папок
        for (let i = 0; i < pathParts.length - 1; i++) {
          const folderName = pathParts[i]
          if (!current[folderName]) {
            current[folderName] = { type: 'folder', children: {} }
          }
          current = current[folderName].children
        }

        // Добавить файл
        const fileName = pathParts[pathParts.length - 1]
        if (file.type.startsWith('text/') || 
            fileName.match(/\.(js|jsx|ts|tsx|css|html|json|md|txt|py|java|c|cpp)$/i)) {
          
          try {
            const content = await file.text()
            current[fileName] = {
              type: 'file',
              content: content,
              size: file.size,
              lastModified: file.lastModified
            }
          } catch (error) {
            console.error(`Error reading ${fileName}:`, error)
          }
        }
      }
    }

    if (Object.keys(projectStructure).length > 0 && onProjectLoaded) {
      onProjectLoaded(projectStructure)
    }
  }

  const exportProject = async (projectData) => {
    const zip = new JSZip()

    const addToZip = (obj, path = '') => {
      Object.entries(obj).forEach(([name, item]) => {
        const currentPath = path ? `${path}/${name}` : name
        
        if (item.type === 'folder') {
          addToZip(item.children, currentPath)
        } else if (item.type === 'file') {
          zip.file(currentPath, item.content)
        }
      })
    }

    addToZip(projectData)

    try {
      const blob = await zip.generateAsync({ type: 'blob' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'iCoder-Plus-Project.zip'
      a.click()
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Export error:', error)
    }
  }

  return (
    <>
      {/* Drag & Drop Overlay */}
      {isDragOver && (
        <div className="drag-overlay">
          <div className="drag-content">
            <Upload size={48} />
            <h3>Drop files or folders here</h3>
            <p>Support: JS, TS, HTML, CSS, JSON, MD, TXT</p>
          </div>
        </div>
      )}

      {/* Upload Zone */}
      <div
        className={`upload-zone ${isDragOver ? 'drag-over' : ''}`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <div className="upload-content">
          {isUploading ? (
            <div className="upload-loading">
              <div className="spinner"></div>
              <p>Uploading files...</p>
            </div>
          ) : (
            <>
              <Upload size={32} />
              <h3>Upload Files or Project</h3>
              <p>Drag & drop files here or click to browse</p>
              
              <div className="upload-actions">
                <button
                  className="upload-btn"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <File size={16} />
                  Select Files
                </button>
                
                <button
                  className="upload-btn"
                  onClick={() => folderInputRef.current?.click()}
                >
                  <FolderPlus size={16} />
                  Select Folder
                </button>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Hidden File Inputs */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        accept=".js,.jsx,.ts,.tsx,.css,.html,.json,.md,.txt,.py,.java,.c,.cpp"
        style={{ display: 'none' }}
        onChange={handleFileSelect}
      />

      <input
        ref={folderInputRef}
        type="file"
        webkitdirectory=""
        style={{ display: 'none' }}
        onChange={handleFolderSelect}
      />
    </>
  )
}

export default FileUpload
