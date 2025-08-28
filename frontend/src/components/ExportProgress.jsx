import React from 'react'

const ExportProgress = ({ progress }) => {
  return (
    <div className="export-progress">
      <h3 className="text-sm font-semibold mb-2">Exporting Project...</h3>
      <p className="text-xs text-ide-muted mb-2">{progress.message}</p>
      <div className="progress-bar">
        <div 
          className="progress-fill"
          style={{ width: `${progress.progress}%` }}
        />
      </div>
      <p className="text-xs mt-2">{Math.round(progress.progress)}%</p>
    </div>
  )
}

export default ExportProgress
