import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// All page text lives in ../content (repo root), readable on GitHub as is.
const pages = defineCollection({
  loader: glob({ pattern: '**/*.md', base: '../content' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    section: z.string().optional(),
    order: z.number().default(100),
    status: z.enum(['draft', 'published']).default('draft'),
    updated: z.coerce.date().optional(),
  }),
});

export const collections = { pages };
