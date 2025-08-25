import React, { Suspense, lazy } from 'react';

// Динамический импорт Monaco Editor для уменьшения начального bundle
const MonacoEditor = lazy(() => 
  import('@monaco-editor/react').then(module => ({
    default: module.default || module.Editor
  }))
);

// Компонент загрузки
const EditorSkeleton = () => (
  <div className="w-full h-64 bg-gray-800 rounded-lg flex items-center justify-center">
    <div className="text-gray-400 animate-pulse">Loading Code Editor...</div>
  </div>
);

// Обертка для Monaco с fallback
const CodeEditor = ({ 
  value = '', 
  language = 'javascript', 
  onChange, 
  theme = 'vs-dark',
  height = '300px',
  ...props 
}) => {
  const handleEditorChange = (newValue) => {
    if (onChange) {
      onChange(newValue || '');
    }
  };

  return (
    <Suspense fallback={<EditorSkeleton />}>
      <MonacoEditor
        height={height}
        language={language}
        value={value}
        theme={theme}
        onChange={handleEditorChange}
        options={{
          selectOnLineNumbers: true,
          roundedSelection: false,
          readOnly: false,
          cursorStyle: 'line',
          automaticLayout: true,
          minimap: { enabled: false },
          scrollBeyondLastLine: false,
          fontSize: 14,
          fontFamily: 'JetBrains Mono, Consolas, Monaco, monospace',
          ...props.options
        }}
        {...props}
      />
    </Suspense>
  );
};

export default CodeEditor;
