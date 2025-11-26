import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './app/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#358373', // Deep Muted Emerald
        secondary: '#5FCEB3', // Bright Teal
        muted: '#B9E4D4', // Soft Mint
        surface: '#F5F7FA', // Very light grey/white
        textmain: '#1E293B', // Dark Slate
      },
      fontFamily: {
        sans: [
          'Montserrat',
          'Inter',
          'Arial',
          'sans-serif',
        ],
      },
      borderRadius: {
        pill: '9999px',
        xl: '1rem',
      },
    },
  },
  plugins: [],
};

export default config;
