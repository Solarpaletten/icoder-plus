import React, { useRef, useEffect, useState } from 'react'

const PreviewPanel = ({ activeTab }) => {
  const [consoleOutput, setConsoleOutput] = useState([])
  const previewFrameRef = useRef(null)

  const updatePreview = (htmlContent) => {
    if (previewFrameRef.current) {
      const iframe = previewFrameRef.current
      const doc = iframe.contentDocument || iframe.contentWindow.document
      doc.open()
      doc.write(htmlContent)
      doc.close()
      
      // Capture console output
      iframe.contentWindow.console = {
        log: (...args) => {
          setConsoleOutput(prev => [...prev, { 
            type: 'log', 
            content: args.join(' '),
            timestamp: new Date().toLocaleTimeString()
          }])
        },
        error: (...args) => {
          setConsoleOutput(prev => [...prev, { 
            type: 'error', 
            content: args.join(' '),
            timestamp: new Date().toLocaleTimeString()
          }])
        }
      }
    }
  }

  useEffect(() => {
    if (activeTab?.name.endsWith('.html')) {
      updatePreview(activeTab.content || '')
    }
  }, [activeTab])

  return (
    <div className="preview-panel">
      <div className="flex justify-between items-center mb-3">
        <h3 className="text-sm font-semibold">⚡ Live Preview</h3>
        <button 
          className="btn text-xs p-1"
          onClick={() => {
            if (activeTab?.name.endsWith('.html')) {
              updatePreview(activeTab.content || '')
            }
          }}
        >
          🔄 Refresh
        </button>
      </div>
      
      <iframe 
        ref={previewFrameRef}
        className="preview-frame"
        title="Preview"
      />

      {consoleOutput.length > 0 && (
        <div className="console-output">
          <h4 className="text-xs font-semibold mb-2">📟 Console:</h4>
          {consoleOutput.map((log, i) => (
            <div key={i} className={`console-${log.type} text-xs`}>
              [{log.timestamp}] {log.content}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default PreviewPanel
