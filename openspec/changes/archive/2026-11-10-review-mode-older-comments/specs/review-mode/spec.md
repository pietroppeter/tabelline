## MODIFIED Requirements

### Requirement: The export
**Export** SHALL give one text: a title, a ```yaml block (`format: nimib-review/5`, `title`,
`page`, `source`, `version`, `commit`, `exported`, `comments`), then one section per comment in the
order of the page (`## n. In “Heading” (#id)`, `## n. At the top`, `## n. On the whole page`) with
the quote, the words around it and the note. A comment written on another version than the
exported one SHALL say `From version N (commit c).` under its heading, and one whose words the
page no longer has SHALL say `(Not found on the page any more.)`. Each screenshot SHALL be named
in its note and have its own **Copy image**. **Copy** SHALL copy the text only. The export SHALL
also have **History** and **Close review**.

#### Scenario: An agent knows what changed
- **WHEN** an export of version 12 (commit `a1b2c3d`) is pasted after the page reached version 14
- **THEN** the agent can see what changed since the review with `git diff a1b2c3d -- <source>`

### Requirement: History
**History** SHALL list the versions of the page that have comments in this browser, this one
first, then the others newest first, each with its number of comments and **Clear** (which asks
with a second tap). An older version SHALL also have **Bring here**, which moves to this version
its comments on the whole page and those whose words this version still has, and keeps the
others on their version, and **Export**, which exports its comments. **Export everything** SHALL
export the comments of every version of the page.

#### Scenario: Comments on an old build
- **WHEN** the page is at version 14 and the browser keeps comments on version 12
- **THEN** History lists version 12 with its comments, and Clear deletes them

#### Scenario: Bringing comments to the new version
- **WHEN** version 12 has three comments, and version 14 still has the words of two of them
- **THEN** Bring here moves those two to version 14 and keeps the third on version 12, and
  Export everything exports all three, the third marked as not found
