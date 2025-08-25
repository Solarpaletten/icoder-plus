/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'midnight': '#0D1117',
        'neon-blue': '#1F6FEB', 
        'cyber-purple': '#9D4EDD',
        'matrix-green': '#00FF9D',
        'warning-yellow': '#FFD60A'
      },
      fontFamily: {
        'poppins': ['Poppins', 'sans-serif'],
        'jetbrains': ['JetBrains Mono', 'monospace'],
        'mono': ['JetBrains Mono', 'Fira Code', 'monospace']
      }
    },
  },
  plugins: [],
}
