import { useState } from 'react'

export const useDualAgent = () => {
  const [agent, setAgent] = useState('claudy') // По умолчанию Claudy активен

  return {
    agent,
    setAgent
  }
}
