// src/services/diffService.js - Advanced Diff Engine for iCoder Plus v2.0
import { diffLines, diffWords, createPatch } from 'diff';
import { html } from 'diff2html';

/**
 * Generate line-by-line diff between two code versions
 */
export function generateLineDiff(oldCode, newCode, fileName = 'file.js') {
  const diff = diffLines(oldCode || '', newCode || '');
  
  const changes = {
    added: [],
    removed: [],
    unchanged: [],
    hasChanges: false
  };

  let lineNumber = 1;
  
  diff.forEach(part => {
    const lines = part.value.split('\n').filter((line, idx, arr) => 
      idx < arr.length - 1 || line.trim() !== ''
    );

    lines.forEach(line => {
      if (part.added) {
        changes.added.push({ line, lineNumber: lineNumber++ });
        changes.hasChanges = true;
      } else if (part.removed) {
        changes.removed.push({ line, lineNumber });
        changes.hasChanges = true;
      } else {
        changes.unchanged.push({ line, lineNumber: lineNumber++ });
      }
    });
  });

  return changes;
}

/**
 * Generate word-level diff for inline highlighting
 */
export function generateWordDiff(oldCode, newCode) {
  const diff = diffWords(oldCode || '', newCode || '');
  
  return diff.map(part => ({
    value: part.value,
    added: part.added || false,
    removed: part.removed || false
  }));
}

/**
 * Generate HTML diff view using diff2html
 */
export function generateHTMLDiff(oldCode, newCode, fileName = 'file.js') {
  try {
    const patch = createPatch(fileName, oldCode || '', newCode || '');
    
    const diffHtml = html(patch, {
      drawFileList: false,
      matching: 'lines',
      outputFormat: 'side-by-side',
      colorScheme: 'dark'
    });

    return diffHtml;
  } catch (error) {
    console.error('HTML diff generation failed:', error);
    return '<div class="error">Diff generation failed</div>';
  }
}

/**
 * Get diff statistics (additions, deletions, changes)
 */
export function getDiffStats(oldCode, newCode) {
  const diff = diffLines(oldCode || '', newCode || '');
  
  const stats = {
    additions: 0,
    deletions: 0,
    modifications: 0,
    totalLines: 0
  };

  diff.forEach(part => {
    const lineCount = part.value.split('\n').length - 1;
    
    if (part.added) {
      stats.additions += lineCount;
    } else if (part.removed) {
      stats.deletions += lineCount;
    } else {
      stats.totalLines += lineCount;
    }
  });

  // Calculate modifications (pairs of add/remove operations)
  stats.modifications = Math.min(stats.additions, stats.deletions);
  stats.netAdditions = stats.additions - stats.modifications;
  stats.netDeletions = stats.deletions - stats.modifications;

  return stats;
}

/**
 * Simple diff for basic visualization (used in UI components)
 */
export function getSimpleDiff(oldCode, newCode) {
  if (!oldCode && !newCode) {
    return { type: 'none', message: 'No content to compare' };
  }
  
  if (!oldCode) {
    return { 
      type: 'added', 
      message: '🆕 New file created',
      preview: newCode.slice(0, 100) + (newCode.length > 100 ? '...' : '')
    };
  }
  
  if (!newCode) {
    return { 
      type: 'deleted', 
      message: '❌ File deleted',
      preview: oldCode.slice(0, 100) + (oldCode.length > 100 ? '...' : '')
    };
  }
  
  if (oldCode === newCode) {
    return { 
      type: 'unchanged', 
      message: '✅ No changes detected',
      preview: newCode.slice(0, 100) + (newCode.length > 100 ? '...' : '')
    };
  }

  const stats = getDiffStats(oldCode, newCode);
  const changeType = stats.additions > stats.deletions ? 'mostly-added' : 
                    stats.deletions > stats.additions ? 'mostly-deleted' : 'modified';

  return {
    type: changeType,
    message: `✏️ ${stats.additions} additions, ${stats.deletions} deletions`,
    stats,
    preview: newCode.slice(0, 100) + (newCode.length > 100 ? '...' : '')
  };
}

/**
 * Find changed functions/classes in the code
 */
export function findChangedFunctions(oldCode, newCode) {
  const functionRegex = /(?:function\s+(\w+)|const\s+(\w+)\s*=.*=>|class\s+(\w+))/g;
  
  const oldFunctions = new Set();
  const newFunctions = new Set();
  
  let match;
  
  // Extract function names from old code
  while ((match = functionRegex.exec(oldCode || '')) !== null) {
    const functionName = match[1] || match[2] || match[3];
    if (functionName) oldFunctions.add(functionName);
  }
  
  // Reset regex for new code
  functionRegex.lastIndex = 0;
  
  // Extract function names from new code
  while ((match = functionRegex.exec(newCode || '')) !== null) {
    const functionName = match[1] || match[2] || match[3];
    if (functionName) newFunctions.add(functionName);
  }
  
  return {
    added: [...newFunctions].filter(fn => !oldFunctions.has(fn)),
    removed: [...oldFunctions].filter(fn => !newFunctions.has(fn)),
    common: [...newFunctions].filter(fn => oldFunctions.has(fn))
  };
}

/**
 * Generate compact diff summary for version history
 */
export function generateDiffSummary(oldCode, newCode, maxLength = 200) {
  const simpleDiff = getSimpleDiff(oldCode, newCode);
  
  if (simpleDiff.type === 'unchanged') {
    return '✅ No changes';
  }
  
  const changedFunctions = findChangedFunctions(oldCode, newCode);
  let summary = simpleDiff.message;
  
  if (changedFunctions.added.length > 0) {
    summary += ` | ➕ ${changedFunctions.added.join(', ')}`;
  }
  
  if (changedFunctions.removed.length > 0) {
    summary += ` | ➖ ${changedFunctions.removed.join(', ')}`;
  }
  
  return summary.length > maxLength ? 
    summary.slice(0, maxLength - 3) + '...' : 
    summary;
}

/**
 * Check if changes are significant enough to create a new version
 */
export function isSignificantChange(oldCode, newCode, threshold = 0.05) {
  if (!oldCode || !newCode) return true;
  
  const stats = getDiffStats(oldCode, newCode);
  const totalOriginalLines = oldCode.split('\n').length;
  
  // Consider significant if changes affect more than threshold% of the file
  const changeRatio = (stats.additions + stats.deletions) / totalOriginalLines;
  
  return changeRatio > threshold;
}

/**
 * Format diff for console output (development/debugging)
 */
export function formatDiffForConsole(oldCode, newCode) {
  const diff = diffLines(oldCode || '', newCode || '');
  
  let output = '';
  diff.forEach(part => {
    const prefix = part.added ? '+' : part.removed ? '-' : ' ';
    const lines = part.value.split('\n');
    
    lines.forEach(line => {
      if (line.trim()) {
        output += `${prefix} ${line}\n`;
      }
    });
  });
  
  return output;
}

// Export utility functions
export const DIFF_TYPES = {
  NONE: 'none',
  ADDED: 'added', 
  DELETED: 'deleted',
  UNCHANGED: 'unchanged',
  MODIFIED: 'modified',
  MOSTLY_ADDED: 'mostly-added',
  MOSTLY_DELETED: 'mostly-deleted'
};

export const DIFF_CONFIG = {
  maxPreviewLength: 100,
  significanceThreshold: 0.05,
  htmlOptions: {
    drawFileList: false,
    matching: 'lines',
    outputFormat: 'side-by-side',
    colorScheme: 'dark'
  }
};