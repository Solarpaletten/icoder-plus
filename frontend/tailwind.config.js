/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#007acc',
        secondary: '#4ec9b0', 
        background: '#1e1e1e',
        surface: '#252526',
        border: '#464647',
        gray: {
          750: '#2d2d30',
          850: '#1a1a1a'
        }
      }
    },
  },
  plugins: [],
}
