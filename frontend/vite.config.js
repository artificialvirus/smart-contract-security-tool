import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// frontend/vite.config.js
export default defineConfig({
  server: {
    proxy: {
      '/api': 'http://localhost:5000',
    },
  },
  plugins: [react()],
})
