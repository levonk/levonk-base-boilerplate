---
description: Commit uncommitted changes
---


1. Look at the files within all repositories that have been changed and not committed.
2. run any registered linter, formatter, and finally unit tests.
2. Understand the changes, and try to group them in unique changesets that make sense so multiple changes get multiple commits. e.g. changes to login page, and it's associated documentation is one commit, and changes to catalog browsing and it's associated database files is a different commit.
3. Title each commit with the following
  a. a short prefix to identify the type of change e.g. is it a feat[ure], fix, new, doc, test, chore, refactor
  b. a hyphen to separate the the type, from the scope which follows
  c. a short name that represents scope of the change. e.g. feat-build, fix-login, etc..
  d. a colon followed by a space, an a short synopsis of the change
  e. the title should be no longer that 50 characters. Use contractions, and other tricks to shorten the title to below <50 characters. An example would be `feat(search): added filters for user`
4. A body that explains the change in more detail, wrapped at 72 characters per line
5. A footer that references any bug base tickets, story IDs
6. summarize what you did, and if anything needs the USER's attention.

## Guidelines
- Use the imperitive mood: "Add checkbox" not "Added checkbox"
- Be specific: "fix overflow in sidebar menu" is better than "fix bug"
- Explain the why: Not just what changed, but why it was needed.
- Avoid filler Skip vague phrases like "oops" or "maybe fixed"
- Capitalize the subject and omit punctuation
- Avoid commiting half done work
- If you aren't 96% confident you understand the change, ask for clarification.


4. After all commits are processed, summarize what you did, and which comments need the USER's attention.