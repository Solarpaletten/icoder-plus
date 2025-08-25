import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@services': resolve(__dirname, './src/services'),
      '@utils': resolve(__dirname, './src/utils'),
      '@hooks': resolve(__dirname, './src/hooks')
    }
  },
  server: {
    port: 5173,
    host: true,
    open: true,
    proxy: {
      // Проксировать API запросы на backend
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          // Monaco Editor в отдельном чанке для оптимизации
          editor: ['monaco-editor', '@monaco-editor/react'],
          utils: ['diff2html', 'clsx', 'axios']
        }
      }
    }
  },
  optimizeDeps: {
    include: [
      'react', 
      'react-dom', 
      'lucide-react', 
      'axios',
      // Предварительная оптимизация Monaco
      'monaco-editor/esm/vs/language/typescript/ts.worker',
      'monaco-editor/esm/vs/language/json/json.worker',
      'monaco-editor/esm/vs/editor/editor.worker'
    ]
  },
  define: {
    // Определить глобальные константы
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version)
  },
  worker: {
    format: 'es'
  }
})
