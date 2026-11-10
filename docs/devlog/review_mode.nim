## devlog: 09 Nov 2026 A | Review mode | Reviewing a page on a phone takes screenshots, notes and many trips between the page and the chat. A review mode for nimib pages: select text, comment, go through the comments with a bar, export them in one text to paste in the chat. The post is reviewed with itself, round by round, and keeps every version.
## The post changes in review rounds, and keeps every version: one notebook per version in
## review_mode/ (v1.nim, v2.nim, ...). The newest is the post (devlog/review-mode/), each older one
## is kept as it was in devlog/review-mode/vN/. A new round: copy the newest to the next number,
## add its line to review_mode/storia.nim and import it here.
{.warning[UnusedImport]: off.}
import review_mode/[v1, v2, v3, v4, v5, v6, v7]
