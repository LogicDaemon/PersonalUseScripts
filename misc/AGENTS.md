# GitHub Copilot Instructions

- Avoid AI sycophancy. Even if there could be multiple views or the user gets easily offended, at least express a mild doubt
  * NEVER say "You’re absolutely right", "Good point", "you’re right that" etc. No such introductions are allowed at all! Only dry objective facts
  * Avoid adjectives and adverbs, especially emotional ones
- Avoid `run_in_terminal` when more targeted tool is available:
  * `read_file` not `cat`
  * `list_dir` not `ls`
  * `file_search`, `grep_search`, `semantic_search` instead of `grep`
  * `replace_string_in_file` not `sed`
  * etc: `create_directory`, `create_file`, `fetch_webpage`, `get_changed_files`, `get_errors`, `list_code_usages`
- When `run_in_terminal` is necessary, prefer Python over shell commands
- If there is a `.jj` subdir in the workspace, run `jj describe --no-pager -m 'add a brief description here'` after every change
- Do not commit anything to git unless requested to. Before committing, run `git status` and `git diff` to ensure only the intended changes are included
- If you patched a file, do not reiterate your changes in the response; better re-read the file to ensure your changes are good
## If multi-root worspace:
- Check the current directory (`pwd`) or execute `cd` before the shell commands, do not assume the default directory is what you expect

## Coding Conventions
- Do not remove comments you did not add
- Avoid Speculative Safety: evaluate code by context, not hypothetical reuse (e.g. python aliasing is acceptable if it works)
- No Premature Generalization
- When updating the repository, check and update documentation to reflect any changes in architecture or conventions
  * But keep it concise. Document nuances that are not obvious from scanning the code, but skip trivia or restating implementation details visible in the modules
  * Prefer inline documentation over separate files, except when those files already exist or explicitly requested

## Complex tasks approach
- Create a `.github/tasks/<name>.md` file with:
  1. End goal
    * Do not update the goal: if the goal shifts/does not match anymore for any reason, create a new task file
  2. Starting state, constraints (but do not reiterate instructions or skills)
  3. Failed attempts: what has been tried already (if applicable). This should be updated as you learn more, and must be updated after each failed attempt
  3. Step-by-step plan, each step with a verifiable outcome.
- Treat the file as your help when the chat history is wiped or compacted. Write exact values, paths, mistakes and solutions (working commands), not some vague descriptions.
- After implementing each step, mark it as "verifying" and test (or ask the user to test with exact instructions).
  * If it works, mark it as "done", deduplicate failed attempts and plan, then proceed to the next step.
  * If it doesn't work:
    1. Update the failed attempts, remove the failed step from the plan
    2. Undo changes from the failed step
- When starting/continuing a task, review the file and re-analyze the repository contents to understand the context and avoid repeating past mistakes, and to check if the file is up-to-date
- ONLY when the task is done AND you got the user's confirmation, append the summary to the file. If the task appears incomplete but the task file has summary, move new information from it (if any) to failed attempts to avoid repeating the mistake, and remove the summary.
