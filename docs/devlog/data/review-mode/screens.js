// Takes the two annotated screenshots of the post "Review mode" (sheet.jpg, export.jpg) and the
// places of their numbered circles (sheet.json, export.json), from the built page, on a phone.
// Run after building the post: node docs/devlog/data/review-mode/screens.js ; then build it again.
const { chromium, devices } = require('playwright');
const path = require('path');
const fs = require('fs');
const here = __dirname;
const page_ = path.join(here, '..', '..', 'review-mode', 'index.html');

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ ...devices['iPhone 13'], deviceScaleFactor: 2 });
  await ctx.addInitScript(() => { navigator.share = () => Promise.resolve(); navigator.canShare = () => true; });
  const p = await ctx.newPage();
  await p.goto('file://' + page_);
  await p.evaluate(() => localStorage.clear());
  await p.reload();
  const vw = p.viewportSize();
  async function select(text) {
    await p.evaluate((text) => {
      const w = document.createTreeWalker(document.querySelector('main'), NodeFilter.SHOW_TEXT);
      for (let n = w.nextNode(); n; n = w.nextNode()) {
        const i = n.data.indexOf(text);
        if (i >= 0 && !n.parentNode.closest('pre, table, .nota')) {
          const r = document.createRange(); r.setStart(n, i); r.setEnd(n, i + text.length);
          getSelection().removeAllRanges(); getSelection().addRange(r);
          n.parentNode.scrollIntoView({ block: 'center' }); return;
        }
      }
    }, text);
    await p.waitForTimeout(200);
  }
  // one comment saved, the arrows stopped on it
  await select('Ten comments are ten trips');
  await p.click('.rv-add');
  await p.fill('textarea[name="text"]', 'Say how long a trip takes.');
  await p.click('.rv-compact .rv-save');
  await p.waitForTimeout(400);
  // a second one being written, with a screenshot
  await select('makes one trip at the end');
  await p.click('.rv-add');
  await p.fill('textarea[name="text"]', 'Show it as a picture: before and after.');
  const shot = await p.screenshot({ type: 'png' });
  await p.setInputFiles('.rv-attach input', { name: 'shot.png', mimeType: 'image/png', buffer: shot });
  await p.waitForSelector('.rv-thumb img');
  await p.waitForTimeout(400);
  const at = async (sel, where = 'corner') => {
    const b = await p.$eval(sel, (e) => { const r = e.getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; });
    const x = where === 'center' ? b[0] + b[2] / 2 : b[0] + 2;
    const y = where === 'center' ? b[1] + b[3] / 2 : b[1] + 2;
    return { x: +(100 * x / vw.width).toFixed(1), y: +(100 * y / vw.height).toFixed(1) };
  };
  const sheetPoints = [
    { n: 1, ...(await at('mark.rv-mark[data-id="rv-new"]', 'corner')) },
    { n: 2, ...(await at('[data-do="prev"]')) },
    { n: 3, ...(await at('[data-do="edit"]')) },
    { n: 4, ...(await at('.rv-add')) },
    { n: 5, ...(await at('[data-do="export"]')) },
    { n: 6, ...(await at('.rv-compact .rv-kinds')) },
    { n: 7, ...(await at('.rv-compact textarea[name="text"]', 'corner')) },
    { n: 8, ...(await at('.rv-compact .rv-paste')) },
  ];
  await p.screenshot({ path: path.join(here, 'sheet.jpg'), type: 'jpeg', quality: 70 });
  fs.writeFileSync(path.join(here, 'sheet.json'), JSON.stringify({ points: sheetPoints }, null, 1) + '\n');
  await p.click('.rv-compact .rv-save');
  await p.waitForTimeout(400);
  await p.evaluate(() => getSelection().removeAllRanges());
  await p.click('[data-do="export"]');
  await p.waitForTimeout(400);
  const exportPoints = [
    { n: 9, ...(await at('.rv-export textarea', 'corner')) },
    { n: 10, ...(await at('.rv-export [value="copy"]')) },
    { n: 11, ...(await at('.rv-export [value="share"]')) },
    { n: 12, ...(await at('.rv-export [value="clear"]')) },
  ];
  await p.screenshot({ path: path.join(here, 'export.jpg'), type: 'jpeg', quality: 70 });
  fs.writeFileSync(path.join(here, 'export.json'), JSON.stringify({ points: exportPoints }, null, 1) + '\n');
  await browser.close();
})();
