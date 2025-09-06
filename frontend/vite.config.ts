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
