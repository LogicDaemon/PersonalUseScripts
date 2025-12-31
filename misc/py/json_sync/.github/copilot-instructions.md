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

### Python:
  - Use single quotes for strings
  - Prefer r-strings over escaping backslashes
  - Docstrings keep triple double-quotes with a one-line summary followed by optional details. Use """ text """ formatting, with spaces around and without final `.`
  - Type-annotate, except variables which type is derived from the expression
    * `root = Path(__file__).parent` does not need annotation
    * `var = function()` MUST not be annotated, but the function must be
  - Always type-annotate the variable when assigning literal containers (e.g. `d: Dict[str, int] = { ... }`)
  - Prefer `typing` classed such as `List`, `Dict`, `Optional` over built-in generics
  - Use `assert` (not `if`) for sanity and type checks
  - To build strings, use concatenation for 2 parts, f-strings for ≥3 (if the resulting line is too long, split it using implied concatenation or switch to explicit contatenation from f-strings, whichever is shorter), and lazy formatting for functions which may avoid templating the string (ex. logging)
  - Types must be public
  - Avoid unnecessary "stabilization" like sorting, `.get()`, `path.resolve()`, `str(value)`, `if bool(var)` unless there is a specific need. Every method/call has a cost and thus should be justified.
  - Prefer direct checking `if var` over expressions, except:
    * `is [not] None`
    * when the value needs to be reused in the if body, but nowhere else — use `if var := expr`.
  - Avoid single-use variables, especially before `return`, `if` or a function call, unless the line is too long or expression is overly complex (multiple brackets, etc).
  - Do not hide output of subprocess calls (no stderr=subprocess.DEVNULL). If it corrupts display, capture it and output in a file.
  - Let `problems` tool or Pylance MCP surface syntax issues
  - Avoid `dict.keys()` unless it's performance-optimal (avoids copying)

#### Functions:
  - Avoid:
    * passing in arguments to another function without additional logic
    * functions calculating a single expression and only used once
    * inner functions (except to avoid creating a single-use context object)
  - If there are more than 3 parameters passed over to (or through) multiple functions, use NamedTuple or dataclass (if mutable)
  - If a function returns more than 2 values, or 2 values of of same type, use NamedTuple
  - Never introduce wrappers just to pass same parameters; use functools.partial or lambdas when passing to higher-order functions

#### Exceptions:
  - Exceptions over checking first (EAFP over LBYL)
  - Do not catch what you cannot handle or which are of not a concern of the scope
  - Do not catch for logging, except in functions called in `threading.Threads`
  - Python logs unhandled exceptions, no need to duplicate

### Github Actions Workflows:
  - Prefer `hashicorp/vault-action` for secret retrieval over manual CLI commands.
    * Use [RFC021: Leveraging Hashicorp Vault as a Secret Store via GitHub Actions](https://intermedia.atlassian.net/wiki/spaces/IDP/pages/1003978867/) as an example for secret management. Note that RFC refers a PSA vault which may be different from what this repository use.
  - Define static environment variables in the YAML `env` block rather than using `echo "..." >> $GITHUB_ENV` in run steps.
