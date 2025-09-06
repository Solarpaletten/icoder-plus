#!/bin/bash

echo "🚀 PHASE 1: MONACO EDITOR INTEGRATION"
echo "===================================="
echo "Создаем профессиональный редактор кода как в VS Code"

# ============================================================================
# 1. УСТАНОВИТЬ MONACO EDITOR
# ============================================================================

echo "📦 Устанавливаем Monaco Editor..."
npm install @monaco-editor/react monaco-editor

echo "✅ Monaco Editor установлен"

# ============================================================================
# 2. СОЗДАТЬ MONACO EDITOR КОМПОНЕНТ
# ============================================================================

cat > src/components/MonacoEditor.tsx << 'EOF'
import { useEffect, useRef, useState } from 'react';
import Editor, { OnMount, OnChange } from '@monaco-editor/react';
import { editor } from 'monaco-editor';
import type { FileItem } from '../types';

interface MonacoEditorProps {
  file: FileItem | null;
  onChange: (fileId: string, content: string) => void;
}

export function MonacoEditor({ file, onChange }: MonacoEditorProps) {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  const [isEditorReady, setIsEditorReady] = useState(false);

  // Определение языка по расширению файла
  const getLanguage = (filename: string): string => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const languageMap: Record<string, string> = {
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'sass',
      'json': 'json',
      'md': 'markdown',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'go': 'go',
      'rs': 'rust',
      'sh': 'shell',
      'sql': 'sql',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml'
    };
    return languageMap[ext || ''] || 'plaintext';
  };

  // Обработчик монтирования редактора
  const handleEditorDidMount: OnMount = (editor, monaco) => {
    editorRef.current = editor;
    setIsEditorReady(true);

    // Конфигурация темы VS Code Dark
    monaco.editor.defineTheme('vscode-dark', {
      base: 'vs-dark',
      inherit: true,
      rules: [
        { token: 'comment', foreground: '6A9955' },
        { token: 'keyword', foreground: '569CD6' },
        { token: 'string', foreground: 'CE9178' },
        { token: 'number', foreground: 'B5CEA8' },
        { token: 'type', foreground: '4EC9B0' },
        { token: 'function', foreground: 'DCDCAA' },
        { token: 'variable', foreground: '9CDCFE' },
      ],
      colors: {
        'editor.background': '#1E1E1E',
        'editor.foreground': '#D4D4D4',
        'editor.selectionBackground': '#264F78',
        'editor.lineHighlightBackground': '#2A2D2E',
        'editorCursor.foreground': '#AEAFAD',
        'editorWhitespace.foreground': '#404040',
        'editorIndentGuide.background': '#404040',
        'editorIndentGuide.activeBackground': '#707070',
        'editor.selectionHighlightBackground': '#ADD6FF26',
      }
    });

    // Применение темы
    monaco.editor.setTheme('vscode-dark');

    // Дополнительные настройки редактора
    editor.updateOptions({
      fontSize: 14,
      fontFamily: 'Cascadia Code, Fira Code, SF Mono, Monaco, Inconsolata, Roboto Mono, monospace',
      fontLigatures: true,
      lineNumbers: 'on',
      minimap: { enabled: true },
      scrollBeyondLastLine: false,
      wordWrap: 'on',
      automaticLayout: true,
      tabSize: 2,
      insertSpaces: true,
      folding: true,
      foldingStrategy: 'indentation',
      showFoldingControls: 'always',
      bracketPairColorization: { enabled: true },
      guides: {
        indentation: true,
        bracketPairs: true,
        bracketPairsHorizontal: true,
      },
      suggest: {
        enableExtendedSuggestionSupport: true,
        showKeywords: true,
        showSnippets: true,
      },
      quickSuggestions: {
        other: true,
        comments: false,
        strings: false
      },
      parameterHints: { enabled: true },
      hover: { enabled: true },
      contextmenu: true,
      mouseWheelZoom: true,
      cursorBlinking: 'blink',
      cursorSmoothCaretAnimation: 'on',
      smoothScrolling: true,
    });

    // Команды
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
      // Сохранение файла
      if (file) {
        console.log('Saving file:', file.name);
      }
    });

    // Фокус на редактор
    editor.focus();
  };

  // Обработчик изменения содержимого
  const handleEditorChange: OnChange = (value) => {
    if (file && value !== undefined) {
      onChange(file.id, value);
    }
  };

  // Обновление содержимого при смене файла
  useEffect(() => {
    if (editorRef.current && file && isEditorReady) {
      const model = editorRef.current.getModel();
      if (model && model.getValue() !== file.content) {
        // Устанавливаем язык для модели
        const language = getLanguage(file.name);
        const monaco = (window as any).monaco;
        if (monaco) {
          monaco.editor.setModelLanguage(model, language);
        }
      }
    }
  }, [file, isEditorReady]);

  if (!file) {
    return (
      <div className="h-full flex items-center justify-center bg-gray-900 text-gray-400">
        <div className="text-center">
          <div className="text-6xl mb-4">📝</div>
          <h2 className="text-xl mb-2">Welcome to iCoder Plus</h2>
          <p className="text-sm">Select a file from Explorer to start editing</p>
          <div className="mt-4 text-xs">
            <p>Pro tip: Press Ctrl+P to quickly open files</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full w-full">
      <Editor
        value={file.content}
        language={getLanguage(file.name)}
        theme="vscode-dark"
        onMount={handleEditorDidMount}
        onChange={handleEditorChange}
        options={{
          readOnly: false,
          domReadOnly: false,
          selectOnLineNumbers: true,
        }}
        loading={
          <div className="h-full flex items-center justify-center bg-gray-900 text-gray-400">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4"></div>
              <p>Loading Monaco Editor...</p>
            </div>
          </div>
        }
      />
    </div>
  );
}
EOF

echo "✅ MonacoEditor.tsx создан"

# ============================================================================
# 3. СОЗДАТЬ ХУК ДЛЯ ТЕМЫ MONACO
# ============================================================================

cat > src/hooks/useMonacoTheme.ts << 'EOF'
import { useCallback } from 'react';

export interface MonacoTheme {
  name: string;
  displayName: string;
  base: 'vs' | 'vs-dark' | 'hc-black';
  colors: Record<string, string>;
  rules: Array<{
    token: string;
    foreground?: string;
    background?: string;
    fontStyle?: string;
  }>;
}

export const themes: Record<string, MonacoTheme> = {
  'vscode-dark': {
    name: 'vscode-dark',
    displayName: 'VS Code Dark',
    base: 'vs-dark',
    colors: {
      'editor.background': '#1E1E1E',
      'editor.foreground': '#D4D4D4',
      'editor.selectionBackground': '#264F78',
      'editor.lineHighlightBackground': '#2A2D2E',
      'editorCursor.foreground': '#AEAFAD',
      'editorWhitespace.foreground': '#404040',
      'editorIndentGuide.background': '#404040',
      'editorIndentGuide.activeBackground': '#707070',
      'editor.selectionHighlightBackground': '#ADD6FF26',
      'editorLineNumber.foreground': '#858585',
      'editorLineNumber.activeForeground': '#C6C6C6',
    },
    rules: [
      { token: 'comment', foreground: '6A9955' },
      { token: 'keyword', foreground: '569CD6' },
      { token: 'string', foreground: 'CE9178' },
      { token: 'number', foreground: 'B5CEA8' },
      { token: 'type', foreground: '4EC9B0' },
      { token: 'function', foreground: 'DCDCAA' },
      { token: 'variable', foreground: '9CDCFE' },
      { token: 'constant', foreground: '4FC1FF' },
      { token: 'class', foreground: '4EC9B0' },
      { token: 'interface', foreground: 'B8D7A3' },
    ]
  },
  'vscode-light': {
    name: 'vscode-light',
    displayName: 'VS Code Light',
    base: 'vs',
    colors: {
      'editor.background': '#FFFFFF',
      'editor.foreground': '#000000',
      'editor.selectionBackground': '#ADD6FF',
      'editor.lineHighlightBackground': '#F5F5F5',
      'editorCursor.foreground': '#000000',
      'editorLineNumber.foreground': '#237893',
    },
    rules: [
      { token: 'comment', foreground: '008000' },
      { token: 'keyword', foreground: '0000FF' },
      { token: 'string', foreground: 'A31515' },
      { token: 'number', foreground: '098658' },
      { token: 'type', foreground: '267F99' },
      { token: 'function', foreground: '795E26' },
      { token: 'variable', foreground: '001080' },
    ]
  }
};

export function useMonacoTheme() {
  const applyTheme = useCallback((themeName: string) => {
    const monaco = (window as any).monaco;
    if (!monaco) return;

    const theme = themes[themeName];
    if (!theme) return;

    monaco.editor.defineTheme(theme.name, {
      base: theme.base,
      inherit: true,
      rules: theme.rules,
      colors: theme.colors
    });

    monaco.editor.setTheme(theme.name);
  }, []);

  const getAvailableThemes = useCallback(() => {
    return Object.values(themes);
  }, []);

  return {
    applyTheme,
    getAvailableThemes,
    themes
  };
}
EOF

echo "✅ useMonacoTheme.ts создан"

# ============================================================================
# 4. ОБНОВИТЬ EditorArea ДЛЯ ИСПОЛЬЗОВАНИЯ MONACO
# ============================================================================

cat > src/components/layout/EditorArea.tsx << 'EOF'
import { X, Circle } from 'lucide-react';
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
          <div className="text-6xl mb-4">🚀</div>
          <h2 className="text-2xl font-light text-blue-400 mb-2">iCoder Plus v2.2 - IDE Shell</h2>
          <p className="text-gray-400 mb-4">Professional Monaco Editor Integration</p>
          <div className="text-sm text-gray-500 space-y-1">
            <p>📁 Open files from Explorer</p>
            <p>⌨️ Full IntelliSense support</p>
            <p>🎨 Syntax highlighting</p>
            <p>📋 Advanced code editing</p>
          </div>
        </div>
      </div>
    );
  }

  const getFileIcon = (filename: string) => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const iconMap: Record<string, string> = {
      'js': '🟨', 'jsx': '🟨', 'ts': '🟦', 'tsx': '🟦',
      'html': '🟧', 'css': '🟪', 'scss': '🟪', 'sass': '🟪',
      'json': '🟩', 'md': '⬜', 'py': '🟨', 'java': '🟫',
      'cpp': '🟦', 'c': '🟦', 'cs': '🟪', 'php': '🟪',
      'rb': '🟥', 'go': '🟦', 'rs': '🟫', 'sh': '🟩'
    };
    return iconMap[ext || ''] || '📄';
  };

  return (
    <div className="flex-1 flex flex-col bg-gray-900">
      {/* Enhanced Tab Bar */}
      <div className="flex bg-gray-800 border-b border-gray-700 overflow-x-auto">
        {openTabs.map(tab => (
          <div
            key={tab.id}
            className={`flex items-center px-3 py-2 border-r border-gray-700 cursor-pointer min-w-32 max-w-48 group ${
              activeTab?.id === tab.id 
                ? 'bg-gray-900 text-white border-b-2 border-blue-500' 
                : 'hover:bg-gray-700 text-gray-300'
            }`}
            onClick={() => setActiveTab(tab)}
          >
            {/* File Icon */}
            <span className="mr-2 text-sm">{getFileIcon(tab.name)}</span>
            
            {/* File Name */}
            <span className="text-sm truncate flex-1">{tab.name}</span>
            
            {/* Modified Indicator */}
            {tab.isDirty && (
              <Circle 
                size={8} 
                className="ml-2 text-white fill-current" 
                title="Unsaved changes"
              />
            )}
            
            {/* Close Button */}
            <button
              onClick={(e) => { 
                e.stopPropagation(); 
                closeTab(tab); 
              }}
              className="ml-2 p-0.5 hover:bg-gray-600 rounded text-gray-400 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity"
              title="Close tab"
            >
              <X size={12} />
            </button>
          </div>
        ))}
      </div>

      {/* Monaco Editor */}
      <div className="flex-1 overflow-hidden">
        <MonacoEditor
          file={activeTab}
          onChange={updateFileContent}
        />
      </div>
    </div>
  );
}
EOF

echo "✅ EditorArea.tsx обновлен с Monaco Editor"

# ============================================================================
# 5. ОБНОВИТЬ VITE CONFIG ДЛЯ MONACO
# ============================================================================

cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      },
      '/terminal': {
        target: 'ws://localhost:3000',
        ws: true
      }
    }
  },
  optimizeDeps: {
    include: [
      '@monaco-editor/react',
      'monaco-editor',
      '@xterm/xterm', 
      '@xterm/addon-fit', 
      '@xterm/addon-web-links'
    ]
  },
  define: {
    global: 'globalThis',
  },
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})
EOF

echo "✅ Vite config обновлен для Monaco Editor"

# ============================================================================
# 6. ТЕСТИРОВАТЬ СБОРКУ
# ============================================================================

echo "🧪 Тестируем Monaco Editor интеграцию..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Monaco Editor успешно интегрирован!"
    echo "🎯 Новые возможности:"
    echo "   • Профессиональный редактор кода"
    echo "   • IntelliSense и автодополнение"
    echo "   • Подсветка синтаксиса для 20+ языков"
    echo "   • Folding/unfolding кода"
    echo "   • Minimap справа"
    echo "   • VS Code темы (Dark/Light)"
    echo "   • Горячие клавиши (Ctrl+S)"
    echo "   • Улучшенные табы с иконками"
    echo ""
    echo "🚀 Phase 1 завершен! Готовы к Phase 2: Side Panel System?"
else
    echo "❌ Ошибки сборки - проверьте консоль"
fi