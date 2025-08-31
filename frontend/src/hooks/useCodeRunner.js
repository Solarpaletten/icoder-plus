import { useState, useCallback, useRef } from 'react'

export const useCodeRunner = () => {
  const [isRunning, setIsRunning] = useState(false)
  const [previewMode, setPreviewMode] = useState(false) // Editor / Preview toggle
  const [output, setOutput] = useState('')
  const [consoleLog, setConsoleLog] = useState([])
  const previewFrameRef = useRef(null)

  // Execute JavaScript code
  const runJavaScript = useCallback((code, filename = 'script.js') => {
    setConsoleLog([])
    const logs = []
    
    try {
      // Capture console.log
      const originalLog = console.log
      const originalError = console.error
      const originalWarn = console.warn
      
      console.log = (...args) => {
        const message = args.map(arg => 
          typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
        ).join(' ')
        logs.push({ type: 'log', message, timestamp: new Date().toLocaleTimeString() })
        originalLog(...args)
      }
      
      console.error = (...args) => {
        const message = args.join(' ')
        logs.push({ type: 'error', message, timestamp: new Date().toLocaleTimeString() })
        originalError(...args)
      }
      
      console.warn = (...args) => {
        const message = args.join(' ')
        logs.push({ type: 'warn', message, timestamp: new Date().toLocaleTimeString() })
        originalWarn(...args)
      }

      // Execute code in isolated scope
      const executeCode = new Function('console', code)
      executeCode(console)
      
      // Restore original console
      console.log = originalLog
      console.error = originalError
      console.warn = originalWarn
      
      if (logs.length === 0) {
        logs.push({ 
          type: 'success', 
          message: '✅ Code executed successfully with no output',
          timestamp: new Date().toLocaleTimeString()
        })
      }
    } catch (error) {
      logs.push({ 
        type: 'error', 
        message: `❌ ${error.name}: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      })
    }
    
    setConsoleLog(logs)
    setOutput(logs.map(log => `[${log.timestamp}] ${log.message}`).join('\n'))
    return logs
  }, [])

  // Render HTML in iframe
  const runHTML = useCallback((htmlContent, filename = 'index.html') => {
    if (!previewFrameRef.current) return

    const iframe = previewFrameRef.current
    
    try {
      // Enhanced HTML template with console capture
      const enhancedHTML = `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live Preview - ${filename}</title>
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background: #ffffff;
                    color: #333;
                }
                pre { 
                    background: #f5f5f5; 
                    padding: 10px; 
                    border-radius: 4px; 
                    overflow-x: auto;
                }
            </style>
        </head>
        <body>
            ${htmlContent}
            <script>
                // Capture console output and send to parent
                const originalLog = console.log;
                const originalError = console.error;
                
                console.log = (...args) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'log',
                        message: args.join(' '),
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                    originalLog(...args);
                };
                
                console.error = (...args) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'error',
                        message: args.join(' '),
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                    originalError(...args);
                };
                
                // Catch runtime errors
                window.onerror = (message, source, lineno, colno, error) => {
                    window.parent.postMessage({
                        type: 'console',
                        level: 'error',
                        message: \`Runtime Error: \${message} at line \${lineno}\`,
                        timestamp: new Date().toLocaleTimeString()
                    }, '*');
                };
            </script>
        </body>
        </html>
      `

      const doc = iframe.contentDocument || iframe.contentWindow.document
      doc.open()
      doc.write(enhancedHTML)
      doc.close()
      
      setConsoleLog([{
        type: 'success',
        message: `🌐 HTML rendered successfully: ${filename}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    } catch (error) {
      setConsoleLog([{
        type: 'error',
        message: `❌ HTML Render Error: ${error.message}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    }
  }, [])

  // Main run function - detects file type and runs accordingly
  const runCode = useCallback(async (file) => {
    if (!file || !file.content) return

    setIsRunning(true)
    const fileName = file.name || 'untitled'
    const content = file.content

    if (fileName.endsWith('.js') || fileName.endsWith('.jsx')) {
      runJavaScript(content, fileName)
    } else if (fileName.endsWith('.html') || fileName.endsWith('.htm')) {
      runHTML(content, fileName)
      setPreviewMode(true) // Auto-switch to preview for HTML
    } else if (fileName.endsWith('.css')) {
      // CSS Preview
      const cssPreview = `
        <style>${content}</style>
        <div class="css-demo">
          <h1>CSS Preview</h1>
          <p>Your styles are applied to this demo content.</p>
          <button>Sample Button</button>
          <div class="box">Sample Box</div>
        </div>
      `
      runHTML(cssPreview, fileName)
      setPreviewMode(true)
    } else {
      setConsoleLog([{
        type: 'warn',
        message: `⚠️ File type not supported for preview: ${fileName}`,
        timestamp: new Date().toLocaleTimeString()
      }])
    }

    // Simulate execution delay for UX
    setTimeout(() => setIsRunning(false), 500)
  }, [runJavaScript, runHTML])

  // Listen for iframe console messages
  const handleIframeMessage = useCallback((event) => {
    if (event.data?.type === 'console') {
      setConsoleLog(prev => [...prev, {
        type: event.data.level,
        message: event.data.message,
        timestamp: event.data.timestamp
      }])
    }
  }, [])

  // Setup iframe message listener
  useState(() => {
    window.addEventListener('message', handleIframeMessage)
    return () => window.removeEventListener('message', handleIframeMessage)
  }, [handleIframeMessage])

  const clearConsole = () => {
    setConsoleLog([])
    setOutput('')
  }

  const togglePreview = () => {
    setPreviewMode(!previewMode)
  }

  return {
    isRunning,
    previewMode,
    output,
    consoleLog,
    previewFrameRef,
    runCode,
    clearConsole,
    togglePreview,
    setPreviewMode
  }
}
