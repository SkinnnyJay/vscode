# Pointer IDE

## Project Overview

Pointer is a **provider-agnostic AI IDE** built by forking **Code - OSS** (the open source core of VS Code). It aims for Cursor-style UX (Tab, Chat, Agent, Rules, Hooks, MCP) with CLI-first model backends (Codex CLI, Claude Code, OpenCode, etc.) and a clean-room implementation. Agent rules and conventions are shared across Cursor (`.cursorrules`), Claude Code (this file), and Codex (`CODEX.md`) so behavior is consistent. See [README.md](README.md) for goals, status, quickstart, and architecture.

## Tech Stack

- **Base:** Code - OSS (VS Code open source). Build and run follow upstream unless documented otherwise.
- **Languages:** TypeScript (majority), CSS, JavaScript, Rust, HTML, Inno Setup (Windows installer). React for UI.
- **Runtime:** Electron 39.x, Chromium 142.x, Node.js 22.x, V8 14.x. Cross-platform (Windows, Linux, macOS).
- **Pointer layer:** Model router, rules, hooks, MCP; CLI-first backends. (Stack details TBD as implemented.)

## Project Structure

```
.
├── .claude/          # Claude Code configuration
│   ├── agents/       # Custom agent definitions
│   ├── commands/     # Slash commands
│   └── skills/       # Reusable skills
├── scripts/          # Runnable scripts (invoked via Makefile)
├── sandbox/          # Experimentation area (see sandbox/README.md)
├── scratchpad/       # Temporary working files (see scratchpad/README.md)
├── Makefile          # Commands delegate to scripts/
└── README.md
```

## Development

### Setup

```bash
make setup
```

### Build

```bash
make build    # when scripts/build.sh exists
```

### Test

```bash
make test     # when scripts/test.sh exists
```

### Lint and formatting

Lint and formatting align with **Code - OSS** (upstream). Use `make lint` and `make fmt` when available; otherwise use project or upstream npm scripts.

- **Upstream:** [VS Code eslint.config.js](https://github.com/microsoft/vscode/blob/main/eslint.config.js), [README](https://github.com/microsoft/vscode/blob/main/README.md), [.vscode](https://github.com/microsoft/vscode/tree/main/.vscode).
- **ESLint:** Flat config; TypeScript-ESLint; stylistic rules; no explicit `any`; `prefer-const`, `no-var`, `curly`, `eqeqeq`.
- **Editor:** Tabs for indentation; trim trailing whitespace; final newline; format on save for TS/JS. Recommended: ESLint and EditorConfig extensions; `eslint.useFlatConfig: true`.

## Conventions

- **Commands:** Add new workflows by adding a script in `scripts/` and a target in the Makefile. Run `make help` to list commands. For atomic commits use `./scripts/committer -m "type: message" path1 path2` or `make commit FILES="..." MSG="..."`.
- **Docs:** Agent-facing docs in `docs/` when used; keep them current so agents have good context. Prefer local Markdown over web scraping (see scratchpad/research/research_02.md).
- **Inspiration repos:** To fork or learn from a similar project, use `scratchpad/research/inspiration-forked-projects/`: list in `repos.json`, how-to in the folder README. Run `./scripts/import-inspiration-repos.sh [name ...]` or `make import-inspiration` to clone; repos appear under `inspiration-forked-projects/repos/<name>/`.
- **Scratchpad:** Temporary drafts and notes only; see `scratchpad/README.md` for use and formats.
- **Sandbox:** Runnable experiments only; one subfolder per experiment; see `sandbox/README.md`.
- Use clear, descriptive commit messages (Conventional Commits: `feat`, `fix`, `refactor`, `docs`, `chore`) and keep PRs focused and small.
- Write tests for new functionality once the test layout is defined.
- Follow existing code style and patterns. No secrets in repo—use env or a secrets manager.
- **Workflow:** Work on one aspect of a feature at a time; hand off clearly; let the agent run. No need for huge Plan.md files.
- **PLAN files:** If a `PLAN` file enumerates tasks, execute them strictly in order one at a time. Finish a task, mark it complete, then proceed. Do not stop or ask for human interaction until 100% of tasks are resolved.

## Claude Code Notes

- Use `/commit` to create well-formatted commits.
- Use `/review` to review code changes.
- Use `/test` to run the test suite when available.
- Custom commands are in `.claude/commands/`.
- Align with `.cursorrules` and `CODEX.md` so Cursor, Claude, and Codex behave consistently.
