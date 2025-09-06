#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ TYPESCRIPT ОШИБОК MONACO"
echo "======================================"

# 1. Исправить EditorArea.tsx - убрать title prop и исправить типы
cat > src/components/layout/EditorArea.tsx << 'EOF'
import { X } from 'lucide-react';
import { MonacoEditor } from '../MonacoEditor';
import type { FileManagerState, TabItem } from '../../types';

interface EditorAreaProps extends FileManagerState {
  closeTab: (tab: TabItem) => void;
  setActiveTab: (tab: TabItem) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function EditorArea({ 
  openTabs, 
  activeTab, 
  closeTab, 
  setActiveTab, 
  updateFileContent 
}: EditorAreaProps) {
  if (openTabs.length === 0) {
    return (
      <div className="flex-1 flex items-center justify-center bg-gray-900">
        <div className="text-center">
          <div className="text-4xl mb-4">🚀</div>
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2 - IDE Shell</h2>
          <p className="text-gray-400 mb-4">Professional Code Editor with Monaco</p>
          <div className="text-sm text-gray-500 font-mono">
            <p>// Welcome to iCoder Plus IDE Shell</p>
            <p>console.log('Hello from IDE!');</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col bg-gray-900">
      {/* Tab Bar */}
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
            {tab.isDirty && (
              <span 
                className="ml-2 w-2 h-2 bg-orange-400 rounded-full"
                aria-label="Unsaved changes"
              />
            )}
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
          <MonacoEditor
            content={activeTab.content}
            language={activeTab.language || 'javascript'}
            onChange={(content) => updateFileContent(activeTab.id, content)}
            filename={activeTab.name}
          />
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ EditorArea.tsx исправлен"

# 2. Исправить MonacoEditor.tsx - убрать устаревшие опции и исправить props
cat > src/components/MonacoEditor.tsx << 'EOF'
import { useEffect, useRef } from 'react';
import * as monaco from 'monaco-editor';

interface MonacoEditorProps {
  content: string;
  language: string;
  onChange: (content: string) => void;
  filename: string;
}

export function MonacoEditor({ content, language, onChange, filename }: MonacoEditorProps) {
  const editorRef = useRef<HTMLDivElement>(null);
  const monacoRef = useRef<monaco.editor.IStandaloneCodeEditor | null>(null);

  useEffect(() => {
    if (!editorRef.current) return;

    // Создаем Monaco editor
    const editor = monaco.editor.create(editorRef.current, {
      value: content,
      language: getMonacoLanguage(language),
      theme: 'vs-dark',
      automaticLayout: true,
      fontSize: 14,
      fontFamily: '"Cascadia Code", "Fira Code", "SF Mono", Monaco, Consolas, monospace',
      lineNumbers: 'on',
      roundedSelection: false,
      scrollBeyondLastLine: false,
      readOnly: false,
      minimap: {
        enabled: true,
        side: 'right'
      },
      suggest: {
        enableExtendedSelection: true,
        showIcons: true,
        showSnippets: true,
        showWords: true,
        showColors: true,
        showFiles: true,
        showReferences: true,
        showFolders: true,
        showTypeParameters: true,
        showIssues: true,
        showUsers: true,
        showValues: true,
        showVariables: true,
        showEnums: true,
        showEnumMembers: true,
        showKeywords: true,
        showText: true,
        showClasses: true,
        showFunctions: true,
        showConstructors: true,
        showFields: true,
        showInterfaces: true,
        showModules: true,
        showProperties: true,
        showEvents: true,
        showOperators: true,
        showUnits: true
      },
      wordWrap: 'off',
      scrollbar: {
        vertical: 'visible',
        horizontal: 'visible',
        useShadows: false,
        verticalHasArrows: false,
        horizontalHasArrows: false
      },
      folding: true,
      foldingStrategy: 'indentation',
      showFoldingControls: 'always',
      unfoldOnClickAfterEndOfLine: false,
      bracketPairColorization: {
        enabled: true
      }
    });

    monacoRef.current = editor;

    // Обработчик изменений
    const disposable = editor.onDidChangeModelContent(() => {
      const value = editor.getValue();
      onChange(value);
    });

    return () => {
      disposable.dispose();
      editor.dispose();
    };
  }, []);

  // Обновление контента
  useEffect(() => {
    if (monacoRef.current && monacoRef.current.getValue() !== content) {
      const editor = monacoRef.current;
      const model = editor.getModel();
      
      if (model) {
        model.setValue(content);
      }
    }
  }, [content]);

  // Обновление языка
  useEffect(() => {
    if (monacoRef.current) {
      const model = monacoRef.current.getModel();
      if (model) {
        monaco.editor.setModelLanguage(model, getMonacoLanguage(language));
      }
    }
  }, [language]);

  // Фокус на редактор
  useEffect(() => {
    if (monacoRef.current) {
      monacoRef.current.focus();
    }
  }, [filename]);

  return (
    <div className="h-full w-full">
      <div ref={editorRef} className="h-full w-full" />
    </div>
  );
}

// Маппинг языков для Monaco
function getMonacoLanguage(lang: string): string {
  const languageMap: Record<string, string> = {
    'js': 'javascript',
    'jsx': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'py': 'python',
    'css': 'css',
    'scss': 'scss',
    'sass': 'sass',
    'html': 'html',
    'xml': 'xml',
    'json': 'json',
    'md': 'markdown',
    'markdown': 'markdown',
    'yml': 'yaml',
    'yaml': 'yaml',
    'sh': 'shell',
    'bash': 'shell',
    'sql': 'sql',
    'php': 'php',
    'java': 'java',
    'cpp': 'cpp',
    'c': 'c',
    'cs': 'csharp',
    'go': 'go',
    'rust': 'rust',
    'ruby': 'ruby',
    'swift': 'swift',
    'kotlin': 'kotlin',
    'dart': 'dart'
  };

  return languageMap[lang.toLowerCase()] || 'plaintext';
}
EOF

echo "✅ MonacoEditor.tsx исправлен"

# 3. Обновить типы в types/index.ts
cat > src/types/index.ts << 'EOF'
export interface FileItem {
  id: string;
  name: string;
  type: 'file' | 'folder';
  content?: string;
  language?: string;
  children?: FileItem[];
  expanded?: boolean;
  parentId?: string | null;
}

export interface TabItem {
  id: string;
  name: string;
  content: string;
  language?: string;
  isDirty?: boolean;
  isActive?: boolean;
  type?: 'file' | 'folder'; // Добавлено для совместимости с FileItem
}

export interface FileManagerState {
  fileTree: FileItem[];
  openTabs: TabItem[];
  activeTab: TabItem | null;
}

export interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
}
EOF

echo "✅ Типы обновлены"

# 4. Тестировать сборку
npm run build

if [ $? -eq 0 ]; then
    echo "✅ TypeScript ошибки исправлены!"
    echo "🎯 Monaco Editor готов к использованию"
    echo "   • Убран устаревший enableExtendedSuggestionSupport"
    echo "   • Исправлены props между TabItem и FileItem"
    echo "   • Убран title prop из Lucide иконки"
    echo "   • Добавлена совместимость типов"
else
    echo "❌ Остались ошибки"
fi