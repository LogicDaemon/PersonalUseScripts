---
description: Custom AGENTS.md initialization
---
Create or update `AGENTS.md` for this repository.
The goal is a compact instructions to avoid mistakes and ramp up quickly.

Read first:
- `README*`, root manifests, workspace config, lockfiles
- build, test, lint, formatter, typecheck, and codegen config
- CI workflows and pre-commit / task runner config
- existing instruction files (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md` only from "/.github for vbo")
Prefer executable sources of truth over prose. If docs conflict with config or scripts, trust the executable source and only keep what you can verify.

Look for the non-obvious facts for an agent working in this repo:
- required commands and their order, such as `set those environment variables before building`, `use this tool instead of other tool`
- monorepo or multi-package boundaries, ownership of major directories, and the real app/library entrypoints
- constraints like ALWAYS and NEVER from existing instruction files

Include only high-signal, repo-specific guidance such as:
- exact commands and shortcuts the agent would otherwise guess wrong
- architecture notes that are not obvious from filenames
- conventions that differ from language or framework defaults
- setup requirements, environment quirks, and operational gotchas
- references to existing instruction sources

Exclude:
- generic software advice
- tutorials or file trees
- generic language conventions
- speculative claims or anything you do not have an exact reference for
- content stored in another file referenced via `opencode.json` `instructions`

Prefer short sections and bullets. If the repo is simple, keep the file small. If the repo is large, specify structural facts to ease search of more specific items.
If `AGENTS.md` already exists at `/`, improve it in place rather than rewriting . Preserve verified useful guidance, delete fluff or stale claims, and reconcile it with the current codebase.
$ARGUMENTS

After writing, do a second pass to:
1. Group the instructions by section.
2. Deduplicate and remove obvious and unnecessary. Every line should answer: "Would an agent likely miss this without help?" If not, leave it out.
