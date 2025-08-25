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
      '@utils': resolve(__dirname, './src/utils')
    }
  },
  server: {
    port: 5173,
    host: true,
    open: true
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ai: ['openai', '@anthropic-ai/sdk'],
          editor: ['monaco-editor', '@monaco-editor/react'],
          utils: ['diff', 'diff2html', 'clsx']
        }
      }
    }
  },
  define: {
    'process.env': process.env
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'lucide-react']
  }
})