import { useState, useCallback } from 'react'

export const useCodeRunner = () => {
  const [previewContent, setPreviewContent] = useState('')
  const [consoleOutput, setConsoleOutput] = useState([])
  const [isRunning, setIsRunning] = useState(false)

  const runCode = useCallback(async (file) => {
    if (!file) return

    setIsRunning(true)
    setConsoleOutput([])

    try {
      const ext = file.name.split('.').pop()?.toLowerCase()
      
      if (ext === 'html') {
        // Run HTML directly
        setPreviewContent(file.content)
        setConsoleOutput([{
          type: 'info',
          message: `HTML file "${file.name}" loaded in preview`,
          timestamp: new Date().toLocaleTimeString()
        }])
      } 
      else if (ext === 'js' || ext === 'jsx') {
        // Run JavaScript
        await runJavaScript(file.content, file.name)
      }
      else {
        setConsoleOutput([{
          type: 'warn',
          message: `File type "${ext}" cannot be executed`,
          timestamp: new Date().toLocaleTimeString()
        }])
      }
    } catch (error) {
      setConsoleOutput(prev => [...prev, {
        type: 'error',
        message: `Runtime error: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } finally {
      setIsRunning(false)
    }
  }, [])

  const runJavaScript = async (code, fileName) => {
    // Create a sandboxed environment for JS execution
    const originalConsole = window.console
    const logs = []

    // Override console methods
    const mockConsole = {
      log: (...args) => logs.push({ type: 'log', args, timestamp: new Date().toLocaleTimeString() }),
      error: (...args) => logs.push({ type: 'error', args, timestamp: new Date().toLocaleTimeString() }),
      warn: (...args) => logs.push({ type: 'warn', args, timestamp: new Date().toLocaleTimeString() }),
      info: (...args) => logs.push({ type: 'info', args, timestamp: new Date().toLocaleTimeString() })
    }

    try {
      // Replace console temporarily
      window.console = mockConsole

      // Create function and execute
      const func = new Function('console', code)
      const result = func(mockConsole)

      // If there's a return value, log it
      if (result !== undefined) {
        logs.push({
          type: 'return',
          args: [result],
          timestamp: new Date().toLocaleTimeString()
        })
      }

      // Convert logs to console output format
      const output = logs.map(log => ({
        type: log.type,
        message: log.args.map(arg => 
          typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
        ).join(' '),
        timestamp: log.timestamp
      }))

      setConsoleOutput(output)

    } catch (error) {
      setConsoleOutput([{
        type: 'error',
        message: `Execution error in "${fileName}": ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } finally {
      // Restore original console
      window.console = originalConsole
    }
  }

  const clearConsole = () => {
    setConsoleOutput([])
  }

  const clearPreview = () => {
    setPreviewContent('')
  }

  return {
    previewContent,
    consoleOutput,
    isRunning,
    runCode,
    clearConsole,
    clearPreview
  }
}
