// Review mode for a nimib page: select text, comment on it, keep the comments in this browser,
// export them as Markdown with a YAML front matter for a coding agent. No dependencies.
// The page gives its settings on <div id="revisione" data-page data-version data-title data-source>.
// Each part is between `// part:` lines, which the devlog post "Review mode" shows one by one.
(function () {
  var cfg = document.getElementById('revisione');
  var root = document.querySelector('main');
  if (!cfg || !root) return;
  var page = cfg.dataset;

  // part: anchor
  // A comment points at the text it quotes, with a few words around it (as a W3C text quote
  // selector does), and the heading it is under. Not at an element: the page is rebuilt from its
  // source, and the text is what stays. The text of the page is its text nodes, in order.
  var CONTEXT = 32;
  var BLOCKS = 'p, li, h1, h2, h3, h4, pre, td, th, caption, blockquote, summary, dt, dd, div, nav';
  function textIndex() {
    // a line break between blocks, so the words around a quote read "page Select", not "pageSelect"
    var nodes = [], text = '', last = null;
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode: function (n) {
        var p = n.parentNode.closest('script, style, #revisione');
        return p ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
      }
    });
    for (var n = walker.nextNode(); n; n = walker.nextNode()) {
      var block = n.parentNode.closest(BLOCKS);
      if (nodes.length && block !== last) text += '\n';
      last = block;
      nodes.push({ node: n, start: text.length });
      text += n.data;
    }
    return { nodes: nodes, text: text };
  }
  function pointToIndex(idx, container, offset) {
    if (container.nodeType === 3) {
      for (var i = 0; i < idx.nodes.length; i++)
        if (idx.nodes[i].node === container) return idx.nodes[i].start + offset;
    }
    var at = document.createRange();
    at.setStart(container, offset);
    for (var j = 0; j < idx.nodes.length; j++)   // the first text node after the point
      if (at.comparePoint(idx.nodes[j].node, 0) >= 0) return idx.nodes[j].start;
    return idx.text.length;
  }
  function sectionOf(node) {
    var found = { title: '', id: '' };
    root.querySelectorAll('h1, h2, h3').forEach(function (h) {
      if (h.compareDocumentPosition(node) & Node.DOCUMENT_POSITION_FOLLOWING)
        found = { title: h.textContent.trim(), id: h.id || '' };
    });
    return found;
  }
  function describe(range) {
    var idx = textIndex();
    var s = pointToIndex(idx, range.startContainer, range.startOffset);
    var e = pointToIndex(idx, range.endContainer, range.endOffset);
    var quote = idx.text.slice(s, e);
    if (!quote.trim()) return null;
    return { quote: quote, prefix: idx.text.slice(Math.max(0, s - CONTEXT), s),
             suffix: idx.text.slice(e, e + CONTEXT), section: sectionOf(range.startContainer) };
  }
  function locate(note, idx) {
    // every place the quote is, scored by how much of its context matches; the best wins
    var best = null, bestScore = -1;
    for (var at = idx.text.indexOf(note.quote); at >= 0; at = idx.text.indexOf(note.quote, at + 1)) {
      var before = idx.text.slice(Math.max(0, at - note.prefix.length), at);
      var after = idx.text.slice(at + note.quote.length, at + note.quote.length + note.suffix.length);
      var score = common(before, note.prefix, true) + common(after, note.suffix, false);
      if (score > bestScore) { best = at; bestScore = score; }
    }
    return best === null ? null : { start: best, end: best + note.quote.length };
  }
  function common(a, b, fromEnd) {
    var n = 0;
    while (n < a.length && n < b.length &&
           (fromEnd ? a[a.length - 1 - n] === b[b.length - 1 - n] : a[n] === b[n])) n++;
    return n;
  }

  // part: mark
  // A located comment is drawn with <mark> around each piece of text it covers (a quote can
  // cross a link or a paragraph). Marks only wrap text, so the text of the page stays the same.
  function mark(note) {
    if (!note.quote) return;   // a comment on the whole page has nothing to mark
    var idx = textIndex(), at = locate(note, idx);
    note.found = !!at;
    if (!at) return;
    idx.nodes.forEach(function (n) {
      var a = Math.max(at.start, n.start) - n.start;
      var b = Math.min(at.end, n.start + n.node.data.length) - n.start;
      if (b <= a || !n.node.data.slice(a, b).trim()) return;
      if (n.node.parentNode.closest('table') && !n.node.parentNode.closest('td, th, caption')) return;
      var t = n.node;
      if (b < t.data.length) t.splitText(b);
      if (a > 0) t = t.splitText(a);
      var m = document.createElement('mark');
      m.className = 'rv-mark';
      m.dataset.id = note.id;
      t.parentNode.replaceChild(m, t);
      m.appendChild(t);
    });
  }
  function unmarkAll() {
    root.querySelectorAll('mark.rv-mark').forEach(function (m) {
      var p = m.parentNode;
      while (m.firstChild) p.insertBefore(m.firstChild, m);
      p.removeChild(m);
      p.normalize();
    });
  }
  function drawAll() {
    unmarkAll();
    notes.forEach(mark);
    var idx = textIndex();
    function place(note) {   // the page's order: a comment on the whole page first, one not found last
      if (!note.quote) return -1;
      var m = root.querySelector('mark.rv-mark[data-id="' + note.id + '"]');
      return m ? pointToIndex(idx, m.firstChild, 0) : Infinity;
    }
    notes.sort(function (a, b) { return place(a) - place(b); });
  }

  // part: store
  // The comments of a page live in this browser's localStorage, one key per page and version,
  // so a new version starts with no comments and the old ones stay with the version they are on.
  var KEY = 'nimib-review:' + page.page + '@v' + page.version;
  function load() {
    try { return JSON.parse(localStorage.getItem(KEY)) || []; } catch (e) { return []; }
  }
  function save() {
    try {
      localStorage.setItem(KEY, JSON.stringify(notes.map(function (n) {
        return { id: n.id, kind: n.kind, quote: n.quote, prefix: n.prefix, suffix: n.suffix,
                 section: n.section, text: n.text, replacement: n.replacement, at: n.at, images: n.images };
      })));
      return true;
    } catch (e) { return false; }   // the browser's storage is full: screenshots take the most
  }
  var notes = load();
  var current = -1, full = false;

  // part: bar
  // The bar stays at the bottom of the screen, where a thumb reaches on a phone: the previous and
  // next comment, which one this is, edit it, comment (on the selected text, or on the page when
  // nothing is selected), and export. A selection is kept as soon as it is made, because tapping
  // a button can clear it on a phone.
  var bar = document.createElement('div');
  bar.className = 'rv-bar';
  bar.setAttribute('role', 'toolbar');
  bar.setAttribute('aria-label', 'Review mode');
  bar.innerHTML =
    '<button type="button" data-do="prev" aria-label="Previous comment">‹</button>' +
    '<span class="rv-count" aria-live="polite"></span>' +
    '<button type="button" data-do="next" aria-label="Next comment">›</button>' +
    '<button type="button" data-do="edit" aria-label="Edit this comment">Edit</button>' +
    '<button type="button" data-do="add" class="rv-add">Comment</button>' +
    '<button type="button" data-do="export">Export</button>';
  document.body.appendChild(bar);
  document.body.classList.add('rv-on');
  var pending = null;
  document.addEventListener('selectionchange', function () {
    var sel = document.getSelection();
    if (sel.rangeCount && !sel.isCollapsed && root.contains(sel.getRangeAt(0).commonAncestorContainer)) {
      pending = describe(sel.getRangeAt(0));
    } else if (!sheet.open) {
      setTimeout(function () { if (document.getSelection().isCollapsed) { pending = null; show(); } }, 400);
    }
    show();
  });
  bar.addEventListener('pointerdown', function (e) { e.preventDefault(); });   // keep the selection
  bar.addEventListener('click', function (e) {
    var b = e.target.closest('button');
    if (!b) return;
    var act = b.dataset.do;
    if (act === 'prev' || act === 'next') go(current + (act === 'next' ? 1 : -1));
    if (act === 'edit' && notes[current]) openSheet(notes[current]);
    if (act === 'add') openSheet(pending ? Object.assign({ kind: 'comment', text: '' }, pending)
                                         : { kind: 'comment', text: '', quote: '', prefix: '', suffix: '',
                                             section: { title: '', id: '' } });
    if (act === 'export') openExport();
  });
  root.addEventListener('click', function (e) {
    var m = e.target.closest('mark.rv-mark');
    if (!m || !document.getSelection().isCollapsed) return;
    var i = notes.findIndex(function (n) { return n.id === m.dataset.id; });
    if (i >= 0) { go(i); openSheet(notes[i]); }
  });
  function go(i) {
    if (!notes.length) return;
    current = (i + notes.length) % notes.length;
    root.querySelectorAll('mark.rv-current').forEach(function (m) { m.classList.remove('rv-current'); });
    var ms = root.querySelectorAll('mark.rv-mark[data-id="' + notes[current].id + '"]');
    ms.forEach(function (m) { m.classList.add('rv-current'); });
    if (ms.length) ms[0].scrollIntoView({ block: 'center', behavior: 'smooth' });
    show();
  }
  function show() {
    var c = bar.querySelector('.rv-count');
    if (full) { c.textContent = 'storage full: export'; return; }
    c.textContent = notes.length ? (current >= 0 ? (current + 1) + '/' : '') + notes.length : 'none';
    bar.querySelector('[data-do="prev"]').disabled = !notes.length;
    bar.querySelector('[data-do="next"]').disabled = !notes.length;
    bar.querySelector('[data-do="edit"]').disabled = current < 0;
    var add = bar.querySelector('.rv-add');
    add.textContent = pending ? 'Comment ✓' : 'Comment';
    add.classList.toggle('rv-selected', !!pending);
    add.setAttribute('aria-label', pending ? 'Comment on the selected text' : 'Comment on the whole page');
  }

  // part: sheet
  // Writing a comment, in a sheet that slides down from the top and stays small, so the words it
  // is about stay in view under it, marked. One row: Cancel, the kind, Delete (for a comment
  // already saved), Save. Then the new text, for a replacement (starting from the words
  // selected; empty, it removes them), and the note. A screenshot is pasted in the note, like
  // text: the note is an editable box, not a text field, so a phone offers to paste an image
  // there. While a sheet is open the page may not zoom, so a phone does not zoom in on it.
  var viewport = document.querySelector('meta[name="viewport"]');
  var looseViewport = viewport ? viewport.content : '';
  function noZoom(on) {
    if (viewport) viewport.content = on ? looseViewport + ', maximum-scale=1' : looseViewport;
  }
  var sheet = document.createElement('dialog');
  sheet.className = 'rv-sheet rv-compact';
  sheet.innerHTML =
    '<form method="dialog">' +
    '<div class="rv-row"><button value="cancel" aria-label="Cancel">×</button>' +
    '<span class="rv-kinds" role="radiogroup" aria-label="Kind">' +
    '<label><input type="radio" name="kind" value="comment"><span>Comment</span></label>' +
    '<label><input type="radio" name="kind" value="replace"><span>Replace</span></label></span>' +
    '<span class="rv-whole">On the whole page</span>' +
    '<button value="delete" class="rv-delete">Delete</button>' +
    '<button value="save" class="rv-save">Save</button></div>' +
    '<textarea name="replacement" rows="2" class="rv-replacement" aria-label="Replace with" placeholder="New text (empty: remove the words)"></textarea>' +
    '<div class="rv-note" contenteditable="true" role="textbox" aria-multiline="true" aria-label="Note"' +
    ' data-placeholder="Note, or paste a screenshot"></div>' +
    '<div class="rv-thumbs"></div>' +
    '</form>';
  document.body.appendChild(sheet);
  var form = sheet.querySelector('form'), noteBox = sheet.querySelector('.rv-note');
  var editing = null, shots = [];
  function openSheet(n) {
    editing = n;
    shots = (n.images || []).slice();
    thumbs();
    sheet.querySelector('.rv-kinds').hidden = !n.quote;
    sheet.querySelector('.rv-whole').hidden = !!n.quote;
    form.elements.kind.value = n.kind === 'cut' ? 'replace' : n.kind || 'comment';   // a cut of v3 is an empty replacement
    noteBox.textContent = n.text || '';
    form.elements.replacement.value = n.kind === 'cut' ? '' : n.replacement != null ? n.replacement
                                    : (n.quote || '').replace(/\s+/g, ' ').trim();
    sheet.querySelector('.rv-delete').hidden = !n.id;
    kinds();
    if (n.quote && !n.id) mark(Object.assign({}, n, { id: 'rv-new' }));   // the words, marked while writing
    noZoom(true);
    sheet.showModal();
    keepInView(n.id || 'rv-new');
  }
  function keepInView(id) {   // the marked words, just under the sheet
    var m = root.querySelector('mark.rv-mark[data-id="' + id + '"]');
    if (!m) return;
    var under = sheet.offsetHeight + 24;   // its height, not its place: it is still sliding in
    window.scrollBy(0, m.getBoundingClientRect().top - under);
  }
  function kinds() { form.elements.replacement.hidden = form.elements.kind.value !== 'replace' || !editing || !editing.quote; }
  form.addEventListener('change', kinds);
  function thumbs() {
    var box = sheet.querySelector('.rv-thumbs');
    box.innerHTML = '';
    box.hidden = !shots.length;
    shots.forEach(function (src, i) {
      var t = document.createElement('div');
      t.className = 'rv-thumb';
      t.innerHTML = '<img alt="screenshot ' + (i + 1) + '"><button type="button" aria-label="Remove screenshot ' + (i + 1) + '">×</button>';
      t.querySelector('img').src = src;
      t.querySelector('button').addEventListener('click', function () { shots.splice(i, 1); thumbs(); });
      box.appendChild(t);
    });
  }
  function grown() { if (sheet.open && editing) keepInView(editing.id || 'rv-new'); }   // a screenshot added: the words, still in view
  function shrink(blob, width, quality) {   // an image as a JPEG at most `width` pixels wide
    return new Promise(function (ok, ko) {
      var img = new Image(), url = URL.createObjectURL(blob);
      img.onload = function () {
        var k = Math.min(1, width / img.naturalWidth), c = document.createElement('canvas');
        c.width = Math.round(img.naturalWidth * k); c.height = Math.round(img.naturalHeight * k);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);
        ok(c.toDataURL('image/jpeg', quality));
      };
      img.onerror = ko;
      img.src = url;
    });
  }
  noteBox.addEventListener('paste', function (e) {   // an image goes to the screenshots, text stays plain text
    e.preventDefault();
    var files = [].filter.call(e.clipboardData.files || [], function (f) { return /^image\//.test(f.type); });
    Promise.all(files.map(function (b) { return shrink(b, 900, 0.72); })).then(function (srcs) {
      shots = shots.concat(srcs); thumbs(); grown();
    });
    var text = e.clipboardData.getData('text/plain');
    if (text) document.execCommand('insertText', false, text);
  });
  noteBox.addEventListener('drop', function (e) { e.preventDefault(); });   // no images inside the text
  sheet.addEventListener('close', function () {
    var act = sheet.returnValue, n = editing;
    editing = null;
    noZoom(false);
    if (act === 'save') {
      n.kind = n.quote ? form.elements.kind.value : 'comment';
      n.text = noteBox.innerText.trim();
      n.replacement = n.kind === 'replace' ? form.elements.replacement.value : null;
      n.images = shots.length ? shots : undefined;
      if (!n.id) {
        n.id = 'c' + Date.now().toString(36);
        n.at = new Date().toISOString();
        notes.push(n);
      }
      document.getSelection().removeAllRanges();
      pending = null;
    } else if (act === 'delete') {
      notes = notes.filter(function (x) { return x !== n; });
    } else { pending = null; drawAll(); show(); return; }
    var saved = save();
    drawAll();
    current = notes.indexOf(n);
    full = !saved;
    if (current >= 0) go(current); else show();
  });

  // part: export
  // The comments as one text, for a person and for an agent: a YAML front matter that says which
  // page, version and source they are on, then one Markdown section per comment, in page order.
  // The text can be edited before it is copied or shared. Copy copies the text only, short
  // enough for a chat message; each screenshot has a Copy of its own, to paste after it. Share
  // sends the text as a file with the screenshots, named as the text names them.
  function yaml(s) { return JSON.stringify(String(s)); }   // a JSON string is a YAML string
  function flat(s) { return s.replace(/\s+/g, ' '); }
  function quoted(s) { return flat(s).trim(); }
  function fence(s) {
    var f = '~~~';
    while (s.indexOf(f) >= 0) f += '~';
    return f + 'text\n' + s.trim() + '\n' + f;
  }
  function shotName(i, k) { return 'review-v' + page.version + '-' + (i + 1) + '-' + (k + 1) + '.jpg'; }
  function exportText() {
    var out = ['---',
      'format: nimib-review/1',
      'title: ' + yaml(page.title),
      'page: ' + yaml(location.origin + location.pathname),
      'source: ' + yaml(page.source),
      'version: ' + page.version,
      'exported: ' + yaml(new Date().toISOString()),
      'comments: ' + notes.length,
      '---', '',
      '# Review of “' + page.title + '”, version ' + page.version, ''];
    notes.forEach(function (n, i) {
      var cut = n.kind === 'cut' || (n.kind === 'replace' && !(n.replacement || '').trim());
      var kind = cut ? 'Remove' : n.kind === 'replace' ? 'Replace' : 'Comment';
      var where = !n.quote ? 'on the whole page'
                : n.section && n.section.title ? 'in “' + n.section.title + '”' + (n.section.id ? ' (#' + n.section.id + ')' : '')
                : 'at the top';
      out.push('## ' + (i + 1) + '. ' + kind + ', ' + where, '');
      if (n.quote) {
        out.push('> ' + quoted(n.quote), '');
        out.push('Around it: “…' + flat(n.prefix) + '⟦' + flat(n.quote) + '⟧' + flat(n.suffix) + '…”', '');
        if (n.found === false) out.push('(Not found on the page any more.)', '');
      }
      if (cut) out.push('Remove these words.', '');
      else if (n.kind === 'replace') out.push('Replace with:', '', fence(n.replacement), '');
      if (n.text) out.push(n.text, '');
      if (n.images) out.push('Screenshots: ' + n.images.map(function (src, k) { return shotName(i, k); }).join(', '), '');
    });
    return out.join('\n');
  }
  var box = document.createElement('dialog');
  box.className = 'rv-sheet rv-export';
  box.innerHTML =
    '<form method="dialog"><p class="rv-where">Export: edit it if you like, then copy or share it</p>' +
    '<textarea rows="12" spellcheck="false"></textarea><div class="rv-shotlist"></div>' +
    '<div class="rv-actions"><button value="clear" class="rv-delete">Clear all</button>' +
    '<button value="close">Close</button><button value="share">Share</button>' +
    '<button value="copy" class="rv-save">Copy</button></div></form>';
  document.body.appendChild(box);
  var area = box.querySelector('textarea');
  function openExport() {
    var clear = box.querySelector('[value="clear"]');
    clear.dataset.sure = ''; clear.textContent = 'Clear all';
    area.value = exportText();
    box.querySelector('[value="share"]').hidden = !navigator.share;
    shotList();
    noZoom(true);
    box.showModal();
  }
  box.addEventListener('close', function () { noZoom(false); });
  function fileOf(src, name) {   // a data: URL as a File, without fetch (an artifact may block it)
    var bytes = atob(src.split(',')[1]), arr = new Uint8Array(bytes.length);
    for (var i = 0; i < bytes.length; i++) arr[i] = bytes.charCodeAt(i);
    return new File([arr], name, { type: 'image/jpeg' });
  }
  function allShots() {
    var all = [];
    notes.forEach(function (n, i) { (n.images || []).forEach(function (src, k) { all.push({ name: shotName(i, k), src: src }); }); });
    return all;
  }
  function shotList() {   // each screenshot, with its own Copy: paste it in the chat after the text
    var list = box.querySelector('.rv-shotlist');
    list.innerHTML = '';
    var all = allShots();
    list.hidden = !all.length || !(navigator.clipboard && window.ClipboardItem);
    all.forEach(function (shot) {
      var row = document.createElement('div');
      row.className = 'rv-shot';
      row.innerHTML = '<img alt=""><span></span><button type="button">Copy image</button>';
      row.querySelector('img').src = shot.src;
      row.querySelector('span').textContent = shot.name;
      var b = row.querySelector('button');
      b.addEventListener('click', function () {
        copied(b, navigator.clipboard.write([new ClipboardItem({ 'image/png': png(shot.src) })]));
      });
      list.appendChild(row);
    });
  }
  function png(src) {   // the clipboard takes PNG images everywhere, JPEG not always
    return new Promise(function (ok, ko) {
      var img = new Image();
      img.onload = function () {
        var c = document.createElement('canvas');
        c.width = img.naturalWidth; c.height = img.naturalHeight;
        c.getContext('2d').drawImage(img, 0, 0);
        c.toBlob(ok, 'image/png');
      };
      img.onerror = ko;
      img.src = src;
    });
  }
  function copied(button, promise) {
    var label = button.textContent;
    return promise.then(function () {
      button.textContent = 'Copied ✓';
      setTimeout(function () { button.textContent = label; }, 1500);
    }, function () { button.textContent = 'Blocked'; });
  }
  function share() {
    var files = [new File([area.value], 'review-v' + page.version + '.md', { type: 'text/markdown' })];
    allShots().forEach(function (shot) { files.push(fileOf(shot.src, shot.name)); });
    var data = { title: 'Review of ' + page.title, files: files };
    if (!navigator.canShare || !navigator.canShare(data)) data = { title: data.title, text: area.value };
    return navigator.share(data);
  }
  box.querySelector('form').addEventListener('submit', function (e) {
    var act = e.submitter && e.submitter.value;
    if (act === 'share') {
      e.preventDefault();
      share().catch(function () {});
    } else if (act === 'copy') {
      e.preventDefault();
      var button = e.submitter;
      var fallback = function () { area.select(); document.execCommand('copy'); };
      copied(button, navigator.clipboard ? navigator.clipboard.writeText(area.value).catch(fallback)
                                         : Promise.resolve().then(fallback));
    } else if (act === 'clear' && e.submitter.dataset.sure !== 'yes') {
      e.preventDefault();   // a second tap deletes: confirm() is blocked inside an artifact
      e.submitter.dataset.sure = 'yes';
      e.submitter.textContent = 'Delete ' + notes.length + '?';
    } else if (act === 'clear') {
      notes = []; current = -1; full = !save(); drawAll(); show();
    }
  });

  drawAll();
  show();
})();
