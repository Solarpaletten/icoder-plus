import React from 'react'
import DualAgentChat from './DualAgentChat'
import PreviewPanel from './PreviewPanel'

const RightPanel = ({ 
  activePanel, 
  setActivePanel,
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
    <div className="right-panel">
      <div className="panel-tabs">
        <div 
          className={`panel-tab ${activePanel === 'ai-chat' ? 'active' : ''}`}
          onClick={() => setActivePanel('ai-chat')}
        >
          🤖 Dual AI
        </div>
        <div 
          className={`panel-tab ${activePanel === 'preview' ? 'active' : ''}`}
          onClick={() => setActivePanel('preview')}
        >
          ▶ Preview
        </div>
      </div>

      <div className="panel-content">
        {activePanel === 'ai-chat' ? (
          <DualAgentChat
            agent={agent}
            setAgent={setAgent}
            targetFile={targetFile}
            setTargetFile={setTargetFile}
            proposals={proposals}
            setProposals={setProposals}
            chatInput={chatInput}
            setChatInput={setChatInput}
            aiLoading={aiLoading}
            sendChatMessage={sendChatMessage}
            applyProposal={applyProposal}
            activeTab={activeTab}
            fileTree={fileTree}
          />
        ) : (
          <PreviewPanel activeTab={activeTab} />
        )}
      </div>
    </div>
  )
}

export default RightPanel
