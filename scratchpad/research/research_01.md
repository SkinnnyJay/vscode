
Deep research prompt for the agent (copy-paste)

Project: Pointer (Cursor-like IDE fork)

Role
You are the Research Lead + Product Engineer + OSS Compliance lead for Pointer. Your job is to produce a detailed PRD and implementation plan to build a Cursor-like IDE by forking Code - OSS (VS Code repository) and integrating multiple AI backends primarily via official CLIs (Codex CLI, Claude Code, Cursor CLI, OpenCode, etc), plus optional API and local model support.

Non-negotiable constraints
1) No reverse engineering, decompiling, or copying proprietary Cursor code or assets.
   - Do NOT use any decompiled Cursor binary or minified proprietary code.
   - Clean-room reimplementation only.
2) Use only:
   - Public documentation
   - Open-source repositories under compatible licenses
   - Black-box behavior testing (using Cursor as an end-user, screenshots, feature exploration)
3) Must comply with VS Code and Marketplace licensing constraints:
   - Code - OSS is MIT, but “Visual Studio Code” product assets and Marketplace access have separate terms.
   - Plan for extension distribution without relying on Visual Studio Marketplace if that violates terms.
4) Output must be “engineering-ready”: clear epics, milestones, APIs, data contracts, risks, open questions, and success metrics.

Primary goal
Achieve Cursor-like feature parity while being provider-agnostic:
- Tab autocomplete
- Inline edit
- Chat and agentic code edits
- Project context and retrieval/indexing
- Rules/instructions + hooks
- CLI-powered behind the scenes by default
- API access and local models (where feasible)
- Strong performance (speed, memory, startup)
- Enterprise controls (policy, audit, data boundary) as future scope

Key “Cursor capability areas” to inventory
- Tab (autocomplete) UX parity: ghost text, diff previews, accept/partial accept, syntax highlighting, multi-file suggestion behavior
- Agent workflows: plan, multi-file edits, refactors, follow-up tasks, background agents
- Context ingestion controls: folder-level context, file-level pinning, exclusions, safety
- Rules system: global rules + repo rules + per-chat instructions
- Hooks: lifecycle hooks around agent actions (pre/post file read/write, tool call, terminal exec)
- MCP support: connect external tools and data sources
- Bug/PR review automation (“Bugbot” equivalent): PR scanning, CI feedback, issue generation
- CLI and headless usage: run agent from terminal and in CI

Pointer product definition
Pointer is a fork of Code - OSS (microsoft/vscode) with:
- Pointer-branded UI (no VS Code or Cursor trademarks)
- A first-class “Pointer” AI surface (sidebar/activity bar icon)
- Built-in provider adapters (CLI first, API optional)
- A unified model router with configurable defaults, prompt templates, and policy controls
- A sandboxed tool execution model for terminals, filesystem writes, and network access

Research deliverables (must produce all)
A) PRD (Markdown) with:
   1. Vision and principles (speed, reliability, safety, clean code, no anti-patterns)
   2. Personas and top workflows
   3. Feature list with priority (MVP vs parity vs future)
   4. Requirements by feature area (functional + non-functional)
   5. UX parity notes (how Cursor behaves, how Pointer should behave)
   6. Telemetry/privacy stance and enterprise posture
   7. Success metrics (latency, acceptance rate, crash-free sessions, memory ceiling)

B) Feature matrix (table)
Columns:
- Feature
- Cursor behavior (what it does, UX expectations)
- VS Code baseline capability (extension API vs requires core fork changes)
- Pointer approach (fork core vs bundled extension vs separate service)
- Dependencies (model/router/indexer/agent protocol)
- Risk and effort (S/M/L)
- Open questions

C) Architecture doc
Include:
- Diagrams for data flow and process model (renderer, extension host, worker processes)
- Provider adapter design:
  - CLI adapters (Codex CLI, Claude Code, Cursor CLI, OpenCode)
  - Optional API adapters (OpenAI/Anthropic direct)
  - Optional local model adapters (llama.cpp, Ollama, etc)
- Context engine:
  - workspace indexing, embeddings, caching, invalidation
  - “context budget” enforcement and transparency UI
- Tool execution framework:
  - terminal execution gating
  - filesystem write policies
  - network access policy
  - hooks framework
- Security model:
  - prompt injection resistance strategies
  - least-privilege, explicit confirmation for high-risk actions
  - audit log schema (future enterprise)
- Packaging and distribution plan:
  - extension marketplace strategy (Open VSX/private registry)
  - auto-update strategy
  - multi-platform builds

D) Upstream PR candidates (distinct headers)
Identify improvements that should be proposed upstream to microsoft/vscode (when feasible), each with:
- Motivation
- Proposed change
- Risk
- How it benefits VS Code ecosystem
- Whether it unblocks Pointer

E) Milestones and phases
Provide phases with entry/exit criteria and demo artifacts:
Phase 0: Fork + build reproducibility (clean/test/build/watch/package)
Phase 1: Pointer shell UI parity (layout, iconography, settings surfaces)
Phase 2: Model router + provider adapters (CLI-first)
Phase 3: Tab completion MVP
Phase 4: Chat + agent MVP (file edits + diff UI + tool calls)
Phase 5: Context/indexing + rules + hooks
Phase 6: Performance hardening (memory leaks, startup, responsiveness)
Phase 7: Bugbot/PR review + CI hooks (optional)
Phase 8: Enterprise controls (optional)

Must research and cite
Use high-quality sources, prioritize official docs and upstream repos. Include a References section.

Minimum required sources to use (start here)
- VS Code Extension API and docs:
  https://code.visualstudio.com/api
  https://code.visualstudio.com/docs
  https://github.com/microsoft/vscode
  https://github.com/microsoft/vscode/issues
- VS Code “Code - OSS vs VS Code distribution” and Marketplace limits:
  https://code.visualstudio.com/docs/supporting/FAQ
  https://github.com/microsoft/vscode/wiki/Differences-between-the-repository-and-Visual-Studio-Code
  https://cdn.vsassets.io/v/M190_20210811.1/_content/Microsoft-Visual-Studio-Marketplace-Terms-of-Use.pdf
- VS Code AI/agent extensibility:
  https://code.visualstudio.com/docs/copilot/agents/third-party-agents
  (Also find the “Chat Participant API” and related extension samples)
- Cursor docs and public info (do NOT reverse engineer):
  https://cursor.com/en-US/docs
  https://cursor.com/docs/api
  https://cursor.com/blog
  https://forum.cursor.com
- Codex and Claude IDE integrations:
  https://developers.openai.com/codex/ide/
  https://github.com/openai/codex
  https://github.com/anthropics/claude-code
  https://code.claude.com/docs/en/vs-code
- OpenCode:
  https://opencode.ai/
- CodexMonitor and Toad:
  https://github.com/Dimillian/CodexMonitor
  https://github.com/batrachianai/toad
  https://agentclientprotocol.com

Research methods to apply
1) Cursor feature inventory
- Extract features from Cursor docs, blog posts, release notes, forum announcements.
- Add user feedback clusters from Cursor forum, Reddit, X, GitHub discussions.
- For each feature: define exact UX behavior and acceptance criteria.

2) VS Code platform analysis
- Identify the exact extension points for:
  - inline completion (tab)
  - chat participants / agent UI integration
  - filesystem editing flows + diff UI
  - activity bar and view containers
- Identify what must be forked (core workbench/editor changes) vs what can be done as an extension.

3) Licensing and IP risk analysis
- Clarify what can be copied (MIT Code - OSS) vs what cannot (Cursor proprietary, VS Code product trademarks/assets).
- Clarify Marketplace constraints and define a distribution plan that is compliant.

4) Performance + quality
- Create a plan for profiling and perf budgets:
  - startup time, memory ceiling, typing latency, extension host overhead
- Identify known VS Code bottlenecks and how Pointer can improve them.

5) Output format rules
- Write the PRD and architecture docs in Markdown.
- Provide a concise executive summary and a detailed appendix.
- Provide a final “Open Questions” list with owners and proposed resolution path.
- Provide a “Definition of Done” for MVP and “Parity v1”.

Start now and produce the full deliverables.


⸻

Starter notes you should bake into the PRD (based on public sources)

Cursor has real moat in custom models and speed

Cursor publicly positions its agent model “Composer” as optimized for speed and software engineering via reinforcement learning, with tool use (search, edits, terminal) built into training. That means “Cursor-level quality” is not just UI, it is model + infra + product integration.  ￼

Your clone plan should explicitly separate:
	•	UI parity (highly achievable in a VS Code fork)
	•	Workflow parity (achievable with good agent orchestration)
	•	Model quality parity (hard, likely not equal without training + data + infra)

VS Code has official agent extension points you can leverage

VS Code now documents “third-party agents” integration so external agents can participate in the VS Code agent experience (instead of being second-class). Use this to integrate Codex and Claude without a separate UI surface.  ￼

Marketplace and “VS Code distribution” lock-downs are real

Key constraint for any Code - OSS fork:
	•	The Visual Studio Marketplace is intended for “In-Scope Products and Services” and the terms state you may install and use Marketplace offerings only with those in-scope products.  ￼
	•	Microsoft explicitly documents that Marketplace access and some branded assets are part of the VS Code distribution, not Code - OSS, and are governed by Marketplace Terms and product licensing.  ￼

So Pointer needs a real plan:
	•	Use Open VSX or a private registry for extensions, and document “how to install VSIX” flows.  ￼

Settings sync can be an early “Pointer beats Cursor” win

VS Code has built-in Settings Sync.  ￼
Cursor has public forum threads stating settings sync is not supported or inconsistent.  ￼
Pointer can ship reliable sync (profiles + UI state + AI configs) early as a differentiator.

⸻

A practical architecture direction for “CLI-first” providers

The fastest way to avoid every provider becoming a one-off is to standardize your internal agent interface.

Two relevant public protocols to consider:
	1.	Agent Client Protocol (ACP)
ACP is designed to connect editors to agents, defines JSON-RPC over stdio, and reuses MCP style types.  ￼
Toad is explicitly built around ACP to unify multiple agents in one interface.  ￼
	2.	MCP (Model Context Protocol)
MCP is widely used to connect tools and data sources to AI systems. Cursor supports MCP in their product docs.  ￼

Suggested internal layering (diagram):

Pointer (VS Code fork)
  |
  |-- Pointer AI UI (Chat, Tab, Inline Edit, Diff Review)
  |
  |-- Agent Orchestrator (core)
        |
        |-- Model Router (defaults, policies, per-feature model selection)
        |
        |-- Provider Adapters
        |     |-- Codex CLI adapter
        |     |-- Claude Code adapter
        |     |-- Cursor CLI adapter
        |     |-- OpenCode adapter
        |     '-- (optional) API adapters
        |
        |-- Context Engine
        |     |-- workspace index + embeddings cache
        |     '-- context budget + transparency UI
        |
        '-- Tool Gateway
              |-- Terminal (policy + allow/deny + audit)
              |-- FS edits (diff-first, atomic writes)
              '-- MCP servers (tools + data)

CodexMonitor is worth studying for orchestration patterns, since it manages multiple Codex agents and uses a codex app-server protocol.  ￼

⸻

Mini feature matrix starter (agent should expand this)

Legend: VS Code baseline means “in stock Code - OSS via extension APIs unless forked”.

Feature area	Cursor (public signal)	VS Code baseline	Pointer approach (recommended)	Notes / risks
Tab autocomplete	Dedicated “Tab” feature with ghost text and diff-like UX.  ￼	Inline completions are possible via extension APIs; VS Code docs note local models are not supported for inline suggestions in the built-in LM path.  ￼	Implement tab via core +/or bundled extension using inline completion provider, with router selecting per-feature model	Quality parity depends on model + latency
Inline edit (Cmd/Ctrl+K)	Cursor iterates on inline edit UI.  ￼	Possible with extensions, but deep UX parity might need fork	Fork for full parity in editor UX	Must keep typing latency low
Agent that edits files	Cursor agent + background agent.  ￼	VS Code agent/third-party agent support exists.  ￼	Prefer “VS Code-native agent integration” first, then enhance in fork	Avoid second-class UI for Claude/Codex
Rules system	Cursor supports rules / shared workflows.  ￼	No direct equivalent	Implement .pointer/rules + UI editor + per-workspace overrides	Do not clone file names that imply Cursor branding
Hooks	Cursor has agent hooks communicating via stdio JSON.  ￼	No direct equivalent	Implement Hook runtime in orchestrator with event bus + safe execution	High security impact
MCP	Cursor supports MCP.  ￼	MCP can be integrated via extensions	Add MCP client + server management UI	Treat MCP servers as untrusted
Bugbot-like PR review	Cursor markets Bugbot.  ￼	Not built in	Build optional GitHub App + CI integration	Needs security and permissions
Marketplace	VS Code distro integrates Visual Studio Marketplace.  ￼	Code - OSS forks do not get Marketplace access by default.  ￼	Use Open VSX / private marketplace	Critical for adoption


⸻

“VS Code lock-downs / limitations / unknowns” you should call out explicitly
	1.	Marketplace is not a given for forks
Microsoft documents Marketplace integration as part of the VS Code distribution, governed by Marketplace terms.  ￼
Also explicitly noted: the Marketplace is not available from open source builds.  ￼
	2.	Branding and trademarked assets
Microsoft documents trademarked assets (logos, product names) as closed-source parts of the distribution.  ￼
Pointer must be fully rebranded.
	3.	Remote Development and some debug adapters can be restricted
Microsoft documents that some remote development portions and certain proprietary debug adapters involve licensed components and handshake mechanisms.  ￼
Pointer should plan alternatives or ensure compliance.
	4.	Electron APIs upstream PR risk
VS Code contributing guidance warns about relying on Electron APIs they do not use and prefers web standards for compatibility.  ￼
So “fix Electron” needs a concrete plan and a realistic upstream strategy.

⸻

Hard-to-replicate areas (call out upfront)
	1.	Model quality and latency at Cursor level
Cursor’s Composer work suggests significant investment in RL, tool-use training, and speed optimizations.  ￼
	2.	Background/remote parallel agents
Cursor’s “Background Agent” implies orchestration and probably remote execution infrastructure, not just editor UI.  ￼
	3.	Ecosystem friction without Microsoft Marketplace
You need Open VSX or a private registry plan to avoid adoption failure.  ￼
	4.	Safety and trust boundaries
Any tool-executing agent needs strong policies to avoid accidental destructive commands. This is not optional for an IDE.

⸻

Upstream PR headers (starter list)

These are “headers” you can drop into your PRD as an upstream section. Your agent should fill in actual proposals after code reading and issue review.
	•	Upstream PR: Improve agent extensibility primitives and stabilize third-party agent APIs
	•	Upstream PR: Make inline completion provider hooks more performant and observable (profiling hooks, budgets)
	•	Upstream PR: Improve large-workspace performance defaults (watcher throttling, search/index scheduling)
	•	Upstream PR: Memory leak and renderer responsiveness investigations (linked issues + repro harness)
	•	Upstream PR: Better extension host isolation and crash containment (especially for agentic extensions)

(Your agent should map each to existing VS Code issues and verify feasibility before proposing.)

⸻

If you want, paste your agent’s final PRD output back here and I’ll:
	•	turn it into a tighter “MVP vs parity vs v2” backlog,
	•	produce a clean feature matrix with acceptance criteria,
	•	and draft your repo structure + “agent files” layout for fast iteration (TypeScript-first, DRY, testable).