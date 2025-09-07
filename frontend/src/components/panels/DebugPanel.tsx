import React, { useState, useEffect } from 'react';
import { Play, Pause, Square, SkipForward, ArrowDown, ArrowRight, RotateCcw, X, Circle, Eye, Settings } from 'lucide-react';
import type { FileItem } from '../../types';

interface Breakpoint {
  id: string;
  file: string;
  line: number;
  enabled: boolean;
  condition?: string;
}

interface Variable {
  name: string;
  value: string;
  type: string;
  expandable: boolean;
  expanded?: boolean;
  children?: Variable[];
}

interface CallStackFrame {
  id: string;
  name: string;
  file: string;
  line: number;
  column: number;
}

interface DebugPanelProps {
  files: FileItem[];
  onFileSelect: (file: FileItem) => void;
  onClose: () => void;
}

export const DebugPanel: React.FC<DebugPanelProps> = ({
  files,
  onFileSelect,
  onClose
}) => {
  const [isDebugging, setIsDebugging] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [breakpoints, setBreakpoints] = useState<Breakpoint[]>([]);
  const [variables, setVariables] = useState<Variable[]>([]);
  const [callStack, setCallStack] = useState<CallStackFrame[]>([]);
  const [watchExpressions, setWatchExpressions] = useState<string[]>([]);
  const [newWatchExpression, setNewWatchExpression] = useState('');
  const [selectedConfig, setSelectedConfig] = useState('Launch Program');

  // Mock debug data
  useEffect(() => {
    const mockBreakpoints: Breakpoint[] = [
      { id: '1', file: 'src/App.tsx', line: 15, enabled: true },
      { id: '2', file: 'src/components/AppShell.tsx', line: 23, enabled: false },
      { id: '3', file: 'src/hooks/useFileManager.ts', line: 45, enabled: true }
    ];

    const mockVariables: Variable[] = [
      { 
        name: 'fileManager', 
        value: '{...}', 
        type: 'object', 
        expandable: true,
        expanded: false,
        children: [
          { name: 'fileTree', value: 'Array(3)', type: 'Array', expandable: false },
          { name: 'openTabs', value: 'Array(2)', type: 'Array', expandable: false },
          { name: 'activeTab', value: '{id: "1", name: "App.tsx"}', type: 'object', expandable: false }
        ]
      },
      { name: 'panelState', value: '{...}', type: 'object', expandable: true, expanded: false },
      { name: 'searchQuery', value: '"react"', type: 'string', expandable: false },
      { name: 'isLoading', value: 'false', type: 'boolean', expandable: false }
    ];

    const mockCallStack: CallStackFrame[] = [
      { id: '1', name: 'App', file: 'src/App.tsx', line: 15, column: 8 },
      { id: '2', name: 'AppShell', file: 'src/components/AppShell.tsx', line: 23, column: 12 },
      { id: '3', name: 'useFileManager', file: 'src/hooks/useFileManager.ts', line: 45, column: 5 },
      { id: '4', name: 'openFile', file: 'src/hooks/useFileManager.ts', line: 67, column: 15 }
    ];

    setBreakpoints(mockBreakpoints);
    setVariables(mockVariables);
    setCallStack(mockCallStack);
    setWatchExpressions(['fileManager.openTabs.length', 'panelState.leftVisible']);
  }, []);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey && e.key === 'D') {
        e.preventDefault();
        const input = document.querySelector('#debug-config-select') as HTMLSelectElement;
        input?.focus();
      }
      if (e.key === 'F5') {
        e.preventDefault();
        if (isDebugging) {
          if (isPaused) {
            continueExecution();
          }
        } else {
          startDebugging();
        }
      }
      if (e.key === 'F10') {
        e.preventDefault();
        stepOver();
      }
      if (e.key === 'F11') {
        e.preventDefault();
        stepInto();
      }
      if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose, isDebugging, isPaused]);

  const startDebugging = () => {
    setIsDebugging(true);
    setIsPaused(false);
    console.log('Debug session started');
  };

  const pauseDebugging = () => {
    setIsPaused(true);
    console.log('Debug session paused');
  };

  const continueExecution = () => {
    setIsPaused(false);
    console.log('Debug session continued');
  };

  const stopDebugging = () => {
    setIsDebugging(false);
    setIsPaused(false);
    console.log('Debug session stopped');
  };

  const stepOver = () => {
    console.log('Step over');
  };

  const stepInto = () => {
    console.log('Step into');
  };

  const stepOut = () => {
    console.log('Step out');
  };

  const toggleBreakpoint = (id: string) => {
    setBreakpoints(prev => prev.map(bp => 
      bp.id === id ? { ...bp, enabled: !bp.enabled } : bp
    ));
  };

  const removeBreakpoint = (id: string) => {
    setBreakpoints(prev => prev.filter(bp => bp.id !== id));
  };

  const toggleVariable = (name: string) => {
    setVariables(prev => prev.map(variable => 
      variable.name === name ? { ...variable, expanded: !variable.expanded } : variable
    ));
  };

  const addWatchExpression = () => {
    if (newWatchExpression.trim()) {
      setWatchExpressions(prev => [...prev, newWatchExpression.trim()]);
      setNewWatchExpression('');
    }
  };

  const removeWatchExpression = (index: number) => {
    setWatchExpressions(prev => prev.filter((_, i) => i !== index));
  };

  const handleFileClick = (filePath: string, line?: number) => {
    // Find file in tree and open it
    const findFile = (items: FileItem[], path: string): FileItem | null => {
      for (const item of items) {
        if (item.type === 'file' && path.includes(item.name)) {
          return item;
        }
        if (item.children) {
          const found = findFile(item.children, path);
          if (found) return found;
        }
      }
      return null;
    };

    const file = findFile(files, filePath);
    if (file) {
      onFileSelect(file);
      // TODO: Jump to specific line in Monaco Editor
    }
  };

  return (
    <div className="h-full bg-gray-900 text-gray-200 flex flex-col">
      {/* Header */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-medium text-gray-300">RUN AND DEBUG</h3>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
          >
            <X size={14} />
          </button>
        </div>

        {/* Debug Configuration */}
        <div className="mb-3">
          <select
            id="debug-config-select"
            value={selectedConfig}
            onChange={(e) => setSelectedConfig(e.target.value)}
            className="w-full bg-gray-800 text-gray-200 text-xs border border-gray-600 rounded px-2 py-1.5"
          >
            <option value="Launch Program">Launch Program</option>
            <option value="Attach to Process">Attach to Process</option>
            <option value="Debug Tests">Debug Tests</option>
            <option value="Debug Current File">Debug Current File</option>
          </select>
        </div>

        {/* Debug Controls */}
        <div className="flex items-center gap-1 mb-3">
          {!isDebugging ? (
            <button
              onClick={startDebugging}
              className="p-2 bg-green-600 hover:bg-green-700 rounded text-white transition-colors"
              title="Start Debugging (F5)"
            >
              <Play size={14} />
            </button>
          ) : (
            <>
              {isPaused ? (
                <button
                  onClick={continueExecution}
                  className="p-2 bg-blue-600 hover:bg-blue-700 rounded text-white transition-colors"
                  title="Continue (F5)"
                >
                  <Play size={14} />
                </button>
              ) : (
                <button
                  onClick={pauseDebugging}
                  className="p-2 bg-yellow-600 hover:bg-yellow-700 rounded text-white transition-colors"
                  title="Pause"
                >
                  <Pause size={14} />
                </button>
              )}
              <button
                onClick={stopDebugging}
                className="p-2 bg-red-600 hover:bg-red-700 rounded text-white transition-colors"
                title="Stop"
              >
                <Square size={14} />
              </button>
              <button
                onClick={stepOver}
                className="p-2 bg-gray-600 hover:bg-gray-700 rounded text-white transition-colors"
                title="Step Over (F10)"
              >
                <ArrowDown size={14} />
              </button>
              <button
                onClick={stepInto}
                className="p-2 bg-gray-600 hover:bg-gray-700 rounded text-white transition-colors"
                title="Step Into (F11)"
              >
                <ArrowRight size={14} />
              </button>
              <button
                onClick={stepOut}
                className="p-2 bg-gray-600 hover:bg-gray-700 rounded text-white transition-colors"
                title="Step Out"
              >
                <SkipForward size={14} />
              </button>
            </>
          )}
          <button
            className="p-2 bg-gray-600 hover:bg-gray-700 rounded text-white transition-colors"
            title="Restart"
          >
            <RotateCcw size={14} />
          </button>
        </div>

        {/* Debug Status */}
        <div className="text-xs text-gray-400 mb-2">
          {isDebugging ? (
            <span className="text-green-400">
              {isPaused ? '⏸ Paused on breakpoint' : '▶ Running'}
            </span>
          ) : (
            'Not debugging'
          )}
        </div>
      </div>

      {/* Debug Sections */}
      <div className="flex-1 overflow-y-auto">
        {/* Variables */}
        <div className="border-b border-gray-800">
          <div className="px-3 py-2 bg-gray-800 border-b border-gray-700">
            <span className="text-sm font-medium text-gray-300">VARIABLES</span>
          </div>
          <div className="max-h-40 overflow-y-auto">
            {variables.map((variable, index) => (
              <div key={index} className="px-3 py-1">
                <div 
                  className="flex items-center cursor-pointer hover:bg-gray-800 py-1"
                  onClick={() => variable.expandable && toggleVariable(variable.name)}
                >
                  {variable.expandable && (
                    <div className="mr-1 w-3">
                      {variable.expanded ? <ArrowDown size={10} /> : <ArrowRight size={10} />}
                    </div>
                  )}
                  <span className="text-xs text-blue-400 mr-2">{variable.name}</span>
                  <span className="text-xs text-gray-300 truncate">{variable.value}</span>
                  <span className="text-xs text-gray-500 ml-auto">{variable.type}</span>
                </div>
                {variable.expanded && variable.children && (
                  <div className="ml-4">
                    {variable.children.map((child, childIndex) => (
                      <div key={childIndex} className="flex items-center py-1">
                        <span className="text-xs text-blue-400 mr-2">{child.name}</span>
                        <span className="text-xs text-gray-300 truncate">{child.value}</span>
                        <span className="text-xs text-gray-500 ml-auto">{child.type}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Watch */}
        <div className="border-b border-gray-800">
          <div className="px-3 py-2 bg-gray-800 border-b border-gray-700">
            <span className="text-sm font-medium text-gray-300">WATCH</span>
          </div>
          <div className="max-h-32 overflow-y-auto">
            <div className="px-3 py-2">
              <input
                type="text"
                placeholder="Add expression to watch..."
                className="w-full bg-gray-800 text-gray-200 text-xs rounded px-2 py-1 border border-gray-600"
                value={newWatchExpression}
                onChange={(e) => setNewWatchExpression(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && addWatchExpression()}
              />
            </div>
            {watchExpressions.map((expression, index) => (
              <div key={index} className="px-3 py-1 flex items-center hover:bg-gray-800 group">
                <Eye size={10} className="mr-2 text-gray-400" />
                <span className="text-xs text-gray-300 flex-1 truncate">{expression}</span>
                <span className="text-xs text-blue-400 mr-2">2</span>
                <button
                  onClick={() => removeWatchExpression(index)}
                  className="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-700 rounded"
                >
                  <X size={8} />
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Call Stack */}
        <div className="border-b border-gray-800">
          <div className="px-3 py-2 bg-gray-800 border-b border-gray-700">
            <span className="text-sm font-medium text-gray-300">CALL STACK</span>
          </div>
          <div className="max-h-32 overflow-y-auto">
            {callStack.map((frame, index) => (
              <div 
                key={frame.id} 
                className="px-3 py-1 hover:bg-gray-800 cursor-pointer"
                onClick={() => handleFileClick(frame.file, frame.line)}
              >
                <div className="text-xs text-gray-300">{frame.name}</div>
                <div className="text-xs text-gray-500">
                  {frame.file}:{frame.line}:{frame.column}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Breakpoints */}
        <div>
          <div className="px-3 py-2 bg-gray-800 border-b border-gray-700">
            <span className="text-sm font-medium text-gray-300">BREAKPOINTS</span>
          </div>
          <div className="max-h-32 overflow-y-auto">
            {breakpoints.map((breakpoint) => (
              <div 
                key={breakpoint.id} 
                className="px-3 py-1 flex items-center hover:bg-gray-800 group"
              >
                <button
                  onClick={() => toggleBreakpoint(breakpoint.id)}
                  className="mr-2"
                >
                  <Circle 
                    size={10} 
                    className={breakpoint.enabled ? 'text-red-500 fill-current' : 'text-gray-500'}
                  />
                </button>
                <div 
                  className="flex-1 cursor-pointer"
                  onClick={() => handleFileClick(breakpoint.file, breakpoint.line)}
                >
                  <div className="text-xs text-gray-300">{breakpoint.file}</div>
                  <div className="text-xs text-gray-500">Line {breakpoint.line}</div>
                </div>
                <button
                  onClick={() => removeBreakpoint(breakpoint.id)}
                  className="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-700 rounded"
                >
                  <X size={8} />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
