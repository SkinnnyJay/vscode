# Pointer IDE — Recommended agent skills

Pointer is a fork of Code - OSS (VS Code). These [skills from skills.sh](https://skills.sh/) are chosen for **performance, profiling, debugging, system/desktop (Electron/Chromium), Rust/C, concurrency, cross-platform (Windows/Linux/macOS), advanced patterns, AI integration, and forking/upstream** work.

## Codebase tech stack

Languages and runtimes in the repo (for agent context):

| Category | Details |
|----------|---------|
| **Languages** | TypeScript ~95.8%, CSS ~1.5%, JavaScript ~1.0%, Rust ~0.6%, HTML ~0.4%, Inno Setup ~0.4%, other ~0.3%. |
| **UI** | React (Code - OSS webviews and UI). |
| **Runtime** | Electron 39.x, Chromium 142.x, Node.js 22.x, V8 14.x (Electron). |
| **Platform** | Cross-platform (Windows, Linux, macOS); e.g. Darwin arm64. |

**Inno Setup** is used for Windows installers; no skills.sh skill. Use upstream Inno Setup docs and existing build scripts when touching installer logic.

## Installed reference skills

Reference skills live in **`.agents/skills/`**. Project workflow skills stay in **`.claude/skills/`**. Cursor and Claude Code use both; see `.cursor/README.md` and `.claude/README.md`.

| Skill | Source | Installs | Why relevant for Pointer |
|-------|--------|----------|---------------------------|
| **systematic-debugging** | obra/superpowers | 10.4K | Root-cause-first debugging; build/runtime failures; multi-component (main/renderer, Node/Chromium). No fixes before root cause. |
| **debugging-strategies** | wshobson/agents | 2.0K | Profiling, root-cause analysis across stacks. Fits IDE and native/TS codebases. |
| **leak-hunter** | (project) | — | Already in `.claude/skills/`. Memory/resource leaks; critical for long-running Electron/VS Code processes. |
| **typescript-advanced-types** | wshobson/agents | 5.7K | Code - OSS is TypeScript-heavy. Generics, conditional types, strict typing for extensions and core. |
| **architecture-patterns** | wshobson/agents | 3.6K | Clean/Hexagonal/DDD; useful when forking and evolving VS Code architecture. |
| **rust-async-patterns** | wshobson/agents | 1.8K | Rust in Chromium/Electron tooling; async/concurrency for native modules. |
| **error-handling-patterns** | wshobson/agents | 2.8K | Cross-language error propagation; extensions and multi-process IDE. |
| **modern-javascript-patterns** | wshobson/agents | 2.1K | ES6+, async/await, modules; aligns with Code - OSS and extension APIs. |
| **vercel-react-best-practices** | vercel-labs/agent-skills | 130.5K | Already in `.agents/skills/`. React rendering, bundle, and server patterns; webviews and UI. |
| **e2e-testing-patterns** | wshobson/agents | 2.7K | Playwright/Cypress; E2E for IDE and web UI. |
| **ai-sdk** | vercel/ai | 4.7K | AI features (Chat, Agent, MCP) in an IDE; model routing and tool use. |
| **monorepo-management** | wshobson/agents | 2.1K | Code - OSS is a large monorepo; build and dependency boundaries. |
| **git-advanced-workflows** | wshobson/agents | 2.1K | Rebasing, bisect, worktrees; maintaining a fork and upstream sync. |

## Themes vs. skills.sh coverage

- **Performance & profiling:** No dedicated Electron/Chromium skill on skills.sh. Use **systematic-debugging**, **debugging-strategies**, and **leak-hunter**; add upstream [VSCode runtime debugging](https://github.com/microsoft/vscode/wiki/Runtime-debugging) and [Electron performance](https://www.electronjs.org/docs/latest/tutorial/performance) as local docs in `docs/` or `scratchpad/`.
- **Electron / Chromium / VSCode:** Not listed as skills. Rely on upstream wikis and local reference in `.agents/` or `docs/`.
- **Rust / C:** **rust-async-patterns** (1.8K); **memory-safety-patterns** (wshobson/agents, 1.5K) for RAII, ownership, C/C++/Rust. Consider adding **memory-safety-patterns** if you add native modules.
- **Windows / Linux / macOS:** No OS-specific skills. **architecture-patterns**, **error-handling-patterns**, and **debugging-strategies** apply across platforms.
- **Concurrency:** **rust-async-patterns**, **async-python-patterns** (2.6K), **go-concurrency-patterns** (1.6K). For Node/TS, **modern-javascript-patterns** and **vercel-react-best-practices** cover async patterns.
- **AI:** **ai-sdk** (vercel/ai) for model integration; **prompt-engineering-patterns** (3.2K) for prompts and tool design.
- **Forking / upstream:** **git-advanced-workflows**; document upstream sync in `README.md` or `docs/`.

## Optional adds (high value)

| Skill | Source | Installs | Use when |
|-------|--------|----------|----------|
| **memory-safety-patterns** | wshobson/agents | 1.5K | Native (Rust/C/C++) or security-sensitive paths. |
| **code-review-excellence** | wshobson/agents | 3.4K | PR review and fork hygiene. |
| **prompt-engineering-patterns** | wshobson/agents | 3.2K | Designing AI features and agent prompts. |
| **verification-before-completion** | obra/superpowers | 6.3K | Confirm fixes and tests before marking done. |

## Install commands

From repo root, install to `.agents/skills` (and optionally to `.claude/skills` or Cursor via the CLI prompts):

```bash
# Non-interactive: installs to .agents/skills by default (Universal)
npx skills add obra/superpowers --skill systematic-debugging -y
npx skills add wshobson/agents --skill debugging-strategies -y
npx skills add wshobson/agents --skill architecture-patterns -y
npx skills add wshobson/agents --skill rust-async-patterns -y
npx skills add wshobson/agents --skill error-handling-patterns -y
npx skills add wshobson/agents --skill modern-javascript-patterns -y
npx skills add wshobson/agents --skill e2e-testing-patterns -y
npx skills add wshobson/agents --skill monorepo-management -y
npx skills add wshobson/agents --skill git-advanced-workflows -y
npx skills add vercel/ai --skill ai-sdk -y
```

To also install for **Claude Code** (`.claude/skills`) or **Cursor**, run without `-y` and select the desired agents when prompted.

## Where skills live

| Location | Purpose |
|---------|---------|
| **`.agents/skills/`** | Reference and toolchain skills (Vitest, Vercel/React, TypeScript, debugging, architecture, etc.). Shared across agents. |
| **`.claude/skills/`** | Project workflow skills (commit, test, lint, leak-hunter, bug-hunter, etc.). Canonical for Cursor and Claude Code. |
| **`.cursor/skills/`** | Symlinks to `.agents/skills/` and `.claude/skills/` so Cursor sees all reference and project skills. |

Agents should use **`.agents/skills/`** for deep reference (e.g. debugging, architecture, Rust, E2E) and **`.claude/skills/`** for project-specific workflows.

---

## Folder layout and naming (per platform docs)

Expected paths, file/folder names, and format for each artifact type. Names use **kebab-case** unless a platform specifies otherwise.

| Folder | Format | Naming | Docs |
|--------|--------|--------|------|
| **`.cursor/agents/`** | One `.md` per agent. Frontmatter: `name` (kebab-case), `description` (when to invoke). Optional: `model`, `readonly`, `tools` (Claude). Body: When to use, Process, Output; reference skills/commands by path. | `code-reviewer.md`, `root-cause-debugger.md` | [Cursor Agent](https://docs.cursor.com/agent/overview), [Claude Code subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) |
| **`.agents/skills/`** | One **folder** per skill; `SKILL.md` required. Frontmatter: `name`, `description` (third person; WHAT + WHEN). Optional: `references/`, `rules/`. | `systematic-debugging/`, `typescript-advanced-types/` | `.agents/README.md` |
| **`.claude/skills/`** | One **folder** per skill; `SKILL.md` required. Frontmatter: `name` (kebab-case, max 64 chars), `description` (WHAT + WHEN, max 1024 chars). | `leak-hunter/`, `commit/`, `bug-hunter/` | `.claude/skills/README.md` |
| **`.cursor/commands/`** | One `.md` per command. Frontmatter: `description`. Body: Overview, Steps, Checklist. | `build.md`, `typecheck.md`, `commit.md` | `.cursor/README.md` |
| **`.cursor/rules/`** | One `.mdc` per rule. Frontmatter: `description`; `alwaysApply: true` or `globs: "**/*.ts"`. Body: Markdown. | `code-style.mdc`, `fixing-workflow.mdc` | [Cursor Rules](https://cursor.com/docs/context/rules), `.cursor/rules/README.md` |

- **Agents:** Canonical in `.cursor/agents/`; Claude Code uses project `.claude/agents/` (this repo points to `.cursor/agents/`). Codex uses `AGENTS.md` and can delegate to agents listed in `.cursor/README.md`.
- **Skills:** Installed via `npx skills add <owner/repo> --skill <name> -y` into `.agents/skills/`; CLI symlinks into `.claude/skills/` and `.cursor/skills/` as needed. Project-only skills live only in `.claude/skills/` (e.g. `commit`, `leak-hunter`).

---

## Project agents

All agents live in **`.cursor/agents/`** as `<name>.md`. Invoke as subagents by name (e.g. "Use the type-specialist to fix these type errors"). Full index: `.cursor/README.md`.

### Core (6)

| Name (file) | When to use |
|-------------|-------------|
| `code-reviewer` | Review PRs or changes for quality, patterns, and best practices. |
| `verifier` | Validate completed work (typecheck, lint, tests, build, review checklist). |
| `test-runner` | Run test suites and interpret failures. |
| `security-reviewer` | Review auth, sensitive data, API routes, or security-critical paths. |
| `researcher` | Deep exploration of codebase, dependencies, or architecture. |
| `debugger` | Investigate failures, errors, or unexpected behavior; root-cause analysis. |

### Specialists (15)

| Name (file) | When to use | Skills / commands |
|-------------|-------------|--------------------|
| `root-cause-debugger` | Strict root-cause investigation before any fix. | systematic-debugging, debugging-strategies |
| `performance-profiler` | Startup, memory, UI jank; Electron/Chromium profiling. | leak-hunter, debugging-strategies |
| `architect` | Architecture decisions, module boundaries, ADRs. | architecture-patterns, monorepo-management |
| `type-specialist` | Complex TypeScript types or type errors. | typescript-advanced-types; `/typecheck` |
| `e2e-specialist` | E2E tests (Playwright/Cypress); fix or add E2E. | e2e-testing-patterns, e2e-expert; `/e2e` |
| `fork-upstream-sync` | Upstream sync, rebase, conflicts, bisect, worktrees. | git-advanced-workflows |
| `monorepo-navigator` | Package boundaries, dependency impact, "who depends on X." | monorepo-management |
| `react-ui-specialist` | React UI, webviews, renderer; bundle/rerender. | vercel-react-best-practices |
| `rust-native-helper` | Rust or native code; async, FFI, Electron tooling. | rust-async-patterns |
| `error-handling-auditor` | Error propagation, user messages, resilience. | error-handling-patterns |
| `commit-gate` | Atomic commits, conventional format, quality gates. | commit; `/commit` |
| `ai-feature-builder` | Chat, Agent, model routing, tools, MCP. | ai-sdk |
| `test-writer` | Write unit/integration tests, TDD, coverage. | test-forge, test-suite, vitest; `/test`, `/coverage` |
| `verification-runner` | Full gate before "done"; verifier checklist. | verifier, verification-before-completion |
| `literal-consolidator` | Magic numbers, duplicated strings → constants/enums. | literal-hunter |
