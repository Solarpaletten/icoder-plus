import React from 'react'

const ProposalsList = ({ proposals, setProposals, applyProposal, agent }) => {
  return (
    <div className="proposals-section">
      <div className="proposals-header">
        <span className="proposals-title">Code Proposals</span>
        {proposals.length > 0 && (
          <>
            <span className="proposals-count">{proposals.length}</span>
            <button 
              className="btn text-xs p-1 ml-2"
              onClick={() => setProposals([])}
              title="Clear all proposals"
            >
              🗑️
            </button>
          </>
        )}
      </div>

      {proposals.length === 0 ? (
        <div className="text-ide-muted text-center py-5 text-xs">
          {agent === 'dashka' 
            ? "💡 Dashka provides architecture guidance"
            : "🤖 Claudy generates code proposals. Try: 'Create a React component'"
          }
        </div>
      ) : (
        proposals.map(proposal => (
          <div key={proposal.id} className="proposal-item">
            <div className="proposal-header">
              <div>
                <div className="proposal-title">{proposal.title}</div>
                <div className="proposal-meta">
                  📁 {proposal.file || 'current'} • {proposal.language}
                </div>
              </div>
            </div>
            
            <div className="proposal-actions">
              <button 
                className="proposal-btn apply"
                onClick={() => applyProposal(proposal, 'apply')}
                title="Replace entire file"
              >
                Apply
              </button>
              <button 
                className="proposal-btn insert"
                onClick={() => applyProposal(proposal, 'insert')}
                title="Insert at cursor"
              >
                Insert
              </button>
              <button 
                className="proposal-btn create"
                onClick={() => applyProposal(proposal, 'create')}
                title="Create new file"
              >
                Create
              </button>
            </div>
          </div>
        ))
      )}
    </div>
  )
}

export default ProposalsList
