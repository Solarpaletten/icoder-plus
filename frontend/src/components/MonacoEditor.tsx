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
