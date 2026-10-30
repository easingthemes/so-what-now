import { getCollection, type CollectionEntry } from 'astro:content';

export type Page = CollectionEntry<'pages'>;

/** URL path of a page, relative to base: '' for home, 'guides/start-here/' otherwise. */
export const slugOf = (p: Page) => p.id.replace(/(^|\/)index$/, '');

export const href = (p: Page) => {
  const s = slugOf(p);
  return `${import.meta.env.BASE_URL.replace(/\/$/, '')}/${s ? s + '/' : ''}`;
};

/** Published pages only; drafts never reach the site. */
export async function publishedPages() {
  const all = await getCollection('pages', (p) => p.data.status === 'published');
  return all.sort((a, b) => a.data.order - b.data.order || a.data.title.localeCompare(b.data.title));
}

/** Pages grouped by section for the nav; pages without a section come first. */
export async function nav() {
  const groups = new Map<string, Page[]>();
  for (const p of await publishedPages()) {
    if (slugOf(p) === '') continue;
    const key = p.data.section ?? '';
    groups.set(key, [...(groups.get(key) ?? []), p]);
  }
  return [...groups.entries()];
}
