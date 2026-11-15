#!/usr/bin/env node
// Looks at a table the way a reader will: screenshots an HTML page wide (1100px) and on a phone
// (390px), and lists what a grep of the HTML cannot show.
//   node look.js page.html [out-prefix]     -> <prefix>-wide.png, <prefix>-phone.png, a report
// Needs Playwright (npm i playwright, or the one already installed). Read the PNGs afterwards:
// the report finds only some defects.
const path = require('path');
let chromium;
try { ({ chromium } = require('playwright')); } catch (e) {
  console.error('look.js: Playwright is not installed. Install it (npm i playwright && npx playwright install chromium),\n' +
    'or take the screenshots another way, e.g.\n' +
    '  chromium --headless --screenshot=wide.png --window-size=1100,1400 page.html\n' +
    '  chromium --headless --screenshot=phone.png --window-size=390,1400 page.html\n' +
    'and read them. Do not skip the look.');
  process.exit(2);
}
const file = process.argv[2];
if (!file) { console.error('usage: node look.js page.html [out-prefix]'); process.exit(2); }
const prefix = process.argv[3] || file.replace(/\.html?$/, '');
const maxHeight = 2400;   // a screenshot taller than this is too small to read: the top is enough

async function look(browser, name, width) {
  const page = await browser.newPage({ viewport: { width, height: 900 }, deviceScaleFactor: 1 });
  const failed = [];
  page.on('requestfailed', r => failed.push(r.url()));
  await page.goto('file://' + path.resolve(file), { waitUntil: 'load' });
  await page.waitForTimeout(500);
  const r = await page.evaluate(() => {
    const out = { tables: [], clipped: [], brokenImages: [], tallRows: [], emptyColumns: [] };
    out.pageWidth = document.documentElement.scrollWidth;
    out.pageHeight = document.documentElement.scrollHeight;
    for (const img of document.images) if (!img.complete || img.naturalWidth === 0) out.brokenImages.push(img.src);
    document.querySelectorAll('table').forEach((t, i) => {
      const box = t.getBoundingClientRect();
      const rows = [...t.querySelectorAll('tbody tr')];
      const heights = rows.map(tr => tr.getBoundingClientRect().height).filter(h => h > 0).sort((a, b) => a - b);
      const median = heights.length ? heights[heights.length >> 1] : 0;
      // a table may scroll inside a box of its own: that is fine, a page that scrolls sideways is not
      let scroller = t.parentElement;
      while (scroller && scroller !== document.body && getComputedStyle(scroller).overflowX === 'visible') scroller = scroller.parentElement;
      out.tables.push({ table: i + 1, width: Math.round(box.width), rows: rows.length,
        medianRowHeight: Math.round(median), tallestRow: Math.round(heights[heights.length - 1] || 0),
        scrollsInItsBox: !!scroller && scroller !== document.body });
      rows.forEach((tr, j) => { const h = tr.getBoundingClientRect().height;
        if (median > 0 && h > 3 * median && h > 90) out.tallRows.push(`table ${i + 1} row ${j + 1}: ${Math.round(h)}px (median ${Math.round(median)}px)`); });
      t.querySelectorAll('th, td').forEach(c => {
        if (c.scrollWidth > c.clientWidth + 2 && getComputedStyle(c).overflow !== 'visible')
          out.clipped.push(`table ${i + 1}: "${(c.textContent || '').trim().slice(0, 30)}" is cut (${c.clientWidth}px of ${c.scrollWidth}px)`);
      });
    });
    return out;
  });
  const shot = `${prefix}-${name}.png`;
  await page.screenshot({ path: shot, clip: { x: 0, y: 0, width: Math.max(width, Math.min(r.pageWidth, 2 * width)), height: Math.min(r.pageHeight, maxHeight) } });
  await page.close();
  console.log(`\n== ${name} (${width}px): ${shot}${r.pageHeight > maxHeight ? ` (the top ${maxHeight}px of ${r.pageHeight}px)` : ''}`);
  const problems = [];
  if (r.pageWidth > width + 2) problems.push(`the page is ${r.pageWidth}px wide and scrolls sideways: ${name === 'phone' ? 'let the table scroll in its own box, or show fewer columns' : 'the table is too wide'}`);
  for (const t of r.tables) console.log(`   table ${t.table}: ${t.width}px wide, ${t.rows} rows, rows ${t.medianRowHeight}px (tallest ${t.tallestRow}px)${t.scrollsInItsBox ? ', scrolls inside its box' : ''}`);
  if (r.tables.length === 0) problems.push('no <table> on the page');
  for (const t of r.tables) {
    if (t.medianRowHeight > 100) problems.push(`table ${t.table}: its rows are ${t.medianRowHeight}px tall: is a drawing or a picture in them larger than it should be?`);
    if (t.width > width + 2 && name === 'wide') problems.push(`table ${t.table} is ${t.width}px wide: its last columns are out of view even on a wide screen`);
  }
  const remote = [...new Set([...r.brokenImages, ...failed])];
  if (remote.length) problems.push(`${remote.length} image(s) or file(s) did not load (offline here, or a wrong address?): ${remote.slice(0, 3).join(', ')}${remote.length > 3 ? ', ...' : ''}`);
  for (const p of r.tallRows.slice(0, 5)) problems.push('a row far taller than the others: ' + p);
  for (const p of r.clipped.slice(0, 5)) problems.push(p);
  if (problems.length) for (const p of problems) console.log('   ! ' + p); else console.log('   nothing found by the checks');
  return problems.length;
}

(async () => {
  const browser = await chromium.launch();
  let n = 0;
  n += await look(browser, 'wide', 1100);
  n += await look(browser, 'phone', 390);
  await browser.close();
  console.log(`\nNow read ${prefix}-wide.png and ${prefix}-phone.png: the checks above do not see a title shown twice,\na drawing out of place, a label that wraps badly, or colours that cannot be read.`);
})().catch(e => { console.error('look.js: ' + e.message); process.exit(1); });
