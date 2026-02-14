# Research 02: Agent Workflow, Docs, and Conventions

Temporary research note. Synthesizes references from VS Code, Codex AGENTS.md, Peter Steinberger’s workflow, steipete/agent-scripts, DocSetQuery, and practical agent usage. Use for Pointer IDE agent/rules/doc strategy—not committed as long-term docs.

---

## 1. Reasoning level: high is enough

- **Prefer `high` reasoning.** Reserve `xhigh` (or “ultrathink”) for genuinely tricky problems only.
- **Why:** Higher reasoning uses more tokens and is slower. For most tasks, high is sufficient; the bottleneck is often elsewhere (e.g. context or instructions).
- **Reference:** [Steipete – Shipping at Inference Speed](https://steipete.me/posts/2025/shipping-at-inference-speed): *“My go-to model is gpt-5.2-codex high. Again, KISS. There’s very little benefit to xhigh other than it being far slower.”*

---

## 2. Better docs beat more reasoning

- **Sometimes more reasoning doesn’t help.** Improving agent-facing documentation often has a bigger impact than cranking reasoning effort.
- **Prefer local, stable docs over web scraping.**  
  - Use **DocSetQuery** to produce **Markdown from Dash DocSet bundles** so agents get deterministic, citeable, local references.  
  - [DocSetQuery](https://github.com/PaulSolt/DocSetQuery): export/sanitize DocC/DocSet content to Markdown, build a local index, search by heading/section. CLI-first for agent scripting.
- **Workflow (DocSetQuery):** Search locally → fetch only what’s missing → sanitize for stable context → rebuild index. Keeps agent answers grounded in local, vetted Markdown without hitting remote docs every run.

---

## 3. Peter Steinberger’s post – “Shipping at Inference Speed”

**Read first:** [Shipping at Inference Speed \| steipete.me](https://steipete.me/posts/2025/shipping-at-inference-speed)  
**Blog to follow:** [steipete.me](https://steipete.me) — workflow and agent posts are consistently high signal.

**Takeaways:**

- **Model + workflow:** He ships at “inference speed”; limits are inference time and hard thinking, not typing. Most software is “boring” (data in → store → show); start as CLI so agents can call and verify.
- **Codex vs Opus:** Codex often reads a lot before writing (10–15 min); that reduces wrong fixes. Opus is more eager, good for small edits, less reliable on large refactors. He uses Codex for big work.
- **No “plan mode” theater:** Start a conversation, let the model explore/code/search, then “build” or “write plan to docs/*.md and build this.” Plan mode was a workaround for older models.
- **Multi-project queue:** He runs 3–8 projects; uses Codex queueing. One main project + satellites. “I’m the bottleneck,” not multi-agent orchestration.
- **Linear evolution:** Commits to main; rarely reverts/checkpoints. If wrong, ask the model to change it. Worktrees only when explicitly needed (e.g. messy state).
- **Cross-project copy:** “Look at ../other-project and do the same here” — reuse solved patterns across repos. Scaffold new projects by pointing at an existing one.
- **Docs as context:** `docs/` per project; script (`docs:list` / `bin/docs-list`) forces the model to read docs before coding. “Engineer codebases so agents can work in it efficiently.”
- **Config:** `model_reasoning_effort = "high"`, `tool_output_token_limit = 25000`, compaction tuned for context window; `unified_exec`, `apply_patch_freeform`, `web_search_request`, `skills`, etc.

---

## 4. steipete/agent-scripts – copy and adapt

**Repo:** [steipete/agent-scripts](https://github.com/steipete/agent-scripts)  
**Full guardrails:** [AGENTS.MD](https://github.com/steipete/agent-scripts/blob/main/AGENTS.MD) (canonical copy; he also mirrors to `~/AGENTS.MD` for Codex global).

**Ideas to adopt (make your own):**

- **Pointer-style AGENTS:** One canonical AGENTS file (e.g. in a shared `agent-scripts` repo or `~/.codex`). Per-repo file is a single line: “READ path/to/shared/AGENTS.MD BEFORE ANYTHING (skip if missing).” Repo-specific rules go after that.
- **Committer:** Bash helper that stages only listed files and enforces non-empty commit messages. **Critical when multiple agents work in one folder** — atomic, reviewable commits.
- **docs-list:** Script that walks `docs/`, enforces front matter (`summary`, `read_when`), prints summaries. Agents run it before coding so they open the right docs.
- **Conventions from his AGENTS.MD:** Telegraph style; min tokens; Conventional Commits; safe Git (no destructive ops unless explicit); “committer” on PATH; guardrails (e.g. `trash` for deletes); PR/CI via `gh`; no slash commands required — natural language “commit/push” is fine.
- **UI guidance:** Avoid “AI slop” — real typography, committed palette, 1–2 high-impact motions, depth in background; no purple-on-white clichés.

Sync rule: when you change shared helpers (e.g. committer, docs-list), copy back to the canonical repo and then out to every repo that uses them so they stay byte-identical.

---

## 5. Simple rules; no huge Plan.md

- **You don’t need complex rules or a giant Plan.md.** Good results come from:
  - Working on **one aspect of a feature** at a time.
  - **Handing off** clearly.
  - Letting the agent (e.g. Codex) do the work.
- **If you get bored:** Start another project; when you come back, the first one is often done (unless it’s a huge refactor).
- **Reference:** Steipete’s workflow — iterate by “play with it, touch it, feel it”; rarely a complete picture upfront. Systems that “take the full idea and deliver output” don’t fit that style.

---

## 6. Copy from other projects; Makefiles

- **Ask the agent to copy patterns from another project.** Peter does this constantly — e.g. “look at ../vibetunnel and do the same for Sparkle changelogs.”
- **Makefiles:** Have agents create Makefiles to build and run apps; for new projects, have them copy that structure from a reference project.
- **Workflow reference:** [How I use Codex GPT 5.2 with Xcode (My Complete Workflow)](https://youtu.be/o4iKnSYlhBQ) — shows Makefile/structure reuse in practice.

---

## 7. YOLO / danger mode

- **To get real work done without constant nagging,** you often need to allow more autonomy (e.g. “YOLO” or danger mode in Cursor/Codex).
- Balance with guardrails: atomic commits (committer), safe Git defaults, and clear “stop and ask” rules for destructive or ambiguous actions.

---

## Reference: VS Code and Codex layout

**VS Code (microsoft/vscode):**

- [Repository](https://github.com/microsoft/vscode): Code - OSS; TypeScript, Electron, layered architecture (`src/vs/base`, `platform`, `editor`, `workbench`, etc.).
- [.claude](https://github.com/microsoft/vscode/tree/main/.claude): Claude Code configuration.
- [.vscode](https://github.com/microsoft/vscode/tree/main/.vscode): VS Code workspace settings/tasks.
- [AGENTS.md](https://raw.githubusercontent.com/microsoft/vscode/main/AGENTS.md): Short pointer; detailed instructions live in [.github/copilot-instructions.md](https://raw.githubusercontent.com/microsoft/vscode/main/.github/copilot-instructions.md) (architecture, validation, coding guidelines).
- [SECURITY.md](https://raw.githubusercontent.com/microsoft/vscode/main/SECURITY.md): Microsoft security reporting (aka.ms/SECURITY.md).

**Codex – AGENTS.md discovery:**  
[Custom instructions with AGENTS.md (OpenAI)](https://developers.openai.com/codex/guides/agents-md/):

- **Global:** `~/.codex/AGENTS.md` or `AGENTS.override.md`.
- **Project:** From repo root down to cwd: `AGENTS.override.md` then `AGENTS.md` (and optional fallback filenames in config). One file per directory; concatenated root → cwd; later = override.
- **Size:** Truncation at `project_doc_max_bytes` (default 32 KiB). Can add fallback filenames (e.g. `TEAM_GUIDE.md`) in Codex config.

---

## Summary table

| Topic | Recommendation |
|-------|----------------|
| Reasoning | Prefer **high**; use xhigh only for genuinely tricky tasks. |
| Docs | **Better docs > more reasoning.** Prefer **local Markdown from DocSets** (DocSetQuery) over web scraping. |
| Steipete | Read “Shipping at Inference Speed”; follow his blog; adopt pointer-style AGENTS + committer + docs-list from agent-scripts. |
| Planning | **One aspect at a time**, hand off, let the agent run. No need for huge Plan.md. |
| Reuse | **Copy from other projects**; use **Makefiles** and copy structure for new projects. |
| Autonomy | **YOLO/danger mode** often needed to avoid constant approval nagging; pair with safe Git and atomic commits. |

---

*Generated for Pointer IDE scratchpad. Treat as temporary research; move or refine in docs/ when turning into project standards.*
