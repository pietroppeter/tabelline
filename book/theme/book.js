// The tabelline book's script: the 👑 Nim / 🐍 Python / 🏴‍☠️ R tabs (the choice holds for every
// example and is remembered; an example with no tab for it shows its first). `nim r book/bookbuild.nim` appends
// it to nimibook's assets/js/book.js, so it runs on every page.
(function () {
  function choose(lang) {
    document.querySelectorAll(".tb-tabs").forEach(function (t) {
      var here = t.querySelector('.tb-tab[data-lang="' + lang + '"]') ? lang : t.querySelector(".tb-tab").dataset.lang;
      t.querySelectorAll(".tb-tab").forEach(function (b) {
        b.setAttribute("aria-selected", b.dataset.lang === here ? "true" : "false"); });
      t.querySelectorAll(".tb-panel").forEach(function (p) { p.hidden = p.dataset.lang !== here; });
    });
    try { localStorage.setItem("tabelline-book-lang", lang); } catch (e) {}
  }
  document.addEventListener("click", function (e) {
    var b = e.target.closest && e.target.closest(".tb-tab");
    if (b) choose(b.dataset.lang);
  });
  document.addEventListener("DOMContentLoaded", function () {
    var lang = null;
    try { lang = new URLSearchParams(location.search).get("lang") || localStorage.getItem("tabelline-book-lang"); } catch (e) {}
    if (lang === "nim" || lang === "python" || lang === "r") choose(lang);
  });
})();

// a finder (tabbook.nim): the chosen button looks pressed; CSS (:target) shows its part
(function () {
  function mark() {
    document.querySelectorAll(".tb-choices a[href^='#']").forEach(function (a) {
      a.setAttribute("aria-current", String(a.getAttribute("href") === location.hash));
    });
  }
  window.addEventListener("hashchange", mark);
  document.addEventListener("DOMContentLoaded", mark);
})();
