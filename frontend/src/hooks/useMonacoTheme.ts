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
