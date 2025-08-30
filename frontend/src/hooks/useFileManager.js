import { useState, useEffect } from 'react'
import { initialFiles } from '../utils/initialData'

export const useFileManager = () => {
  const [fileTree, setFileTree] = useState(initialFiles)
  const [openTabs, setOpenTabs] = useState([])
  const [activeTab, setActiveTab] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  const generateId = () => Math.random().toString(36).substr(2, 9)

  // Find file by ID in tree structure
  const findFileById = (tree, id) => {
    for (const item of tree) {
      if (item.id === id) return item
      if (item.children) {
        const found = findFileById(item.children, id)
        if (found) return found
      }
    }
    return null
  }

  // Sort items (folders first, then files alphabetically)
  const sortTreeItems = (items) => {
    return items.sort((a, b) => {
      if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
      return a.name.localeCompare(b.name)
    })
  }

  // Get language from file extension
  const getLanguageFromExtension = (filename) => {
    const ext = filename.split('.').pop()?.toLowerCase()
    const languageMap = {
      js: 'javascript',
      jsx: 'javascript',
      ts: 'typescript',
      tsx: 'typescript',
      html: 'html',
      css: 'css',
      json: 'json',
      py: 'python',
      md: 'markdown'
    }
    return languageMap[ext] || 'text'
  }

  // Update file content
  const updateFileContent = (fileId, content) => {
    const updateInTree = (tree) => {
      return tree.map(item => {
        if (item.id === fileId) {
          return { ...item, content }
        }
        if (item.children) {
          return { ...item, children: updateInTree(item.children) }
        }
        return item
      })
    }
    
    setFileTree(updateInTree)
    
    // Update open tabs
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === fileId ? { ...tab, content } : tab
    ))
    
    // Update active tab if it's the file being updated
    if (activeTab?.id === fileId) {
      setActiveTab({ ...activeTab, content })
    }
  }

  // Create new file
  const createFile = (parentId = null, name, content = '') => {
    const newFile = {
      id: generateId(),
      name,
      type: 'file',
      content,
      language: getLanguageFromExtension(name)
    }

    if (parentId) {
      // Add to specific folder
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFile]
            return {
              ...item,
              children: sortTreeItems(children)
            }
          }
          if (item.children) {
            return { ...item, children: addToTree(item.children) }
          }
          return item
        })
      }
      setFileTree(addToTree)
    } else {
      // Add to root
      setFileTree(tree => sortTreeItems([...tree, newFile]))
    }

    // Auto-open the new file
    openFile(newFile)
    return newFile
  }

  // Create new folder
  const createFolder = (parentId = null, name) => {
    const newFolder = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: true,
      children: []
    }

    if (parentId) {
      // Add to specific folder
      const addToTree = (tree) => {
        return tree.map(item => {
          if (item.id === parentId && item.type === 'folder') {
            const children = [...(item.children || []), newFolder]
            return {
              ...item,
              children: sortTreeItems(children)
            }
          }
          if (item.children) {
            return { ...item, children: addToTree(item.children) }
          }
          return item
        })
      }
      setFileTree(addToTree)
    } else {
      // Add to root
      setFileTree(tree => sortTreeItems([...tree, newFolder]))
    }

    return newFolder
  }

  // Rename item
  const renameItem = (item, newName) => {
    const updateInTree = (tree) => {
      return tree.map(treeItem => {
        if (treeItem.id === item.id) {
          return { 
            ...treeItem, 
            name: newName,
            language: treeItem.type === 'file' ? getLanguageFromExtension(newName) : undefined
          }
        }
        if (treeItem.children) {
          return { ...treeItem, children: updateInTree(treeItem.children) }
        }
        return treeItem
      })
    }
    setFileTree(updateInTree)

    // Update open tabs
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === item.id ? { ...tab, name: newName } : tab
    ))
    
    // Update active tab
    if (activeTab?.id === item.id) {
      setActiveTab({ ...activeTab, name: newName })
    }
  }

  // Delete item
  const deleteItem = (item) => {
    const removeFromTree = (tree) => {
      return tree.filter(treeItem => {
        if (treeItem.id === item.id) return false
        if (treeItem.children) {
          treeItem.children = removeFromTree(treeItem.children)
        }
        return true
      })
    }
    
    setFileTree(removeFromTree)
    
    // Close related tabs
    setOpenTabs(tabs => tabs.filter(tab => tab.id !== item.id))
    
    // Update active tab
    if (activeTab?.id === item.id) {
      const remainingTabs = openTabs.filter(tab => tab.id !== item.id)
      setActiveTab(remainingTabs.length > 0 ? remainingTabs[0] : null)
    }
  }

  // Open file in tab
  const openFile = (file) => {
    if (file.type !== 'file') return
    
    const existingTab = openTabs.find(tab => tab.id === file.id)
    if (existingTab) {
      setActiveTab(existingTab)
      return
    }

    const newTab = { ...file }
    setOpenTabs(prev => [...prev, newTab])
    setActiveTab(newTab)
  }

  // Close tab
  const closeTab = (tab) => {
    const newTabs = openTabs.filter(t => t.id !== tab.id)
    setOpenTabs(newTabs)
    
    if (activeTab?.id === tab.id) {
      setActiveTab(newTabs.length > 0 ? newTabs[newTabs.length - 1] : null)
    }
  }

  // Toggle folder expanded state
  const toggleFolder = (folder) => {
    const updateInTree = (tree) => {
      return tree.map(item => {
        if (item.id === folder.id) {
          return { ...item, expanded: !item.expanded }
        }
        if (item.children) {
          return { ...item, children: updateInTree(item.children) }
        }
        return item
      })
    }
    setFileTree(updateInTree)
  }

  // Auto-save project to localStorage
  useEffect(() => {
    const projectData = {
      fileTree,
      openTabs: openTabs.map(tab => tab.id),
      activeTabId: activeTab?.id
    }
    localStorage.setItem('icoder-project-v2.2.0', JSON.stringify(projectData))
  }, [fileTree, openTabs, activeTab])

  // Load project from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('icoder-project-v2.2.0')
    if (saved) {
      try {
        const project = JSON.parse(saved)
        if (project.fileTree) {
          setFileTree(project.fileTree)
          
          // Restore open tabs
          if (project.openTabs) {
            const restoredTabs = project.openTabs
              .map(tabId => findFileById(project.fileTree, tabId))
              .filter(Boolean)
            setOpenTabs(restoredTabs)
            
            // Restore active tab
            if (project.activeTabId) {
              const activeFile = findFileById(project.fileTree, project.activeTabId)
              if (activeFile) setActiveTab(activeFile)
            }
          }
        }
      } catch (e) {
        console.warn('Failed to load project:', e)
      }
    }
  }, [])

  return {
    fileTree,
    openTabs,
    activeTab,
    searchQuery,
    setSearchQuery,
    createFile,
    createFolder,
    renameItem,
    deleteItem,
    openFile,
    closeTab,
    setActiveTab,
    toggleFolder,
    updateFileContent,
    findFileById
  }
}
