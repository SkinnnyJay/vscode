# Scripts

Runnable scripts for setup, automation, tooling, and one-off tasks that support the Pointer IDE project.

## What this folder is for

- **Setup and tooling** — Install, bootstrap, or environment setup scripts (e.g. `setup.sh`, `bootstrap.js`).
- **Automation** — Build helpers, codegen, deploy steps, or CI-related scripts that are part of the workflow.
- **One-off utilities** — Small runnable tools used by developers (e.g. lint fixers, data migrations, local dev helpers).
- **Documented entrypoints** — Scripts that are referenced from the main README or CLAUDE.md and are intended to be run by humans or CI.

## What this folder is not for

- **Application source code** — App logic belongs in the main source tree, not here.
- **Temporary or throwaway scripts** — One-off experiments belong in `scratchpad/` or `sandbox/`.
- **Third-party or vendored tools** — Use a proper package/dependency instead of dumping binaries or copied scripts here.
- **Secrets or credentials** — Never hardcode API keys, passwords, or tokens in scripts; use env vars or a secrets manager.

## Required formats

- **File types:** Use a single, obvious language per script (e.g. `.sh` for shell, `.js`/`.mjs` for Node, `.py` for Python). Avoid mixed or opaque extensions.
- **Naming:** Use clear, kebab-case names that describe the action (e.g. `setup-dev.sh`, `run-migrations.js`, `deploy-preview.sh`).
- **Documentation:** Each script should have a short comment or docstring at the top describing what it does, required env vars, and usage (e.g. `./scripts/setup-dev.sh`).
- **Executability:** Mark shell scripts executable (`chmod +x`) and use a proper shebang (e.g. `#!/usr/bin/env bash`). Scripts here are expected to be run directly from the repo root or via `npm`/task runners.

## Scripts reference

- **committer** — Stages only the listed paths and creates one commit with a non-empty message. Use for atomic, reviewable commits (e.g. when multiple agents work in the same folder). Usage: `./scripts/committer -m "feat: add X" path1 path2`. From repo root: `make commit FILES="path1 path2" MSG="feat: add X"`.
- **import-inspiration-repos** — Clone or update inspiration/forked-project repos on demand. Repo list: `scratchpad/research/inspiration-forked-projects/repos.json`. Usage: `./scripts/import-inspiration-repos.sh` (all) or `./scripts/import-inspiration-repos.sh toad codex-monitor` (selected). From repo root: `make import-inspiration` or `make import-inspiration REPOS="toad open-code"`. Requires `jq`. Clones go to `scratchpad/research/inspiration-forked-projects/repos/<name>/` (gitignored).
