// Takes the four annotated screenshots of the post "Review mode" (reading, reviewing, export,
// history: <name>-v9.jpg) and the places of their numbered circles (<name>-v9.json), from the built
// page, on a phone. The screenshots of older versions are in git with them (commit 64f87e2).
// Run after building the post: node docs/devlog/data/review-mode/screens.js ; then build it again.
const { chromium, devices } = require('playwright');
const path = require('path');
const fs = require('fs');
const here = __dirname;
const page_ = path.join(here, '..', '..', 'review-mode', 'index.html');
const suffix = '-v9';

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ ...devices['iPhone 13'], deviceScaleFactor: 2 });
  const p = await ctx.newPage();
  await p.goto('file://' + page_);
  await p.evaluate(() => {   // nothing kept, but three comments on version 8, for History
    localStorage.clear();
    localStorage.setItem('nimib-review:devlog/review-mode@v8', JSON.stringify([{}, {}, {}]));
  });
  await p.reload();
  const vw = p.viewportSize();
  const at = async (sel, where = 'corner') => {
    const b = await p.$eval(sel, (e) => { const r = e.getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; });
    const x = where === 'center' ? b[0] + b[2] / 2 : b[0] + 2;
    const y = where === 'center' ? b[1] + b[3] / 2 : b[1] + 2;
    return { x: +(100 * x / vw.width).toFixed(1), y: +(100 * y / vw.height).toFixed(1) };
  };
  async function take(name, points) {
    await p.screenshot({ path: path.join(here, name + suffix + '.jpg'), type: 'jpeg', quality: 70 });
    fs.writeFileSync(path.join(here, name + suffix + '.json'), JSON.stringify({ points }, null, 1) + '\n');
  }
  // reading: the page as it opens, scrolled to its lede
  await p.$eval('.rv-enter', (e) => window.scrollTo(0, e.getBoundingClientRect().top + scrollY - 380));
  await p.waitForTimeout(300);
  await take('reading', [{ n: 1, ...(await at('.rv-toggle')) }]);
  await p.click('.rv-toggle');   // open the review mode
  async function select(text) {
    await p.evaluate((text) => {
      const w = document.createTreeWalker(document.querySelector('main'), NodeFilter.SHOW_TEXT);
      for (let n = w.nextNode(); n; n = w.nextNode()) {
        const i = n.data.indexOf(text);
        if (i >= 0 && !n.parentNode.closest('pre, table, .nota, script, style')) {
          const r = document.createRange(); r.setStart(n, i); r.setEnd(n, i + text.length);
          getSelection().removeAllRanges(); getSelection().addRange(r); return;
        }
      }
    }, text);
    await p.waitForTimeout(250);
  }
  // one comment written, then closed with a tap on the page
  await select('select text, comment on it');
  await p.click('.rv-add');
  await p.fill('.rv-note', 'Say how long a trip takes.');
  await p.mouse.click(vw.width / 2, vw.height / 2 + 60);
  await p.waitForTimeout(300);
  // a second one, with a screenshot pasted in its note: it stays open
  await select('export them all in one text');
  await p.click('.rv-add');
  await p.fill('.rv-note', 'Replace with: export them in one text, screenshots after it');
  const shot = (await p.screenshot({ type: 'png' })).toString('base64');
  await p.evaluate((b64) => {   // a screenshot pasted in the note, as a phone pastes it
    const bytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
    const dt = new DataTransfer();
    dt.items.add(new File([bytes], 'shot.png', { type: 'image/png' }));
    document.querySelector('.rv-note').dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true }));
  }, shot);
  await p.waitForSelector('.rv-thumb img');
  await p.evaluate(() => document.activeElement.blur());
  await p.waitForTimeout(800);
  await take('reviewing', [
    { n: 1, ...(await at('.rv-toggle')) },
    { n: 2, ...(await at('mark.rv-current')) },
    { n: 3, ...(await at('[data-do="prev"]')) },
    { n: 4, ...(await at('[data-do="delete"]')) },
    { n: 5, ...(await at('.rv-add')) },
    { n: 6, ...(await at('[data-do="export"]')) },
    { n: 7, ...(await at('.rv-panel .rv-note')) },
    { n: 8, ...(await at('.rv-panel .rv-thumb img')) },
  ]);
  await p.click('[data-do="export"]');
  await p.waitForTimeout(500);
  await take('export', [
    { n: 1, ...(await at('.rv-export textarea')) },
    { n: 2, ...(await at('.rv-export .rv-shot')) },
    { n: 3, ...(await at('.rv-export [value="history"]')) },
    { n: 4, ...(await at('.rv-export [value="leave"]')) },
    { n: 5, ...(await at('.rv-export [value="copy"]')) },
  ]);
  const text = await p.$eval('.rv-export textarea', (e) => e.value);
  await p.click('.rv-export [value="history"]');
  await p.waitForTimeout(500);
  await take('history', [
    { n: 1, ...(await at('.rv-history .rv-versions li')) },
    { n: 2, ...(await at('.rv-history .rv-versions li button:not([hidden])')) },
    { n: 3, ...(await at('.rv-history [value="wipe"]')) },
    { n: 4, ...(await at('.rv-history [value="export"]')) },
  ]);
  console.log(text);
  await browser.close();
})();
