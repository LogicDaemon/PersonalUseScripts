---
description: update jujutsu description if jujutsu vcs is used
applyTo: '*'
---
If there is a `.jj` subdir in the workspace root, the repository is using jujutsu vcs.
The main loop is following:
1. `jj new` or `jj new -c 'a git commit-like-message'` to create a new change. `jj describe -m 'a git commit-like-message'` anytime allows updating the message of the current commit
2. Make the changes as you go, check `jj diff --no-pager` or `jj st --no-pager` periodically, this records the changes history (no need for explicit commit)
there is no step 3.

`jj abandon` is like `git reset --hard HEAD^`
Run `jj describe -m 'a brief commit-like description here'` after successfully completing a change (not after every edit, but when you finish), if the current message is outdated.
Run `jj new` when trying any new approach, starting a task, or switching to a next step of a task.
Use `jj diff --no-pager`, `jj history --no-pager`, `jj status --no-pager` (or `jj st --no-pager`) instead of `git`.

`jj help --no-pager` and `jj help -k tutorial --no-pager` for more details or if you want to check/restore some files.

NEVER remove or change bookmarks you did not create unless explicitly requested. Yes, even after rebasing or otherwise rewriting history.
