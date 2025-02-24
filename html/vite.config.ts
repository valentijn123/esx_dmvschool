import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    port: 3000,
    strictPort: true,
  },
  build: {
    outDir: 'build',
    assetsDir: 'assets',
    rollupOptions: {
      input: {
        main: 'src/main.ts'
      },
      output: {
        entryFileNames: `assets/[name].js`,
        chunkFileNames: `assets/[name].js`,
        assetFileNames: (assetInfo) => {
          if (assetInfo.name.match(/\.(png|jpe?g|svg|gif|webp)$/)) {
            return `[name].[ext]`;
          }
          return 'assets/[name]-[hash].[ext]';
        }
      }
    }
  }
});
