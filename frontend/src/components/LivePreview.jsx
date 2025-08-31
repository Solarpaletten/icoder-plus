import React from 'react'
import { Play, Eye, Code, RotateCcw, Trash2, Maximize2 } from 'lucide-react'

const LivePreview = ({ 
  activeTab, 
  isRunning, 
  previewMode, 
  consoleLog, 
  previewFrameRef,
  onRunCode,
  onTogglePreview,
  onClearConsole 
}) => {
  const getFileTypeIcon = (fileName) => {
    if (fileName?.endsWith('.html') || fileName?.endsWith('.htm')) return '🌐'
    if (fileName?.endsWith('.js') || fileName?.endsWith('.jsx')) return '🟨'
    if (fileName?.endsWith('.css')) return '🎨'
    return '📄'
  }

  const getConsoleIcon = (type) => {
    switch (type) {
      case 'error': return '❌'
      case 'warn': return '⚠️'
      case 'success': return '✅'
      default: return '📝'
    }
  }

  return (
    <div className="live-preview-panel">
      {/* Header */}
      <div className="preview-header">
        <div className="preview-title">
          <span>{getFileTypeIcon(activeTab?.name)} Live Preview</span>
          {activeTab?.name && (
            <span className="preview-filename">{activeTab.name}</span>
          )}
        </div>
        
        <div className="preview-actions">
          <button 
            className="action-btn run-btn"
            onClick={() => onRunCode(activeTab)}
            disabled={!activeTab || isRunning}
            title="Run Code (Ctrl+R)"
          >
            <Play size={16} />
            {isRunning ? 'Running...' : 'Run'}
          </button>
          
          <button
            className="action-btn"
            onClick={onTogglePreview}
            title="Toggle Preview Mode"
          >
            {previewMode ? <Code size={16} /> : <Eye size={16} />}
            {previewMode ? 'Code' : 'Preview'}
          </button>
          
          <button
            className="action-btn"
            onClick={onClearConsole}
            title="Clear Console"
          >
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="preview-content">
        {!activeTab ? (
          <div className="preview-empty">
            <Code size={48} style={{color: '#666'}} />
            <h3>No File Selected</h3>
            <p>Select a file from the explorer to preview it here</p>
          </div>
        ) : previewMode ? (
          /* Preview Mode - Show iframe */
          <div className="preview-iframe-container">
            <iframe 
              ref={previewFrameRef}
              className="preview-iframe"
              title={`Preview: ${activeTab.name}`}
              sandbox="allow-scripts allow-same-origin allow-forms"
            />
          </div>
        ) : (
          /* Console Mode - Show output */
          <div className="console-output">
            <div className="console-header">
              <span>📟 Console Output</span>
              <span className="console-count">
                {consoleLog.length} {consoleLog.length === 1 ? 'entry' : 'entries'}
              </span>
            </div>
            
            <div className="console-logs">
              {consoleLog.length === 0 ? (
                <div className="console-empty">
                  <span>No output yet. Click "Run" to execute your code.</span>
                </div>
              ) : (
                consoleLog.map((log, index) => (
                  <div key={index} className={`console-log console-${log.type}`}>
                    <span className="console-icon">{getConsoleIcon(log.type)}</span>
                    <span className="console-timestamp">[{log.timestamp}]</span>
                    <span className="console-message">{log.message}</span>
                  </div>
                ))
              )}
            </div>
          </div>
        )}
      </div>

      {/* Footer with file info */}
      {activeTab && (
        <div className="preview-footer">
          <span className="file-info">
            Language: {activeTab.name?.split('.').pop()?.toUpperCase() || 'Unknown'}
          </span>
          <span className="file-size">
            {activeTab.content?.length || 0} characters
          </span>
        </div>
      )}
    </div>
  )
}

export default LivePreview
