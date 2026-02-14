# Pointer backlog
Tight MVP vs Parity vs V2 plan for a Cursor-like, provider-agnostic fork of Code - OSS.

This backlog is intentionally opinionated:
- Ship a usable MVP fast.
- Keep the fork maintainable.
- Push as much as possible into built-in extensions and a sidecar agent service.
- Only fork core workbench/editor code when required for UX parity or performance.

## Definitions

### MVP
What must exist for Pointer to be usable day 1:
- Pointer launches and looks like the target UX baseline.
- Providers work via CLI (Codex CLI, Claude Code, OpenCode) behind the scenes.
- Tab completion works (even if quality is backend-dependent).
- Chat works with code context.
- Safe agent edits with diff preview exist.
- Settings for default provider/model/prompt policies exist.

### Parity (Cursor-style parity v1)
What closes the biggest user-facing gaps:
- Rules, hooks, MCP, richer context controls, multi-step agent flows.
- Better UX polish: partial accept, better diff review, structured commands, pinned context.
- Reliability and performance work to avoid “AI features make the editor feel heavy”.

### V2
What makes Pointer meaningfully better than parity:
- Faster indexing and caching, better session history, settings sync improvements.
- Enterprise controls (policy, audit), PR review bot, headless/CI usage.
- Optional migration experiments beyond Electron.

## Milestones overview

- M0: Fork + build reproducibility
- M1: Pointer shell UX (branding, surfaces, settings)
- M2: Model Router + Provider CLI adapters (CLI-first)
- M3: Tab completion MVP (ghost text, cancellation, telemetry-free metrics)
- M4: Chat + Agent edits MVP (diff-first edits, tool gating)
- M5: Context engine v1 (indexing + pinning + exclusions)
- M6: Rules + Hooks + MCP v1
- M7: Performance hardening (memory, latency, startup)
- M8: Parity polish + backlog burn-down
- M9: V2 bets (PR bot, enterprise, alternative runtime exploration)

Each milestone below includes:
- Goals
- Work items (issue-ready)
- Exit criteria

---

# M0 - Fork + build reproducibility

## Goals
- Fork Code - OSS cleanly.
- Keep upstream merge friction low.
- Ensure build/run/test commands work on macOS/Linux/Windows.

## Work items
### M0.1 Fork hygiene and branding foundation
- [ ] Replace product branding in `product.json` (Pointer name, icons, URLs).
- [ ] Add `pointer/BRANDING.md` describing allowed assets and forbidden trademarks.
- [ ] Add `SECURITY.md` and `CODE_OF_CONDUCT.md`.

### M0.2 Build scripts and CI
- [ ] `npm install` works.
- [ ] `npm run watch` works.
- [ ] `./scripts/code.sh` and `./scripts/code.bat` run a dev build.
- [ ] Add CI that builds dev artifacts for all OSes.
- [ ] Add CI that runs unit tests and lint for Pointer-owned packages.

### M0.3 Repo policy guardrails
- [ ] `.gitignore` includes `scratchpad/` and any local binaries.
- [ ] Add a pre-commit check that blocks committing large binaries and common “decompiled output” file types.
- [ ] Add “clean-room” contribution rules.

## Exit criteria
- New dev can:
  1) clone
  2) `npm install`
  3) `npm run watch`
  4) launch with `./scripts/code.sh`
  with no undocumented steps.

---

# M1 - Pointer shell UX

## Goals
- Cursor-like ergonomics without copying proprietary assets.
- A first-party Pointer AI surface exists (icon, view container, commands).
- Copilot UI is hidden/disabled by default.

## Work items
### M1.1 Pointer surfaces
- [ ] Activity Bar icon + “Pointer” view container.
- [ ] Commands:
  - `Pointer: Open Chat`
  - `Pointer: Toggle Tab`
  - `Pointer: Select Model`
  - `Pointer: Open Settings`
- [ ] Status bar item showing active provider/model per surface.

### M1.2 Settings parity scaffolding
- [ ] Settings categories:
  - Pointer: Providers
  - Pointer: Models
  - Pointer: Context
  - Pointer: Tools and Safety
  - Pointer: Prompts and Rules
- [ ] UI to set defaults:
  - default tab provider/model
  - default chat provider/model
  - default agent provider/model

### M1.3 “No Copilot” mode
- [ ] Disable or hide Copilot-related commands and menus by default.
- [ ] Add a compatibility mode setting if you later want to re-enable.

## Exit criteria
- Pointer feels like a coherent product and the AI surface is first-class.

---

# M2 - Model Router + Provider CLI adapters

## Goals
- One internal contract for all AI backends.
- CLI-first integration as default.
- Deterministic prompt assembly with policy controls.

## Work items
### M2.1 Model Router (core)
- [ ] Router concepts:
  - surface: `tab | chat | agent`
  - provider: `codex_cli | claude_code | opencode | ...`
  - model: provider-specific string
  - template: prompt template id
  - policy: tool/network/filesystem constraints
- [ ] Router resolves provider/model based on:
  - workspace overrides
  - user overrides
  - defaults
- [ ] Router exposes a stable internal API for UI surfaces.

### M2.2 Provider adapters (CLI)
- [ ] Codex CLI adapter:
  - spawn process
  - pass workspace path
  - stream responses
  - cancellation support
- [ ] Claude Code adapter (CLI or extension bridge):
  - spawn process OR invoke via extension protocol if needed
  - stream responses
  - cancellation support
- [ ] OpenCode adapter:
  - json/table output modes
  - session stats retrieval (optional)
- [ ] “Provider health”:
  - detect missing binary
  - show fix instructions
  - “Test provider” command

### M2.3 Prompt assembly and context budget
- [ ] Standard prompt parts:
  - system template
  - rules
  - pinned context
  - retrieved context
  - user prompt
  - tool specs
- [ ] Hard token budget per surface.
- [ ] Explainability: show what context was sent (redacted paths allowed).

### M2.4 Provider capability model
- [ ] Each provider declares capabilities:
  - supports_tab
  - supports_streaming
  - supports_tools
  - supports_json_schema
  - supports_long_context
- [ ] Router picks fallback behaviors based on capability.

## Exit criteria
- “My models are there” and selectable.
- All surfaces use Router, not bespoke provider calls.

---

# M3 - Tab completion MVP

## Goals
- Cursor-like ghost text UX baseline.
- Fast cancellation to avoid typing lag.
- Works with at least one provider reliably.

## Work items
### M3.1 Inline completion implementation
- [ ] Use VS Code inline completion provider APIs (custom provider).
- [ ] Show ghost text in editor.
- [ ] Accept with Tab.
- [ ] Cancel on Escape or typing.
- [ ] Respect multi-cursor and selections (best-effort in MVP).

### M3.2 Latency and caching
- [ ] Debounce strategy for requests.
- [ ] Request cancellation wired end-to-end.
- [ ] Local cache keyed by:
  - document uri
  - cursor position
  - nearby text hash
  - provider/model
  - rules hash

### M3.3 Settings
- [ ] Enable/disable tab feature.
- [ ] Default tab provider/model.
- [ ] Max latency setting (soft timeout).
- [ ] Privacy: never send full workspace by default, only necessary snippets.

## Exit criteria
- Tab suggestions appear and accept smoothly with no obvious editor lag.

---

# M4 - Chat + Agent edits MVP

## Goals
- A usable chat that can reference code context.
- Agent can propose edits safely with diff preview.
- Tool execution is gated.

## Work items
### M4.1 Chat UI baseline
- [ ] Chat pane supports:
  - multi-turn history
  - attach file(s)
  - attach selection
  - “pin context”
- [ ] Stream responses.
- [ ] Provider/model selector.

### M4.2 Agent edit loop (diff-first)
- [ ] Agent proposes file edits as patches.
- [ ] Show diff view:
  - apply
  - reject
  - apply all
- [ ] Track which files changed and why.

### M4.3 Tool execution gating
- [ ] Terminal tool:
  - disabled by default in MVP or confirm-every-run
  - visible command preview
- [ ] Filesystem tool:
  - only via diff apply
  - no silent writes
- [ ] Network tool:
  - disabled by default unless explicitly enabled

## Exit criteria
- You can ask it to change code, review diffs, and apply.

---

# M5 - Context engine v1

## Goals
- Predictable context selection with controls.
- Scales to medium-large repos without choking the editor.

## Work items
### M5.1 Indexing
- [ ] File discovery respecting `.gitignore` and Pointer excludes.
- [ ] Incremental updates (watcher-based).
- [ ] Store in local db:
  - metadata
  - embeddings (optional in MVP, required in parity)
  - symbol index (optional)

### M5.2 Retrieval
- [ ] Basic lexical retrieval for MVP.
- [ ] Optional embeddings retrieval if local model or remote embeddings are configured.
- [ ] Context merging and dedupe.

### M5.3 User controls
- [ ] “Pinned context” list per chat.
- [ ] Workspace exclude UI.
- [ ] Show token estimate per context chunk.

## Exit criteria
- Chat and agent use context without manual copy-paste.
- Context controls are understandable.

---

# M6 - Rules + Hooks + MCP v1

## Goals
- Cursor-style persistent context via rules.
- Hooks for governance and automation.
- MCP integration for tools and data.

## Work items
### M6.1 Rules
- [ ] `.pointer/rules/` support.
- [ ] UI editor for rules (optional).
- [ ] Rule precedence:
  - global -> workspace -> chat/session override
- [ ] Rule audit display: “these rules were applied”.

### M6.2 Hooks
- [ ] Hook events (initial set):
  - pre_prompt_build
  - post_prompt_build
  - pre_tool_run
  - post_tool_run
  - pre_apply_patch
  - post_apply_patch
  - tab_request
  - tab_response
- [ ] Hooks run in a sandboxed environment with timeouts.
- [ ] Hooks can:
  - block an action
  - redact context
  - modify prompts (policy-limited)

### M6.3 MCP client and manager
- [ ] Connect to local MCP servers.
- [ ] Tool allowlist per workspace.
- [ ] UI: list MCP servers, enabled tools, and permissions.

## Exit criteria
- You can enforce consistent behavior via rules.
- You can gate or automate with hooks.
- MCP tools can be used safely.

---

# M7 - Performance hardening

## Goals
- Fix the issues that make “AI IDEs feel heavy”.
- Explicit budgets for memory, CPU, typing latency, and suggestion latency.

## Work items
### M7.1 Instrumentation
- [ ] Measure:
  - request latency per surface
  - cancellation success rate
  - time-to-first-token for chat
  - tab suggestion latency distribution
  - indexer CPU and memory
- [ ] Local-only telemetry (opt-in) for debugging.

### M7.2 Memory and leak hunting
- [ ] Baseline memory snapshots after:
  - startup
  - open large workspace
  - run 50 agent operations
- [ ] Automated leak test harness (repeatable scenario runner).

### M7.3 Startup and responsiveness
- [ ] Lazy-load heavy AI components.
- [ ] Ensure indexer runs off the UI critical path.
- [ ] Backpressure on provider requests.

## Exit criteria
- No noticeable typing lag.
- Memory usage stays bounded during typical sessions.

---

# M8 - Parity polish

## Goals
- Close UX gaps vs Cursor-style expectations.
- Reduce friction: fewer clicks, clearer status, fewer “why did it do that?” moments.

## Work items
- [ ] Partial accept for tab suggestions.
- [ ] Better multi-file refactor UX (grouped diffs).
- [ ] Slash commands and structured workflows.
- [ ] Workspace-level “intent” or “project brief” pinned context.
- [ ] Session management: named sessions, export/import.

## Exit criteria
- Feature parity v1 is credible for daily use.

---

# M9 - V2 bets

## Goals
- Differentiators, enterprise posture, and automation.

## Work items
### V2.1 Headless agent and CI integration
- [ ] `pointer-agent` can run in CI to propose patches and open PRs (GitHub App optional).
- [ ] Policy and secrets handling.

### V2.2 PR review bot (Bugbot-like)
- [ ] Repo-level rules.
- [ ] PR annotations and suggested changes.
- [ ] Integration with GitHub checks.

### V2.3 Enterprise controls
- [ ] Admin policy bundles.
- [ ] Audit logs.
- [ ] Provider allowlists and data boundary controls.

### V2.4 Runtime experiments
- [ ] Investigate alternative shells or partial migration paths:
  - web-first surfaces
  - lighter desktop shells
- [ ] Do not block core delivery on this.

## Exit criteria
- Pointer has clear advantages beyond parity.

---

# Cross-cutting open questions (keep updated)
- Provider CLIs:
  - What stable machine-readable output modes exist for each CLI?
  - What is the best cancellation mechanism per CLI?
- Licensing:
  - Which providers allow bundling or automated invocation?
  - How will Pointer distribute extensions without relying on Microsoft Marketplace?
- Security:
  - What are the default tool policies for safe-by-default?
  - How will prompt injection defenses be tested?
- Performance:
  - What is the acceptable idle memory ceiling for Pointer vs stock Code - OSS?
- Upstream:
  - Which changes should be proposed upstream vs kept Pointer-only?

---

# Suggested GitHub labels (for issue hygiene)

- `scope:mvp` `scope:parity` `scope:v2`
- `area:router` `area:provider` `area:tab` `area:chat` `area:agent`
- `area:context` `area:rules` `area:hooks` `area:mcp`
- `area:perf` `area:security` `area:build` `area:ux`
- `type:bug` `type:chore` `type:refactor` `type:epic`

