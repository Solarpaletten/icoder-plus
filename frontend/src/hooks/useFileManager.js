import { useState, useEffect } from 'react'
import { initialFiles } from '../utils/initialData'

export const useFileManager = () => {
  const [fileTree, setFileTree] = useState(initialFiles)
  const [openTabs, setOpenTabs] = useState([])
  const [activeTab, setActiveTab] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  const generateId = () => Math.random().toString(36).substr(2, 9)

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
    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === fileId ? { ...tab, content } : tab
    ))
    
    if (activeTab?.id === fileId) {
      setActiveTab({ ...activeTab, content })
    }
  }

  const createFile = (parentId, name, content = '') => {
    const newFile = {
      id: generateId(),
      name,
      type: 'file',
      content
    }

    const addToTree = (tree) => {
      return tree.map(item => {
        if (item.id === parentId) {
          const children = [...(item.children || []), newFile]
          return {
            ...item,
            children: children.sort((a, b) => {
              if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
              return a.name.localeCompare(b.name)
            })
          }
        }
        if (item.children) {
          return { ...item, children: addToTree(item.children) }
        }
        return item
      })
    }

    setFileTree(addToTree)
    openFile(newFile)
    return newFile
  }

  const createFolder = (parentId, name) => {
    const newFolder = {
      id: generateId(),
      name,
      type: 'folder',
      expanded: true,
      children: []
    }

    const addToTree = (tree) => {
      return tree.map(item => {
        if (item.id === parentId) {
          const children = [...(item.children || []), newFolder]
          return {
            ...item,
            children: children.sort((a, b) => {
              if (a.type !== b.type) return a.type === 'folder' ? -1 : 1
              return a.name.localeCompare(b.name)
            })
          }
        }
        if (item.children) {
          return { ...item, children: addToTree(item.children) }
        }
        return item
      })
    }

    setFileTree(addToTree)
  }

  const renameItem = (item, newName) => {
    const updateInTree = (tree) => {
      return tree.map(treeItem => {
        if (treeItem.id === item.id) {
          return { ...treeItem, name: newName }
        }
        if (treeItem.children) {
          return { ...treeItem, children: updateInTree(treeItem.children) }
        }
        return treeItem
      })
    }
    setFileTree(updateInTree)

    setOpenTabs(tabs => tabs.map(tab => 
      tab.id === item.id ? { ...tab, name: newName } : tab
    ))
    
    if (activeTab?.id === item.id) {
      setActiveTab({ ...activeTab, name: newName })
    }
  }

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
    setOpenTabs(tabs => tabs.filter(tab => tab.id !== item.id))
    
    if (activeTab?.id === item.id) {
      const remainingTabs = openTabs.filter(tab => tab.id !== item.id)
      setActiveTab(remainingTabs.length > 0 ? remainingTabs[0] : null)
    }
  }

  const openFile = (file) => {
    if (file.type !== 'file') return
    
    const existingTab = openTabs.find(tab => tab.id === file.id)
    if (existingTab) {
      setActiveTab(existingTab)
      return
    }

    const newTab = { ...file }
    setOpenTabs([...openTabs, newTab])
    setActiveTab(newTab)
  }

  const closeTab = (tab) => {
    const newTabs = openTabs.filter(t => t.id !== tab.id)
    setOpenTabs(newTabs)
    
    if (activeTab?.id === tab.id) {
      setActiveTab(newTabs.length > 0 ? newTabs[newTabs.length - 1] : null)
    }
  }

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

  // Auto-save to localStorage
  useEffect(() => {
    localStorage.setItem('icoder-project-v2.1.1', JSON.stringify(fileTree))
  }, [fileTree])

  // Load from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('icoder-project-v2.1.1')
    if (saved) {
      try {
        const project = JSON.parse(saved)
        setFileTree(project)
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
    updateFileContent
  }
}
