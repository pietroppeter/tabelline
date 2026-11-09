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
  function textIndex() {
    var nodes = [], text = '';
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode: function (n) {
        var p = n.parentNode.closest('script, style, #revisione');
        return p ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
      }
    });
    for (var n = walker.nextNode(); n; n = walker.nextNode()) {
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
                 section: n.section, text: n.text, replacement: n.replacement, at: n.at };
      })));
    } catch (e) {}
  }
  var notes = load();
  var current = -1;

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
  // Writing a comment: what it is about, its kind (a comment, a replacement or a cut), and the
  // text. A replacement starts from the quoted text, to be edited in place.
  var sheet = document.createElement('dialog');
  sheet.className = 'rv-sheet';
  sheet.innerHTML =
    '<form method="dialog">' +
    '<p class="rv-where"></p><blockquote class="rv-quote"></blockquote>' +
    '<fieldset class="rv-kinds"><legend>Kind</legend>' +
    '<label><input type="radio" name="kind" value="comment"> Comment</label>' +
    '<label><input type="radio" name="kind" value="replace"> Replace</label>' +
    '<label><input type="radio" name="kind" value="cut"> Cut</label></fieldset>' +
    '<label class="rv-replacement">Replace with<textarea name="replacement" rows="3"></textarea></label>' +
    '<label>Note<textarea name="text" rows="4" placeholder="What should change, and why"></textarea></label>' +
    '<div class="rv-actions"><button value="delete" class="rv-delete">Delete</button>' +
    '<button value="cancel">Cancel</button><button value="save" class="rv-save">Save</button></div>' +
    '</form>';
  document.body.appendChild(sheet);
  var form = sheet.querySelector('form'), editing = null;
  function openSheet(note) {
    editing = note;
    var where = note.section && note.section.title ? 'In “' + note.section.title + '”' : 'At the top of the page';
    sheet.querySelector('.rv-where').textContent = note.quote ? where : 'On the whole page';
    sheet.querySelector('.rv-quote').textContent = note.quote ? note.quote.replace(/\s+/g, ' ').trim() : '';
    sheet.querySelector('.rv-quote').hidden = !note.quote;
    sheet.querySelector('.rv-kinds').hidden = !note.quote;
    form.elements.kind.value = note.kind || 'comment';
    form.elements.text.value = note.text || '';
    form.elements.replacement.value = note.replacement != null ? note.replacement : (note.quote || '').replace(/\s+/g, ' ').trim();
    sheet.querySelector('.rv-delete').hidden = !note.id;
    kinds();
    sheet.showModal();
  }
  function kinds() { sheet.querySelector('.rv-replacement').hidden = form.elements.kind.value !== 'replace'; }
  form.addEventListener('change', kinds);
  sheet.addEventListener('close', function () {
    var act = sheet.returnValue, note = editing;
    editing = null;
    if (act === 'save') {
      note.kind = note.quote ? form.elements.kind.value : 'comment';
      note.text = form.elements.text.value.trim();
      note.replacement = note.kind === 'replace' ? form.elements.replacement.value : null;
      if (!note.id) {
        note.id = 'c' + Date.now().toString(36);
        note.at = new Date().toISOString();
        notes.push(note);
      }
      document.getSelection().removeAllRanges();
      pending = null;
    } else if (act === 'delete') {
      notes = notes.filter(function (n) { return n !== note; });
    } else { pending = null; show(); return; }
    save();
    drawAll();
    current = notes.indexOf(note);
    if (current >= 0) go(current); else show();
  });

  // part: export
  // The comments as one text, for a person and for an agent: a YAML front matter that says which
  // page, version and source they are on, then one Markdown section per comment, in page order.
  function yaml(s) { return JSON.stringify(String(s)); }   // a JSON string is a YAML string
  function flat(s) { return s.replace(/\s+/g, ' '); }
  function quoted(s) { return flat(s).trim(); }
  function fence(s) {
    var f = '~~~';
    while (s.indexOf(f) >= 0) f += '~';
    return f + 'text\n' + s.trim() + '\n' + f;
  }
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
      var kind = { comment: 'Comment', replace: 'Replace', cut: 'Cut' }[n.kind] || 'Comment';
      var where = !n.quote ? 'on the whole page'
                : n.section && n.section.title ? 'in “' + n.section.title + '”' + (n.section.id ? ' (#' + n.section.id + ')' : '')
                : 'at the top';
      out.push('## ' + (i + 1) + '. ' + kind + ', ' + where, '');
      if (n.quote) {
        out.push('> ' + quoted(n.quote), '');
        out.push('Around it: “…' + flat(n.prefix) + '⟦' + flat(n.quote) + '⟧' + flat(n.suffix) + '…”', '');
        if (n.found === false) out.push('(Not found on the page any more.)', '');
      }
      if (n.kind === 'replace') out.push('Replace with:', '', fence(n.replacement || ''), '');
      if (n.kind === 'cut') out.push('Cut it.', '');
      if (n.text) out.push(n.text, '');
    });
    return out.join('\n');
  }
  var box = document.createElement('dialog');
  box.className = 'rv-sheet rv-export';
  box.innerHTML =
    '<form method="dialog"><p class="rv-where">Export: paste it in the chat</p>' +
    '<textarea readonly rows="12"></textarea>' +
    '<div class="rv-actions"><button value="clear" class="rv-delete">Clear all</button>' +
    '<button value="close">Close</button><button value="copy" class="rv-save">Copy</button></div></form>';
  document.body.appendChild(box);
  var area = box.querySelector('textarea');
  function openExport() {
    var clear = box.querySelector('[value="clear"]');
    clear.dataset.sure = ''; clear.textContent = 'Clear all';
    area.value = exportText();
    box.showModal();
  }
  box.querySelector('form').addEventListener('submit', function (e) {
    var act = e.submitter && e.submitter.value;
    if (act === 'copy') {
      e.preventDefault();
      var done = function () { e.submitter.textContent = 'Copied ✓'; setTimeout(function () { e.submitter.textContent = 'Copy'; }, 1500); };
      var fallback = function () { area.select(); try { document.execCommand('copy'); done(); } catch (x) {} };
      if (navigator.clipboard) navigator.clipboard.writeText(area.value).then(done, fallback); else fallback();
    } else if (act === 'clear' && e.submitter.dataset.sure !== 'yes') {
      e.preventDefault();   // a second tap deletes: confirm() is blocked inside an artifact
      e.submitter.dataset.sure = 'yes';
      e.submitter.textContent = 'Delete ' + notes.length + '?';
    } else if (act === 'clear') {
      notes = []; current = -1; save(); drawAll(); show();
    }
  });

  drawAll();
  show();
})();
