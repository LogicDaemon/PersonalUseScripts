### Python:
- Use single quotes for strings
- Prefer r-strings over escaping backslashes
- Docstrings keep triple double-quotes with a one-line summary followed by optional details. Use """ text """ formatting, with spaces around and without final `.`
  * Use `:param` style when describing args, but skip args description when the format and purpose is clear from names and type annotations
- Type-annotate, except variables which type is derived from the expression
  * `root = Path(__file__).parent` does not need annotation
  * `var = function()` MUST not be annotated, but the function must be
- Always type-annotate the variable when assigning literal containers (e.g. `d: Dict[str, int] = { ... }`)
- Prefer `typing` classed such as `List`, `Dict`, `Optional` over built-in generics
- Types must be public
- Use `assert` (not `if`) for sanity and type checks
- To build strings, use concatenation for 2 parts, f-strings for ≥3 (if the resulting line is too long, split it using implied concatenation or switch to explicit contatenation of f-strings, whichever is shorter)
- For any status/diagnostics, use logging not printf
  * Use lazy formatting for logging
- Use more brief/terse syntax when options are available
  * Use subprocess.check_output instead of subprocess.run when you only need the output
  * Do not hide output of subprocess calls (no subprocess.DEVNULL) except in loops
    · If necessary to avoid flooding the terminal or corrupting display output, capture it to a file
  * Avoid unnecessary "stabilization" like sorting, `.get()`, `Path.resolve()`, `str(value)`, `if bool(var)` unless there is a specific need
  * Every method/call has a cost and thus should be justified
  * Prefer direct checking `if var` over expressions, except `is [not] None`
  * In newer pythons, prefer `if var := expression:` or `if not (var := expression)`, or even `if xxx and (yyy := expression())` instead of assignment on a separate line
  * Prefer `Path.read_text()` to opening a file and reading it explicitly, except when it's not fully loaded in the memory for processing
  * Avoid single-use variables, especially before `return`, `if` or a function call, unless the line is too long or expression is overly complex (multiple brackets, etc)
  * Avoid `dict.keys()` unless it's performance-optimal (avoids copying)
  * For merging dicts, use `base | override` (preferred) or `{**base, **override}` (only for py < 3.9)
    · When deep merging or resolving conflicts, iterate over intersection of keys: `base.keys() & override.keys()` to avoid checking all keys
- Use `problems` tool or Pylance MCP to surface issues

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
  * ESPECIALLY where race conditions are possible:
    · never check for a file existence/readability before trying to open it
    · Do not reopen the file if multiple reads are necessary
- No broad try/except, no try/except around large blocks of code, fail fast
  * Do not catch what you cannot handle or which are of not a concern of the scope
  * Python logs unhandled exceptions, no need to duplicate
- Do not catch for logging, except in functions called in `threading.Threads`. Specifically, avoid
    ```python
	  try:
	      # code
	  except Exception as e:
	      logging.error(f"Error: {e}") # or print
	      os.exit(1) # or raise
    ```
    ```` ````
- Do not wrap exceptions just to re-raise them
- The example above is a very frequent mistake, re-check the code after implementing any change to ensure it wasn't introduced

#### Additional passes
After implementing the working script logic, review the code in a few passes (focusing on one item below at a time):
0. Move imports to the top of the module
1. Check the codebase for any functions and constants similar to the ones introduced and use them
  * If their signature is unfit, but it's easy to modify them for the new use case without sacrificing the old one, modify and use them
2. Merge regular expressions and other string operations applied in sequence
3. Remove unnecessary single-use variables
4. Remove short single-use functions which could be inlined, especially if they just calculate a single expression
5. Remove redundant exceptions and reduce `try:` scopes and `except:` types
6. Refactor loops (both blocks and comprehensions) to use set or dict operations where possble to avoid unnecessary iterations and checks
7. Use trenary operator and walrus operator where appropriate to simplify the code and reduce the number of lines
8. Run 'problems' tool or Pylance MCP if available, or pylint and mypy in shell, and fix any issues they raise
9. Add types to functions and variables where the exact type could not be inferred from the first assignment, and ensure they are specific (not `Any`) except when parsing an unknown structure (e.g. JSON from a user input; but for API, always define the expected types)
