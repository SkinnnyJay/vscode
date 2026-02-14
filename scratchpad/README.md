# Scratchpad

Temporary working area for quick notes, drafts, and one-off experiments that are not part of the main codebase.

## What the scratchpad is for

- **Temporary working files** — Drafts, snippets, and in-progress ideas you don’t want in the repo yet.
- **Quick experiments** — Throwaway code or config to try something out.
- **Notes and outlines** — Meeting notes, task lists, design sketches, or reference text.
- **Copy/paste staging** — Content you’re shaping before moving into real docs or code.

## What the scratchpad is not for

- **Committed source code** — Real application code belongs under the proper project structure, not here.
- **Long-term documentation** — Docs that should be versioned and shared go in the repo root or `docs/`, not here.
- **Secrets or credentials** — Never put API keys, passwords, or other sensitive data here (or anywhere in the repo).
- **Build artifacts or dependencies** — No compiled output, `node_modules`, or similar; use `sandbox/` for experiments that need that.

## Required formats

- **File types:** Use plain text, Markdown (`.md`), or common code/config extensions (e.g. `.txt`, `.json`, `.py`) as needed. Avoid binaries or large media unless clearly temporary.
- **Naming:** Use clear, descriptive names (e.g. `draft-api-notes.md`, `experiment-auth-flow.txt`) so contents are easy to find and delete later.
- **Lifecycle:** Treat everything here as disposable. Clean up or archive when done; this directory can be pruned or emptied without affecting the project.
