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
