# Pointer repo structure and agent files layout
TypeScript-first, DRY, testable, and low merge-friction with upstream Code - OSS.

This doc assumes you are forking `microsoft/vscode` (Code - OSS) and want:
- minimal invasive changes to upstream
- fast iteration loops (`npm run watch` + Reload Window)
- clean separation between:
  - UI surfaces (extension host)
  - orchestration logic (sidecar service)
  - provider adapters (CLI-first)
  - workspace configuration (`.pointer/`)

## Design goals

1) Keep upstream merges easy  
Avoid scattering Pointer code across unrelated upstream folders.

2) Make AI logic testable  
Orchestration should be runnable without launching the full editor.

3) Keep the editor responsive  
Heavy work belongs in a sidecar process, not in the renderer or extension host.

4) Let providers evolve independently  
Provider adapters should be isolated and swappable.

## High-level layout

Two layers:
- **Editor layer**: Code - OSS fork + built-in Pointer extension(s)
- **Agent layer**: a sidecar Node process (`pointer-agent`) for router, context, tools, and provider CLIs

### Why a sidecar process
- isolates memory leaks and heavy CPU from the extension host
- can be fuzzed and unit-tested like a normal service
- can implement stricter sandboxing for tools
- can support headless/CI mode later

---

# Proposed repo tree (additive to upstream)

This is a suggested directory tree. The upstream repo is large. The goal is to keep Pointer-owned code in well-known places.

```
.
├─ .github/
│  ├─ workflows/
│  │  ├─ pointer-ci.yml
│  │  ├─ pointer-release.yml
│  │  └─ pointer-perf.yml
│  └─ ISSUE_TEMPLATE/
│
├─ build/                         # upstream
├─ extensions/                    # upstream (built-in extensions)
│  ├─ pointer-ai/                 # Pointer built-in extension (UI surfaces)
│  │  ├─ package.json
│  │  ├─ src/
│  │  │  ├─ extension.ts
│  │  │  ├─ ui/                   # webview + view container UI
│  │  │  ├─ chat/                 # chat participant integration
│  │  │  ├─ tab/                  # inline completion provider
│  │  │  ├─ commands/             # command registration
│  │  │  ├─ settings/             # settings schema + helpers
│  │  │  └─ protocol/             # JSON-RPC client to pointer-agent
│  │  ├─ media/                   # webview assets (Pointer-owned)
│  │  ├─ test/
│  │  └─ README.md
│  │
│  └─ pointer-tools/              # optional: built-in helpers (MCP UI, policies UI)
│
├─ pointer/                       # Pointer-owned root folder
│  ├─ product/
│  │  ├─ product.json             # Pointer product config overrides
│  │  ├─ icons/                   # Pointer icons
│  │  └─ branding.md
│  │
│  ├─ agent/                      # sidecar service (TypeScript)
│  │  ├─ package.json
│  │  ├─ tsconfig.json
│  │  ├─ src/
│  │  │  ├─ main.ts               # stdio / socket server entry
│  │  │  ├─ router/               # model router logic
│  │  │  ├─ providers/            # CLI adapters (codex, claude, opencode)
│  │  │  ├─ context/              # indexing + retrieval
│  │  │  ├─ tools/                # terminal/fs/network + policies
│  │  │  ├─ hooks/                # hook engine
│  │  │  ├─ mcp/                  # MCP client + server manager
│  │  │  ├─ schemas/              # JSON schemas for config, messages
│  │  │  ├─ telemetry/            # local-only metrics (opt-in)
│  │  │  └─ util/
│  │  ├─ test/
│  │  └─ README.md
│  │
│  ├─ agent-files/                # shipped defaults for prompts, rules, commands
│  │  ├─ prompts/
│  │  ├─ rules/
│  │  ├─ commands/
│  │  ├─ hooks/
│  │  └─ mcp/
│  │
│  ├─ scripts/
│  │  ├─ pointer-watch.sh         # runs upstream watch + agent watch
│  │  ├─ pointer-run.sh           # launches Code - OSS + pointer-agent
│  │  ├─ pointer-test.sh
│  │  └─ pointer-lint.sh
│  │
│  └─ docs/
│     ├─ BACKLOG.md
│     ├─ FEATURE_MATRIX.md
│     ├─ ARCHITECTURE.md
│     └─ SECURITY_MODEL.md
│
├─ scratchpad/                    # gitignored, local experiments only
│  ├─ inspiration/                # do not commit proprietary binaries
│  └─ playground-workspaces/
│
└─ README.md
```

Notes:
- Put the **built-in Pointer extension** in `extensions/pointer-ai` so it plugs into the upstream build pipeline naturally.
- Put the sidecar service under `pointer/agent` so it is clearly “not upstream”.
- Keep shipped defaults (prompts/rules/commands) under `pointer/agent-files`.

---

# Build and run workflow

Upstream Code - OSS uses:
- `npm install`
- `npm run watch`
- run dev build via `./scripts/code.sh` (macOS/Linux) or `./scripts/code.bat` (Windows)

Pointer should preserve that flow and add one wrapper command that runs the editor and the sidecar together.

## Suggested scripts

### `pointer/scripts/pointer-watch.sh`
- runs `npm run watch` (upstream)
- runs `npm --prefix pointer/agent run watch` (sidecar TS build)
- optional: runs extension watch if needed

### `pointer/scripts/pointer-run.sh`
- ensures the agent is built
- starts `pointer-agent` (stdio server or local TCP)
- starts `./scripts/code.sh` with env vars that point the extension to the agent endpoint

Environment variables (example):
- `POINTER_AGENT_TRANSPORT=stdio|tcp`
- `POINTER_AGENT_ADDR=127.0.0.1:PORT`
- `POINTER_LOG_LEVEL=debug|info|warn|error`

---

# “Agent protocol” between extension and sidecar

Keep the protocol:
- simple
- stable
- versioned
- testable

## Recommended shape
- JSON-RPC 2.0 over stdio (default) or local TCP (optional)
- Message types:
  - `router.resolveRequest`
  - `tab.suggest`
  - `chat.send`
  - `agent.plan`
  - `agent.applyPatch`
  - `tools.runTerminal`
  - `context.search`
  - `mcp.listTools`
  - `hooks.run`

## ACP compatibility (optional)
If you want broad interoperability with other agents/clients:
- implement ACP as a compatibility layer inside `pointer/agent/protocol/acp`
- map ACP calls to your internal router and tool gateway

This lets Pointer integrate agents that already speak ACP and reduces “one-off integrations”.

---

# Workspace “agent files” layout (`.pointer/`)

These files live in a user’s repo, not Pointer’s repo. Pointer loads them only for trusted workspaces.

```
.my-repo/
└─ .pointer/
   ├─ config.toml                 # provider defaults, policies, budgets
   ├─ rules/
   │  ├─ style.md
   │  ├─ security.md
   │  └─ project-brief.md
   ├─ prompts/
   │  ├─ chat.system.md
   │  ├─ tab.system.md
   │  └─ agent.system.md
   ├─ commands/
   │  ├─ refactor.md              # slash command templates
   │  └─ test.md
   ├─ hooks/
   │  ├─ hooks.json               # hook registration
   │  ├─ pre_tool_validate.ts
   │  └─ post_patch_format.ts
   ├─ mcp/
   │  ├─ servers.json             # MCP server list and permissions
   │  └─ allowlist.json
   └─ excludes
```

## File format recommendations

### `config.toml`
Keep it ergonomic and mergeable. Include:
- defaults per surface (tab/chat/agent)
- provider allowlist/denylist
- tool policies (terminal, filesystem, network)
- context budgets
- indexing options

### Rules (`rules/*.md`)
- short, direct, stable
- “do” more than “don’t”
- one topic per file
- no secrets

### Prompts (`prompts/*.md`)
- treat as “templates”, not giant system prompts
- include placeholders:
  - `{workspace}`
  - `{selection}`
  - `{pinned_context}`
  - `{retrieved_context}`
  - `{policy}`

### Commands (`commands/*.md`)
Use a simple frontmatter + body pattern:

```md
---
name: refactor
description: Refactor selection into smaller functions with tests.
tools:
  - filesystem
  - terminal
---
Instructions:
1) Propose patch first
2) Apply after approval
3) Run tests
```

### Hooks (`hooks/`)
- hooks must be fast and deterministic
- enforce timeouts
- treat outputs as untrusted
- do not allow silent network exfiltration

---

# Testing strategy

## Unit tests (fast)
- `pointer/agent`:
  - router resolution
  - context chunking and budget
  - tool policy decisions
  - provider adapter parsing
- `extensions/pointer-ai`:
  - prompt assembly UI logic
  - settings schema validation
  - protocol client

## Integration tests (realistic)
- fake provider CLI fixtures:
  - deterministic outputs
  - streaming simulation
- “golden” patch apply tests:
  - apply
  - reject
  - conflicts

## E2E tests (editor)
- launch Pointer dev build
- open a sample workspace
- run:
  - tab suggestion appears
  - chat sends
  - agent patch appears and applies
- perf smoke:
  - capture timing and memory

---

# DRY and layering rules (to keep the fork sane)

1) UI never calls providers directly  
UI calls sidecar over protocol. Sidecar calls CLIs.

2) No business logic in webviews  
Webviews are dumb renderers. State lives in extension host or sidecar.

3) Keep core fork patches minimal  
If an extension API can do it, prefer extension.
If parity requires core patch, isolate behind feature flags.

4) Everything versioned  
- protocol version
- config schema version
- migration scripts

---

# Scratchpad policy

`scratchpad/` is local-only and gitignored. Do not commit:
- proprietary binaries
- decompiled output
- customer code
- secrets

Use `scratchpad/playground-workspaces/` to keep repeatable test repos.

