// Rewrites relative links to .md files (which work on GitHub) into site URLs,
// so a page written once reads correctly in both places.
import path from 'node:path';

export function mdLinks({ base, contentDir }) {
  const toUrl = (from, href) => {
    const [target, hash] = href.split('#');
    const abs = path.resolve(path.dirname(from), target);
    let rel = path.relative(contentDir, abs).replace(/\\/g, '/').replace(/\.md$/, '');
    rel = rel.replace(/(^|\/)index$/, '');
    return `${base}/${rel ? rel + '/' : ''}${hash ? '#' + hash : ''}`;
  };
  const walk = (node, file) => {
    if (node.type === 'link' && /^(?![a-z]+:|\/|#).+\.md(#.*)?$/i.test(node.url)) {
      node.url = toUrl(file, node.url);
    }
    (node.children || []).forEach((c) => walk(c, file));
  };
  return (tree, vfile) => {
    if (vfile.path) walk(tree, vfile.path);
  };
}
