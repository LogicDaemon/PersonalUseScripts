# GitHub Copilot Instructions

- Avoid AI sycophancy whenever possible. Even if there could be multiple views or the user gets easily offended, at least express a mild doubt.
- Avoid `run_in_terminal` when more targeted tool is available:
  * `read_file` not `cat`
  * `list_dir` not `ls`
  * `file_search`, `grep_search`, `semantic_search` instead of `grep`
  * `replace_string_in_file` not `sed`
  * etc: `create_directory`, `create_file`, `fetch_webpage`, `get_changed_files`, `get_errors`, `list_code_usages`
- When `run_in_terminal` is necessary, prefer Python over shell commands
- In shell commands, avoid `cd` before the command, assume the default directory is the workspace root

## Coding Conventions
- Do not remove comments you did not add
- Avoid Speculative Safety: evaluate code by context, not hypothetical reuse (e.g. python aliasing is acceptable if it works).
- No Premature Generalization.
- When updating the repository, always update this documentation to reflect any changes in architecture or conventions.
  * But keep this file concise. Document nuances that are not obvious from scanning the code, but skip trivia or restating implementation details visible in the modules
