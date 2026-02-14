# Pointer feature matrix
Clean matrix with acceptance criteria for MVP, Parity, and V2.

This file is designed to be used as:
- PRD appendix
- release gating checklist
- test plan starter

## Legend

- Scope:
  - MVP: must ship to be usable
  - Parity: closes major Cursor-style gaps
  - V2: differentiators and enterprise/automation
- Implementation:
  - Core fork: patch Code - OSS workbench/editor/platform
  - Built-in extension: shipped inside Pointer under `extensions/`
  - Sidecar service: separate process (recommended for heavy AI logic)
  - Hybrid: multiple components

## Feature summary table

| ID | Feature | Scope | Implementation | Acceptance criteria (summary) |
|---|---|---|---|---|
| P0 | Build and run | MVP | Core fork | Dev build runs via `npm run watch` and `./scripts/code.sh` and passes smoke tests |
| P1 | Pointer branding + AI surface | MVP | Core fork + built-in extension | Pointer icon/view container exists; Copilot UI hidden by default |
| P2 | Model Router | MVP | Sidecar service + built-in extension | Per-surface default provider/model; supports disable/allowlist; deterministic prompt assembly |
| P3 | Provider CLI adapters | MVP | Sidecar service | Codex CLI, Claude Code, OpenCode work with streaming and cancellation where supported |
| P4 | Tab completion (ghost text) | MVP | Built-in extension (or core fork if needed) | Inline suggestions show, accept with Tab, cancel fast, no typing lag |
| P5 | Chat UI + context attach | MVP | Built-in extension | Multi-turn chat, attach file/selection, stream responses, provider selector |
| P6 | Agent edits with diff-first apply | MVP | Built-in extension + sidecar | Agent proposes patches, user can apply/reject per file, no silent writes |
| P7 | Tool gating (terminal/fs/network) | MVP | Sidecar + built-in extension | Tools are disabled or confirm-by-default; every action is visible before execution |
| P8 | Workspace context engine v1 | MVP | Sidecar | Basic retrieval works; excludes respected; pinned context works |
| P9 | Rules | Parity | Sidecar + built-in extension | `.pointer/rules` applied predictably; visible in UI; precedence rules work |
| P10 | Hooks | Parity | Sidecar | Hooks can block or redact; timeouts enforced; safe execution |
| P11 | MCP integration | Parity | Sidecar + built-in extension | Connect local MCP servers; tool allowlist; show enabled tools |
| P12 | Slash commands + workflows | Parity | Built-in extension | `/commands` dispatch to templates; works across providers |
| P13 | Sessions and history | Parity | Built-in extension + sidecar | Named sessions, export/import, searchable history |
| P14 | Performance budgets + profiling harness | Parity | Core fork + sidecar | Defined budgets; automated perf smoke; leak regression harness |
| P15 | Settings sync for Pointer AI config | V2 | Built-in extension + service | Sync rules/prompts/provider defaults across machines (optional) |
| P16 | Headless/CI mode | V2 | Sidecar | `pointer-agent` runs tasks in CI and produces patches/PR artifacts |
| P17 | PR review bot (Bugbot-like) | V2 | Cloud service optional | PR scanning + comments + rules; safe permission model |
| P18 | Enterprise policy + audit | V2 | Sidecar + admin tooling | Allowlists, audit log schema, policy bundles |

---

# Detailed acceptance criteria

Below, each feature includes testable acceptance criteria in Given/When/Then form.

## P0 - Build and run

**Scope:** MVP  
**Implementation:** Core fork  

Acceptance criteria:
- Given a clean machine with prerequisites installed, when a dev runs `npm install`, it completes without manual edits.
- Given dependencies installed, when a dev runs `npm run watch`, the first build completes and stays watching.
- Given watch is running, when a dev runs `./scripts/code.sh` (macOS/Linux) or `./scripts/code.bat` (Windows), Pointer launches and can open a folder.
- Given Pointer is running, when the dev changes a Pointer-owned file, then Reload Window picks up the change without rebuild-from-scratch.

## P1 - Pointer branding + AI surface

**Scope:** MVP  
**Implementation:** Core fork + built-in extension  

Acceptance criteria:
- Given Pointer launches, when the Activity Bar is visible, then a Pointer icon exists and opens the Pointer view container.
- Given the Pointer view is open, then a “Pointer Chat” entry point exists (button or command).
- Given default settings, Copilot menus and Copilot commands do not appear in the primary UI.
- Given a user enables “compatibility mode”, Copilot-related features may reappear without breaking Pointer.

## P2 - Model Router

**Scope:** MVP  
**Implementation:** Sidecar service + built-in extension  

Acceptance criteria:
- Given a workspace is trusted, when `.pointer/config` sets default providers/models, then Pointer uses those defaults for Tab, Chat, and Agent surfaces.
- Given the user overrides the model in the UI, then that override takes effect immediately for the selected surface.
- Given a provider is disabled by policy, when a user tries to select it, then the UI blocks selection and explains why.
- Given a request is made, then Router emits a structured “request plan”:
  - provider
  - model
  - context sources included
  - tool permissions
  - token budget
- Given a request is canceled (typing or user action), then the provider process is canceled or the output is ignored within a bounded time.

## P3 - Provider CLI adapters

**Scope:** MVP  
**Implementation:** Sidecar service  

Acceptance criteria:
- Given the provider binary is missing, when the user selects it, then Pointer shows install instructions.
- Given the provider is installed, when the user clicks “Test provider”, then a short prompt succeeds and returns output.
- Given streaming is supported, chat streams tokens to the UI.
- Given the user cancels, the adapter attempts cancellation and no further output is applied to the UI.

Provider-specific acceptance criteria:
- Codex CLI: can run a simple code edit task in a sample workspace.
- Claude Code: can run a “plan then edit” task and return diffs or patches.
- OpenCode: can run a task and optionally produce JSON output if configured.

## P4 - Tab completion (ghost text)

**Scope:** MVP  
**Implementation:** Built-in extension (fallback to core fork if needed)

Acceptance criteria:
- Given a supported file, when the user pauses while typing, then a ghost text suggestion may appear.
- Given a suggestion is visible, when the user presses Tab, the suggestion is inserted.
- Given a suggestion is visible, when the user presses Escape, it disappears.
- Given the user keeps typing, suggestions cancel quickly and do not block typing.
- Given multi-cursor mode, suggestions do not corrupt the document and fail safely.

## P5 - Chat UI + context attach

**Scope:** MVP  
**Implementation:** Built-in extension  

Acceptance criteria:
- Given the user opens Pointer Chat, then they can:
  - start a new session
  - switch provider/model
  - send a prompt
  - see a streamed response
- Given the user selects code, when they click “Send selection”, then the selection is included in context and indicated in UI.
- Given the user attaches a file, then the file path is shown and can be removed before sending.
- Given the user sends a prompt, then the UI shows “what context was included” in a collapsible panel.

## P6 - Agent edits with diff-first apply

**Scope:** MVP  
**Implementation:** Built-in extension + sidecar  

Acceptance criteria:
- Given an agent task that requires edits, the agent returns a set of patches (or patch-like instructions) instead of silently writing files.
- Given patches exist, Pointer shows a diff view per file.
- Given the user clicks Apply, the patch is applied cleanly or fails with a clear conflict message.
- Given the user clicks Reject, the workspace remains unchanged for that patch.
- Given multiple files, the user can apply file-by-file or apply all.

## P7 - Tool gating (terminal/fs/network)

**Scope:** MVP  
**Implementation:** Sidecar + built-in extension  

Acceptance criteria:
- Terminal:
  - default is “confirm every command”
  - user can set allowlist patterns per workspace
  - every command is shown before execution
- Filesystem:
  - agent writes happen only via diff apply or explicit user approval
  - no hidden writes outside approved scope
- Network:
  - default disabled (or explicit confirmation)
  - if enabled, show destination domain before request where possible

## P8 - Workspace context engine v1

**Scope:** MVP  
**Implementation:** Sidecar  

Acceptance criteria:
- Given a workspace opens, file discovery respects `.gitignore` and `.pointer/excludes`.
- Given the user requests chat/agent, context retrieval returns relevant files/snippets within a set budget.
- Given pinned context items, they are included until unpinned.
- Given a file changes, retrieval sees new content without requiring a full reindex.

## P9 - Rules

**Scope:** Parity  
**Implementation:** Sidecar + built-in extension  

Acceptance criteria:
- Given `.pointer/rules/*.md` exist, when a request is made, rules are injected consistently.
- Given global rules exist, workspace rules override or extend based on precedence rules.
- Given a request is made, Pointer shows “Applied rules” with a list of rule files.

## P10 - Hooks

**Scope:** Parity  
**Implementation:** Sidecar  

Acceptance criteria:
- Given hooks are configured, they run in the correct order and cannot run forever (timeouts).
- Given a hook blocks a tool run, the UI shows the reason.
- Given a hook redacts content, the redaction is reflected in the “context sent” panel.
- Given hook code errors, Pointer fails safe: tool does not run and user is notified.

## P11 - MCP integration

**Scope:** Parity  
**Implementation:** Sidecar + built-in extension  

Acceptance criteria:
- Given an MCP server config, Pointer can connect and list available tools.
- Given tool allowlist is enforced, only allowed tools are callable.
- Given a tool call occurs, it is logged in the session timeline.

## P12 - Slash commands + workflows

**Scope:** Parity  
**Implementation:** Built-in extension  

Acceptance criteria:
- Given `.pointer/commands/` exists, commands appear as slash commands in chat.
- Given a command is invoked, it expands a prompt template and runs through Router.
- Given a command requires tools, it respects tool gating policy.

## P13 - Sessions and history

**Scope:** Parity  
**Implementation:** Built-in extension + sidecar  

Acceptance criteria:
- Given multiple sessions exist, user can name, search, and archive them.
- Given a session is exported, it produces a portable JSON file including references (not raw secrets).
- Given imported session, it renders correctly and can continue.

## P14 - Performance budgets + profiling harness

**Scope:** Parity  
**Implementation:** Core fork + sidecar  

Acceptance criteria:
- Define budgets:
  - tab p95 latency target
  - chat time-to-first-token target
  - memory ceiling after N operations
- Provide a repeatable perf scenario runner that fails CI when budgets regress.
- Provide memory snapshot scripts and a standard repro checklist.

## P15 - Settings sync for Pointer AI config

**Scope:** V2  
**Implementation:** Built-in extension + service  

Acceptance criteria:
- Given user signs in to a sync provider, Pointer AI settings sync across devices:
  - provider defaults
  - prompt templates
  - rules (optional)
- Sync is opt-in and supports self-hosting (future).

## P16 - Headless/CI mode

**Scope:** V2  
**Implementation:** Sidecar  

Acceptance criteria:
- Given a repo and a task prompt, `pointer-agent` produces:
  - a patch set
  - a summary
  - optional test run output
- CI mode never runs destructive commands without policy.

## P17 - PR review bot (Bugbot-like)

**Scope:** V2  
**Implementation:** Cloud service optional  

Acceptance criteria:
- Given a PR event, bot can:
  - run analysis
  - comment findings
  - suggest patches
- Rules can be applied per org and per repo.
- Permissions follow least privilege.

## P18 - Enterprise policy + audit

**Scope:** V2  
**Implementation:** Sidecar + admin tooling  

Acceptance criteria:
- Policies can disable providers, models, tools, and network access.
- Audit logs capture:
  - prompts (redacted)
  - context references
  - tool calls
  - patch applies
- Admin can export logs.

---

## References (public docs)

- VS Code build/run from source guidance (watch + scripts).  
- VS Code Extension API, including Chat Participant API and inline completion provider concepts.  
- VS Code agent docs for third-party agent integrations.  
- Cursor docs describing Tab, Rules, Hooks, MCP, Bugbot, and APIs.  
- MCP and ACP protocol docs for standard tool/agent connectivity.

