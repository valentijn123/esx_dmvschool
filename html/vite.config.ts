import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],
	server: {
		port: 3000,
		strictPort: true,
	},
	build: {
		outDir: 'dist',
		target: 'esnext',
		rollupOptions: {
			output: {
				entryFileNames: `assets/[name].js`,
				chunkFileNames: `assets/[name].js`,
				assetFileNames: `assets/[name].[ext]`
			}
		}
	}
});
