---
description: Promote the code to the next level of deployment e.g. dev->stage or stage->qa or qa->prod
---

1. make sure everything is committed, if there are files that need to be added or committed, notify the user you can't proceed and the reason why
2. update the minor version number of the application.
3. examine git history between the last version tag, and this tag. Add a summary of the changes as bullets into internal-docs/changelog/changelog-version.md
4. rebase the higher enviornment onto the lower environment if necessary (e.g. git checkout env/dev && git rebase env/stage). resolve any conflicts if you can.
5. run formatter, linter, unit tests, security scans, and any other scans. If any fail, notify the user you can't proceed and the reason why
6. /commit those two changes.
7. tag the repository with the version of the application in the tag/v/app/{my-frontend} path with the short name of the application an underscore then the version number if it doesn't already exist. E.g. {my-frontend}_4.3.2 (e.g. git tag tag/v/app/backend_4.6.8 followed by git push origin tag/v/app/backend_4.6.8)
8. tag the repository with the version and the level of the deployment (the env/branch you're on) with tags/v/{level of deployment short code}/{my-frontend}_4.3.2
9. checkout the branch that's at the next level of deployment the repository is configured with, e.g. branch u/{username}/env/dev -> branch env/dev, env/dev -> env/stage, env/stage -> env/qa, env/qa -> env/prod
10. merge the previous branch into this branch. If there are ny 
11. run formatter, linter, unit tests, security scans, and any other scans. If any fail, notify the user you can't proceed and the reason why
12. summarize what you did, and if anything needs the USER's attention.
