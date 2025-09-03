import React from 'react'
import AgentSelector from './AgentSelector'
import ProposalsList from './ProposalsList'
import { getAllFilePaths } from '../utils/fileUtils'

const DualAgentChat = ({
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
  applyProposal,
  activeTab,
  fileTree
}) => {
  return (
    <div className="ai-chat-panel">
      {/* Agent Selector */}
      <AgentSelector agent={agent} setAgent={setAgent} />

      {/* Target File Selector */}
      <div className="target-selector mb-3">
        <label className="text-ide-muted text-xs">Target File:</label>
        <select 
          className="target-select"
          value={targetFile}
          onChange={(e) => setTargetFile(e.target.value)}
        >
          <option value="">(current: {activeTab?.name || 'none'})</option>
          {getAllFilePaths(fileTree).map(path => (
            <option key={path} value={path}>{path}</option>
          ))}
        </select>
      </div>

      {/* Chat Input */}
      <div className="chat-input-area">
        <textarea
          className="chat-input"
          placeholder={agent === 'dashka' 
            ? "Ask Dashka for architecture advice, code review, or planning..." 
            : "Ask Claudy to generate components, functions, or code snippets..."
          }
          value={chatInput}
          onChange={(e) => setChatInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
              sendChatMessage()
            }
          }}
        />
        <button 
          className="chat-send"
          onClick={sendChatMessage}
          disabled={aiLoading || !chatInput.trim()}
        >
          {aiLoading ? '⏳' : '🚀'}
        </button>
      </div>

      {/* Proposals */}
      <ProposalsList
        proposals={proposals}
        setProposals={setProposals}
        applyProposal={applyProposal}
        agent={agent}
      />
    </div>
  )
}

export default DualAgentChat
