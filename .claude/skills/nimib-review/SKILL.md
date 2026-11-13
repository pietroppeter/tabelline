---
name: nimib-review
description: Use when a review export from a nimib page is pasted in the chat (Markdown with a YAML block or front matter holding `format: nimib-review/1` to `/6`), to apply each comment to the page's source and close the review round, including a second or later round on the same version.
metadata:
  status: draft
---

# Apply a review export

The review mode of a nimib page (`nbReview` in tabelline's `docs/review.nim`) lets a reader
open the review with a button, select text, comment on it, and export every comment as one text:
a title, a YAML block (a ```yaml fence since `nimib-review/2`; a front matter between `---` lines
in `nimib-review/1`), then one Markdown section per comment, in page order. This skill turns that
text into changes.

## 1. Read the export

- The YAML says which page (`page`, its URL), which notebook builds it (`source`, a path
  in the repository), which `version` was read, the `commit` it was built from (`/4`), and how
  many `comments` there are. The version is the number of commits that changed the source (`12+`:
  built from uncommitted changes; 7 hex characters: built outside git). Check that the
  count matches the `## n.` sections: a long paste can arrive cut short, and the count is how you
  notice. If it does not match, say so.
- `round` and `sent` (`/6`): the reviewer sends a version's comments in rounds. **Copy** sends
  the comments of the export, which get their numbers then and keep them; the next export holds
  only what is new. `round: 2` and `sent: 4` mean comments 1 to 4 went in earlier rounds of this
  same version, and this one starts at 5. See step 2 for what that changes.
- Each section is `## n. Where` in `nimib-review/3` to `/6`: `In “Heading” (#id)`, `At the top`, or
  `On the whole page` (no quote: the note is about the page as a whole). Every comment is a note;
  a replacement is said in it, as `Replace with: ...`, or `Remove`. Do what the note asks.
- In `/1` and `/2` the section is `## n. Kind, where`:
  - `Comment`: do what the note asks.
  - `Replace`: replace the quoted text with the text in the `~~~text` fence; the note, if any,
    says why.
  - `Remove` (`Cut` in exports of version 3 and before): remove the quoted text and mend the
    sentence around it.
  A `/3` to `/5` export may still hold one of these, from a comment written on an older version.
- `· changed since round 1` after a heading (`/6`): a comment already sent, changed afterwards.
  It replaces what that number said before: do what it says now, and undo what the old text asked
  for if the new one asks for something else. `· sent in round 1` (an export of every comment,
  from History): already sent; check it was done, don't do it twice.
- `## 11.3.`: the third comment of version 11, in an export of every version.
- `From version 7 (commit a1b2c3d).` under a heading (`/5`): the comment was written on an older
  version than the export's, and kept in the browser (History's **Export** or **Export
  everything**). Check it before you apply it: see step 2.
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

When the export is a round after the first on the same version (`round: 2` or more, the same
`version` and `commit` as an earlier export in the chat), the earlier rounds are already applied
or being applied, and the page has not been rebuilt for the reviewer since: the quotes are from
the page as it was before your changes. So:

- Work on the same branch as the earlier rounds, and keep their changes. Read them first
  (`git diff <commit> -- <source>`, and what you said about them in the chat).
- A quote may be gone because an earlier round changed it: find the new text, and apply the
  comment to it if it still makes sense; say so in the reply.
- Numbers go on from the earlier rounds and never repeat on a version, so refer to comments by
  their numbers as given. A round that repeats a number already seen is a changed comment (its
  heading says so) or an export by hand: ask.
- A missing number between rounds is a comment the reviewer deleted before sending: nothing to do.
- In the reply, say which round it is and refer only to this round's comments.

When the export has a `commit`, first see what changed in the source since it was read:
`git log --oneline <commit>..HEAD -- <source>` and `git diff <commit> -- <source>`. A comment
on text that changed since may already be done, or need reading again.

A comment from an older version (`From version N`, or an export whose `version` is older than
the page's) needs checking before it is applied, because the page moved on since:

- Diff from the comment's own commit when it has one (`git diff <its commit> -- <source>`),
  else from the export's, else find the version's commit: the version is the number of commits
  that changed the source, so `git log --reverse --format=%h -- <source> | sed -n <N>p`.
- Still valid: the quote is still on the page and the note still asks for something not done.
  Apply it.
- Already done: the diff made the change it asks for. Say so, and change nothing.
- Moot: the text it is about is gone or rewritten (`(Not found on the page any more.)`, or the
  diff removed it). Say what became of that text, and ask only if the note still points to
  something worth doing.
- In the reply, list the older comments apart, each as valid (applied), already done or moot.

The quote is rendered text, not source. Search the notebook for it, and expect:

- Markdown marks gone: `**bold**`, `` `code` ``, `*em*` appear without their marks, a link shows
  only its text, a line break in the source is a space in the quote.
- Text made by code (a table, a generated list, the indice, a block of `blocks.nim` or
  `review.nim`) is not
  in the notebook's text: find the code or the data file that makes it.
- Text in a shared block (a header, a footer) is in `docs/blocks.nim`, which changes every page:
  say so before changing it.

## 3. Make the changes

Change the notebook named in `source`. There are no versions to keep: git keeps them, and the
commit that holds the changes is the page's next version (its comments start empty, and its
rounds start from 1 again). Commit each round on its own, so a later round can be read against
it.

The devlog post `review_mode` also keeps each round, as its own record, not a step for other
pages: the export, as pasted, in `docs/devlog/data/review-mode/round-<n>.md`, and a line in
`review_mode/storia.nim` for the new version (the date, what the round changed) with how many
comments the round had and what they found. Its versions 1 to 8 were a notebook each
(`review_mode/vN.nim`, in git at commit 64f87e2); exports of those name that file as `source`:
the post is now `docs/devlog/review_mode.nim`.

## 4. Build, check, report

- Rebuild the page, check it at 390px in Munari (the quaderno only when the change might affect it), run the repository's checks (`nim r
  tools/drift.nim` in tabelline).
- Reply by theme, not in the order of the comments: group the comments that ask for related
  changes, and for each theme say what was asked (with the comments' numbers) and what changed,
  or the question it raises. Comments that only say something works go in a section of their
  own at the end. Every comment is in the reply once; don't skip one silently, and don't change
  what no comment asked for.
