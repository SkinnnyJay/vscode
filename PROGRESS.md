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
