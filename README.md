# Pointer

A Cursor-like, provider-agnostic AI IDE built by forking **Code - OSS** (the open source core of VS Code), with **CLI-first** model backends (Codex CLI, Claude Code, OpenCode, etc), optional API backends, optional local models, and first-class hooks.

> Goal: **feature parity UX** with Cursor-style Tab, Chat, Agent edits, Rules, Hooks, MCP integrations, and performance focus, while keeping a clean-room implementation (no proprietary code or assets).

---

## Table of contents

- [What is Pointer](#what-is-pointer)
- [Project status](#project-status)
- [Key goals](#key-goals)
- [Non-goals](#non-goals)
- [Legal, licensing, trademarks](#legal-licensing-trademarks)
- [Quickstart (dev build)](#quickstart-dev-build)
- [Provider setup (CLI-first)](#provider-setup-cli-first)
  - [Codex CLI](#codex-cli)
  - [Claude Code](#claude-code)
  - [OpenCode](#opencode)
  - [Cursor CLI](#cursor-cli)
- [Configuration](#configuration)
  - [Model router](#model-router)
  - [Rules](#rules)
  - [Hooks](#hooks)
  - [MCP](#mcp)
- [Architecture](#architecture)
- [Feature parity roadmap](#feature-parity-roadmap)
- [Performance](#performance)
- [Extensions and marketplaces](#extensions-and-marketplaces)
- [Contributing](#contributing)
- [Security](#security)
- [Upstream PR strategy](#upstream-pr-strategy)
- [Repo hygiene](#repo-hygiene)
- [Credits](#credits)

---

## What is Pointer

Pointer is a **VS Code-compatible editor** that:

- Forks **Code - OSS** as the base platform
- Replaces Copilot branding/surfaces with a first-party **Pointer** AI surface
- Routes all AI actions through a **Model Router** that can:
  - Set defaults per feature (Tab vs Chat vs Agent)
  - Disable models/providers globally or per workspace
  - Enforce policy (tool execution, network, filesystem write boundaries)
- Prefers **official provider CLIs** behind the scenes:
  - Codex CLI
  - Claude Code
  - OpenCode
  - (Optional) Cursor CLI
- Adds **Hooks**, **Rules**, and **MCP** integrations as first-class concepts

---

## Project status

Pointer is **pre-alpha**.

MVP definition:
- It launches
- It looks like a Cursor-style UI (layout + keybindings + settings parity)
- Your models/providers show up and work via CLI
- Basic chat and basic tab completion function end-to-end

---

## Key goals

1) **Cursor-like UX parity**  
Tab autocomplete, inline edits, chat, agent file edits, diff review, and context controls.

2) **Provider-agnostic**  
One UX across many backends. Switch providers without switching UI.

3) **CLI-first by default**  
Avoid brittle direct SDK bindings when providers already ship mature CLIs.

4) **Fast, stable, low-memory**  
Typing latency and editor responsiveness are non-negotiable.

5) **Clean implementation**  
Strict TypeScript, DRY, no “patch spaghetti”, minimal invasive edits to upstream where possible.

---

## Non-goals

- Not a binary clone of Cursor.
- No reverse engineering or inclusion of proprietary Cursor code, assets, or binaries.
- No bundling Microsoft proprietary VS Code components or Marketplace integration that violates terms.

---

## Legal, licensing, trademarks

Pointer is built on **Code - OSS** (MIT). The official “Visual Studio Code” distribution includes Microsoft-specific branding/assets and Marketplace integrations that are not part of Code - OSS. Do not copy their product name/icons or proprietary integrations.

Important distribution note:
- The **Visual Studio Marketplace** is not guaranteed for forks and is governed by separate terms.
- Plan to use **Open VSX** or a private extension registry, or side-load VSIX.

---

## Quickstart (dev build)

Pointer tracks upstream **VS Code build flows** unless explicitly documented otherwise.

### Prerequisites

- Git
- Node.js 22.22.0+ (match `.nvmrc` / setup script requirement)
- Linux build prerequisites: `libkrb5-dev` (Kerberos headers for native module builds)
- Enough RAM/CPU to build Code - OSS

### Clone + install

```bash
git clone https://github.com/<your-org>/pointer.git
cd pointer
make setup
```

### Development commands

All commands are run via the **Makefile** and delegate to scripts in `./scripts/`. Run `make help` to list them.

| Command | Description |
|---------|-------------|
| `make setup` | Install dependencies (Node 22.x). |
| `make build` | Compile the project. |
| `make clean` | Remove build artifacts; `make clean ALL=1` also removes `node_modules`. |
| `make test` | Run full Electron unit tests (requires build). |
| `make test-unit` | Run fast Node unit tests (no Electron). |
| `make test-integration` | Run Electron integration tests. |
| `make test-web-integration` | Run web/browser integration tests. |
| `make test-smoke` | Run smoke tests. |
| `make test-e2e` | Run E2E/integration tests. |
| `make lint` | Run ESLint and Stylelint. |
| `make fmt` | Apply formatting fixes; `make fmt-check` to check only. |
| `make typecheck` | Run TypeScript type checking. |
| `make hygiene` | Run full pre-commit hygiene. |
| `make commit FILES="path1 path2" MSG="feat: description"` | Atomic commit (for agents/reviewable changes). |

See **scripts/README.md** for the full list and script details.

---

## Credits

See [CREDITS.md](CREDITS.md) for sources and attribution (upstream Code - OSS/VS Code, provider CLIs, and protocols).