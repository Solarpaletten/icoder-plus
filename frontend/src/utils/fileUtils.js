export const getFileIcon = (name) => {
  const ext = name.split('.').pop()?.toLowerCase()
  const icons = {
    html: '🟥', htm: '🟥',
    js: '🟦', jsx: '🟦', mjs: '🟦',
    ts: '🟨', tsx: '🟨',
    css: '🟪', scss: '🟪', less: '🟪',
    json: '🟩', jsonc: '🟩',
    md: '📝', txt: '📝',
    png: '🖼️', jpg: '🖼️', gif: '🖼️', svg: '🖼️'
  }
  return icons[ext] || '📄'
}

export const getLanguageFromFilename = (filename) => {
  const ext = filename.split('.').pop()?.toLowerCase()
  const langMap = {
    html: 'html', htm: 'html',
    js: 'javascript', jsx: 'javascript',
    ts: 'typescript', tsx: 'typescript',
    css: 'css', scss: 'scss',
    json: 'json', md: 'markdown'
  }
  return langMap[ext] || 'plaintext'
}

export const getAllFilePaths = (tree, path = '') => {
  let paths = []
  for (const item of tree) {
    const currentPath = path ? `${path}/${item.name}` : item.name
    if (item.type === 'file') {
      paths.push(currentPath)
    }
    if (item.children) {
      paths = paths.concat(getAllFilePaths(item.children, currentPath))
    }
  }
  return paths
}
