/** @type {import('tailwindcss').Config} */
export default {
    content: [
      "./index.html",
      "./src/**/*.{js,ts,jsx,tsx}",
      "./*.jsx"
    ],
    theme: {
      extend: {
        colors: {
          // iCoder Plus Brand Colors
          'midnight': '#0D1117',
          'neon-blue': '#1F6FEB', 
          'cyber-purple': '#9D4EDD',
          'matrix-green': '#00FF9D',
          'warning-yellow': '#FFD60A',
          
          // Extended palette
          'dark-gray': '#21262d',
          'medium-gray': '#30363d',
          'light-gray': '#484f58',
          'text-primary': '#f0f6fc',
          'text-secondary': '#7d8590',
          'border-primary': '#30363d',
          'border-secondary': '#21262d'
        },
        fontFamily: {
          'poppins': ['Poppins', 'sans-serif'],
          'jetbrains': ['JetBrains Mono', 'Consolas', 'Monaco', 'Courier New', 'monospace'],
          'inter': ['Inter', 'system-ui', 'sans-serif']
        },
        fontSize: {
          'xs': '0.75rem',
          'sm': '0.875rem', 
          'base': '1rem',
          'lg': '1.125rem',
          'xl': '1.25rem',
          '2xl': '1.5rem',
          '3xl': '1.875rem',
          '4xl': '2.25rem'
        },
        spacing: {
          '18': '4.5rem',
          '88': '22rem',
          '128': '32rem'
        },
        animation: {
          'fade-in': 'fadeIn 0.3s ease-in-out',
          'slide-up': 'slideUp 0.3s ease-in-out',
          'slide-down': 'slideDown 0.3s ease-in-out',
          'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
          'bounce-gentle': 'bounceGentle 2s infinite'
        },
        keyframes: {
          fadeIn: {
            '0%': { opacity: '0' },
            '100%': { opacity: '1' }
          },
          slideUp: {
            '0%': { transform: 'translateY(10px)', opacity: '0' },
            '100%': { transform: 'translateY(0)', opacity: '1' }
          },
          slideDown: {
            '0%': { transform: 'translateY(-10px)', opacity: '0' },
            '100%': { transform: 'translateY(0)', opacity: '1' }
          },
          bounceGentle: {
            '0%, 100%': { 
              transform: 'translateY(-5%)',
              animationTimingFunction: 'cubic-bezier(0.8, 0, 1, 1)'
            },
            '50%': { 
              transform: 'translateY(0)',
              animationTimingFunction: 'cubic-bezier(0, 0, 0.2, 1)'
            }
          }
        },
        backdropBlur: {
          xs: '2px',
        },
        boxShadow: {
          'glow-blue': '0 0 20px rgba(31, 111, 235, 0.3)',
          'glow-purple': '0 0 20px rgba(157, 78, 221, 0.3)',
          'glow-green': '0 0 20px rgba(0, 255, 157, 0.3)',
          'inner-light': 'inset 0 1px 0 rgba(255, 255, 255, 0.1)'
        }
      },
    },
    plugins: [
      // Add any additional Tailwind plugins here
    ],
  }