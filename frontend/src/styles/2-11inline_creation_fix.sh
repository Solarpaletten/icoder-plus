
cat >> globals.css << 'EOF'

/* VS Code Inline Creation Styles */
.tree-item.creating {
  background: var(--bg-tertiary);
  border: 1px solid var(--accent-blue);
  margin: 2px 4px;
  border-radius: 4px;
}

.tree-creation-input {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--text-primary);
  font-size: 13px;
  font-family: inherit;
  outline: none;
  padding: 2px 4px;
}

.tree-creation-input::placeholder {
  color: var(--text-secondary);
  font-style: italic;
}

/* Улучшенные кнопки + */
.tree-btn {
  padding: 4px;
  background: transparent;
  border: none;
  border-radius: 3px;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.tree-btn:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.tree-header {
  padding: 8px 12px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  user-select: none;
}

.search-box {
  padding: 8px 12px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
}

.search-input {
  width: 100%;
  padding: 4px 8px;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: 3px;
  color: var(--text-primary);
  font-size: 13px;
}

.search-input:focus {
  outline: none;
  border-color: var(--accent-blue);
}

.search-input::placeholder {
  color: var(--text-secondary);
}
EOF

