import React, { useEffect, useRef } from 'react';
import * as monaco from 'monaco-editor';

interface MonacoEditorProps {
  filename: string;
  content: string;
  onChange: (value: string) => void;
}

export const MonacoEditor: React.FC<MonacoEditorProps> = ({ filename, content, onChange }) => {
  const editorRef = useRef<HTMLDivElement>(null);
  const monacoInstance = useRef<monaco.editor.IStandaloneCodeEditor | null>(null);

  const getLanguageFromFilename = (filename: string): string => {
    const ext = filename.split('.').pop()?.toLowerCase();
    const languageMap: { [key: string]: string } = {
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'py': 'python',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'json': 'json',
      'md': 'markdown',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'sql': 'sql',
      'php': 'php',
      'go': 'go',
      'rs': 'rust',
      'cpp': 'cpp',
      'c': 'c',
      'java': 'java',
      'sh': 'shell'
    };
    return languageMap[ext || ''] || 'plaintext';
  };

  useEffect(() => {
    if (editorRef.current && !monacoInstance.current) {
      // Создаем редактор
      monacoInstance.current = monaco.editor.create(editorRef.current, {
        value: content,
        language: getLanguageFromFilename(filename),
        theme: 'vs-dark',
        fontSize: 14,
        fontFamily: 'Cascadia Code, Fira Code, Consolas, monospace',
        lineNumbers: 'on',
        roundedSelection: false,
        scrollBeyondLastLine: false,
        automaticLayout: true,
        tabSize: 2,
        insertSpaces: true,
        wordWrap: 'on',
        minimap: {
          enabled: true,
          side: 'right'
        },
        suggest: {
          showKeywords: true,
          showSnippets: true,
          showFunctions: true,
          showVariables: true
        },
        quickSuggestions: {
          other: true,
          comments: true,
          strings: true
        },
        folding: true,
        foldingStrategy: 'indentation',
        showFoldingControls: 'always',
        bracketPairColorization: {
          enabled: true
        }
      });

      // Обработчик изменений
      monacoInstance.current.onDidChangeModelContent(() => {
        const value = monacoInstance.current?.getValue() || '';
        onChange(value);
      });
    }

    return () => {
      monacoInstance.current?.dispose();
      monacoInstance.current = null;
    };
  }, []);

  // Обновляем содержимое при изменении файла
  useEffect(() => {
    if (monacoInstance.current) {
      const currentValue = monacoInstance.current.getValue();
      if (currentValue !== content) {
        monacoInstance.current.setValue(content);
      }
      
      // Обновляем язык
      const model = monacoInstance.current.getModel();
      if (model) {
        monaco.editor.setModelLanguage(model, getLanguageFromFilename(filename));
      }
    }
  }, [content, filename]);

  return (
    <div className="w-full h-full">
      <div ref={editorRef} className="w-full h-full" />
    </div>
  );
};
