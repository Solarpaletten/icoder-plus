import React, { useState, useEffect } from 'react';
import CodeEditor from './CodeEditor';
import SimpleEditor from './SimpleEditor';

// Умный компонент, который выбирает Monaco или fallback
const SmartCodeEditor = (props) => {
  const [useMonaco, setUseMonaco] = useState(true);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Проверяем, доступен ли Monaco Editor
    const checkMonaco = async () => {
      try {
        await import('@monaco-editor/react');
        setUseMonaco(true);
      } catch (error) {
        console.warn('Monaco Editor not available, falling back to simple editor');
        setUseMonaco(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkMonaco();
  }, []);

  if (isLoading) {
    return (
      <div className="w-full h-64 bg-gray-800 rounded-lg flex items-center justify-center">
        <div className="text-gray-400 animate-pulse">Initializing Editor...</div>
      </div>
    );
  }

  // Используем Monaco если доступен, иначе простой редактор
  return useMonaco ? <CodeEditor {...props} /> : <SimpleEditor {...props} />;
};

export default SmartCodeEditor;
