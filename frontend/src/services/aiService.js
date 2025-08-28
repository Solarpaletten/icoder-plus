export const aiService = {
  async sendMessage(agentPrefix, message, targetPath, code = '') {
    // Simulate AI response - replace with real API call
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    if (agentPrefix.includes('DASHKA')) {
      return generateDashkaResponse(message, code)
    } else {
      return generateClaudyResponse(message, targetPath)
    }
  }
}

const generateDashkaResponse = (message, code) => {
  return `🏗️ **Architecture Analysis**

Analyzing: "${message}"

**Code Structure Assessment:**
- Consider modular component design
- Implement proper error boundaries
- Use custom hooks for state logic
- Follow consistent naming patterns

**Performance Recommendations:**
- Use React.memo for optimization
- Implement code splitting
- Add proper loading states

**Best Practices:**
- Add TypeScript for better DX
- Implement proper testing
- Use proper state management

Need specific implementation guidance?`
}

const generateClaudyResponse = (message, targetPath) => {
  if (message.toLowerCase().includes('component')) {
    return `🤖 **Component Generation**

file: ${targetPath || 'components/GeneratedComponent.jsx'}
\`\`\`jsx
import React, { useState } from 'react'

const GeneratedComponent = ({ title = "New Component" }) => {
  const [active, setActive] = useState(false)

  return (
    <div className={\`component \${active ? 'active' : ''}\`}>
      <h2>{title}</h2>
      <button onClick={() => setActive(!active)}>
        {active ? 'Deactivate' : 'Activate'}
      </button>
    </div>
  )
}

export default GeneratedComponent
\`\`\`

file: ${targetPath ? targetPath.replace('.jsx', '.css') : 'components/GeneratedComponent.css'}
\`\`\`css
.component {
  padding: 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  transition: all 0.3s;
}

.component.active {
  border-color: #4ecdc4;
  background: rgba(78, 205, 196, 0.1);
}
\`\`\``
  }
  
  return `🤖 **Claudy Ready**

I can generate:
- React components
- Utility functions  
- CSS styles
- API services

What would you like me to create?`
}
