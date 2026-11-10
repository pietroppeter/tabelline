# Review of “Review mode”, version 6

```yaml
format: nimib-review/2
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode/v6.nim"
version: 6
exported: "2026-11-10T04:17:13.205Z"
comments: 27
```

## 1. Comment, on the whole page

You know what? Let’s remove the replace option altogether. To replace (or remove/cut) we just say replace with (or remove).
Also adapt the rest of the page to this change.

## 2. Comment, on the whole page

We are changing a lot in this review, by adding a review mode. Try to rethink everything from scratch, make diagrams of the different modalities and map all user stories that the review mode enables

## 3. Comment, at the top

> version 6

Around it: “… 9 November 2026 · ⟦version 6⟧ Review mode Reviewing a pag…”

We need to change how review mode appears and have an option to enter/exit review mode. The part above the title (A in screenshot) should have: the day of the post/document creation (for stuff that is not a post). If there was at least on change or review that changed it it should have a last updated field. It should have also the number of version and an option to enter review mode (a button keep the styling not too heavy, it should be understandable that it is some kind of change). The same button will exit the reeview mode. Probably the version and the button should go where area B in screenshot now is. We do not need to show the link to previous version anymore. We should have a separate way to view revision history.
When we are not in review mode we should see no UI for the review mode.
Also the new in version should appear only in review mode

Screenshots: review-v6-3-1.jpg

## 4. Replace, in “The problem” (#the-problem)

> ten trips

Around it: “…chat and back. Ten comments are ⟦ten trips⟧. The idea A review mode kee…”

Replace with:

~~~text
ten trips
~~~

ten round trips

## 5. Replace, in “The decisions behind it” (#the-decisions-behind-it)

> The first version made them all without asking anyone, and every review round since has tested them; a decision that a round changed says so at its end.

Around it: “…tays until a review changes it. ⟦The first version made them all without asking anyone, and every review round since has tested them; a decision that a round changed says so at its end.⟧ The table of Versions and round…”

Replace with:

~~~text
The first version made them all without asking anyone, and every review round since has tested them; a decision that a round changed says so at its end.
~~~

## 6. Comment, in “The decisions behind it” (#the-decisions-behind-it)

> The table of Versions and rounds has what each round asked.

Around it: “…und changed says so at its end. ⟦The table of Versions and rounds has what each round asked.⟧ One reviewer, one browser. T…”

I have removed the sentence before (also to test replace without text, adapt this

## 7. Comment, in “The decisions behind it” (#the-decisions-behind-it)

> Share sends the text as a file, with the screenshots at full size, to an app such as Claude

Around it: “…xt in its box and copy by hand. ⟦Share sends the text as a file, with the screenshots at full size, to an app such as Claude⟧. Changed in rounds 1, 2 and 3. …”

I have not tested this yet, let’s try it

## 8. Comment, in “The simplest review: one comment” (#the-simplest-review-one-comment)

> Select ten trips in the first section

Around it: “…comment or replace) and a note. ⟦Select ten trips in the first section⟧, tap Comment ✓, choose Replace,…”

This has been tested so you will need to adapt this.

## 9. Comment, in “Keeping the comments” (#keeping-the-comments)

> he comments of a page are kept in the browser

Around it: “…lace. Keeping the comments T⟦he comments of a page are kept in the browser⟧, under one key per page and ver…”

How can we remove all comments and start from scratch?

## 10. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> Should a comment on the whole page show somewhere on it?

Around it: “…, its words are marked already. ⟦Should a comment on the whole page show somewhere on it?⟧ 2 ‹ › and the count In the ba…”

I do not know and with the whole changes we are doing it is unclear to me how to handle page notes anymore.

## 11. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> Could the bar fold away while reading, and show only the count?

Around it: “…er of the page; 2/5 says which. ⟦Could the bar fold away while reading, and show only the count?⟧ 3 Edit Opens the comment the …”

No but as stated the bar should be present only when review mode is active

## 12. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> Unclear in round 1:

Around it: “…yed out until they stop on one. ⟦Unclear in round 1:⟧ should it say Open 2 instead? …”

Now it is fine, point is closed

## 13. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> The sheet's first row

Around it: “…ort Opens the export sheet. 6 ⟦The sheet's first row⟧ × to cancel, the kind (comment …”

Without replace kind we can skip the first row. Save should be done anyway without asking. X should not be needed since this part should be visible when there is a comment with last comment selected and we do not need also the edit mode, when a comment is specter we are in edit mode. This also means that arrow and everything else keeps working when this part above is present

## 14. Replace, in “The pieces of the screen” (#the-pieces-of-the-screen)

> For a replacement, a second field above it holds the new text

Around it: “…te What should change, and why. ⟦For a replacement, a second field above it holds the new text⟧, starting from the words select…”

Replace with:

~~~text
For a replacement, a second field above it holds the new text
~~~

This is unclear, in my earlier test of replace I thought the second field was the replaced text (I will now go back and change it). The text in the second field (the one that disappears when you input something (remind me what it is called), should explicitly say: change the text above to what the replacement should be (empty for removing this part) and optionally add a note explaining the replacement here.
Also can we add a feature so that when I tap on a screenshot, here or in the export screen, a modal opens up with the image seen bigger (with x to close again)

Screenshots: review-v6-14-1.jpg

## 15. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> Draw on a screenshot, to circle what is wrong?

Around it: “…there only when there are some. ⟦Draw on a screenshot, to circle what is wrong?⟧ 9 The export text Every comme…”

No not needed native screenshot taking takes care of that (on iOS, I am assuming on android too but for the moment I do not care too much)

## 16. Comment, in “The pieces of the screen” (#the-pieces-of-the-screen)

> Clear all

Around it: “…Clear after Share, or ask? 12 ⟦Clear all⟧ Deletes every comment of this v…”

Instead of clear all we should have a button to enter version history a new mode where we can change versions and clear comments from local storage of a specific version (or clear everything from local storage). From version history mode we should be able to go back to export mode

## 17. Comment, in “The bar” (#the-bar)

> Once a page has review mode, a bar stays at the bottom of the screen while it scrolls:

Around it: “… line under it. The bar ⟦Once a page has review mode, a bar stays at the bottom of the screen while it scrolls:⟧ ‹ and › go to the previous a…”

This has been changed. A page that has review mode has a way to enter review mode and when you enter you see the bar below

## 18. Comment, in “The export” (#the-export)

> Up to version 3 the YAML was a front matter,

Around it: “…lacement in a fence of its own. ⟦Up to version 3 the YAML was a front matter,⟧ between two --- lines: round 3 …”

When we apply the change we do not need to explain the change here in the page. The page has the current state. We already have a section at the end for what changed each round

## 19. Comment, in “Processing an export: a skill” (#processing-an-export-a-skill)

> In short

Around it: “…Pietro's skills once it works). ⟦In short⟧: read the YAML block (or the…”

Is this the full version or a summary? Where can I find the full version?

## 20. Comment, in “Processing an export: a skill” (#processing-an-export-a-skill)

> read the YAML block (or the front matter, before version 4), and check that the number of comments matches;

Around it: “…ls once it works). In short: ⟦read the YAML block (or the front matter, before version 4), and check that the number of comments matches;⟧ find each quote in the source…”

Why is this important?

## 21. Comment, in “Processing an export: a skill” (#processing-an-export-a-skill)

> find each quote in the source, knowing that it is rendered text (no Markdown marks, and the text of a table is made by code, not written in the notebook); keep the version that was reviewed, and make the changes in a new one; save the export with the page's data, and add the round to the page's record; rebuild, check on a phone, and answer with one line per comment: done, or the question it raises.

Around it: “…e number of comments matches; ⟦find each quote in the source, knowing that it is rendered text (no Markdown marks, and the text of a table is made by code, not written in the notebook); keep the version that was reviewed, and make the changes in a new one; save the export with the page's data, and add the round to the page's record; rebuild, check on a phone, and answer with one line per comment: done, or the question it raises.⟧ Versions and rounds This p…”

Let’s review all of this in the chat, I am not sold

## 22. Comment, in “Versions and rounds” (#versions-and-rounds)

> Every version is in the table below, linked

Around it: “… between them is a short slide. ⟦Every version is in the table below, linked⟧. Each version is a notebook of …”

This is something that we will have only in this page (a document section with a table full of changes. In normal review mode we will have review history mode

## 23. Comment, in “How it is built” (#how-it-is-built)

> Three pieces:

Around it: “…ound. 0 How it is built ⟦Three pieces:⟧ a block that puts the review mo…”

This should start with the most important piece of context: this is only possible because of nimib! (Well someone could implement in other frameworks but here it is implemented in nimib. See also other comments in this section on how to improve. Start with overview of modules/files where the revision mode is implemented, how an example file would change, then explain the new blocks/commands, then the js part.. do it limit yourself to using the three part rule ;)

## 24. Comment, in “How it is built” (#how-it-is-built)

> the script is inlined in the page, which stays one standalone file.

Around it: “…thing is loaded from elsewhere: ⟦the script is inlined in the page, which stays one standalone file.⟧ The block A page turns the …”

We should have an option to have the script as an assets when we add review mode on every page.

## 25. Comment, in “The block” (#the-block)

> A page turns the review mode on

Around it: “… standalone file. The block ⟦A page turns the review mode on⟧ with one line after useTabellin…”

How does a page turns revision mode on? A new command? This command should also have option to add review mode only for this page - with script inlined, or be based on a shared script

## 26. Comment, in “The script” (#the-script)

> about three hundred lines of plain JavaScript

Around it: “…ipt docs/assets/revisione.js, ⟦about three hundred lines of plain JavaScript⟧ with no dependencies, in six pa…”

Is it overkill to try and have this already in Nim? If we have it in Nim should it be compiled in danger mode to strip more stuff? Anyway explain what each part does ina synthetic way (since we are in tabelline, so it with a table) and then the code below for each part should be folded

## 27. Comment, in “The versions” (#the-versions)

> nbVersioni

Around it: “… show(); })(); The versions ⟦nbVersioni⟧ draws the strip at the top from…”

Is this everything? Show me how a simple nimib document activates review mode. Also show me where the implementation resides in terms of file. Is it a module.

<!-- Saved with this round: the result of comment 7, sent in the chat before the export.
Pietro tried Share on the iPhone: the export reached Claude as a .md file with both screenshots
at full size, but the iOS share sheet always opens a new Claude session; it cannot pick a project
or a thread, so the review lands outside the project. Decision: remove Share; Copy, open the
thread, paste, and attach the screenshots from Photos. The two screenshots are
round-6-3-1.png (review-v6-3-1) and round-6-14-1.png (review-v6-14-1). -->
