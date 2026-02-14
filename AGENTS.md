# Pointer IDE — Agent instructions

Pointer is a provider-agnostic AI IDE forked from Code - OSS (VS Code open source). For detailed project overview, conventions, and validation steps, see:

- **Cursor:** `.cursorrules`
- **Claude Code:** `CLAUDE.md`
- **Codex:** `CODEX.md`

Shared rules are aligned across these files. **Lint/format** expectations follow Code - OSS upstream (ESLint flat config, TypeScript-ESLint, tabs, trim/final newline; see `.cursorrules` and [VS Code .vscode / eslint.config.js](https://github.com/microsoft/vscode/tree/main/.vscode)). Prefer **high** reasoning; use xhigh only for genuinely tricky tasks. Use `./scripts/committer` for atomic commits when multiple agents work in the same folder. Agent-facing docs live in `docs/` when used; keep them up to date.

Use `make setup` to enforce Node 22.x and install dependencies.

Research and workflow notes (e.g. DocSetQuery, steipete/agent-scripts): `scratchpad/research/research_02.md`. **Inspiration/forked projects:** Curated list and on-demand clone in `scratchpad/research/inspiration-forked-projects/` (repos.json, README); use when learning from or forking projects (e.g. Toad, OpenCode, codex-monitor). Run `./scripts/import-inspiration-repos.sh [name]` or `make import-inspiration`.

**Reference skills:** For debugging, performance, architecture, Rust, E2E, monorepos, and AI integration use the skills in `.agents/skills/` (and symlinks in `.claude/skills/`, `.cursor/skills/`). See `docs/skills-recommendations.md` for the full list and rationale.

**PLAN workflow:** When a `PLAN` file defines tasks, take them strictly one at a time. Complete a task, mark it complete, then move to the next. Do not pause or ask for human interaction until 100% of tasks are resolved.

**Agents (subagents):** Canonical definitions in `.cursor/agents/` (21 agents). Core: code-reviewer, verifier, test-runner, security-reviewer, researcher, debugger. Specialists: root-cause-debugger, performance-profiler, architect, type-specialist, e2e-specialist, fork-upstream-sync, monorepo-navigator, react-ui-specialist, rust-native-helper, error-handling-auditor, commit-gate, ai-feature-builder, test-writer, verification-runner, literal-consolidator. Delegate by name for specialized work; full index in `.cursor/README.md`.
