import React from 'react'

const ContextMenu = ({ contextMenu, onAction }) => {
  const { x, y, item } = contextMenu

  return (
    <div 
      className="context-menu"
      style={{ left: x, top: y }}
    >
      {item.type === 'folder' && (
        <>
          <div 
            className="context-item"
            onClick={() => onAction('add-file', item)}
          >
            📄 New File
          </div>
          <div 
            className="context-item"
            onClick={() => onAction('add-folder', item)}
          >
            📁 New Folder
          </div>
          <div className="context-divider"></div>
        </>
      )}
      
      {item.type === 'file' && item.name.endsWith('.html') && (
        <div 
          className="context-item"
          onClick={() => onAction('run-preview', item)}
        >
          ▶ Run in Preview
        </div>
      )}
      
      <div 
        className="context-item"
        onClick={() => onAction('rename', item)}
      >
        ✏️ Rename
      </div>
      <div 
        className="context-item"
        onClick={() => onAction('delete', item)}
      >
        🗑️ Delete
      </div>
    </div>
  )
}

export default ContextMenu
