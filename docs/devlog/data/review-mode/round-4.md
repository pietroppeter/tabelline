# Review of “Review mode”, version 4

```yaml
format: nimib-review/2
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode/v4.nim"
version: 4
exported: "2026-11-09T13:48:25.831Z"
comments: 6
```

## 1. Comment, in “Review mode”

> Review mode

Around it: “… 9 November 2026 · version 4 ⟦Review mode⟧ Reviewing a page on a phone t…”

Unrelated to this specific piece of text. How do we add a comment that is not tied to a specific place in the document? Propose and implement a solution

## 2. Comment, in “Review mode”

> New in version 4

Around it: “…s v4 9 Nov 2026 v3 9 Nov 2026 ⟦New in version 4⟧ Round 3: an image pasted in the…”

In the version recap here let’s number the changes (it could be a numbered list)

## 3. Comment, in “Review mode”

> Round 3

Around it: “…3 9 Nov 2026 New in version 4 ⟦Round 3⟧: an image pasted in the note ju…”

Round 3 is confusing for a version 4, I think we can skip it

## 4. Comment, in “Review mode”

> an image pasted in the note just works

Around it: “…026 New in version 4 Round 3: ⟦an image pasted in the note just works⟧, no buttons; Delete in the top …”

Screenshots: review-v4-4-1.jpg

## 5. Comment, in “The problem” (#the-problem)

> A review mode keeps the whole review on the page and makes one trip at the end: select, comment, and when the reading is done, export everything at once. The agent gets one text that says which page, which version, and what to change where, in the order of the page.

Around it: “…. Ten comments are ten trips. ⟦A review mode keeps the whole review on the page and makes one trip at the end: select, comment, and when the reading is done, export everything at once. The agent gets one text that says which page, which version, and what to change where, in the order of the page.⟧ What the review mode assumes …”

Is this the summary of the solution? Should it have its own heading? We should mention screenshots, since we now have a working solution

## 6. Comment, in “What the review mode assumes” (#what-the-review-mode-assumes)

> The first pass was built without questions, so its choices are written down here, to be changed by the reviews. Round 1 changed the fifth and added the ninth, round 2 changed the fifth again and the sixth, round 3 the fourth, the fifth and the ninth:

Around it: “… What the review mode assumes ⟦The first pass was built without questions, so its choices are written down here, to be changed by the reviews. Round 1 changed the fifth and added the ninth, round 2 changed the fifth again and the sixth, round 3 the fourth, the fifth and the ninth:⟧ One reviewer, one browser. T…”

Unclear this part, assumes context on reader’s part
The list below seems like a list of decision records. Are these some kind of principles that we are accumulating that are the bases of our solution?

<!-- Comment 4 is the test of round 3's paste (a screenshot of the same words, no note): it
showed that pasting an image in the note works on an iPhone. -->
