import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import { mdLinks } from './src/plugins/md-links.mjs';

const base = '/so-what-now';

export default defineConfig({
  site: 'https://easingthemes.github.io',
  base,
  trailingSlash: 'always',
  integrations: [sitemap()],
  markdown: {
    remarkPlugins: [[mdLinks, { base, contentDir: new URL('../content/', import.meta.url).pathname }]],
  },
});
