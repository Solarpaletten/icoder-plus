import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3008',
        changeOrigin: true
      },
      '/terminal': {
        target: 'ws://localhost:3008',
        ws: true
      }
    }
  },
  optimizeDeps: {
    include: ['@xterm/xterm', '@xterm/addon-fit', '@xterm/addon-web-links']
  }
})
