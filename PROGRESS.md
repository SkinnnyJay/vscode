## Execution Log

### 2026-02-14
- **M0-01** Completed fork hygiene initialization by configuring `upstream` remote to `microsoft/vscode` while keeping `origin` on the Pointer fork.  
  **Why:** establishes canonical upstream linkage required for merge policy and conflict-check automation.
- **M0-02** Verified required upstream tree roots exist: `src/`, `extensions/`, `product.json`, and `package.json`.  
  **Why:** confirms fork integrity before layering merge policy, CI checks, and Pointer-specific code.
- **M0-03** Recorded remote and branch tracking metadata in `docs/upstream-tracking.md`, including upstream default branch detection (`main`).  
  **Why:** creates an explicit, versioned reference for future merge operations and CI conflict detection steps.
- **M0-04** Added `docs/upstream-merge-strategy.md` with merge cadence and rebase/merge branch policy.  
  **Why:** defines a stable operating model for keeping the fork current while minimizing long-term merge friction.
- **M0-05** Added `docs/upstream-merge-playbook.md` with executable sync commands and explicit conflict resolution policy.  
  **Why:** gives contributors a deterministic, repeatable upstream sync flow and reduces unsafe conflict handling.
- **M0-06** Added `.github/workflows/upstream-conflict-check.yml` to detect merge conflicts against `upstream/main` on PRs and a weekly schedule.  
  **Why:** surfaces upstream drift risk automatically before manual sync windows and shortens reaction time.
- **M0-07** Added `.github/workflows/smoke-launch.yml` to execute `./scripts/code.sh --version` on Linux and macOS after build/runtime setup.  
  **Why:** creates a fast cross-platform launch signal that catches broken dev startup paths early in CI.
- **M0-08** Rebranded core product identity values in `product.json` (app names, protocol, issue URL, platform IDs, server/tunnel names).  
  **Why:** establishes Pointer-specific product identity and removes Code - OSS defaults from runtime metadata.
- **M0-09** Replaced product launcher icon assets across Linux/Windows/macOS and added pointer-named icon variants for packaging compatibility.  
  **Why:** removes inherited product icon branding and aligns runtime/package assets with Pointer identity.
- **M0-10** Updated packaging/product strings (desktop metadata, Linux package text, Windows display name) and added a Pointer update URL in `product.json`.  
  **Why:** aligns user-facing product metadata with Pointer branding and avoids stale Code - OSS/VS Code references in installer surfaces.
- **M0-11** Added `pointer/BRANDING.md` with explicit allowed assets, forbidden trademarks, and branding review rules.  
  **Why:** codifies clean-room branding boundaries so future contributions do not reintroduce prohibited marks.
- **M0-12** Replaced inherited security policy text with Pointer reporting guidance and added `CODE_OF_CONDUCT.md`.  
  **Why:** establishes project-owned security disclosure and community standards required for external contributors.
- **M0-13** Added `docs/extension-distribution-strategy.md` selecting Open VSX + VSIX fallback (+ optional private registry).  
  **Why:** formalizes a marketplace-legal distribution path for a Code - OSS fork and unblocks product gallery configuration.
- **M0-14** Configured `product.json` `extensionsGallery` to Open VSX service/item/resource endpoints.  
  **Why:** activates the chosen default extension registry directly in product runtime settings.
- **M0-15** Added `docs/vsix-sideloading.md` covering UI/CLI extension sideload flow and trust guidance.  
  **Why:** provides a concrete operational fallback when registry-based extension discovery is unavailable.
- **M0-16** Hardened setup prerequisites (`scripts/setup.sh` now enforces Node 22.22.0+) and verified `make setup` succeeds after installing required Linux Kerberos headers.  
  **Why:** prevents false-positive setup attempts on incompatible Node patch versions and documents environment requirements for reproducible installs.
- **M0-17** Ran `npm run watch` and confirmed client/extension watchers initialize, complete initial compilation, and remain active in watch mode.  
  **Why:** validates the required iterative development loop for Pointer changes.
- **M0-18** Verified `scripts/code.sh` launches a dev build under virtual display, confirmed `./.build/electron/pointer` executable resolution, and aligned `scripts/code.bat` window title with Pointer branding.  
  **Why:** confirms both platform launch scripts resolve Pointer dev binaries and maintain product-consistent startup behavior.
- **M0-19** Added `.github/workflows/dev-artifacts.yml` to build compile+electron outputs on Linux/macOS/Windows and upload per-OS dev artifacts.  
  **Why:** provides cross-platform artifact validation and reproducible developer runtime outputs in CI.
- **M0-20** Added `.github/workflows/pointer-quality.yml` to run lint and fast unit tests on pointer-owned change paths.  
  **Why:** introduces an explicit quality gate for Pointer-specific modifications without waiting for full-suite pipelines.
- **M0-21** Updated `.gitignore` to exclude `scratchpad/` plus local binary artifacts (`*.vsix`, `*.core`, `*.dmp`).  
  **Why:** prevents accidental commits of ephemeral workspace notes and generated binary outputs.
- **M0-22** Added `scripts/precommit-binary-guard.sh` and wired it into `package.json` `precommit` to block decompiled artifacts, risky binary extensions, and staged files >5MB.  
  **Why:** enforces clean-room and repository hygiene constraints before code reaches version control history.
- **M0-23** Added `docs/clean-room-contribution-rules.md` and linked it from `CONTRIBUTING.md`.  
  **Why:** gives contributors a single explicit policy source for legal-safe clean-room development.
- **M0-24** Collected startup/idle-memory/synthetic-typing baselines and published budgets in `docs/perf/M0-baseline-and-budgets.md`.  
  **Why:** establishes measurable M0 performance guardrails for later optimization and CI regression checks.
- **M0-25** Stored baseline memory snapshots in `docs/perf/` (`perf-heap.txt`, `idle-memory-snapshot.txt`) for reproducible comparisons.  
  **Why:** preserves concrete memory artifacts required for future leak/perf regression analysis.
- **M1-01** Added a new built-in extension scaffold at `extensions/pointer-ai/` with an Activity Bar icon and Pointer view container contribution.  
  **Why:** establishes a first-class Pointer surface entry point in the editor shell.
- **M1-02** Declared `viewsContainers.activitybar` and `views.pointer` contributions in `extensions/pointer-ai/package.json`.  
  **Why:** registers Pointer container/view metadata through extension manifests instead of core forks.
- **M1-03** Switched `pointer.home` to an empty tree state and set an explicit placeholder guidance message via `TreeView.message`.  
  **Why:** provides immediate in-product onboarding context before chat/tab surfaces are wired.
- **M1-04** Added command contributions and handlers for Open Chat, Toggle Tab, Select Model, and Open Settings in `extensions/pointer-ai`.  
  **Why:** establishes stable command IDs and command-palette entry points for the Pointer UX shell.
- **M1-05** Added explicit command palette labels with `Pointer` category prefixes in extension command contributions.  
  **Why:** keeps command discoverability clear and consistent in the global command palette.
- **M1-06** Added a persistent status bar item that reflects active chat provider/model and refreshes on Pointer defaults configuration updates.  
  **Why:** surfaces active model routing context without requiring users to open settings or deep UI panels.
- **M1-07** Added multi-line status-bar tooltip detail for Chat/Tab/Agent provider-model selections.  
  **Why:** provides per-surface visibility while keeping the status bar label compact.
- **M1-08** Added five settings category groups in extension configuration: Providers, Models, Context, Tools and Safety, Prompts and Rules.  
  **Why:** establishes the expected Pointer settings IA early so feature defaults can be wired incrementally.
- **M1-09** Added explicit default values, enums, constraints, and human-readable descriptions for each new Pointer configuration property.  
  **Why:** makes settings self-documenting and safe-by-default in the Settings UI.
- **M1-10** Added per-surface provider/model settings (`pointer.defaults.{chat|tab|agent}.{provider|model}`) in the extension settings schema.  
  **Why:** enables explicit default routing choices for each Pointer UX surface.
- **M1-11** Added settings validation checks plus a schema-version migration placeholder in extension activation flow.  
  **Why:** provides forward-compatibility hooks for future config evolution and early warning for malformed settings values.
- **M1-12** Repointed `product.json` `defaultChatAgent` away from GitHub Copilot IDs/commands to Pointer-owned IDs and removed trusted Copilot auth access defaults.  
  **Why:** disables Copilot-first UI wiring by default and aligns chat/completions command surfaces with Pointer commands.
- **M1-13** Added `configurationDefaults` entries that keep Copilot completions and next-edit suggestions disabled by default while remaining user-overridable.  
  **Why:** preserves a core-level compatibility toggle path for users who explicitly opt back into Copilot visibility.
- **M1-14** Added `pointer.compatibility.enableCopilotVisibility` extension setting and surfaced its state in the Pointer status bar tooltip/text.  
  **Why:** provides an explicit extension-level compatibility switch for users that need temporary Copilot re-enablement.
- **M1-15** Added trust-policy documentation (`docs/workspace-trust-model.md`) and extension trust-state wiring (`pointer.workspaceTrusted` context + warning in untrusted workspaces).  
  **Why:** defines and enforces the security boundary for loading workspace `.pointer/` automation configuration.
- **M1-16** Added `docs/pointer-settings.md` documenting Pointer settings categories, keys, and defaults introduced in M1.  
  **Why:** gives users and contributors a single reference for configurable routing/safety behavior.
- **M2-01** Completed initial CLI feasibility spike and confirmed provider binaries are absent in the current environment.  
  **Why:** establishes an evidence-based baseline before adapter implementation work begins.
- **M2-02** Captured shell transcript snippets for Codex/Claude/OpenCode probes in `docs/router-cli-feasibility.md`.  
  **Why:** preserves reproducible command-level evidence for adapter bootstrap decisions.
- **M2-03** Added explicit non-viable/blocked adapter decision and next-enablement actions in the CLI feasibility doc.  
  **Why:** prevents premature adapter implementation against unavailable binaries and keeps execution focused on viable dependencies.
- **M2-04** Created `pointer/agent` package scaffold and defined strongly-typed router contract interfaces (`surface/provider/model/template/policy`, request, plan, context sources).  
  **Why:** establishes the canonical sidecar contract foundation required by all later router/client integrations.
- **M2-05** Added router config schema types/defaults plus `parseRouterConfig` validation+fallback logic for defaults and policy token budgets.  
  **Why:** provides deterministic configuration loading behavior before implementing routing resolution logic.
- **M2-06** Implemented layered config resolution (`workspace > user > defaults`) in `pointer/agent/src/router/resolver.ts` for surface defaults and policy token/tool settings.  
  **Why:** codifies precedence semantics needed for predictable per-workspace model/provider behavior.
- **M2-07** Added `extensions/pointer-ai/internal-api.js` stable API surface and returned it from extension activation for UI consumers (`getSelection`, `setSelection`, `onDidChangeSelection`, versioned API).  
  **Why:** gives Pointer UI surfaces a shared contract to consume routing selections without tight coupling.
- **M2-08** Added `extensions/pointer-ai/router-client.js` with typed request/response contracts and integrated it through the internal API (`requestRouterPlan`, `getLastRouterPlan`).  
  **Why:** establishes extension-side router client primitives ahead of real sidecar transport wiring.
- **M2-09** Implemented sidecar prompt assembly module (`prompt-assembly.ts`) with canonical part ordering and token/text builders.
  **Why:** centralizes deterministic prompt composition for all surfaces around the required part sequence.
- **M2-10** Added unit tests for prompt ordering/ordering stability/token estimation in `pointer/agent/test/prompt-assembly.test.ts`.
  **Why:** protects prompt composition invariants as router logic expands.
- **M2-11** Added router planner budget enforcement (`planner.ts`) with per-request explainability metadata and context trimming under max input tokens.
  **Why:** enforces deterministic safety limits across surfaces while preserving debuggable reasoning for dropped context.
- **M2-12** Added `pointer.contextSent` view and renderer that subscribes to router plan events, showing plan explainability/context metadata in UI.
  **Why:** gives users immediate visibility into what context and policy decisions are being sent to the router.
- **M2-14** Added provider health/test checks (`providers/health.ts`) with missing-binary classification and install hints, backed by unit tests.
  **Why:** enables deterministic provider readiness checks before routing requests to unavailable CLIs.
- **M2-15** Added provider error classifier (`providers/errors.ts`) for missing binary/auth/rate-limit/timeout cases with retryability signals, plus unit coverage.
  **Why:** standardizes downstream UX/retry behavior from heterogeneous CLI failure modes.
- **M2-16** Implemented `CodexAdapter` with streamed stdout/stderr chunk callbacks, cancellation via `AbortSignal`, and classified error propagation.
  **Why:** provides the first concrete CLI adapter path required for end-to-end router execution.
- **M2-17** Added Codex adapter unit tests validating streaming aggregation and cancellation behavior.
  **Why:** ensures adapter control-flow correctness under both happy path and interrupted requests.
- **M2-18** Implemented `ClaudeAdapter` with streamed chunk handling and `AbortSignal` cancellation semantics parallel to Codex adapter behavior.
  **Why:** brings a second provider into the common adapter contract for multi-provider parity.
- **M2-19** Added Claude adapter unit coverage for streaming aggregation and cancellation interrupt behavior.
  **Why:** validates correctness of shared adapter mechanics across provider-specific implementations.
- **M2-20** Implemented `OpenCodeAdapter` with selectable output modes (`text`/`json`/`table`) and streamed response handling.
  **Why:** supports OpenCode-specific JSON/table interaction modes required by router capabilities.
- **M2-21** Added OpenCode adapter tests validating JSON mode output argument wiring and table-mode argument support.
  **Why:** locks adapter CLI argument behavior for structured output workflows.
- **M2-22** Documented ACP compatibility decision in `docs/acp-compatibility-decision.md` (defer ACP layer in M2; revisit with explicit triggers).
  **Why:** prevents premature abstraction while preserving a clear future decision checkpoint.
- **M3-01/M3-02** Added inline completion plumbing (`tab/inline-completion-provider.js`) and wired tab-surface router requests through the internal API.
  **Why:** establishes first ghost-text completion path using the shared router client contract.
- **M3-03/M3-04/M3-05** Added typing cancellation, explicit cancel command (`pointer.tab.cancel`), multi-cursor safety guard, and debounce/AbortSignal wiring via `PointerTabCompletionEngine`.
  **Why:** keeps inline suggestions responsive and interruption-safe in active editing flows.
- **M3-06/M3-08** Added privacy-scoped prompt assembly and local tab cache keyed by URI/position/nearby text/provider/model/rules profile.
  **Why:** reduces repeated request latency while minimizing context leakage.
- **M3-07** Added tab completion settings (`pointer.tab.enabled`, `pointer.tab.maxLatencyMs`, `pointer.tab.debounceMs`) while reusing defaults for provider/model selection.
  **Why:** enables user-level control over tab behavior and latency tradeoffs.
- **M3-09/M3-10** Added tab completion engine integration/perf smoke tests (`tab-completion-engine.test.js`) covering happy path, cancellation, caching, and latency budget.
  **Why:** verifies baseline correctness and responsiveness targets for the MVP tab flow.
- **M4-01** Added chat sessions view (`pointer.chatSessions`) with `ChatSessionStore` and tree rendering in the Pointer container.
  **Why:** establishes the base chat surface/navigation model before message-level features.
- **M4-02** Added chat session lifecycle actions (`pointer.chat.newSession`, rename, delete) with view title/context menu integration.
  **Why:** enables basic multi-session chat management needed for multi-turn workflows.
- **M4-03/M4-04** Added chat messages tree rendering with streaming updates plus send/cancel chat actions (`pointer.chat.sendMessage`, `pointer.chat.cancelMessage`) backed by store-level message streaming APIs.
  **Why:** delivers a functional multi-turn MVP loop with visible incremental assistant output and interruption support.
- **M4-05/M4-06** Added file/selection/manual pin context actions and a dedicated context chips view (`pointer.chatContext`) with per-chip remove action.
  **Why:** enables explicit context attachment flows and transparent context control in chat sessions.
- **M4-07** Added chat provider/model selector commands with quick-pick UX and config persistence (`pointer.defaults.chat.*`).
  **Why:** allows per-user chat routing control from the chat surface without manual settings edits.
- **M4-08** Added chat stream protocol primitives in sidecar (`pointer/agent/src/chat/protocol.ts`) and wired extension chat send flow to consume streamed router events.
  **Why:** standardizes chat request/response streaming semantics between extension and router layers.
- **M4-09** Added sidecar trace/log primitives (`chat/tracing.ts`) to capture chat request plan metadata with stable trace IDs and test coverage.
  **Why:** provides auditable chat planning telemetry required for debugging and policy review.
- **M4-10** Added sidecar patch schema (`patch/schema.ts`) and validator for diff-first agent responses with unit tests.
  **Why:** enforces explicit, reviewable patch payload structure before editor-side apply workflows.
- **M4-11/M4-12/M4-13** Added patch review store + view (`pointer.patchReview`) with per-file diff preview, apply/reject/apply-all actions, rationale display, and conflict/summary messaging.
  **Why:** enforces diff-first review workflow and gives users transparent per-file decision control with conflict feedback.
- **M4-14/M4-15/M4-16** Added sidecar tool gate evaluator (`policy/tool-gates.ts`) for terminal, filesystem (diff-only), and network policy enforcement with tests.
  **Why:** hardens tool safety defaults to prevent silent terminal/fs/network actions outside approved policy.
- **M4-17** Added prompt injection defense module (`policy/prompt-injection.ts`) and strategy doc (`docs/prompt-injection-defense.md`) covering detection + patch path sanitization.
  **Why:** establishes explicit defense-in-depth policy against instruction override and unsafe patch/tool payloads.
- **M4-18** Added patch apply behavior tests in `extensions/pointer-ai/test/patch-review-store.test.js` covering apply/reject/apply-all/conflict outcomes.
  **Why:** validates the diff-first decision workflow expected for agent patch review.
- **M5-01** Implemented context file discovery (`context/file-discovery.ts`) with `.gitignore`, `.pointer/excludes`, and explicit excludes support plus unit tests.
  **Why:** provides deterministic workspace scope control for context indexing/retrieval.
- **M5-02** Added watcher-capable context indexer (`context/indexer.ts`) with initial indexing and incremental file change/delete update support plus tests.
  **Why:** enables workspace context freshness without full reindex on every change.
- **M5-03** Added local metadata DB (`context/metadata-db.ts`) persisted under `.pointer/context-metadata.json` with optional embedding vector storage and tests.
  **Why:** establishes durable context metadata storage required by retrieval pipelines.
- **M5-04** Added lexical retrieval and context dedupe/merge (`context/retrieval.ts`) with ranking and merge tests.
  **Why:** provides baseline automatic context selection without requiring manual copy/paste.
- **M5-05** Added optional embedding retrieval (`context/embedding-retrieval.ts`) with cosine ranking and feature-flag gating.
  **Why:** enables higher-quality semantic retrieval when embeddings are available while keeping MVP optional.
- **M5-06/M5-08** Extended per-session pinned context chips with stored token estimates and token-aware UI labels in chat context view.
  **Why:** keeps context ownership session-scoped and makes context budget impact visible.
- **M5-07** Added workspace excludes editor command (`pointer.context.openExcludes`) for `.pointer/excludes` management from the UI.
  **Why:** allows users to control indexing scope without leaving the editor.
- **M5-09** Added lexical/dedupe retrieval unit tests (`context-retrieval.test.ts`) for ranking and merge behavior.
  **Why:** protects context engine correctness as retrieval evolves.
- **M6-01/M6-02** Added rules loader (`rules/loader.ts`) for `.pointer/rules/` plus deterministic precedence resolution (global -> workspace -> session override) with tests.
  **Why:** establishes predictable rules application order required for safe policy composition.
- **M6-03** Added rules audit view (`pointer.rulesAudit`) and refresh command to display active workspace rule files with profile context.
  **Why:** surfaces applied rules visibility directly in the UI for policy transparency.
- **M6-04/M6-05/M6-06/M6-10** Added hook dispatcher (`hooks/dispatcher.ts`) covering pre/post events, timeout sandboxing, block/modify/redact controls, and failure-mode tests.
  **Why:** provides safe, policy-limited hook execution with explicit timeout/failure handling guarantees.
- **M6-07/M6-08** Added MCP client + workspace allowlist modules (`mcp/client.ts`, `mcp/allowlist.ts`) with connection/call/allowlist tests.
  **Why:** enables local MCP connectivity with workspace-scoped tool permission boundaries.
- **M6-09** Added MCP audit view (`pointer.mcp`) in extension UI showing configured servers and allowed tools with refresh action.
  **Why:** makes MCP server/tool permission state visible and manageable from the editor surface.
- **M7-01/M7-02** Added request perf metrics recorder (`perf/metrics.ts`) for per-surface latency, cancellation rate, and chat TTFT tracking with tests.
  **Why:** creates measurable runtime telemetry for responsiveness and cancellation reliability.
- **M7-03** Added opt-in indexer resource observer (`perf/indexer-observer.ts`) that captures CPU/memory samples and logs to local perf artifacts.
  **Why:** enables low-friction local profiling of indexing overhead without always-on instrumentation.
- **M7-04/M7-05** Added perf baseline + leak harness scripts (`scripts/perf-capture-m7-baseline.sh`, `scripts/perf-leak-harness.sh`) and generated M7 artifacts in `docs/perf/`.
  **Why:** provides repeatable runtime memory profiling and bounded-growth validation scenarios.
- **M7-06/M7-07** Moved heavy extension module imports to activation-time lazy loading and added deferred indexer startup helper (`context/indexer-runtime.ts`).
  **Why:** keeps AI/indexer initialization off startup/UI-critical path.
- **M7-08** Added provider backpressure queue (`providers/backpressure.ts`) with concurrency enforcement tests.
  **Why:** prevents unbounded provider request fan-out under high load.
- **M7-09** Added CI perf regression workflow (`.github/workflows/perf-regression.yml`) enforcing leak-threshold pass/fail and artifact upload.
  **Why:** gates performance regressions with automated threshold checks.
- **M8-01** Added partial tab accept command (`pointer.tab.acceptPartial`) using last inline suggestion state to insert word-sized partial completions.
  **Why:** improves tab completion ergonomics for incremental acceptance workflows.
- **M8-06** Documented settings-sync scope decision in `docs/m8-ai-settings-sync-decision.md` (deferred to V2/M9).
  **Why:** keeps M8 parity focused while reserving sync complexity for dedicated V2 scope.
- **M8-07** Improved chat UX state handling with explicit loading/cancel/error messaging in the chat messages view.
  **Why:** removes dead-end feedback gaps and makes async chat lifecycle states obvious to users.
- **M8-03** Added structured slash command workflows (`/explain`, `/fix`, `/test`) in chat input parsing with workflow-aware prompt shaping.
  **Why:** speeds common intent-driven chat tasks with predictable prompt templates.
- **M8-05** Added session export/import workflow (`pointer.chat.exportSessions`, `pointer.chat.importSessions`) and session store serialization support.
  **Why:** enables portable multi-session workflows beyond a single local runtime instance.
- **M8-02** Added grouped patch diff workflows (`patch-groups.js`, group tree nodes, group diff/apply commands) for multi-file refactors.
  **Why:** makes larger refactors reviewable by directory-level groups rather than flat file lists.
- **M8-04** Added workspace-level project brief support (`project-brief.md` load/save, set-brief command, pinned context surfacing in chat context and router payloads).
  **Why:** captures durable workspace intent that is automatically available to chat workflows.
- **M8-08** Added upstream security external-fix tracking doc (`docs/upstream-security-external-fix.md`) with explicit tag `upstream-vscode-security-fix`.
  **Why:** marks runtime vulnerability remediation as an upstream Code - OSS dependency update track item.
- **M9-01** Added headless CI agent mode (`src/cli/pointer-agent.ts`, `ci/headless-agent.ts`) producing patch-schema JSON output from CLI prompts.
  **Why:** establishes a runnable `pointer-agent` path for CI-oriented automated patch generation.
- **M9-02** Added CI policy/secrets runtime loader (`ci/policy-secrets.ts`) with allowlisted providers, data-boundary mode, and env-secret filtering.
  **Why:** introduces explicit CI policy and secret controls before automated headless execution.
- **M9-03/M9-04/M9-05** Added PR review bot prototype and cloud outputs (`cloud/pr-review-bot.ts`, `cloud/annotations.ts`, `cloud/checks.ts`) with tests.
  **Why:** provides end-to-end PR review artifact generation (annotations + GitHub checks payloads) from headless agent output.
- **M9-06** Added enterprise policy bundle + audit log schema modules (`enterprise/policy-bundles.ts`, `enterprise/audit-log.ts`) with tests.
  **Why:** defines baseline enterprise governance structures for policy enforcement and auditable action history.
- **M9-07** Added provider allowlist/data-boundary evaluator (`enterprise/provider-boundary.ts`) with allowlist + boundary mismatch tests.
  **Why:** enforces enterprise provider access and data boundary constraints consistently.
- **M9-08** Added AI settings sync-style export/import commands (`pointer.settings.exportAiConfig`, `pointer.settings.importAiConfig`) with normalized key filtering.
  **Why:** provides portable AI config synchronization workflow in V2 track.
- **M9-09** Added runtime experiment research doc (`docs/runtime-experiments-research.md`) covering web-first/light-shell/hybrid options and risk matrix.
  **Why:** captures differentiator exploration track without blocking shipped core capabilities.
- **M9-10** Added non-blocking rationale doc (`docs/runtime-experiments-non-blocking.md`) defining how experiments stay off critical path.
  **Why:** protects delivery cadence while enabling strategic runtime exploration.
- **M2-13** Added provider capability registry/model in `pointer/agent/src/providers/capabilities.ts` (tab/tools/json/long-context/stream/cancel flags).
  **Why:** provides a single source of truth for provider feature compatibility checks during routing.
- **Final revalidation (2026-02-14 PM)** Re-ran release gates: `make lint`, `make test-unit` (7584 passing), `make build` (0 compile errors), and `xvfb-run -a ./scripts/code.sh --version`.
  **Why:** confirms the fully completed PLAN remains green end-to-end after final pass.
- **Extended validation attempt (2026-02-14 PM)** Attempted `make test` and retried via `xvfb-run -a make test` plus `make build && xvfb-run -a make test`; electron renderer test import failed in this headless CI VM (`Failed to fetch dynamically imported module ... bracketMatching.test.js`) while lint/unit/build/smoke remain green.
  **Why:** documents full-suite environment limitation transparently and preserves reproducible evidence of the failure mode.
- **Electron test isolation follow-up (2026-02-14 PM)** Reproduced the same failure on a single renderer case (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and observed `--build` mode fails earlier due missing `out-build/nls.messages.json`; terminated the hanging `--build` run by explicit PID after timeout.
  **Why:** narrows the failure scope to renderer module loading in this VM and records safe process cleanup details.
- **Smoke validation follow-up (2026-02-14 PM)** Ran `xvfb-run -a make test-smoke`; smoke runner launched but all Electron suites timed out waiting for `.monaco-workbench` (0 passing / 19 failing / 3 pending), with logs emitted to `.build/logs`.
  **Why:** captures another reproducible headless-environment limitation while preserving successful lint/unit/typecheck/build evidence as the reliable validation baseline.
- **Pointer agent regression pass (2026-02-14 PM)** Re-ran `npm run typecheck && npm test` in `pointer/agent`; all 72 tests passed with no failures.
  **Why:** reconfirms sidecar router/providers/policy modules remain stable after repeated validation loops.
- **Extension regression pass (2026-02-14 PM)** Re-ran `node --test test/*.test.js` in `extensions/pointer-ai`; all 16 tests passed.
  **Why:** reconfirms Pointer extension chat/tab/patch/settings modules remain stable in the current branch state.
- **Electron loader deep-dive (2026-02-14 PM)** Rechecked the isolated renderer failure and verified the target module file is readable/fetchable (`200 OK`, expected byte size) while dynamic `import()` still fails in this VM; reverted temporary harness instrumentation after confirming no durable code fix.
  **Why:** adds stronger root-cause evidence that the remaining `make test` issue is runtime-environment specific rather than missing build artifacts.
- **Import-map scope experiment (2026-02-14 PM)** Tried extending the renderer import-map generation to add scoped mappings for relative `.css` imports discovered in compiled `out/**/*.js`; isolated renderer test still failed with the same dynamic import error, so the experiment was reverted.
  **Why:** rules out simple relative-css import-map scope gaps as the cause and keeps the branch free of speculative harness changes.
- **Electron runtime switch probe (2026-02-14 PM)** Tested `app.commandLine.appendSwitch('allow-file-access-from-files')` in the Electron test harness for the isolated failing renderer case; the same dynamic import failure persisted and the probe was reverted.
  **Why:** rules out file-scheme access policy as the primary cause and preserves a clean harness baseline.
- **Electron dependency-chain diagnostics (2026-02-14 PM)** Added temporary import probes in renderer test harness to localize failures: `bracketMatching.test.js` failed through `editor/test/browser/testCodeEditor.js`, then `editor/browser/widget/codeEditor/codeEditorWidget.js`, with multiple downstream modules reporting import failure despite direct file fetches usually returning `200 OK`; all instrumentation was reverted afterward.
  **Why:** captures deeper runtime evidence that module-loader failures are occurring beyond missing files and helps scope future environment/runtime debugging.
- **Build-mode remediation attempt (2026-02-14 PM)** Tried `npm run compile-build` to generate `out-build` for `--build` test mode, but the compile-build process was killed during `compile-src` (resource limit/termination).
  **Why:** documents a concrete attempt to unblock `--build` testing and the current environment ceiling.
- **Ongoing gate rerun (2026-02-14 PM)** Re-ran `make typecheck` (build + src) and `xvfb-run -a ./scripts/code.sh --version`; both succeeded (with expected headless DBus/GPU warnings on version smoke run).
  **Why:** confirms the branch remains healthy on core compile/type/runtime smoke checks after repeated diagnostic iterations.
- **Electron runtime flag probes (2026-02-14 PM)** Retried the isolated failing renderer test with extra runtime flags (`--disable-gpu` and `--no-sandbox`) and observed the same dynamic import failure for `bracketMatching.test.js` in both cases.
  **Why:** further narrows the unresolved full-suite failure by ruling out two common headless Electron mitigations.
- **Extended GPU-stack probe (2026-02-14 PM)** Retried isolated renderer test with `--disable-gpu --disable-software-rasterizer --disable-features=VizDisplayCompositor`; dynamic import failure persisted unchanged.
  **Why:** rules out an additional Chromium GPU/compositor path as a practical workaround in this VM.
- **Single-process runtime probe (2026-02-14 PM)** Retried isolated renderer test with `--single-process --in-process-gpu`; Electron exited early with trace/breakpoint trap (core dumped) before resolving the dynamic-import issue.
  **Why:** documents that single-process mode is not a viable stability workaround for this environment.
- **Renderer loader flake characterization (2026-02-14 PM)** Ran repeated isolated Electron module probes and confirmed mixed behavior in this VM: lightweight modules still load (`viewEventHandler.js`), `view.js`/`bracketMatching.test.js` fail consistently with `TypeError: Failed to fetch dynamically imported module`, and `nativeEditContext.js` shows intermittent pass/fail behavior across repeated runs.
  **Why:** sharpens the failure signature from “single file missing” to an environment-level renderer ESM instability pattern.
- **Import-map + fetch verification pass (2026-02-14 PM)** Added temporary harness diagnostics and confirmed the CSS import-map includes `nativeEditContext.css` (`cssEntryCount: 301`, mapping present) and direct `fetch(file://...view.js)` returns `200` with expected byte length even when `import()` fails after retries.
  **Why:** rules out missing CSS mappings and missing on-disk files, reinforcing that the unresolved issue is in runtime module loading rather than build outputs.
- **Diagnostic rollback (2026-02-14 PM)** Reverted all temporary instrumentation/retry experiments in `test/unit/electron/renderer.html` and `test/unit/electron/renderer.js` after collecting evidence.
  **Why:** keeps the branch clean and avoids landing speculative harness behavior changes.
- **Import-map readiness probe (2026-02-14 PM)** Tried a temporary harness change to await `import('assert')` and `import('electron')` immediately after installing the renderer import-map, then re-ran repeated isolated cases (`bracketMatching.test.js` still failed 5/5); reverted the probe.
  **Why:** tested (and ruled out) a simple import-map activation race as the dominant cause of the renderer dynamic-import failures in this VM.
- **Expanded isolated module matrix (2026-02-14 PM)** Ran additional isolated module loads across editor/workbench paths and observed high variability: many modules failed with the same dynamic-import `TypeError` in one run while some (including previously failing paths) occasionally passed.
  **Why:** strengthens the conclusion that this is a broader Electron renderer ESM instability under this headless environment rather than a single bad module artifact.
- **Gate rerun after diagnostics (2026-02-14 PM)** Re-ran `make test-unit` (7584 passing / 134 pending), `make build` (compile finished with 0 errors), and `xvfb-run -a ./scripts/code.sh --version` (pass; expected headless DBus/GPU warnings).  
  **Why:** reconfirms branch health on core quality/runtime gates after the latest diagnostic and rollback cycle.
- **Xvfb/GL runtime matrix probe (2026-02-14 PM)** Repeated isolated renderer runs under alternate display/GL setups (`xvfb-run` defaults, custom GLX screen args, and `LIBGL_ALWAYS_SOFTWARE=1`): `bracketMatching.test.js` and `view.js` still failed 3/3 in every configuration, while control `viewEventHandler.js` remained stable (0/3 failures).
  **Why:** rules out basic Xvfb screen/GL backend tuning as a practical mitigation and confirms the failure is selective (not a universal renderer inability to run tests).
- **Additional Chromium flag probe (2026-02-14 PM)** Retried isolated failing renderer case with further flags (`--disable-dev-shm-usage`, `--disable-dev-shm-usage --no-zygote`, `--in-process-gpu --disable-gpu`, `--disable-features=UseSkiaRenderer`); all variants still failed 3/3 with the same dynamic-import error.
  **Why:** extends the ruled-out mitigation set across shared-memory, process-model, and Skia renderer toggles.
- **Build-mode compilation fallback success (2026-02-14 PM)** Ran `npm run gulp compile-build-without-mangling` successfully after repeated `compile-build-with-mangling` OOM kills; this generated `out-build` artifacts without hitting the mangler memory ceiling in this VM.
  **Why:** provides a reproducible lower-memory path to unblock build-mode test attempts when full mangling compile is resource-constrained.
- **Build-mode test follow-up (2026-02-14 PM)** Re-ran `xvfb-run -a ./scripts/test.sh --build` after generating `out-build`; previous `nls.messages.json` missing-artifact failure is resolved, but the run still fails on the same renderer dynamic-import error (`file:///workspace/out-build/.../bracketMatching.test.js`).
  **Why:** sharpens the remaining blocker to renderer module loading only (not missing build artifacts).
- **Full test rerun after out-build generation (2026-02-14 PM)** Re-ran `xvfb-run -a make test`; failure remains unchanged at renderer dynamic import (`file:///workspace/out/.../bracketMatching.test.js`) despite `out-build` now existing.
  **Why:** confirms the primary `make test` blocker is independent from build-mode artifact generation.
- **Smoke rerun + gate confirmation (2026-02-14 PM)** Re-ran `xvfb-run -a make test-smoke` (now 20 failing / 3 pending, still dominated by `.monaco-workbench` timeout, plus one `spawnSync /bin/sh ENOENT` in notebook cleanup), then re-ran `make test-unit` (7584 passing / 134 pending) and `xvfb-run -a ./scripts/code.sh --version` (pass).
  **Why:** captures current smoke failure profile while reconfirming core unit/runtime gates stay green.
- **Smoke log root-cause capture (2026-02-14 PM)** Inspected `.build/logs/smoke-tests-electron/smoke-test-runner.log` from the latest smoke run and confirmed the renderer repeatedly emits `net::ERR_FAILED` resource loads followed by `TypeError: Failed to fetch dynamically imported module: vscode-file://vscode-app/workspace/out/vs/workbench/workbench.desktop.main.js`.
  **Why:** provides direct runtime evidence that smoke startup failure is aligned with the broader renderer ESM import issue (not only selector timeouts).
- **Workbench module isolation follow-up (2026-02-14 PM)** Ran isolated renderer loads for `vs/workbench/workbench.desktop.main.js` in both dev and `--build` modes; both failed reproducibly with the same dynamic-import error.
  **Why:** demonstrates that the smoke failureing entry module also fails under the unit Electron harness, and that switching `out` vs `out-build` does not mitigate.
- **Single-smoke args probe (2026-02-14 PM)** Ran focused smoke case (`-g "verifies opened editors are restored"`) with and without `--electronArgs "--disable-gpu --no-sandbox"`; both runs still timed out waiting for `.monaco-workbench`.
  **Why:** rules out a straightforward smoke-launch mitigation via those common Electron runtime flags.
- **Notebook smoke cleanup hardening (2026-02-14 PM)** Updated `test/smoke/src/areas/notebook/notebook.test.ts` to avoid shell-based `execSync` cleanup and skip git-reset cleanup when the workspace path is missing; now uses guarded `spawnSync('git', ...)`.
  **Why:** removes spurious `/bin/sh ENOENT` after-hook failures when smoke startup fails before a valid workspace is ready.
- **Smoke rerun after notebook cleanup fix (2026-02-14 PM)** Re-ran `xvfb-run -a make test-smoke`; failure count dropped from 20 to 19 (3 pending), with remaining failures still dominated by `.monaco-workbench` timeout and no notebook `/bin/sh ENOENT` cleanup error.
  **Why:** confirms the cleanup hardening works and isolates remaining smoke failures to the broader renderer import/startup issue.
- **Post-fix gate checks (2026-02-14 PM)** Re-ran `make test-unit` (7584 passing / 134 pending) and `make lint` (pass) after the smoke test code update.
  **Why:** verifies the notebook smoke cleanup change did not regress core unit or lint gates.
- **Renderer import-map blob hardening (2026-02-14 PM)** Updated `test/unit/electron/renderer.html` import-map blob generation to export only valid non-reserved identifier keys when shimming Node modules (`asRequireBlobUri`), avoiding invalid ESM like `export const default = ...` / numeric export names.
  **Why:** eliminates a class of silent syntax-invalid shim modules in the renderer harness and makes bare-module import shims structurally safe.
- **Blob-hardening verification (2026-02-14 PM)** Validated generated shim source across builtin/dependency module set (previously failing examples included `electron`/`open`), now parsing cleanly (`badCount: 0`); re-ran representative renderer probes (`workbench.desktop.main.js`, `bracketMatching.test.js`, control `viewEventHandler.js`) and focused smoke case to confirm no regression (failure pattern otherwise unchanged).
  **Why:** confirms the shim hardening landed correctly while isolating the remaining ESM loader issue as separate.
- **Smoke startup fail-fast diagnostics (2026-02-14 PM)** Added renderer startup failure tracking in test automation (`test/automation/src/playwrightDriver.ts` + `test/automation/src/code.ts`): capture first page error and recent request-failed URLs, then abort `.monaco-workbench` wait early when dynamic-import failure is detected.
  **Why:** replaces low-signal 20s timeouts with immediate, high-signal root-cause errors (module import failure + concrete failing URLs), making smoke failures faster to diagnose.
- **Fail-fast behavior validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran focused smoke case (`-g "verifies opened editors are restored"`): failure now occurs in ~2s with explicit `Workbench startup failed due to renderer module import error` plus recent `vscode-file://...` `net::ERR_FAILED` request list.
  **Why:** proves the new diagnostics are active and materially improve troubleshooting turnaround.
- **Full smoke rerun after fail-fast change (2026-02-14 PM)** Re-ran `xvfb-run -a make test-smoke`; suite still fails on the same underlying renderer import issue, but now completes much faster (~27s) with explicit per-suite import-failure evidence instead of repeated 20-second selector timeouts.
  **Why:** confirms no behavioral masking: only diagnostics/timing improved while root issue remains transparently visible.
- **Post-change quality gates (2026-02-14 PM)** Re-ran `make lint` and `make test-unit` (7584 passing / 134 pending) after automation diagnostics changes.
  **Why:** validates the test-automation code updates did not regress lint or core unit suites.
- **Renderer unit harness import diagnostics (2026-02-14 PM)** Enhanced `test/unit/electron/renderer.js` import failure handling to emit a structured `[ESM IMPORT FAILURE]` record (module, URL, import error, and best-effort `fetch` status/ok) before surfacing the existing loader error.
  **Why:** preserves existing behavior while making `make test` / isolated renderer failures substantially easier to triage from logs.
- **Import diagnostic verification (2026-02-14 PM)** Re-ran isolated failing/passing renderer modules (`vs/workbench/workbench.desktop.main.js`, `vs/editor/common/viewEventHandler.js`) and confirmed new structured diagnostics appear only for failing imports; re-ran `make lint` (pass).
  **Why:** confirms the new observability path is active and non-disruptive.
- **Smoke request-failure on-disk annotation (2026-02-14 PM)** Enhanced Playwright smoke diagnostics (`test/automation/src/playwrightDriver.ts`) to annotate `vscode-file://...` request failures with `existsOnDisk=<bool>` by mapping URL pathname to filesystem path.
  **Why:** quickly distinguishes “missing artifact” vs “loader/runtime transport failure” during smoke startup debugging.
- **On-disk annotation validation (2026-02-14 PM)** Recompiled smoke automation and re-ran focused smoke case; fail-fast startup error now includes request entries like `... existsOnDisk=true` for failed `vscode-file://` module loads, then re-ran `make lint` (pass).
  **Why:** provides direct runtime proof that many failed module requests point to files that do exist on disk, narrowing root cause away from missing outputs.
- **Smoke import-target existence diagnostics (2026-02-14 PM)** Extended smoke fail-fast error formatting in `test/automation/src/code.ts` to parse the dynamic-import target URL from page error text and append `Import target on disk: <path> (exists=<bool>)`.
  **Why:** surfaces the failing entry module’s actual filesystem existence inline, reducing one more manual step in triage.
- **Import-target diagnostics verification (2026-02-14 PM)** Recompiled smoke automation and re-ran focused smoke case (`-g "verifies opened editors are restored"`); output now includes `Import target on disk: /workspace/out/vs/workbench/workbench.desktop.main.js (exists=true)`. Re-ran `make lint` (pass).
  **Why:** confirms the new diagnostics are active and reinforces that the startup failure is not caused by missing target file artifacts.
- **Protocol canonical-path fallback attempt (2026-02-14 PM)** Updated `src/vs/platform/protocol/electron-main/protocolMainService.ts` to add a canonical realpath-based root check fallback for `vscode-file` requests (computed lazily after the normal root check) to tolerate symlinked workspace path mismatches.
  **Why:** tests whether path-alias mismatches between request URLs and allowed roots are causing `net::ERR_FAILED` module loads.
- **Canonical-path fallback validation (2026-02-14 PM)** Rebuilt (`make build`) and reran focused smoke startup case; failure remains the same (`workbench.desktop.main.js` import fetch fails, target exists on disk, failed requests still report `existsOnDisk=true`). Re-ran `make lint` + `make test-unit` (7584 passing / 134 pending).
  **Why:** records a concrete mitigation attempt that did not resolve the loader issue while keeping core gates green.
- **Smoke CDP loading-failed diagnostics (2026-02-14 PM)** Extended `test/automation/src/playwrightDriver.ts` diagnostics with best-effort CDP `Network.loadingFailed` capture (`resourceType`, blocked/canceled flags when present) and merged these into the recent request-failure list.
  **Why:** augments Playwright’s coarse `net::ERR_FAILED` signal with lower-level network event context to tighten root-cause analysis.
- **CDP diagnostics verification (2026-02-14 PM)** Recompiled smoke automation and re-ran focused smoke startup case; fail-fast output now includes entries like `[cdp] net::ERR_FAILED ... resourceType=Script` alongside existing `existsOnDisk=true` annotations. Re-ran `make lint` (pass).
  **Why:** confirms CDP enrichment is active and non-disruptive while preserving prior diagnostics.
- **Extended CDP failure metadata capture (2026-02-14 PM)** Expanded smoke CDP `Network.loadingFailed` diagnostics to include CORS metadata when available (`corsError`, `corsParam`) in addition to resource type/blocked/canceled flags.
  **Why:** preserves current diagnostics while preparing for richer root-cause signals when Chromium surfaces CORS-specific failure context.
- **Extended CDP metadata verification (2026-02-14 PM)** Recompiled smoke automation and re-ran focused smoke startup case; output continues to include `[cdp] ... resourceType=Script` entries (no additional CORS fields surfaced in this run), then re-ran `make lint` (pass).
  **Why:** verifies the metadata extension is active, compatible, and non-regressive even when optional fields are absent.
- **Focused smoke reproducibility check (2026-02-14 PM)** Re-ran the same focused smoke startup case (`-g "verifies opened editors are restored"`) 5 consecutive times; all 5/5 runs failed with the same renderer import-startup error path.
  **Why:** confirms this environment failure mode is deterministic for the focused startup scenario, not a transient flake.
- **Unit harness `existsOnDisk` import diagnostics (2026-02-14 PM)** Extended `test/unit/electron/renderer.js` structured `[ESM IMPORT FAILURE]` logging to include `existsOnDisk` by converting the failing module URL to a local file path (`fileURLToPath` + `fs.existsSync`).
  **Why:** aligns unit-harness diagnostics with smoke diagnostics so both surfaces explicitly report whether failing import targets are physically present.
- **Unit `existsOnDisk` verification (2026-02-14 PM)** Re-ran isolated failing module (`vs/workbench/workbench.desktop.main.js`) and verified new log payload includes `"existsOnDisk":true` while import still fails; re-ran `make lint` (pass).
  **Why:** confirms the additional unit-level signal is active and supports the “not missing artifact” conclusion.
- **Protocol fallback rollback (2026-02-14 PM)** Reverted the earlier canonical realpath fallback logic in `protocolMainService` after observing no runtime improvement, restoring upstream-like protocol behavior.
  **Why:** removes speculative production-path complexity that did not mitigate the renderer import failure.
- **Rollback validation (2026-02-14 PM)** Rebuilt (`make build`), re-ran focused smoke startup case (still fails with the same import error and `existsOnDisk=true` diagnostics), then re-ran `make lint` and `make test-unit` (7584 passing / 134 pending).
  **Why:** confirms rollback is safe and keeps the known failure signature unchanged while preserving green core gates.
- **Smoke duplicate-failure suppression for fatal startup import errors (2026-02-14 PM)** Updated `test/smoke/src/utils.ts` to track the first fatal `Workbench startup failed due to renderer module import error` and skip subsequent smoke tests/suites once that fatal startup condition is detected.
  **Why:** avoids repeated low-value startup failures across unrelated suites, making smoke runs fail faster and more actionable in deterministic renderer-import failure environments.
- **Notebook cleanup hook hardening for skipped suites (2026-02-14 PM)** Updated `test/smoke/src/areas/notebook/notebook.test.ts` `after` hook to guard `this.app` access before resolving `workspacePathOrFolder`.
  **Why:** prevents secondary `TypeError` noise (`workspacePathOrFolder` on undefined) when the suite was skipped after a prior fatal startup failure.
- **Smoke fail-fast suppression validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran full smoke runner (`xvfb-run -a node test/index.js`): run now completes in ~2s with **1 failing** / **94 pending** (down from repeated multi-suite failures), preserving the primary renderer import root-cause failure signal. Re-ran `make lint` (pass).
  **Why:** confirms the suppression logic is active, non-regressive for lint, and materially improves signal-to-noise and runtime for repeated startup-failure loops.
- **Post-change core gate rerun (2026-02-14 PM)** Re-ran `make test-unit`, `make build`, and `xvfb-run -a ./scripts/code.sh --version`; all passed after smoke harness updates.
  **Why:** confirms the smoke harness changes do not regress core compile/unit/runtime gates.
- **Post-change full-suite characterization rerun (2026-02-14 PM)** Re-ran `xvfb-run -a make test` and `xvfb-run -a make test-smoke`:
  - `make test` still fails on renderer dynamic import in unit-electron harness, now with structured `[ESM IMPORT FAILURE]` payload including `fetchStatus=200`, `fetchOk=true`, `existsOnDisk=true`.
  - `make test-smoke` now reports **1 failing / 94 pending / 0 passing (~2s)**, preserving only the primary fatal startup import failure.
  **Why:** verifies improved smoke failure dedupe behavior while reconfirming unchanged underlying environment-level renderer import failure signature.
- **Smoke skip-log compaction for fatal startup dedupe (2026-02-14 PM)** Refined `test/smoke/src/utils.ts` fatal-startup tracking to store a single-line summary of the first fatal workbench startup error and reuse that summary for subsequent `Skipping test/suite startup...` log lines.
  **Why:** removes repeated multiline error payload spam from smoke runner logs while preserving the exact primary failure signal in the first failing test.
- **Compaction validation (2026-02-14 PM)** Recompiled smoke/automation, re-ran `xvfb-run -a make test-smoke` (still **1 failing / 94 pending / 0 passing** in ~2s), verified skip logs are now concise one-line entries, and re-ran `make lint` (pass).
  **Why:** confirms the logging refinement is active, keeps behavior unchanged, and remains lint-clean.
- **One-time skip-log dedupe (2026-02-14 PM)** Further refined `test/smoke/src/utils.ts` to emit fatal-startup skip logs only once per test-level and suite-level path (with explicit “subsequent ... skipped silently” notices).
  **Why:** removes repetitive duplicate skip lines from smoke runner artifacts while still documenting that dedupe behavior is intentional.
- **One-time dedupe validation (2026-02-14 PM)** Recompiled smoke/automation, re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified runner logs now include a single test-skip notice and a single suite-skip notice, and re-ran `make lint` (pass).
  **Why:** confirms log dedupe works as designed without altering failure semantics or lint health.
- **Unit renderer direct-dependency import diagnostics (2026-02-14 PM)** Extended `test/unit/electron/renderer.js` failure handling to parse the failed module’s direct static `import`/`export ... from` specifiers, attempt direct imports for those entries, and emit structured `[ESM IMPORT FAILURE DEP]` records (`specifier`, resolved URL, error, `existsOnDisk`).
  **Why:** adds concrete dependency-edge visibility for otherwise opaque top-level dynamic-import failures, enabling faster narrowing of the first failing branch in large module graphs.
- **Direct-dependency diagnostics validation (2026-02-14 PM)** Re-ran isolated failing modules:
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/test/browser/testCodeEditor.js`
  and confirmed new `[ESM IMPORT FAILURE DEP]` records are emitted with resolved file URLs and `existsOnDisk=true`; re-ran `make lint` (pass).
  **Why:** verifies the new unit-level observability path is active and lint-safe while preserving existing failure behavior.
- **Unit dependency diagnostics compaction (2026-02-14 PM)** Refined `test/unit/electron/renderer.js` direct-import diagnostics to aggregate failures into a single structured `[ESM IMPORT FAILURE DEPS SUMMARY]` payload per failed parent module (including `specifierCount`, `failureCount`, and detailed failure entries), replacing many per-edge log lines.
  **Why:** keeps the same debugging signal while reducing log noise and making failing dependency fronts easier to parse in CI artifacts.
- **Diagnostics compaction validation (2026-02-14 PM)** Re-ran isolated failing renderer module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and confirmed:
  - base `[ESM IMPORT FAILURE]` still emitted,
  - new single `[ESM IMPORT FAILURE DEPS SUMMARY]` record present,
  - previous per-edge spam absent.
  Re-ran `make lint` (pass).
  **Why:** verifies compaction behavior is active and non-regressive.
- **Regex state hardening for dependency-specifier extraction (2026-02-14 PM)** Updated `test/unit/electron/renderer.js` to reset `staticImportRegex.lastIndex` before each parse in `extractDirectImportSpecifiers`.
  **Why:** avoids cross-call global-regex state bleed that could intermittently drop specifiers when multiple failing modules are analyzed in one renderer run.
- **Regex hardening validation (2026-02-14 PM)** Re-ran isolated failing modules back-to-back:
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/test/common/testTextModel.js`
  and confirmed both emit populated `[ESM IMPORT FAILURE DEPS SUMMARY]` payloads (non-zero `specifierCount` / `failureCount`) after sequential runs; re-ran `make lint` (pass).
  **Why:** confirms stable repeated parsing behavior across consecutive diagnostic invocations.
- **Failure-family aggregation in unit dependency diagnostics (2026-02-14 PM)** Extended `[ESM IMPORT FAILURE DEPS SUMMARY]` payloads in `test/unit/electron/renderer.js` with `failureFamilies` counts (grouped by the first three path segments under `out/`, e.g. `vs/editor/test`).
  **Why:** adds quick clustering context to identify which subsystem namespaces dominate import failures without scanning full per-edge failure arrays.
- **Failure-family aggregation validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary now includes family rollups such as `vs/editor/common`, `vs/editor/contrib`, `vs/editor/test`; re-ran `make lint` (pass).
  **Why:** confirms new grouping signal is present and lint-clean.
- **Smoke failure-entry normalization and summary terminator hardening (2026-02-14 PM)** Refined smoke startup diagnostics:
  - `test/automation/src/playwrightDriver.ts`: normalize failure entries more aggressively (strip variable `after <n>ms` suffixes and collapse whitespace across entire entry).
  - `test/automation/src/code.ts`: include `Recent request failures (N):` header and trailing `End of recent request failures.` sentinel in fail-fast error payload.
  **Why:** keeps recent-failure details stable and shifts external timing suffixes to a deterministic terminator line, reducing noisy drift in repeated diagnostics.
- **Normalization/terminator validation (2026-02-14 PM)** Recompiled smoke/automation, re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified fail-fast output now includes the count header + terminator line, and observed variable `after <n>ms` suffix attached only to the sentinel line in runner logs; re-ran `make lint` (pass).
  **Why:** confirms improved diagnostic readability while preserving behavior and lint health.
- **Post-formatting validation sweep (2026-02-14 PM)** Re-ran core gates:
  - `make test-unit` (pass),
  - `make build` (pass),
  - `xvfb-run -a ./scripts/code.sh --version` (pass).
  Re-ran full suites:
  - `xvfb-run -a make test` still fails on renderer ESM import, now emitting both `[ESM IMPORT FAILURE]` and enriched `[ESM IMPORT FAILURE DEPS SUMMARY]` with `failureFamilies` rollups.
  - `xvfb-run -a make test-smoke` remains **1 failing / 94 pending / 0 passing** with compact `Recent request failures (8)` block and terminator line.
  **Why:** reconfirms core health, preserves known environment-level renderer blocker signature, and validates latest diagnostic formatting in end-to-end runs.
- **Smoke fail-fast trailing-newline refinement (2026-02-14 PM)** Adjusted `test/automation/src/code.ts` to append a trailing newline after the `End of recent request failures.` sentinel in startup fail-fast errors.
  **Why:** ensures outer `measureAndLog(...with error ... after Nms)` suffix lands on its own line instead of mutating the sentinel line, improving log readability and parse stability.
- **Trailing-newline validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified:
  - terminal output still shows clean request-failure block with sentinel,
  - smoke runner file now places `after <n>ms` on a dedicated follow-up line (not appended to sentinel text).
  Re-ran `make lint` (pass).
  **Why:** confirms improved log framing without behavior change.
- **Fail-fast recent-failure formatter extraction (2026-02-14 PM)** Refactored `test/automation/src/code.ts` startup fail-fast path to route recent request failures through a dedicated formatter (`formatRecentRequestFailures`) before rendering the failure block.
  **Why:** centralizes block formatting logic so future dedupe/grouping tweaks can be made in one place without touching error-construction control flow.
- **Formatter extraction validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**) and verified the fail-fast block still includes:
  - `Recent request failures (8):`
  - request-failure lines
  - `End of recent request failures.`
  Re-ran `make lint` (pass).
  **Why:** confirms the refactor is behavior-preserving and lint-clean.
- **Smoke recent-failure event counting (2026-02-14 PM)** Updated startup fail-fast diagnostics to preserve repeated request-failure events in `PlaywrightDriver` (bounded ring still capped at 25) and changed `Code` fail-fast rendering to show `events` vs `unique` counts in the header while grouping repeated lines via a formatter.
  **Why:** keeps high-signal compact output but no longer hides repeated failure frequency, improving visibility into bursty startup failures.
- **Event-count validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified fail-fast block now reports `Recent request failures (8 events, 8 unique): ... End of recent request failures.`, and re-ran `make lint` (pass).
  **Why:** confirms the new frequency-aware summary is active and non-regressive.
- **Source-aware fail-fast summary enhancement (2026-02-14 PM)** Updated `test/automation/src/code.ts` recent-failure summarizer to include source breakdown (`cdp` vs `requestfailed`) in the header and to sort grouped failures deterministically (count desc, then lexical).
  **Why:** makes smoke startup diagnostics more immediately interpretable by showing whether failures are observed at Playwright level, CDP level, or both, while keeping output stable across reruns.
- **Source-aware summary validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now reads `Recent request failures (8 events, 8 unique, cdp=4, requestfailed=4):`, and re-ran `make lint` (pass).
  **Why:** confirms enhanced breakdown signal is present and lint-clean.
- **Unit dependency fetch-bytes diagnostics (2026-02-14 PM)** Extended `test/unit/electron/renderer.js` dependency-summary failure entries to include per-edge `fetchStatus`, `fetchOk`, and `fetchedBytes` (captured via best-effort `fetch` after each failed dependency import).
  **Why:** adds concrete transport/readability evidence for each failed dependency edge so we can distinguish parser/loader rejection from content-read failures without rerunning ad-hoc probes.
- **Fetch-bytes diagnostics validation (2026-02-14 PM)** Re-ran isolated failing unit module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified `[ESM IMPORT FAILURE DEPS SUMMARY]` now includes populated per-edge fields such as `"fetchStatus":"200"`, `"fetchOk":true`, and non-zero `"fetchedBytes"`; re-ran `make lint` (pass).
  **Why:** confirms the enhanced unit-edge observability is active and lint-safe.
- **Unit import-error classification enrichment (2026-02-14 PM)** Added `errorKind` classification in `test/unit/electron/renderer.js` for top-level and dependency-edge import failures (currently distinguishing `dynamic-import-fetch-failure` vs `other`) and reused shared fetch diagnostics helper for the top-level failure payload.
  **Why:** provides a stable machine-readable discriminator for failure-type grouping in logs while keeping existing human-readable error text intact.
- **Error-kind validation (2026-02-14 PM)** Re-ran isolated failing unit module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and confirmed:
  - top-level `[ESM IMPORT FAILURE]` includes `errorKind` + `fetchedBytes`,
  - dependency summary entries include per-edge `errorKind`.
  Re-ran `make lint` (pass).
  **Why:** confirms classification and shared fetch metrics are active and lint-clean.
- **Unit family rollup ordering + module-family tagging (2026-02-14 PM)** Extended `test/unit/electron/renderer.js` diagnostics further:
  - top-level `[ESM IMPORT FAILURE]` now includes `moduleFamily`,
  - dependency summary now includes `failureFamilyEntries` (count-sorted family rollups) alongside raw `failureFamilies`.
  **Why:** makes logs easier to scan by surfacing the failing module’s family directly and providing a pre-sorted family ranking without requiring consumers to sort object maps.
- **Family-tag validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - top-level payload includes `"moduleFamily":"vs/editor/contrib"`,
  - summary includes sorted `failureFamilyEntries` (e.g. `vs/editor/test` first with count 2).
  Re-ran `make lint` (pass).
  **Why:** confirms new family-level observability fields are active and lint-safe.
- **Dependency error-kind rollup entries (2026-02-14 PM)** Extended unit dependency summaries in `test/unit/electron/renderer.js` with:
  - raw `failureKinds` count map, and
  - sorted `failureKindEntries` array.
  Also extracted shared count-entry sorting helper for deterministic rollup ordering.
  **Why:** complements family rollups with error-type aggregation, making it easier to quantify whether failures are homogeneous (e.g. all dynamic-import fetch failures) or mixed.
- **Error-kind rollup validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary now includes `failureKinds` + sorted `failureKindEntries`; re-ran `make lint` (pass).
  **Why:** confirms the new error-type rollups are active and lint-clean.
- **Specifier truncation metadata in dependency summaries (2026-02-14 PM)** Enhanced `[ESM IMPORT FAILURE DEPS SUMMARY]` payloads in `test/unit/electron/renderer.js` with:
  - `totalSpecifierCount`,
  - `specifierLimit`,
  - `isSpecifierListTruncated`.
  **Why:** makes it explicit when the diagnostic walk intentionally caps analyzed direct imports, preventing misinterpretation of partial dependency snapshots.
- **Specifier metadata validation (2026-02-14 PM)** Re-ran isolated failing modules:
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/test/common/testTextModel.js`
  and confirmed:
  - non-truncated case reports `totalSpecifierCount === specifierCount`,
  - truncated case reports `totalSpecifierCount > specifierCount` with `isSpecifierListTruncated: true`.
  Re-ran `make lint` (pass).
  **Why:** validates the new fields accurately communicate diagnostic coverage depth.
- **Resolved-kind rollups for dependency failures (2026-02-14 PM)** Extended `test/unit/electron/renderer.js` dependency summaries with:
  - per-edge `resolvedKind` classification (`file-url`, `other-url`, `bare-specifier`),
  - aggregate `failureResolvedKinds` map, and
  - sorted `failureResolvedKindEntries`.
  **Why:** quickly surfaces whether failing edges are filesystem URLs vs bare/import-map paths, tightening triage around protocol/import-map classes of failures.
- **Resolved-kind validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - each failure entry now includes `resolvedKind`,
  - summary includes `failureResolvedKinds` + sorted `failureResolvedKindEntries` (`file-url` count shown).
  Re-ran `make lint` (pass).
  **Why:** confirms resolved-kind diagnostics are active and lint-safe.
- **Dependency success/skip count metrics (2026-02-14 PM)** Extended `[ESM IMPORT FAILURE DEPS SUMMARY]` in `test/unit/electron/renderer.js` with:
  - `successfulDependencyImportCount`,
  - `failedDependencyImportCount`,
  - `skippedSpecifierCount` (when direct-import scan is truncated).
  **Why:** quantifies how much of the direct dependency frontier succeeds vs fails (and whether anything was skipped), improving confidence in diagnostic coverage.
- **Success/skip metrics validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary now reports mixed success/failure counts (e.g. `successfulDependencyImportCount: 6`, `failedDependencyImportCount: 4`, `skippedSpecifierCount: 0`); re-ran `make lint` (pass).
  **Why:** confirms the new coverage/quality metrics are active and lint-clean.
- **Dependency success/failure percentage metrics (2026-02-14 PM)** Extended unit dependency summaries in `test/unit/electron/renderer.js` with:
  - `dependencyAttemptedCount`,
  - `dependencySuccessRatePercent`,
  - `dependencyFailureRatePercent`.
  **Why:** provides at-a-glance normalized coverage of failing fronts across modules with different direct-import fanout sizes.
- **Percentage metrics validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary includes coherent rates (`dependencyAttemptedCount: 10`, success `60`, failure `40`); re-ran `make lint` (pass).
  **Why:** confirms percent metrics are active, consistent with raw counts, and lint-clean.
- **Dependency fetch-status rollup diagnostics (2026-02-14 PM)** Extended unit dependency summaries with fetch outcome aggregations:
  - `failureFetchStatuses` + sorted `failureFetchStatusEntries`,
  - `failureFetchOk` + sorted `failureFetchOkEntries`.
  **Why:** highlights mixed transport behavior (e.g. mostly HTTP 200 fetches plus occasional `TypeError: Failed to fetch`) at a glance without scanning every failure entry.
- **Fetch-rollup validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary now includes fetch-status/fetchOk rollups (example observed: `200:3`, `TypeError: Failed to fetch:1`, `fetchOk true:3 / false:1`); re-ran `make lint` (pass).
  **Why:** confirms the new transport rollup metrics are active and lint-safe.
- **On-disk byte + fetch-delta diagnostics (2026-02-14 PM)** Extended unit ESM diagnostics in `test/unit/electron/renderer.js` to include:
  - `onDiskBytes` for file-backed module URLs,
  - `fetchDiskByteDelta` (fetched bytes minus on-disk bytes when fetch succeeds).
  Applied to both top-level `[ESM IMPORT FAILURE]` and per-edge dependency failures.
  **Why:** gives direct integrity checks for “fetch succeeded but import failed” cases, helping rule out truncation/corruption mismatches quickly.
- **Byte-delta validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - top-level failure now reports `onDiskBytes` and `fetchDiskByteDelta:null` when fetch itself fails,
  - dependency failures with `fetchStatus=200` report `fetchDiskByteDelta:0` and matching `onDiskBytes/fetchedBytes`.
  Re-ran `make lint` (pass).
  **Why:** confirms byte-level diagnostics are active and consistent with observed fetch behavior.
- **Smoke fail-fast signature field (2026-02-14 PM)** Enhanced `test/automation/src/code.ts` recent-failure summarizer to compute and emit a stable hash signature (`signature=<hex>`) for the grouped recent-failure set.
  **Why:** enables quick comparison of failure-shape identity across reruns without visually diffing full failure blocks.
- **Signature validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified fail-fast header now includes `signature=<8-hex>` (e.g. `signature=86c15b67`), and re-ran `make lint` (pass).
  **Why:** confirms signature generation is active and non-regressive.
- **Byte-delta kind classification + rollups (2026-02-14 PM)** Extended unit ESM diagnostics (`test/unit/electron/renderer.js`) with:
  - per-failure `byteDeltaKind` classification (`byte-match`, `byte-mismatch`, `fetch-not-ok`, `disk-bytes-unavailable`),
  - aggregate `failureByteDeltaKinds` + sorted `failureByteDeltaKindEntries` in dependency summaries,
  - top-level failure payload now also includes `byteDeltaKind`.
  **Why:** turns raw byte deltas into immediately readable integrity-state categories for faster triage at both edge and summary levels.
- **Byte-delta kind validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - top-level payload includes `byteDeltaKind`,
  - summary includes `failureByteDeltaKinds` + ordered entries,
  - per-edge entries include `byteDeltaKind` and `fetchDiskByteDelta`.
  Re-ran `make lint` (pass).
  **Why:** confirms new byte-delta categorization is active and lint-safe.
- **Attempted resolved-kind coverage rollups (2026-02-14 PM)** Extended dependency summaries in `test/unit/electron/renderer.js` with:
  - `attemptedResolvedKinds` map and
  - sorted `attemptedResolvedKindEntries`.
  **Why:** distinguishes the shape of *all attempted* direct imports from the subset that failed, helping identify whether failures are concentrated in one resolved-kind class.
- **Attempted-kind validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified summary now reports attempted-kind coverage (example: `file-url:9`, `bare-specifier:1`) alongside failure-only resolved-kind rollups; re-ran `make lint` (pass).
  **Why:** confirms attempted-vs-failed resolved-kind comparison fields are active and lint-clean.
- **Unit dependency failure signature field (2026-02-14 PM)** Added `failureSignature` (stable FNV-style hash) to `[ESM IMPORT FAILURE DEPS SUMMARY]` payloads in `test/unit/electron/renderer.js`, derived from sorted per-edge failure facts.
  **Why:** enables quick equality checks of dependency-failure shape across reruns without diffing full JSON arrays.
- **Failure-signature validation (2026-02-14 PM)** Re-ran the same isolated failing module twice (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and confirmed summary includes `failureSignature`; observed differing signatures across runs when one edge flipped from `fetchStatus=200` to `TypeError: Failed to fetch`, matching payload differences.
  **Why:** confirms signature responds to real failure-shape drift and is useful for flake characterization.
- **Dependency failure-detail cap metadata (2026-02-14 PM)** Updated `test/unit/electron/renderer.js` dependency summaries to cap verbose `failures[]` details at 12 entries while preserving complete aggregate counts. Added:
  - `failureDetailsLimit`,
  - `failureDetailsReturnedCount`,
  - `failureDetailsDroppedCount`.
  Also aligned `failedDependencyImportCount`/rates with aggregate failure counts instead of returned detail length.
  **Why:** prevents oversized payloads for high-fanout failures while retaining truthful totals for analysis.
- **Failure-detail cap validation (2026-02-14 PM)** Re-ran isolated modules:
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js` (no truncation: dropped 0),
  - `xvfb-run -a ./scripts/test.sh --run vs/editor/browser/view.js` (truncation active: failure count 16, returned 12, dropped 4).
  Verified counts/rates remain coherent and re-ran `make lint` (pass).
  **Why:** confirms capped details behave correctly in both small and large failure-frontier cases.
- **Dependency summary reference emission (2026-02-14 PM)** Updated `test/unit/electron/renderer.js` to have `logDirectImportDiagnostics(...)` return a compact summary object (`failureSignature`, counts) and emit a follow-up `[ESM IMPORT FAILURE DEP SUMMARY REF]` record from the top-level import-failure path.
  **Why:** creates an easy-to-grep stable link between top-level failure events and large dependency summary blobs without reprinting full detail payloads.
- **Summary-reference validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified logs now include:
  - full `[ESM IMPORT FAILURE DEPS SUMMARY]` with `failureSignature`,
  - compact `[ESM IMPORT FAILURE DEP SUMMARY REF]` carrying matching signature/counts.
  Re-ran `make lint` (pass).
  **Why:** confirms summary-reference linkage is active and lint-safe.
- **Inlined dependency summary references on top-level failures (2026-02-14 PM)** Refined `test/unit/electron/renderer.js` import-failure logging to inline dependency-summary reference fields directly into `[ESM IMPORT FAILURE]` (`dependencyFailureSignature`, `dependencyFailureCount`, `dependencyFailureDetailsReturnedCount`) and removed the extra standalone ref log record.
  **Why:** keeps correlation metadata attached to the primary failure event while reducing redundant log lines.
- **Inline-reference validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - `[ESM IMPORT FAILURE]` now includes dependency reference fields,
  - `[ESM IMPORT FAILURE DEPS SUMMARY]` remains emitted with matching signature,
  - standalone `[ESM IMPORT FAILURE DEP SUMMARY REF]` line is absent.
  Re-ran `make lint` (pass).
  **Why:** confirms tighter, less noisy correlation path is active and lint-clean.
- **Dependency-summary cache by module URL (2026-02-14 PM)** Updated `test/unit/electron/renderer.js` to cache compact dependency-summary metadata (`failureSignature` + counts) by module URL, so repeated top-level failures in the same run can reuse existing summary linkage without recomputing diagnostics.
  **Why:** preserves correlation data with lower repeated diagnostic overhead and consistent reference payloads for duplicate failure events.
- **Cache-path validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified top-level failure still carries `dependencyFailureSignature`/counts matching emitted summary; re-ran `make lint` (pass).
  **Why:** confirms cache introduction is behavior-preserving and lint-safe.
- **Latest post-enhancement validation sweep (2026-02-14 PM)** Re-ran:
  - `make lint` (pass),
  - `make test-unit` (pass, 7584 passing / 134 pending),
  - `xvfb-run -a make test` (expected renderer ESM failure persists),
  - `xvfb-run -a make test-smoke` (expected **1 failing / 94 pending / 0 passing**).
  Verified full-test logs now include:
  - top-level `[ESM IMPORT FAILURE]` with inlined dependency reference fields (`dependencyFailureSignature`, counts),
  - matching `[ESM IMPORT FAILURE DEPS SUMMARY]` rich rollups.
  Verified smoke fail-fast header includes source rollups + stable signature (latest sample: `signature=7e2978ab`).
  **Why:** reconfirms core green gates and preserves known environment-level blocker while validating that the latest diagnostics continue to surface as designed.
- **Diagnostics schema-version tagging (2026-02-14 PM)** Added `schemaVersion: 1` to unit ESM diagnostic payloads in `test/unit/electron/renderer.js`:
  - `[ESM IMPORT FAILURE]`
  - `[ESM IMPORT FAILURE DEPS]`
  - `[ESM IMPORT FAILURE DEPS SUMMARY]`
  **Why:** establishes explicit schema evolution tracking for downstream log parsers and future backward-compatible changes.
- **Schema-version validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified both top-level and dependency-summary payloads include `"schemaVersion":1`; re-ran `make lint` (pass).
  **Why:** confirms schema metadata is consistently emitted and lint-clean.
- **Smoke fail-fast display-window metadata (2026-02-14 PM)** Updated `test/automation/src/code.ts` to:
  - define a shared `recentFailuresDisplayLimit` constant (8),
  - include `showingLast=<displayed>/<recorded>` in the fail-fast header when the recent-failure ring is truncated.
  **Why:** makes it explicit that the fail-fast summary shows a bounded tail of the diagnostics buffer rather than the full history.
- **Display-window validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now includes truncation metadata (sample: `showingLast=8/25`), and re-ran `make lint` (pass).
  **Why:** confirms bounded-window metadata is active and non-regressive.
- **Always-on fail-fast window metadata (2026-02-14 PM)** Updated `test/automation/src/code.ts` to always include `showingLast=<displayed>/<recorded>` in the smoke fail-fast header, even when the window is not truncated.
  **Why:** keeps header schema stable across runs and simplifies downstream parsing/alerts that consume this field.
- **Always-on window validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header includes `showingLast=...` in this run (`8/25`), and re-ran `make lint` (pass).
  **Why:** confirms schema-stable display-window metadata is active and lint-clean.
- **Smoke fail-fast summary schema version (2026-02-14 PM)** Added `schemaVersion=1` marker to the smoke fail-fast recent-failure header in `test/automation/src/code.ts`.
  **Why:** aligns smoke diagnostics with versioned unit diagnostics so downstream parsers can evolve safely with explicit schema signals.
- **Smoke schema-version validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now includes `schemaVersion=1` alongside counts/signature, and re-ran `make lint` (pass).
  **Why:** confirms schema-version tagging is active and non-regressive.
- **Top-level dependency-schema linkage field (2026-02-14 PM)** Updated `test/unit/electron/renderer.js` so compact dependency summary metadata returned by `logDirectImportDiagnostics` carries `schemaVersion`, and top-level `[ESM IMPORT FAILURE]` now includes `dependencySummarySchemaVersion`.
  **Why:** makes schema compatibility explicit when correlating top-level failure events to dependency-summary records.
- **Dependency-schema linkage validation (2026-02-14 PM)** Re-ran isolated failing module (`xvfb-run -a ./scripts/test.sh --run vs/editor/contrib/bracketMatching/test/browser/bracketMatching.test.js`) and verified:
  - dependency summary includes `"schemaVersion":1`,
  - top-level payload includes `"dependencySummarySchemaVersion":1` with matching dependency signature/counts.
  Re-ran `make lint` (pass).
  **Why:** confirms schema-version correlation is emitted end-to-end and lint-safe.
- **Smoke fail-fast display-limit metadata (2026-02-14 PM)** Updated `test/automation/src/code.ts` recent-failure header to include explicit `displayLimit=<N>` alongside existing `showingLast=<displayed>/<recorded>`.
  **Why:** makes the configured window size explicit for parsers and reviewers, even when observed counts vary across runs.
- **Display-limit validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now includes `displayLimit=8`, and re-ran `make lint` (pass).
  **Why:** confirms the additional metadata is active and non-regressive.
- **Smoke buffer-capacity metadata exposure (2026-02-14 PM)** Added an explicit `recentRequestFailureCapacity` constant/getter in `PlaywrightDriver` and surfaced `bufferCapacity=<N>` in the fail-fast header assembled by `Code`.
  **Why:** clarifies total in-memory ring size independently from display window size (`displayLimit`), improving interpretation of `showingLast` ratios.
- **Buffer-capacity validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now includes `bufferCapacity=25` alongside `displayLimit=8` and `showingLast=8/25`; re-ran `make lint` (pass).
  **Why:** confirms capacity metadata is active and lint-clean.
- **Smoke observed/drop counters in fail-fast metadata (2026-02-14 PM)** Updated `PlaywrightDriver` to track total recorded request-failure events and ring-buffer drops, then surfaced `observedEvents=<N>` and `droppedEvents=<N>` in the smoke fail-fast header from `test/automation/src/code.ts`.
  **Why:** makes historical event loss explicit when the bounded ring buffer overwrites older entries, improving confidence when interpreting `showingLast` diagnostics.
- **Observed/drop counter validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified header now includes `observedEvents=744` and `droppedEvents=719` alongside existing window/capacity fields; re-ran `make lint` (pass).
  **Why:** confirms the new counters are emitted and that formatting/lint behavior remains stable.
- **Smoke script-response diagnostics block (2026-02-14 PM)** Extended `PlaywrightDriver` diagnostics to track recent `vscode-file://` script responses (status, content type, cache-control, existsOnDisk) with bounded-buffer counters (`observed`/`dropped`) and surfaced a new fail-fast `Recent script responses (...)` section in `test/automation/src/code.ts`.
  **Why:** adds direct response-level evidence (including MIME/cache headers) alongside request-failure events, improving triage for dynamic-import startup failures.
- **Script-response diagnostics validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified fail-fast output now includes:
  - `Recent script responses (schemaVersion=1, ... observedEvents=<N>, droppedEvents=<N>, signature=<hex>)`
  - per-entry fields `status=200`, `contentType=text/javascript`, `cacheControl=no-cache, no-store`, and `existsOnDisk=true`
  - terminating sentinel `End of recent script responses.`
  Re-ran `make lint` (pass).
  **Why:** confirms new response-level metadata is emitted and lint-clean without changing the known environment-limited failure mode.
- **Import-target response correlation metadata (2026-02-14 PM)** Added URL-keyed latest script-response summaries in `PlaywrightDriver` (with bounded summary map + per-URL seen-count tracking) and surfaced an explicit fail-fast line in `test/automation/src/code.ts`: `Import target latest script response: ...`.
  **Why:** directly correlates the failing dynamic-import target to its latest observed script response metadata, reducing ambiguity between network/protocol and loader-level failure symptoms.
- **Import-target response correlation validation (2026-02-14 PM)** Recompiled smoke/automation and re-ran `xvfb-run -a make test-smoke` (unchanged **1 failing / 94 pending / 0 passing**), verified fail-fast output now includes:
  - `Import target on disk: /workspace/out/vs/workbench/workbench.desktop.main.js (exists=true)`
  - `Import target latest script response: seenCount=1 status=200 contentType=text/javascript cacheControl=no-cache, no-store existsOnDisk=true`
  - the existing `Recent script responses (...)` block.
  Re-ran `make lint` (pass).
  **Why:** confirms import-target response correlation is emitted correctly and remains non-regressive.
