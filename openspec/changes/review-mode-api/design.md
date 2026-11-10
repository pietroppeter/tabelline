## Context

The review mode is `docs/review.nim` (blocks and styles, in English, so it can move to nimib)
and `docs/assets/review.js` (the script, in nine parts). It was built in seven review rounds of
the post *Review mode*, which keeps a notebook per version. This change gives it a spec, takes
the version from git, and turns it on for every page of the docs.

## Goals and non-goals

- Goal: one line, or none, turns the review mode on; nothing about versions to maintain by hand.
- Goal: every page of the docs can be reviewed, from the theme.
- Non-goal: the book (a nimibook with its own theme), until the module moves to nimib.
- Non-goal: sharing the style and the fonts as files. That is its own change,
  `share-site-assets` (Pietro, 10 Nov 2026: a page in a collection shares what it needs, a
  one-shot page stays one file). This change builds on it: the pages of the docs share
  `assets/review.js`, and a `-d:singleFile` build inlines it again.

## Decisions

**The API.**

```nim
nbReview()        # on; every argument is optional
nbVersion()       # optional: puts the version line here instead of under the title
nbInReview:       # optional: blocks shown only while reviewing
  nbText "..."
```

`nbReview(page = "", title = "", source = "", script = "")`:
- `source`: the notebook's path from the root of its repository (`nb.doc.thisFile`).
- `title`: the page's title (`nb.doc.context["title"]`).
- `page`: the key the comments are kept under; the source by default. Given when a file is
  renamed and its comments should follow (this post, when its versions become one notebook).
- `script`: a link to a shared copy of the script, instead of inlining it.

`version` goes: nothing left needs it. A page outside git gets a hash of its source.

**The version from git.** At build time `nbReview` runs `git log --format=%h|%cs -- <source>`
once: the number of lines is the version, the first line the commit and its date. Outside a
repository, or when git is missing, the version is the first 7 characters of a hash of the
source, and there is no date. A shallow clone would count 1, so CI fetches the whole history.
An uncommitted change shows as `12+`: the page was built from a source that differs from the
commit.

**The version line.** The script writes it when the page has no `nbVersion` block: *Version 12
· updated 10 Nov 2026*, under the lede, or under the title, with **✎ Review** beside it. One
place for the button on every page; the header stays as it is.

**The export, `nimib-review/4`.** The YAML block adds `commit: a1b2c3d`. `version` becomes the
number from git. The skill reads `/4` and can run `git diff <commit> -- <source>` to see what
changed since the review; it still reads `/1` to `/3`.

**History.** It lists the versions of this page that have comments in this browser, newest
first, with Clear, and Clear everything. No links: old versions are not pages any more. It
needs no argument.

**The post *Review mode*.** It becomes one notebook, `docs/devlog/review_mode.nim`, with
`nbReview(page = "devlog/review-mode")` so the comments of version 8 are still found. v1 to v8
are removed from the build; each card of *Versions and rounds* links the commit that version
was built from, and its round's export. The redirect pages `review-mode/vN/` are not kept: the
post was never linked by version from outside.

**Every page of the docs.** `useTabelline(..., review = true)` calls `nbReview(script =
<the shared review.js>)` after the page is set up; with `-d:singleFile` the script is inlined.
The pages that set `review = false`: none to start with.

## Risks and trade-offs

- **A version per build, not per meaningful change**: a commit that only touches the file's
  whitespace starts a new set of comments. The old ones stay in History, and the export of the
  old ones still works; acceptable.
- **Comments on text made by code** (tables, the specs page) point at rendered text: the skill
  already says to find the code or the data behind it.
- **Removing v1 to v8** loses pages that were read, but every one is a commit, and git keeps
  it exactly, which the rebuilt pages did not.
