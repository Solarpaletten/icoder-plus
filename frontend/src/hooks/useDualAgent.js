import { useState } from 'react'
import { aiService } from '../services/aiService'
import { extractProposalsFromText } from '../utils/aiUtils'

export const useDualAgent = ({ activeTab, fileTree, updateFileContent, createFile }) => {
  const [agent, setAgent] = useState('dashka')
  const [targetFile, setTargetFile] = useState('')
  const [proposals, setProposals] = useState([])
  const [chatInput, setChatInput] = useState('')
  const [aiLoading, setAiLoading] = useState(false)

  const sendChatMessage = async () => {
    if (!chatInput.trim() || aiLoading) return

    const agentPrefix = agent === 'dashka' ? '[AGENT:DASHKA]' : '[AGENT:CLAUDY]'
    const targetPath = targetFile || activeTab?.name || ''

    setChatInput('')
    setAiLoading(true)

    try {
      const response = await aiService.sendMessage(agentPrefix, chatInput, targetPath)
      
      if (agent === 'claudy') {
        const newProposals = extractProposalsFromText(response, targetPath)
        setProposals(prev => [...newProposals, ...prev])
      }

    } catch (error) {
      console.error('AI Chat error:', error)
    } finally {
      setAiLoading(false)
    }
  }

  const applyProposal = (proposal, action) => {
    const targetPath = proposal.file || activeTab?.name || ''
    
    if (action === 'apply') {
      // Find and update existing file
      const findFileByPath = (tree, path) => {
        for (const item of tree) {
          if (item.type === 'file' && item.name === path) return item
          if (item.children) {
            const found = findFileByPath(item.children, path)
            if (found) return found
          }
        }
        return null
      }

      const file = findFileByPath(fileTree, targetPath)
      if (file) {
        updateFileContent(file.id, proposal.code)
      } else {
        const parentId = fileTree[0]?.id
        createFile(parentId, targetPath, proposal.code)
      }
    }
    
    setProposals(prev => prev.filter(p => p.id !== proposal.id))
  }

  return {
    agent,
    setAgent,
    targetFile,
    setTargetFile,
    proposals,
    setProposals,
    chatInput,
    setChatInput,
    aiLoading,
    sendChatMessage,
    applyProposal
  }
}
