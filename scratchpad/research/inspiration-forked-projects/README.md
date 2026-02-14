# Inspiration: forked and reference projects

This folder holds a **curated list of Git repos** that Pointer (and agents) can use to learn from when forking, integrating, or aligning with other projects. Repos are **not** committed; they are cloned **on demand** via the import script.

## Purpose

- **Agents:** When you need to fork a project, learn from an existing fork, or compare patterns (e.g. VS Code extensions, CLI backends, AI UX), use the list here and import the repo(s) you need.
- **Humans:** Add or remove repos in `repos.json`; run the import script to clone them locally for inspection or diffing.

## How to use

1. **List available repos**  
   Open `repos.json` in this folder. Each entry has a `name`, `url`, and optional `branch` and `description`.

2. **Import on demand**  
   From the repo root:
   ```bash
   ./scripts/import-inspiration-repos.sh           # clone all listed repos
   ./scripts/import-inspiration-repos.sh toad      # clone only "toad"
   ./scripts/import-inspiration-repos.sh toad open-code   # clone several by name
   ```
   Or use the Makefile:
   ```bash
   make import-inspiration                         # clone all
   make import-inspiration REPOS="toad open-code"  # clone only toad and open-code
   ```

3. **Where clones live**  
   Cloned repos are placed under:
   ```text
   scratchpad/research/inspiration-forked-projects/repos/<name>/
   ```
   The `repos/` directory is gitignored so cloned content is not committed.

4. **Use the code**  
   Read, grep, or diff under `repos/<name>/` to learn structure, patterns, and integration points. Prefer this over web scraping when the repo is in the list.

## How to extend

1. **Add a repo**  
   Edit `repos.json` and add an object:
   ```json
   {
     "name": "short-name",
     "url": "https://github.com/org/repo",
     "branch": "main",
     "description": "Optional one-line description."
   }
   ```
   `name` is used as the folder name under `repos/` and as the script argument. `branch` is optional (defaults to `main`).

2. **Remove a repo**  
   Delete its entry from `repos.json`. To remove the clone from disk, delete `repos/<name>/` (or run a clean script if added later).

3. **Refresh a clone**  
   Re-run the import script for that repo; the script can do a `git pull` if the directory already exists (see script behavior in `scripts/import-inspiration-repos.sh`).

## References in agent files

The agent files (`.cursorrules`, `CLAUDE.md`, `CODEX.md`, `AGENTS.md`) point to this folder so that when an agent needs to fork a project or learn from a similar codebase, it knows to:
- Check `scratchpad/research/inspiration-forked-projects/repos.json` for the list,
- Run `./scripts/import-inspiration-repos.sh <name>` to clone on demand,
- Use the cloned tree under `repos/<name>/` for reading and comparison.

Keep `repos.json` and this README updated when adding or removing inspiration projects.
