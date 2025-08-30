cat >> src/styles/globals.css << 'EOF'

/* File Tree Styles */
.file-tree {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #1e1e1e;
  color: #cccccc;
}

.tree-header {
  padding: 12px 16px;
  border-bottom: 1px solid #2d2d30;
  background: #252526;
}

.tree-btn {
  padding: 4px;
  background: transparent;
  border: none;
  border-radius: 3px;
  color: #cccccc;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tree-btn:hover {
  background: #2a2d2e;
}

.search-box {
  padding: 8px 16px;
  border-bottom: 1px solid #2d2d30;
}

.search-input {
  width: 100%;
  padding: 6px 8px;
  background: #3c3c3c;
  border: 1px solid #464647;
  border-radius: 3px;
  color: #cccccc;
  font-size: 13px;
}

.search-input::placeholder {
  color: #888;
}

.tree-content {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.tree-item-container {
  position: relative;
}

.tree-item {
  display: flex;
  align-items: center;
  padding: 4px 16px 4px 8px;
  cursor: pointer;
  user-select: none;
  gap: 6px;
  min-height: 22px;
}

.tree-item:hover {
  background: #2a2d2e;
}

.tree-item.selected {
  background: #094771;
}

.tree-item.drag-over {
  background: #264f78;
}

.tree-arrow {
  display: flex;
  align-items: center;
  color: #cccccc;
  width: 16px;
  justify-content: center;
}

.tree-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.tree-name {
  font-size: 13px;
  color: #cccccc;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tree-rename-input {
  flex: 1;
  background: #3c3c3c;
  border: 1px solid #007acc;
  border-radius: 3px;
  padding: 2px 4px;
  font-size: 13px;
  color: #cccccc;
  outline: none;
}

.tree-children {
  margin-left: 12px;
}

/* Context Menu */
.context-menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
}

.context-menu {
  position: fixed;
  background: #2d2d30;
  border: 1px solid #464647;
  border-radius: 3px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
  z-index: 1000;
  min-width: 160px;
  padding: 4px 0;
}

.context-menu-item {
  padding: 6px 12px;
  font-size: 13px;
  color: #cccccc;
  cursor: pointer;
  user-select: none;
}

.context-menu-item:hover {
  background: #094771;
}

.context-menu-divider {
  height: 1px;
  background: #464647;
  margin: 4px 0;
}