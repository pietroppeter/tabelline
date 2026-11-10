---
name: nimib-review
description: Use when a review export from a nimib page is pasted in the chat (Markdown with a YAML block or front matter holding `format: nimib-review/1`, `/2` or `/3`), to apply each comment to the page's source and close the review round.
metadata:
  status: draft
---

# Apply a review export

The review mode of a nimib page (`nbRevisione` in tabelline's `docs/blocchi.nim`) lets a reader
open the review with a button, select text, comment on it, and export every comment as one text:
a title, a YAML block (a ```yaml fence since `nimib-review/2`; a front matter between `---` lines
in `nimib-review/1`), then one Markdown section per comment, in page order. This skill turns that
text into changes.

## 1. Read the export

- The YAML says which page (`page`, its URL), which notebook builds it (`source`, a path
  in the repository), which `version` was read, and how many `comments` there are. Check that the
  count matches the `## n.` sections: a long paste can arrive cut short, and the count is how you
  notice. If it does not match, say so.
- Each section is `## n. Where` in `nimib-review/3`: `In “Heading” (#id)`, `At the top`, or
  `On the whole page` (no quote: the note is about the page as a whole). Every comment is a note;
  a replacement is said in it, as `Replace with: ...`, or `Remove`. Do what the note asks.
- In `/1` and `/2` the section is `## n. Kind, where`:
  - `Comment`: do what the note asks.
  - `Replace`: replace the quoted text with the text in the `~~~text` fence; the note, if any,
    says why.
  - `Remove` (`Cut` in exports of version 3 and before): remove the quoted text and mend the
    sentence around it.
  A `/3` export may still hold one of these, from a comment written on an older version.
- `> quote` is the exact text the reader selected, as the page shows it, whitespace collapsed.
  `Around it: “…before ⟦quote⟧ after…”` gives the words around it, to tell apart a quote found
  more than once. `(#id)` is the anchor of the heading the quote is under.
- `Screenshots: review-v2-3-1.jpg, ...` names images that go with the export: the reviewer
  pastes the text, then attaches each image (copied with *Copy image* in the export, or from
  the phone's photos), in the same message or the next ones. Look at them before changing
  anything: they often show what the words can't (a layout, a zoom, a colour). If they are
  named but missing, ask for them. An export of version 3 may end with `## Screenshots, small`
  (data-URL images): decode them to look, and don't keep that section in the saved round.
- The text may have been edited by hand before it was sent: trust what it says over the format.
- `(Not found on the page any more.)`: the text changed after the comment was written. Apply it
  where it still makes sense, or ask.

## 2. Find each quote in the source

The quote is rendered text, not source. Search the notebook for it, and expect:

- Markdown marks gone: `**bold**`, `` `code` ``, `*em*` appear without their marks, a link shows
  only its text, a line break in the source is a space in the quote.
- Text made by code (a table, a generated list, the indice, a block of `blocchi.nim`) is not
  in the notebook's text: find the code or the data file that makes it.
- Text in a shared block (a header, a footer) is in `docs/blocchi.nim`, which changes every page:
  say so before changing it.

## 3. Freeze the version that was reviewed, then change

For a page with versions (`nbVersioni`, such as the devlog post `review_mode`), the reviewed
version is kept as it was:

1. Copy `review_mode/vN.nim` to `review_mode/vN+1.nim`; `vN` now builds into `vN/` by itself
   (the newest file is the post).
2. Add the new version's line to `review_mode/storia.nim`: the date and what the round changed.
3. Import the new file in `docs/devlog/review_mode.nim`.
4. Make the changes in `vN+1.nim` only.

## 4. Keep the round

- Save the export, as pasted, in `docs/devlog/data/<slug>/round-<n>.md`.
- Add the round to the page's record (`storia.nim`): how many comments, what they found.

## 5. Build, check, report

- Rebuild the page, check it at 390px in Munari (the quaderno only when the change might affect it), run the repository's checks (`nim r
  tools/drift.nim` in tabelline).
- Reply with one line per comment: its number, kind, what was done, or the question it raises.
  Don't skip a comment silently, and don't change what no comment asked for.
