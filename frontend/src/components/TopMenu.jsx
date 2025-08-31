import React, { useState, useRef } from 'react'
import { 
  FileText, 
  FolderOpen, 
  Save, 
  Download, 
  Upload,
  Plus,
  Settings,
  HelpCircle,
  ExternalLink
} from 'lucide-react'

const TopMenu = ({ 
  onOpenFile, 
  onOpenFolder, 
  onSaveProject, 
  onNewProject,
  onImportProject 
}) => {
  const [activeMenu, setActiveMenu] = useState(null)
  const fileInputRef = useRef(null)
  const folderInputRef = useRef(null)
  const importInputRef = useRef(null)

  const menuItems = [
    {
      id: 'file',
      label: 'File',
      items: [
        { 
          id: 'new-file', 
          label: 'New File', 
          icon: FileText, 
          shortcut: 'Ctrl+N',
          action: () => onNewProject && onNewProject('file')
        },
        { 
          id: 'new-folder', 
          label: 'New Folder', 
          icon: FolderOpen, 
          shortcut: 'Ctrl+Shift+N',
          action: () => onNewProject && onNewProject('folder')
        },
        { type: 'separator' },
        { 
          id: 'open-file', 
          label: 'Open File...', 
          icon: Upload, 
          shortcut: 'Ctrl+O',
          action: () => fileInputRef.current?.click()
        },
        { 
          id: 'open-folder', 
          label: 'Open Folder...', 
          icon: FolderOpen, 
          shortcut: 'Ctrl+Shift+O',
          action: () => folderInputRef.current?.click()
        },
        { type: 'separator' },
        { 
          id: 'save-project', 
          label: 'Save Project', 
          icon: Save, 
          shortcut: 'Ctrl+S',
          action: onSaveProject
        },
        { 
          id: 'export-project', 
          label: 'Export as ZIP', 
          icon: Download, 
          shortcut: 'Ctrl+Shift+E',
          action: () => onSaveProject && onSaveProject('zip')
        },
        { 
          id: 'import-project', 
          label: 'Import Project', 
          icon: Upload, 
          action: () => importInputRef.current?.click()
        }
      ]
    },
    {
      id: 'edit',
      label: 'Edit',
      items: [
        { id: 'undo', label: 'Undo', shortcut: 'Ctrl+Z' },
        { id: 'redo', label: 'Redo', shortcut: 'Ctrl+Y' },
        { type: 'separator' },
        { id: 'cut', label: 'Cut', shortcut: 'Ctrl+X' },
        { id: 'copy', label: 'Copy', shortcut: 'Ctrl+C' },
        { id: 'paste', label: 'Paste', shortcut: 'Ctrl+V' },
        { type: 'separator' },
        { id: 'find', label: 'Find', shortcut: 'Ctrl+F' },
        { id: 'replace', label: 'Replace', shortcut: 'Ctrl+H' }
      ]
    },
    {
      id: 'view',
      label: 'View',
      items: [
        { id: 'explorer', label: 'Explorer', shortcut: 'Ctrl+Shift+E' },
        { id: 'terminal', label: 'Terminal', shortcut: 'Ctrl+`' },
        { id: 'preview', label: 'Live Preview', shortcut: 'Ctrl+Shift+P' },
        { type: 'separator' },
        { id: 'zoom-in', label: 'Zoom In', shortcut: 'Ctrl++' },
        { id: 'zoom-out', label: 'Zoom Out', shortcut: 'Ctrl+-' },
        { id: 'zoom-reset', label: 'Reset Zoom', shortcut: 'Ctrl+0' }
      ]
    },
    {
      id: 'run',
      label: 'Run',
      items: [
        { id: 'run-file', label: 'Run File', shortcut: 'Ctrl+F5' },
        { id: 'run-build', label: 'Build Project', shortcut: 'Ctrl+Shift+B' },
        { type: 'separator' },
        { id: 'debug', label: 'Start Debugging', shortcut: 'F5' }
      ]
    },
    {
      id: 'help',
      label: 'Help',
      items: [
        { id: 'docs', label: 'Documentation', icon: ExternalLink },
        { id: 'shortcuts', label: 'Keyboard Shortcuts', shortcut: 'Ctrl+?' },
        { type: 'separator' },
        { id: 'about', label: 'About iCoder Plus', icon: HelpCircle }
      ]
    }
  ]

  const handleFileSelect = (event) => {
    const files = event.target.files
    if (files && files.length > 0) {
      Array.from(files).forEach(file => {
        const reader = new FileReader()
        reader.onload = (e) => {
          const fileObj = {
            id: Math.random().toString(36).substr(2, 9),
            name: file.name,
            type: 'file',
            content: e.target.result
          }
          onOpenFile && onOpenFile(fileObj)
        }
        reader.readAsText(file)
      })
    }
    event.target.value = '' // Reset input
  }

  const handleFolderSelect = (event) => {
    const files = event.target.files
    if (files && files.length > 0) {
      const folderStructure = {}
      const filePromises = []

      Array.from(files).forEach(file => {
        const path = file.webkitRelativePath
        const pathParts = path.split('/')
        
        const promise = new Promise((resolve) => {
          const reader = new FileReader()
          reader.onload = (e) => {
            resolve({
              path: path,
              pathParts: pathParts,
              content: e.target.result,
              size: file.size
            })
          }
          reader.readAsText(file)
        })
        
        filePromises.push(promise)
      })

      Promise.all(filePromises).then(results => {
        const tree = buildFolderTree(results)
        onOpenFolder && onOpenFolder(tree)
      })
    }
    event.target.value = '' // Reset input
  }

  const buildFolderTree = (files) => {
    const root = { children: [] }
    
    files.forEach(file => {
      let current = root
      
      file.pathParts.forEach((part, index) => {
        if (!current.children) current.children = []
        
        let existing = current.children.find(child => child.name === part)
        
        if (!existing) {
          const isFile = index === file.pathParts.length - 1
          existing = {
            id: Math.random().toString(36).substr(2, 9),
            name: part,
            type: isFile ? 'file' : 'folder',
            ...(isFile ? { content: file.content } : { expanded: false, children: [] })
          }
          current.children.push(existing)
        }
        
        current = existing
      })
    })
    
    return root.children
  }

  const closeMenu = () => setActiveMenu(null)

  return (
    <>
      <div className="top-menu">
        {menuItems.map(menu => (
          <div key={menu.id} className="menu-item">
            <button
              className={`menu-button ${activeMenu === menu.id ? 'active' : ''}`}
              onClick={() => setActiveMenu(activeMenu === menu.id ? null : menu.id)}
            >
              {menu.label}
            </button>
            
            {activeMenu === menu.id && (
              <>
                <div className="menu-overlay" onClick={closeMenu} />
                <div className="dropdown-menu">
                  {menu.items.map((item, index) => (
                    item.type === 'separator' ? (
                      <div key={index} className="menu-separator" />
                    ) : (
                      <button
                        key={item.id}
                        className="dropdown-item"
                        onClick={() => {
                          item.action && item.action()
                          closeMenu()
                        }}
                      >
                        {item.icon && <item.icon size={14} />}
                        <span className="item-label">{item.label}</span>
                        {item.shortcut && (
                          <span className="item-shortcut">{item.shortcut}</span>
                        )}
                      </button>
                    )
                  ))}
                </div>
              </>
            )}
          </div>
        ))}
        
        <div className="menu-title">
          <span>iCoder Plus v2.2</span>
          <span className="subtitle">AI IDE with Terminal</span>
        </div>
      </div>

      {/* Hidden file inputs */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        accept=".js,.jsx,.ts,.tsx,.html,.css,.json,.md,.txt"
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
      
      <input
        ref={importInputRef}
        type="file"
        accept=".zip"
        style={{ display: 'none' }}
        onChange={(e) => {
          // Handle ZIP import
          const file = e.target.files[0]
          if (file && onImportProject) {
            onImportProject(file)
          }
          e.target.value = ''
        }}
      />
    </>
  )
}

export default TopMenu
