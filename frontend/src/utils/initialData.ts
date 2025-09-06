import type { FileItem } from '../types';

export const initialFiles: FileItem[] = [
  {
    id: '1',
    name: 'src',
    type: 'folder',
    children: [
      {
        id: '2',
        name: 'App.tsx',
        type: 'file',
        content: `import React from 'react';
import { AppShell } from './components/AppShell';

function App() {
  return <AppShell />;
}

export default App;`
      },
      {
        id: '3',
        name: 'main.tsx',
        type: 'file',
        content: `import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)`
      },
      {
        id: '4',
        name: 'components',
        type: 'folder',
        children: [
          {
            id: '5',
            name: 'AppShell.tsx',
            type: 'file',
            content: '// AppShell component'
          }
        ]
      }
    ]
  },
  {
    id: '6',
    name: 'package.json',
    type: 'file',
    content: `{
  "name": "icoder-plus-frontend",
  "version": "2.0.0",
  "type": "module"
}`
  },
  {
    id: '7',
    name: 'README.md',
    type: 'file',
    content: '# iCoder Plus Frontend\n\nModern IDE built with React + TypeScript'
  }
];
