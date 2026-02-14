# Pointer IDE — Codex

## Overview

Pointer is a **provider-agnostic AI IDE** forked from **Code - OSS** (VS Code open source), with Cursor-style UX and CLI-first model backends. Codex CLI configuration lives alongside Pointer IDE so agent behavior is discoverable and consistent with Cursor (`.cursorrules`) and Claude Code (`CLAUDE.md`). Shared conventions apply across all three. See [README.md](README.md) for goals, status, and quickstart.

## Project Structure

```
.
├── .codex/           # Codex configuration
│   ├── agents/       # Agent definitions
│   ├── commands/     # Slash commands
│   └── skills/       # Reusable skills
├── .claude/          # Claude Code configuration
├── scripts/          # Runnable scripts (invoked via Makefile)
├── sandbox/          # Experimentation area (see sandbox/README.md)
├── scratchpad/       # Temporary working files (see scratchpad/README.md)
├── Makefile          # Commands delegate to scripts/
└── README.md
```

## Default Setup

- **Agents:** `default-coder` (primary implementation) and `reviewer` (lightweight change checks).
- **Skills:** Repo basics, editing safely, testing, and review checklist for project context, safety, and validation.
- **Commands:** `/plan`, `/test`, `/review` and any custom commands under `.codex/commands/`.
- **Reasoning:** Prefer `high`; use xhigh only for genuinely tricky tasks (saves tokens and time). Better docs often beat more reasoning.

## Conventions (aligned with .cursorrules and CLAUDE.md)

- **Commands:** Prefer `make <target>` for setup, build, test, and lint. New workflows = new script in `scripts/` + Makefile target. For atomic commits: `./scripts/committer -m "feat: description" path1 path2` or `make commit FILES="path1 path2" MSG="feat: description"`.
- **Docs:** When `docs/` exists, keep agent-facing docs there and up to date; optional `docs:list` (or similar) can list summaries before coding. Prefer local Markdown over web scraping.
- **Inspiration repos:** When forking or learning from another codebase, use `scratchpad/research/inspiration-forked-projects/` (repos.json + README). Clone on demand with `./scripts/import-inspiration-repos.sh [name ...]` or `make import-inspiration`; clones under `inspiration-forked-projects/repos/<name>/`.
- **Scratchpad:** Temporary files only; see `scratchpad/README.md`.
- **Sandbox:** Runnable experiments only; one subfolder per experiment; see `sandbox/README.md`.
- No secrets in repo; use environment variables or a secrets manager.
- Clear commits (Conventional Commits), small PRs, tests for new functionality when the test layout is defined.
- **PLAN files:** If a `PLAN` file lists tasks, complete them one at a time in order. Mark each task complete before starting the next. Do not stop or ask for human interaction until 100% of tasks are resolved.
- **Lint/format:** Align with Code - OSS upstream: ESLint flat config, TypeScript-ESLint, tabs, trim trailing whitespace, final newline; use `make lint` / `make fmt` or project scripts. See [VS Code eslint.config.js](https://github.com/microsoft/vscode/blob/main/eslint.config.js) and [.vscode](https://github.com/microsoft/vscode/tree/main/.vscode).

## Usage

- Start with the `default-coder` agent; use `reviewer` to sanity-check diffs.
- **Subagents:** Project defines 20 specialized agents in `.cursor/agents/` for delegation (e.g. root-cause-debugger, type-specialist, e2e-specialist, ai-feature-builder). Use when a task matches an agent’s description; they reference project skills and commands. Full index: `.cursor/README.md` (Agent index).
- Add or combine skills under `.codex/skills/` to tailor guidance; reference skills also live in `.agents/skills/` (symlinked for Cursor/Claude).
- Extend commands under `.codex/commands/` for common flows; project commands in `.cursor/commands/` (build, test, lint, typecheck, e2e, commit, review, coverage).
- Follow the same layout and convention rules as in `.cursorrules` and `CLAUDE.md` so behavior is consistent across Cursor, Claude, and Codex.
- **AGENTS.md:** This repo uses `.cursorrules`, `CLAUDE.md`, and `CODEX.md` for shared rules. Codex discovers `AGENTS.md` from the repo root; it can point here or to a shared canonical file (see scratchpad/research/research_02.md).
