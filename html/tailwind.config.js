/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        brand: {
          purple: '#8060FC',
          blue: '#6B78FB',
          cyan: '#2cc2FA',
          coolPurple: '#A731FD',
          black: '#00003C',
        }
      }
    }
  }
}