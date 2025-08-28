import JSZip from 'jszip'
import { saveAs } from 'file-saver'

export const exportService = {
  async exportAsZip(fileTree, setProgress) {
    setProgress({ message: 'Preparing export...', progress: 0 })

    try {
      const zip = new JSZip()
      let fileCount = 0
      let processedCount = 0

      const countFiles = (tree) => {
        tree.forEach(item => {
          if (item.type === 'file') fileCount++
          if (item.children) countFiles(item.children)
        })
      }
      countFiles(fileTree)

      const addToZip = (tree, folder = zip) => {
        tree.forEach(item => {
          if (item.type === 'file') {
            folder.file(item.name, item.content || '')
            processedCount++
            setProgress({
              message: `Adding ${item.name}...`,
              progress: (processedCount / fileCount) * 90
            })
          } else if (item.type === 'folder' && item.children) {
            const subFolder = folder.folder(item.name)
            addToZip(item.children, subFolder)
          }
        })
      }

      addToZip(fileTree)

      setProgress({ message: 'Generating ZIP...', progress: 95 })
      const content = await zip.generateAsync({ type: 'blob' })
      
      setProgress({ message: 'Download starting...', progress: 100 })
      const projectName = fileTree[0]?.name || 'iCoder-Project'
      saveAs(content, `${projectName}-${new Date().toISOString().split('T')[0]}.zip`)

      setTimeout(() => setProgress(null), 1000)

    } catch (error) {
      console.error('Export failed:', error)
      alert('Export failed: ' + error.message)
      setProgress(null)
    }
  }
}
