import React from 'react'

const AgentSelector = ({ agent, setAgent }) => {
  return (
    <div className="agent-selector">
      <div
        className={`agent-option dashka ${agent === 'dashka' ? 'active' : ''}`}
        onClick={() => setAgent('dashka')}
      >
        🏗️ Dashka<br/>
        <small>Architecture & Review</small>
      </div>
      <div
        className={`agent-option claudy ${agent === 'claudy' ? 'active' : ''}`}
        onClick={() => setAgent('claudy')}
      >
        🤖 Claudy<br/>
        <small>Code Generation</small>
      </div>
    </div>
  )
}

export default AgentSelector
