## MODIFIED Requirements

### Requirement: The export
**Export** SHALL give one text: a title, a ```yaml block (`format: nimib-review/6`, `title`,
`page`, `source`, `version`, `commit`, `round` and `sent` when there are rounds, `exported`,
`comments`), then one section per comment in the order of the page (`## n. In “Heading” (#id)`,
`## n. At the top`, `## n. On the whole page`) with the quote, the words around it and the note.
A comment written on another version than the exported one SHALL say `From version N (commit c).`
under its heading, and one whose words the page no longer has SHALL say
`(Not found on the page any more.)`. Each screenshot SHALL be named in its note and have its own
**Copy image**. **Copy** SHALL copy the text only. The export SHALL also have **History**,
**Delete** and **Close review**.

#### Scenario: An agent knows what changed
- **WHEN** an export of version 12 (commit `a1b2c3d`) is pasted after the page reached version 14
- **THEN** the agent can see what changed since the review with `git diff a1b2c3d -- <source>`

### Requirement: History
**History** SHALL list the versions of the page that have comments in this browser, this one
first, then the others newest first, each with its number of comments (and how many are sent) and
**Clear** (which asks with a second tap). Its **Export** SHALL export every comment of this
version, sent or not. An older version SHALL also have **Bring here**, which moves to this version
its comments on the whole page and those whose words this version still has, as comments not sent
yet, and keeps the others on their version, and **Export**, which exports its comments. **Export everything** SHALL
export the comments of every version of the page.

#### Scenario: Comments on an old build
- **WHEN** the page is at version 14 and the browser keeps comments on version 12
- **THEN** History lists version 12 with its comments, and Clear deletes them

#### Scenario: Bringing comments to the new version
- **WHEN** version 12 has three comments, and version 14 still has the words of two of them
- **THEN** Bring here moves those two to version 14 and keeps the third on version 12, and
  Export everything exports all three, the third marked as not found

## ADDED Requirements

### Requirement: Rounds
Copying an export SHALL send the comments of this version that it holds: each comment SHALL get
its number when it is first sent, the next after the last number given on this version, and keep
it. **Export** SHALL then hold only the comments not sent yet and those changed since they were
sent, under their old number, with `· changed since round N` in the heading; its round SHALL be
the last round sent plus one, in the title and in `round`, and `sent` SHALL be the last number
sent before it. A number SHALL never be given twice on a version, even when the comments sent are
deleted. A comment sent SHALL stay marked on the page, quieter, and its comment box SHALL say its
number and round.

#### Scenario: A second round on the same version
- **WHEN** a reader copies an export of four comments, then writes three more on the same version
- **THEN** the next export is round 2, holds only the three new comments, numbered 5, 6 and 7,
  and says `sent: 4`

#### Scenario: Comments sent, then deleted
- **WHEN** a reader sends comments 1 to 4, deletes them, and writes a new comment
- **THEN** the new comment is number 5

### Requirement: Deleting from the export
**Delete**, beside **History** in the export, SHALL delete the comments the export holds, after a
second tap that confirms.

#### Scenario: Clearing what was sent
- **WHEN** a reader opens History's Export, then taps Delete twice
- **THEN** every comment of this version is deleted, and the next comment takes the next number
