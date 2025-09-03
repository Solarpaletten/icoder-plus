export const extractProposalsFromText = (text, targetPath) => {
  const proposals = []
  const generateId = () => Math.random().toString(36).substr(2, 9)
  
  // Match file-specific blocks
  const fileBlockRegex = /(?:^|\n)file:\s*([^\n]+)\n```(\w+)?\n([\s\S]*?)```/gi
  let match
  
  while ((match = fileBlockRegex.exec(text)) !== null) {
    const [, filePath, language, code] = match
    proposals.push({
      id: generateId(),
      title: `Update ${filePath}`,
      file: filePath.trim(),
      language: language || 'text',
      code: code.trim(),
      type: 'file-specific'
    })
  }

  // Match general code blocks
  const codeBlockRegex = /```(\w+)?\n([\s\S]*?)```/gi
  while ((match = codeBlockRegex.exec(text)) !== null) {
    const [, language, code] = match
    if (!proposals.some(p => p.code === code.trim())) {
      proposals.push({
        id: generateId(),
        title: `Code snippet (${language || 'text'})`,
        file: targetPath || '',
        language: language || 'text',
        code: code.trim(),
        type: 'code-block'
      })
    }
  }

  return proposals
}
