/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'ide-bg': '#0d1117',
        'ide-surface': '#161b22',
        'ide-panel': '#21262d',
        'ide-border': '#30363d',
        'ide-text': '#e6edf3',
        'ide-muted': '#7d8590',
        'agent-dashka': '#ff6b35',
        'agent-claudy': '#4ecdc4'
      }
    }
  },
  plugins: [],
}
