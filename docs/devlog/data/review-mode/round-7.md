# Review of “Review mode”, version 7

```yaml
format: nimib-review/3
title: "Review mode"
page: "https://ef828b87-e6b5-4cc9-b7e4-3250b16d01e4.frame.claudeusercontent.com/_f/1794285081-80d3/"
source: "docs/devlog/review_mode/v7.nim"
version: 7
exported: "2026-11-10T05:11:05.968Z"
comments: 22
```

## 1. On the whole page

Starting testing this version with a page note

## 2. On the whole page

Adding a second page not now (where will it appear in the order of comments? I have a one page note and two comments the moment I am adding this).

Once I finished adding content for a note I should tap outside of it and it should stay selected, I think. Although it does take a bit of release estate in the phone. Right now I end up only with bottom row and to select last comment I do a bit of back and forth with arrows.

Not sure what is ideal here

## 3. On the whole page

No ok I like it like it is now, I can see how it passes from comment/page note selected (eg 3/4) to a count of all comments and no top text box.

## 4. At the top

> 9 November 2026 · updated 10 November 2026

Around it: “… ⟦9 November 2026 · updated 10 November 2026⟧ Review mode Reviewing a pag…”

I am still not happy about this appears. Research what are common ways to show a created at and last updated at field for a document and give me options

Screenshots: review-v7-4-1.jpg

## 5. In “Review mode”

> Select a few words

Around it: “… You are reviewing this page ⟦Select a few words⟧ and tap Comment ✓ in the bar at…”

Second thing to test the review: add this comment

## 6. In “Two modes” (#two-modes)

> Two modes

Around it: “…find again, and to hand over. ⟦Two modes⟧ A page with the review mode i…”

Not descriptive of what is in this section: try to improve

## 7. In “The decisions behind it” (#the-decisions-behind-it)

> A decision that a round changed says so at its end;

Around it: “…tays until a review changes it. ⟦A decision that a round changed says so at its end;⟧ the table of Versions and round…”

Didn’t we mention before that we are skipping this part?

## 8. In “The pieces of the screen” (#the-pieces-of-the-screen)

> The pieces of the screen

Around it: “…review mode follow the site. ⟦The pieces of the screen⟧ Two screens of this page on a…”

This should be before the diagrams of two modes section which is a deep dive on states. We should mention before this the enter/exit review mode

## 9. In “The pieces of the screen” (#the-pieces-of-the-screen)

> Two screens of this page

Around it: “…. The pieces of the screen ⟦Two screens of this page⟧ on a phone, while reviewing, wi…”

We are not showing the history screen. Let’s make each screenshot a card in a gallery and let’s keep in the card the elements for that specific screenshot. Each card has a title and its numbering starts from 1

## 10. In “The pieces of the screen” (#the-pieces-of-the-screen)

> Also in the bar

Around it: “…, and closes it (Close review). ⟦Also in the bar⟧, to close the review from the b…”

Not in the bar we do not have room, we could have it in export mode

## 11. In “The pieces of the screen” (#the-pieces-of-the-screen)

> sheet

Around it: “…xport Opens the export. 7 The ⟦sheet⟧ The comment open, at the top: a…”

Why is it called the sheet and not text input or something?

## 12. In “Processing an export: a skill” (#processing-an-export-a-skill)

> to Pietro's skills

Around it: “…repository for now (it can move ⟦to Pietro's skills⟧ once it works). read the YAM…”

Replace with: elsewhere

## 13. In “Processing an export: a skill” (#processing-an-export-a-skill)

> keep the version that was reviewed, and make the changes in a new one;

Around it: “…not written in the notebook); ⟦keep the version that was reviewed, and make the changes in a new one;⟧ save the export with the page…”

Right now we keep each version but we might change that later (after all the versions are in git), this should be optional?

## 14. In “Processing an export: a skill” (#processing-an-export-a-skill)

> save the export with the page's data, and add the round to the page's record;

Around it: “…ake the changes in a new one; ⟦save the export with the page's data, and add the round to the page's record;⟧ rebuild, check on a phone, an…”

This is it only optional but I guess it is a unicum for this page? I guess it should not be in the skill

## 15. In “Processing an export: a skill” (#processing-an-export-a-skill)

> with one line per comment

Around it: “…d, check on a phone, and answer ⟦with one line per comment⟧: done, or the question it raise…”

Giving context amid what change was asked. Also if it is easier to understand we should group related changes together regardless of order. If there are comments which are just feedback on something that worked it should be a separate section too

## 16. In “Versions and rounds” (#versions-and-rounds)

> table

Around it: “…out the review mode, it keeps a ⟦table⟧ of its versions and of what eac…”

This table is unreadable

Screenshots: review-v7-16-1.jpg

## 17. In “Where it lives” (#where-it-lives)

> blocchi

Around it: “… File What it holds docs/⟦blocchi⟧.nim The blocks: nbRevisione tur…”

Let’s make a sapevate module for this and let’s put the names in English. When all of this is done it will be probably moved in nimib core (or in some extra but I think nimib core is best)

## 18. In “Where it lives” (#where-it-lives)

> the styles

Around it: “… docs/stile.nim revisioneCss, ⟦the styles⟧, from the page's colours, added…”

Style for review mode could be in the same module as the block for now

## 19. In “A page with the review mode” (#a-page-with-the-review-mode)

> import nimib except md

Around it: “… mode needs only the blocks): ⟦import nimib except md⟧ import tabelline/nimib import b…”

This is not a note for tabelline but for nimib. I think it is time to remove the Md thing from nimib. Not useful anymore (who looks at editor anymore? Too valuable a name to use it on highlighting with nimiboost)

## 20. In “A page with the review mode” (#a-page-with-the-review-mode)

> nbRevisione

Around it: “…"Some text to review." nbSave ⟦nbRevisione⟧ turns the review mode on: its p…”

I do not understand what notes is and I guess this is over complicated by the fact that we need to keep track of history. Explain to me better this Ali and let’s think of a better solution together

## 21. In “A page with the review mode” (#a-page-with-the-review-mode)

> blocks of the review mode (

Around it: “…hem. The blocks, in full: The ⟦blocks of the review mode (⟧docs/blocchi.nim) func versioneH…”

This looks bad, see also related comment on folded code

Screenshots: review-v7-21-1.jpg

## 22. In “The script” (#the-script)

> Where a

Around it: “…each, and clears them. 82 ⟦Where a⟧ comment points // A comment poi…”

This whole section should read more like show code stuff. It is foldable code. Styling here is too much like a section title and the fold not fold is not a clear element visible

Screenshots: review-v7-22-1.jpg

<!-- The four screenshots are round-7-4-1.png, round-7-16-1.png, round-7-21-1.png and round-7-22-1.png.
Comment 4: Pietro chose, on a card, "Updated, beside the version". Comment 19 went to its own
thread, "Remove md template from nimib". -->
