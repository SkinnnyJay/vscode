# Pointer IDE Plan

Last updated: 2026-02-14

## Purpose
Build a provider-agnostic, Cursor-style AI IDE by forking Code - OSS, shipping an MVP fast, and keeping upstream merge friction low. Heavy AI logic lives in a sidecar service; UI surfaces live in a built-in Pointer extension. Clean-room implementation only.

## Non-negotiables
- No reverse engineering, decompiling, or copying proprietary Cursor code/assets.
- No VS Code trademarks or Marketplace reliance; use Pointer branding and alternative extension distribution.
- CLI-first provider adapters (Codex CLI, Claude Code, OpenCode); APIs optional.
- Tooling is safe-by-default: explicit gating for terminal, filesystem, network.
- Keep upstream patches minimal; prefer extension APIs and sidecar service.

## Architecture & repo targets
- Editor layer: Code - OSS fork + built-in extension `extensions/pointer-ai`.
- Agent layer: sidecar service `pointer/agent` (router, context, tools, providers).
- Shared defaults: `pointer/agent-files` for prompts/rules/commands/hooks/mcp.
- Scripts: `pointer/scripts/*` to wrap upstream watch/run flows.

## Execution rules
- Work milestone-by-milestone; finish exit criteria before moving on.
- After each task completion, update this `PLAN.md` and mark the task as complete before moving to the next task.
- Keep tasks atomic and reviewable; add tests for new functionality when test layout is defined.

---

## Detail references
- Backlog: `scratchpad/research/POINTER_BACKLOG.md` (issue-ready breakdown)
- Feature matrix + acceptance criteria: `scratchpad/research/POINTER_FEATURE_MATRIX.md`
- Repo structure guidance: `scratchpad/research/POINTER_REPO_STRUCTURE.md`

---

## Milestones, criteria, success metrics, and tasks

### M0 — Fork + build reproducibility
Criteria (exit):
- New dev can clone, `npm install`, `npm run watch`, and launch via `./scripts/code.sh` or `./scripts/code.bat` with no undocumented steps.
- Pointer branding exists without VS Code or Cursor assets.
Success metrics:
- Clean macOS/Linux/Windows dev build success rate ≥ 90% in CI.
- First dev watch build completes without manual edits.
Tasks:
- [x] - M0 - [repo] Fork `microsoft/vscode` into this repo (or subtree) and set upstream remote.
- [x] - M0 - [repo] Verify upstream tree lands (expects `src/`, `extensions/`, `product.json`, `package.json`).
- [x] - M0 - [repo] Add `upstream` remote and record upstream branch tracking.
- [x] - M0 - [docs] Document upstream merge strategy (cadence + rebase/merge policy).
- [x] - M0 - [docs] Add a short “merge playbook” with exact commands and conflict policy.
- [x] - M0 - [ci] Add CI check that reports upstream merge conflicts early.
- [x] - M0 - [ci] Add CI job to run smoke launch (`./scripts/code.sh`) on macOS/Linux.
- [x] - M0 - [core] Replace product branding in `product.json` (Pointer name/icons/URLs).
- [x] - M0 - [core] Replace product icons and ensure no VS Code/Cursor assets remain.
- [x] - M0 - [core] Update product strings (about dialog, app name, update URL).
- [x] - M0 - [docs] Add `pointer/BRANDING.md` describing allowed assets and forbidden trademarks.
- [x] - M0 - [docs] Add `SECURITY.md` and `CODE_OF_CONDUCT.md`.
- [x] - M0 - [core] Decide extension distribution strategy (Open VSX/private/VSIX) and document it.
- [x] - M0 - [core] Point `product.json` at the chosen extension registry.
- [x] - M0 - [core] Add documentation for VSIX sideloading fallback.
- [x] - M0 - [core] Ensure `npm install` works on a clean machine.
- [x] - M0 - [core] Ensure `npm run watch` works and stays watching.
- [x] - M0 - [core] Ensure `./scripts/code.sh` and `./scripts/code.bat` launch a dev build.
- [x] - M0 - [ci] Add CI to build dev artifacts for macOS/Linux/Windows.
- [x] - M0 - [ci] Add CI to run unit tests and lint for Pointer-owned packages.
- [x] - M0 - [repo] Update `.gitignore` to include `scratchpad/` and local binaries.
- [x] - M0 - [repo] Add pre-commit guard to block large binaries/decompiled output.
- [x] - M0 - [docs] Add clean-room contribution rules.
- [x] - M0 - [perf] Baseline stock Code - OSS perf (startup, idle memory, typing latency) and set budgets.
- [x] - M0 - [perf] Capture baseline memory snapshots and store in `docs/perf/`.

### M1 — Pointer shell UX
Criteria (exit):
- Pointer AI surface is first-class and discoverable.
- Copilot UI hidden/disabled by default with an optional compatibility toggle.
Success metrics:
- Pointer view container opens with one click from Activity Bar.
- No Copilot commands visible in default command palette.
Tasks:
- [x] - M1 - [extension] Add Activity Bar icon and “Pointer” view container.
- [x] - M1 - [extension] Create view container contribution in `package.json`.
- [x] - M1 - [extension] Wire placeholder view with empty state messaging.
- [x] - M1 - [extension] Register commands: Open Chat, Toggle Tab, Select Model, Open Settings.
- [x] - M1 - [extension] Add command palette labels and categories.
- [x] - M1 - [extension] Add status bar item showing active provider/model per surface.
- [x] - M1 - [extension] Add status item tooltip with surface-specific selection.
- [x] - M1 - [extension] Create settings categories: Providers, Models, Context, Tools and Safety, Prompts and Rules.
- [x] - M1 - [extension] Add settings schema defaults and descriptions.
- [x] - M1 - [extension] Add defaults UI for tab/chat/agent provider+model selection.
- [x] - M1 - [extension] Add settings validation and migration placeholder.
- [x] - M1 - [core] Hide/disable Copilot commands and menus by default.
- [x] - M1 - [core] Add setting to re-enable Copilot visibility.
- [x] - M1 - [extension] Add compatibility setting to re-enable Copilot if needed.
- [x] - M1 - [policy] Define workspace trust model for loading `.pointer/` config and rules.
- [x] - M1 - [docs] Document Pointer settings categories and defaults.

### M2 — Model Router + Provider CLI adapters
Criteria (exit):
- All surfaces use Router; no bespoke provider calls.
- Providers are selectable and validated; missing binaries show install guidance.
Success metrics:
- Router emits structured request plans for 100% of AI calls.
- Provider cancellation resolves within 500ms (or documented CLI limitation).
Tasks:
- [x] - M2 - [research] Spike CLI feasibility: codex/claude/opencode stdin/stdout, streaming, JSON, cancel.
- [x] - M2 - [research] Capture example transcripts for each CLI mode.
- [x] - M2 - [docs] Document CLI findings and kill non-viable adapters early.
- [x] - M2 - [sidecar] Define router contract (surface, provider, model, template, policy).
- [x] - M2 - [sidecar] Define config schema for router defaults and policies.
- [x] - M2 - [sidecar] Implement resolution order (workspace overrides → user overrides → defaults).
- [x] - M2 - [extension] Expose stable internal API for UI surfaces.
- [x] - M2 - [extension] Add router client with request/response types.
- [ ] - M2 - [sidecar] Implement prompt assembly (system, rules, pinned, retrieved, user, tools).
- [ ] - M2 - [sidecar] Add prompt part ordering tests.
- [ ] - M2 - [sidecar] Add hard token budgets per surface with explainability data.
- [ ] - M2 - [extension] Render “context sent” panel from router plan.
- [ ] - M2 - [sidecar] Add provider capability model (tab/tools/json/long-context).
- [ ] - M2 - [sidecar] Add provider health checks, missing-binary detection, and “Test provider”.
- [ ] - M2 - [sidecar] Add provider error classification (missing binary, auth, rate limit).
- [ ] - M2 - [sidecar] Implement Codex CLI adapter with streaming + cancellation.
- [ ] - M2 - [sidecar] Add Codex adapter unit tests (streaming + cancel).
- [ ] - M2 - [sidecar] Implement Claude Code adapter with streaming + cancellation.
- [ ] - M2 - [sidecar] Add Claude adapter unit tests (streaming + cancel).
- [ ] - M2 - [sidecar] Implement OpenCode adapter with JSON/table output support.
- [ ] - M2 - [sidecar] Add OpenCode adapter unit tests (JSON mode).
- [ ] - M2 - [sidecar] Decide on ACP compatibility layer and document decision.

### M3 — Tab completion MVP
Criteria (exit):
- Ghost text appears, accepts with Tab, cancels instantly without typing lag.
Success metrics:
- p95 suggestion latency < 500ms on warm cache.
- Cancellation success rate ≥ 95% within 200ms.
Tasks:
- [ ] - M3 - [extension] Implement inline completion provider (ghost text).
- [ ] - M3 - [extension] Add provider request plumbing to router for tab surface.
- [ ] - M3 - [extension] Support accept with Tab and cancel on Escape/typing.
- [ ] - M3 - [extension] Handle multi-cursor safely (best-effort in MVP).
- [ ] - M3 - [extension+sidecar] Add debounce strategy and end-to-end cancellation wiring.
- [ ] - M3 - [sidecar] Add local cache keyed by uri/position/nearby text/provider/model/rules.
- [ ] - M3 - [extension] Add settings: enable/disable, default provider/model, max latency.
- [ ] - M3 - [sidecar] Enforce privacy: send only necessary snippets by default.
- [ ] - M3 - [tests] Add basic tab completion integration test (happy path + cancel).
- [ ] - M3 - [tests] Add perf smoke test for tab latency budget.

### M4 — Chat + Agent edits MVP
Criteria (exit):
- Multi-turn chat works with file/selection attach and streamed responses.
- Agent proposes edits as diffs; user can apply/reject per file.
Success metrics:
- 100% of agent edits go through diff-first apply flow.
- Tool gating prevents silent terminal/fs/network actions.
Tasks:
- [ ] - M4 - [extension] Create chat view container and session list.
- [ ] - M4 - [extension] Add new-session action and session rename/delete.
- [ ] - M4 - [extension] Implement message list rendering with streaming updates.
- [ ] - M4 - [extension] Add prompt composer input with send/cancel.
- [ ] - M4 - [extension] Add attach file/selection and pin context actions.
- [ ] - M4 - [extension] Add context chips UI with remove action.
- [ ] - M4 - [extension] Add provider/model selector for chat.
- [ ] - M4 - [extension+sidecar] Implement chat request/stream protocol over router.
- [ ] - M4 - [sidecar] Add chat request plan logging and trace IDs.
- [ ] - M4 - [sidecar] Define patch schema and diff-first agent response format.
- [ ] - M4 - [extension] Render per-file diff view with apply/reject/apply all.
- [ ] - M4 - [extension] Add apply summary banner and conflict messaging.
- [ ] - M4 - [extension] Track and show changed files with rationale.
- [ ] - M4 - [sidecar] Gate terminal tool (confirm-by-default or disabled).
- [ ] - M4 - [sidecar] Gate filesystem edits to diff apply only.
- [ ] - M4 - [sidecar] Gate network tool (disabled or confirm-by-default).
- [ ] - M4 - [policy] Add prompt injection defense strategy for tools and patches.
- [ ] - M4 - [tests] Add agent patch apply tests (apply/reject/conflict).

### M5 — Context engine v1
Criteria (exit):
- Context retrieval works without manual copy-paste and respects excludes.
Success metrics:
- Indexed workspace updates reflect changes without full reindex.
- Token estimation shown for all context chunks.
Tasks:
- [ ] - M5 - [sidecar] Implement file discovery respecting `.gitignore` and Pointer excludes.
- [ ] - M5 - [sidecar] Add incremental updates via watcher-based indexing.
- [ ] - M5 - [sidecar] Store metadata in a local DB (embeddings optional for MVP).
- [ ] - M5 - [sidecar] Implement lexical retrieval and context dedupe/merge.
- [ ] - M5 - [sidecar] Add optional embeddings retrieval if configured.
- [ ] - M5 - [extension] Add pinned context list per chat.
- [ ] - M5 - [extension] Add workspace exclude UI and `.pointer/excludes` support.
- [ ] - M5 - [extension] Show token estimate per context chunk.
- [ ] - M5 - [tests] Add context retrieval unit tests (lexical + dedupe).

### M6 — Rules + Hooks + MCP v1
Criteria (exit):
- Rules apply predictably with visible audit; hooks can gate actions; MCP tools are manageable and safe.
Success metrics:
- 100% of requests show applied rules list.
- Hook timeouts enforced with safe failure.
Tasks:
- [ ] - M6 - [sidecar] Implement `.pointer/rules/` loader.
- [ ] - M6 - [sidecar] Add rules precedence (global → workspace → session override).
- [ ] - M6 - [extension] Display applied rules in UI.
- [ ] - M6 - [sidecar] Implement hook events (pre/post prompt, tool, patch, tab).
- [ ] - M6 - [sidecar] Run hooks sandboxed with timeouts.
- [ ] - M6 - [sidecar] Allow hooks to block, redact, or modify prompts (policy-limited).
- [ ] - M6 - [sidecar] Implement MCP client to connect to local servers.
- [ ] - M6 - [sidecar] Add tool allowlist per workspace.
- [ ] - M6 - [extension] Add UI for MCP servers, tools, and permissions.
- [ ] - M6 - [tests] Add hook timeout and failure-mode tests.

### M7 — Performance hardening
Criteria (exit):
- AI features do not introduce noticeable typing lag or memory bloat.
Success metrics:
- Budgets (set in M0) are met in perf runs.
- Leak harness shows bounded memory after repeated agent ops.
Tasks:
- [ ] - M7 - [sidecar] Instrument request latency per surface and cancellation success.
- [ ] - M7 - [sidecar] Track time-to-first-token for chat.
- [ ] - M7 - [sidecar] Measure indexer CPU/memory and log locally (opt-in).
- [ ] - M7 - [perf] Capture baseline memory snapshots after key scenarios.
- [ ] - M7 - [perf] Build automated leak test harness and scenario runner.
- [ ] - M7 - [core] Lazy-load heavy AI components.
- [ ] - M7 - [core] Ensure indexer runs off UI critical path.
- [ ] - M7 - [sidecar] Add backpressure on provider requests.
- [ ] - M7 - [perf] Add perf regression thresholds to CI.

### M8 — Parity polish
Criteria (exit):
- Feature parity v1 is credible for daily use.
Success metrics:
- User flows require fewer than 3 clicks for common actions.
- Diff and session workflows have no “dead ends”.
Tasks:
- [ ] - M8 - [extension] Add partial accept for tab suggestions.
- [ ] - M8 - [extension] Add grouped diffs for multi-file refactors.
- [ ] - M8 - [extension] Add slash commands and structured workflows.
- [ ] - M8 - [extension] Add workspace-level “intent/project brief” pinned context.
- [ ] - M8 - [extension+sidecar] Add session management: named sessions, export/import.
- [ ] - M8 - [decision] Decide whether AI settings sync is parity or V2 scope.
- [ ] - M8 - [extension] Improve UX polish (empty states, error states, loading).
- [ ] - M8 - [security][external-fix][upstream] Update Electron/Chromium/deps to reduce active vulns; flag as upstream VS Code fix with comment/tag.

### M9 — V2 bets
Criteria (exit):
- Pointer has clear differentiators beyond parity.
Success metrics:
- Headless agent can run in CI and produce patches consistently.
- Enterprise policy bundle prototype validated with a test org.
Tasks:
- [ ] - M9 - [sidecar] Implement `pointer-agent` headless/CI mode with patch output.
- [ ] - M9 - [sidecar] Add policy and secrets handling for CI mode.
- [ ] - M9 - [sidecar+cloud] Build PR review bot prototype (Bugbot-like).
- [ ] - M9 - [cloud] Add PR annotations and suggested changes.
- [ ] - M9 - [cloud] Integrate with GitHub checks.
- [ ] - M9 - [sidecar] Add enterprise policy bundles and audit log schema.
- [ ] - M9 - [sidecar] Add provider allowlists and data boundary controls.
- [ ] - M9 - [extension+sidecar] Add settings sync for AI config if approved in M8.
- [ ] - M9 - [research] Explore alternative runtime experiments (web-first/light shell).
- [ ] - M9 - [docs] Document why runtime experiments do not block core delivery.