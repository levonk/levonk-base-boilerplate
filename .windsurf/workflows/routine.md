---
description: Perform routing tasks on the project
---

1. run formatter, linter, unit tests, security scans, and any other scans. If any fails, notify the user you can't proceed and the reason why
2. make sure everything is committed, if there are files that need to be added or committed, notify the user you can't proceed and the reason why
3. Update any dependencies that have a newer MINOR version (e.g. 4.1.2 -> 4.3.6 is okay, 4.1.2 -> 5.0.1 is NOT okay)
4. run formatter, linter, build, unit tests, security scans, and any other scans. If any fails, notify the user you can't proceed and the reason why
5. run the /commit workflow to commit the upgraded dependencies.
6. summarize what you did, and if anything needs the USER's attention.
