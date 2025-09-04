#!/bin/bash

echo "🎯 TERMINAL RESIZE + CODE FOLDING + SMART FILE DROP"
echo "=================================================="
echo "Добавляем: resizable терминал, сворачивание кода, умное перетаскивание файлов"

# ============================================================================
# 1. СОЗДАТЬ RESIZABLE ТЕРМИНАЛ
# ============================================================================

cat > src/components/panels/BottomTerminal.tsx << 'EOF'
import { useState, useRef, useCallback } from 'react';
import { ChevronUp, ChevronDown, Maximize2, Minimize2 } from 'lucide-react';
import { Terminal } from '../Terminal';

interface BottomTerminalProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function BottomTerminal({ isCollapsed, onToggle }: BottomTerminalProps) {
  const [height, setHeight] = useState(200);
  const [isDragging, setIsDragging] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  const startPos = useRef(0);
  const startHeight = useRef(0);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (isCollapsed || isMaximized) return;
    
    e.preventDefault();
    setIsDragging(true);
    startPos.current = e.clientY;
    startHeight.current = height;

    const handleMouseMove = (e: MouseEvent) => {
      const deltaY = startPos.current - e.clientY;
      let newHeight = startHeight.current + deltaY;
      
      // Ограничения высоты
      if (newHeight < 100) newHeight = 100;
      if (newHeight > 600) newHeight = 600;
      
      setHeight(newHeight);
    };

    const handleMouseUp = () => {
      setIsDragging(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  }, [height, isCollapsed, isMaximized]);

  const handleMaximize = () => {
    setIsMaximized(!isMaximized);
  };

  const currentHeight = isCollapsed ? 32 : (isMaximized ? '60vh' : `${height}px`);

  return (
    <div 
      className="border-t border-gray-700 bg-gray-900 transition-all duration-200 flex flex-col"
      style={{ height: currentHeight }}
    >
      {/* Resize Handle */}
      {!isCollapsed && !isMaximized && (
        <div
          onMouseDown={handleMouseDown}
          className={`h-1 bg-gray-600 hover:bg-blue-500 cursor-row-resize transition-colors ${
            isDragging ? 'bg-blue-500' : ''
          }`}
          title="Drag to resize terminal height"
        >
          <div className={`w-full h-full bg-blue-400 opacity-0 hover:opacity-100 transition-opacity ${
            isDragging ? 'opacity-100' : ''
          }`} />
        </div>
      )}

      {/* Terminal Header */}
      <div className="h-8 bg-gray-800 flex items-center justify-between px-3 border-b border-gray-700 flex-shrink-0">
        <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Terminal</span>
        
        <div className="flex items-center space-x-1">
          <button
            onClick={handleMaximize}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title={isMaximized ? "Restore" : "Maximize"}
          >
            {isMaximized ? <Minimize2 size={12} /> : <Maximize2 size={12} />}
          </button>
          
          <button
            onClick={onToggle}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
            title={isCollapsed ? "Expand terminal" : "Collapse terminal"}
          >
            {isCollapsed ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
          </button>
        </div>
      </div>

      {/* Terminal Content */}
      {!isCollapsed && (
        <div className="flex-1 overflow-hidden">
          <Terminal />
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ Resizable Terminal создан"

# ============================================================================
# 2. СОЗДАТЬ SMART CODE EDITOR С CODE FOLDING
# ============================================================================

cat > src/components/SmartCodeEditor.tsx << 'EOF'
import { useState, useRef, useEffect } from 'react';
import { ChevronDown, ChevronRight } from 'lucide-react';

interface SmartCodeEditorProps {
  content: string;
  onChange: (content: string) => void;
  language?: string;
}

interface FoldingRange {
  startLine: number;
  endLine: number;
  isFolded: boolean;
}

export function SmartCodeEditor({ content, onChange, language }: SmartCodeEditorProps) {
  const [foldingRanges, setFoldingRanges] = useState<FoldingRange[]>([]);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const lines = content.split('\n');

  // Определяем блоки для сворачивания
  useEffect(() => {
    const ranges: FoldingRange[] = [];
    let braceStack: number[] = [];

    lines.forEach((line, index) => {
      const trimmed = line.trim();
      
      // Обнаружение начала блока
      if (trimmed.includes('{') || trimmed.includes('function') || trimmed.includes('if') || 
          trimmed.includes('for') || trimmed.includes('while') || trimmed.includes('class')) {
        braceStack.push(index);
      }
      
      // Обнаружение конца блока
      if (trimmed.includes('}') && braceStack.length > 0) {
        const startLine = braceStack.pop()!;
        if (index - startLine > 1) { // Блок больше 1 строки
          ranges.push({
            startLine,
            endLine: index,
            isFolded: false
          });
        }
      }
    });

    setFoldingRanges(ranges);
  }, [content]);

  const toggleFold = (rangeIndex: number) => {
    setFoldingRanges(prev => 
      prev.map((range, index) => 
        index === rangeIndex ? { ...range, isFolded: !range.isFolded } : range
      )
    );
  };

  const getVisibleLines = () => {
    const visibleLines: string[] = [];
    const lineStates: boolean[] = new Array(lines.length).fill(true);

    // Отмечаем скрытые строки
    foldingRanges.forEach(range => {
      if (range.isFolded) {
        for (let i = range.startLine + 1; i <= range.endLine; i++) {
          lineStates[i] = false;
        }
      }
    });

    // Собираем видимые строки
    lines.forEach((line, index) => {
      if (lineStates[index]) {
        visibleLines.push(line);
      } else if (index === foldingRanges.find(r => r.isFolded && r.startLine + 1 === index)?.startLine + 1) {
        // Добавляем многоточие для свернутого блока
        visibleLines.push('    ... // collapsed block');
      }
    });

    return visibleLines;
  };

  const renderLineNumbers = () => {
    const visibleLines = getVisibleLines();
    
    return (
      <div className="w-12 bg-gray-800 border-r border-gray-700 text-right pr-2 py-2 text-xs text-gray-500 font-mono select-none">
        {visibleLines.map((_, index) => {
          const actualLineNumber = index + 1;
          const foldingRange = foldingRanges.find(r => r.startLine === index);
          
          return (
            <div 
              key={index}
              className="flex items-center justify-end h-5 relative hover:bg-gray-700"
            >
              <span className="mr-1">{actualLineNumber}</span>
              
              {foldingRange && (
                <button
                  onClick={() => toggleFold(foldingRanges.indexOf(foldingRange))}
                  className="absolute left-1 w-3 h-3 flex items-center justify-center hover:bg-gray-600 rounded"
                  title={foldingRange.isFolded ? "Expand" : "Collapse"}
                >
                  {foldingRange.isFolded ? 
                    <ChevronRight size={8} className="text-gray-400" /> : 
                    <ChevronDown size={8} className="text-gray-400" />
                  }
                </button>
              )}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="flex h-full bg-gray-900">
      {/* Line Numbers with Folding Controls */}
      {renderLineNumbers()}
      
      {/* Code Editor */}
      <div className="flex-1 relative">
        <textarea
          ref={textareaRef}
          value={content}
          onChange={(e) => onChange(e.target.value)}
          className="w-full h-full p-2 bg-gray-900 text-white font-mono text-sm resize-none outline-none leading-5"
          placeholder="Start typing your code..."
          spellCheck={false}
          style={{ lineHeight: '20px' }}
        />
        
        {/* Language indicator */}
        {language && (
          <div className="absolute bottom-2 right-2 px-2 py-1 bg-gray-800 rounded text-xs text-gray-400">
            {language.toUpperCase()}
          </div>
        )}
      </div>
    </div>
  );
}
EOF

echo "✅ Smart Code Editor с folding создан"

# ============================================================================
# 3. ОБНОВИТЬ FileTree С SMART DRAG & DROP
# ============================================================================

cat > src/components/FileTree.tsx << 'EOF'
import { useState } from 'react';
import { ChevronRight, ChevronDown, File, Folder, Plus } from 'lucide-react';
import type { FileItem, FileManagerState } from '../types';

interface FileTreeProps extends FileManagerState {
  createFile: (parentId: string | null, name: string, content?: string) => void;
  createFolder: (parentId: string | null, name: string) => void;
  openFile: (file: FileItem) => void;
  toggleFolder: (folder: FileItem) => void;
  setSearchQuery: (query: string) => void;
}

export function FileTree(props: FileTreeProps) {
  const [dragOver, setDragOver] = useState<string | null>(null);

  const handleDrop = (e: React.DragEvent, targetId: string | null) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(null);

    const files = Array.from(e.dataTransfer.files);
    if (files.length === 0) return;

    files.forEach(file => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const content = event.target?.result as string;
        props.createFile(targetId, file.name, content);
      };
      reader.readAsText(file);
    });
  };

  const handleDragOver = (e: React.DragEvent, itemId: string | null) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(itemId);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(null);
  };

  const renderFileItem = (item: FileItem, level = 0) => (
    <div key={item.id}>
      <div 
        className={`flex items-center px-2 py-1 hover:bg-gray-700 cursor-pointer text-sm transition-colors ${
          dragOver === item.id ? 'bg-blue-600' : ''
        }`}
        style={{ paddingLeft: `${level * 20 + 8}px` }}
        onClick={() => item.type === 'folder' ? props.toggleFolder(item) : props.openFile(item)}
        onDrop={(e) => handleDrop(e, item.type === 'folder' ? item.id : null)}
        onDragOver={(e) => handleDragOver(e, item.type === 'folder' ? item.id : null)}
        onDragLeave={handleDragLeave}
      >
        {item.type === 'folder' && (
          <span className="w-4 h-4 flex items-center justify-center mr-1">
            {item.expanded ? <ChevronDown size={12} /> : <ChevronRight size={12} />}
          </span>
        )}
        
        <span className="w-4 h-4 flex items-center justify-center mr-2">
          {item.type === 'folder' ? 
            <Folder size={14} className={`${dragOver === item.id ? 'text-blue-200' : 'text-blue-400'}`} /> : 
            <File size={14} className="text-gray-300" />
          }
        </span>
        
        <span className={`text-gray-200 ${dragOver === item.id ? 'text-white font-medium' : ''}`}>
          {item.name}
        </span>
      </div>
      
      {item.type === 'folder' && item.expanded && item.children && (
        <div>
          {item.children.map(child => renderFileItem(child, level + 1))}
        </div>
      )}
    </div>
  );

  return (
    <div className="h-full flex flex-col">
      {/* Header с кнопками создания */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs font-semibold text-gray-300 uppercase tracking-wide">Explorer</span>
          <div className="flex space-x-1">
            <button
              onClick={() => {
                const name = prompt('File name:');
                if (name) props.createFile(null, name, '// New file\n');
              }}
              className="p-1.5 bg-blue-600 hover:bg-blue-500 rounded text-white"
              title="New File"
            >
              <Plus size={12} />
            </button>
            <button
              onClick={() => {
                const name = prompt('Folder name:');
                if (name) props.createFolder(null, name);
              }}
              className="p-1.5 bg-green-600 hover:bg-green-500 rounded text-white"
              title="New Folder"
            >
              <Folder size={12} />
            </button>
          </div>
        </div>

        {/* Search */}
        <input
          type="text"
          placeholder="Search files..."
          value={props.searchQuery}
          onChange={(e) => props.setSearchQuery(e.target.value)}
          className="w-full px-2 py-1.5 text-xs bg-gray-800 border border-gray-600 rounded focus:border-blue-500 focus:outline-none"
        />
      </div>

      {/* File Tree с поддержкой drag & drop */}
      <div 
        className={`flex-1 overflow-y-auto ${dragOver === null ? 'bg-gray-900' : 'bg-blue-900/20'}`}
        onDrop={(e) => handleDrop(e, null)}
        onDragOver={(e) => handleDragOver(e, null)}
        onDragLeave={handleDragLeave}
      >
        {props.fileTree.length > 0 ? (
          props.fileTree.map(item => renderFileItem(item))
        ) : (
          <div className="p-4 text-center text-gray-500 text-sm">
            <Folder className="mx-auto mb-2 opacity-50" size={32} />
            <p>Drop files here or create new</p>
          </div>
        )}
      </div>
    </div>
  );
}
EOF

echo "✅ Smart FileTree с drag & drop создан"

# ============================================================================
# 4. ОБНОВИТЬ EDITOR С SMART CODE EDITOR
# ============================================================================

cat > src/components/Editor.tsx << 'EOF'
import { X } from 'lucide-react';
import { SmartCodeEditor } from './SmartCodeEditor';
import type { FileManagerState, TabItem } from '../types';

interface EditorProps extends FileManagerState {
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function Editor({ 
  openTabs, 
  activeTab, 
  closeTab, 
  setActiveTab, 
  updateFileContent 
}: EditorProps) {
  if (openTabs.length === 0) {
    return (
      <div className="h-full flex items-center justify-center bg-gray-900">
        <div className="text-center">
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2</h2>
          <p className="text-gray-400 mb-4">Clean TypeScript Architecture</p>
          <p className="text-sm text-gray-500">Select a file from the explorer to start editing</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col bg-gray-900">
      {/* Tabs */}
      <div className="flex bg-gray-800 border-b border-gray-700 overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-4 py-2 border-r border-gray-700 cursor-pointer min-w-32 ${
              activeTab?.id === tab.id 
                ? 'bg-gray-900 text-white border-b-2 border-blue-500' 
                : 'hover:bg-gray-700 text-gray-300'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            <span className="text-sm truncate flex-1">{tab.name}</span>
            {tab.isDirty && <span className="ml-2 w-2 h-2 bg-orange-400 rounded-full"></span>}
            <button
              onClick={(e) => { e.stopPropagation(); closeTab(tab); }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded text-gray-400 hover:text-white"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Editor Content */}
      {activeTab && (
        <div className="flex-1 overflow-hidden">
          <SmartCodeEditor
            content={activeTab.content}
            onChange={(content) => updateFileContent(activeTab.id, content)}
            language={activeTab.language}
          />
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ Smart Editor обновлен"

# ============================================================================
# 5. ТЕСТИРОВАНИЕ
# ============================================================================

echo "🔨 Тестируем улучшения..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "🎯 УЛУЧШЕНИЯ ГОТОВЫ!"
    echo "=================="
    echo ""
    echo "✅ RESIZABLE TERMINAL:"
    echo "   • Перетаскивание верхней границы для изменения высоты"
    echo "   • Кнопка максимизации (60% экрана)"
    echo "   • Визуальная обратная связь при перетаскивании"
    echo "   • Ограничения min/max высоты"
    echo ""
    echo "✅ CODE FOLDING:"
    echo "   • Автоматическое обнаружение блоков кода"
    echo "   • Кнопки сворачивания в строке номера"
    echo "   • Визуализация свернутых блоков"
    echo "   • Поддержка функций, классов, условий"
    echo ""
    echo "✅ SMART FILE DROP:"
    echo "   • Убрана видимая drag & drop зона"
    echo "   • Перетаскивание файлов прямо на папки"
    echo "   • Визуальная обратная связь при перетаскивании"
    echo "   • Только кнопки + для создания"
    echo ""
    echo "💻 Запуск: npm run dev"
    echo "🎯 Интерфейс теперь как в профессиональных IDE!"
else
    echo "❌ Ошибка сборки"
fi