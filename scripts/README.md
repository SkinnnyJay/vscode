# Scripts

Runnable scripts for setup, build, test, lint, and tooling. All are invoked via the **Makefile** (run `make help` at repo root). Scripts may call `package.json` scripts or Code-OSS/VS Code build steps.

## Convention

- **Location:** `./scripts/` (repo root).
- **Invocation:** Prefer `make <target>`; or run `./scripts/<script>` from repo root.
- **Adding a command:** 1) Add script under `scripts/`. 2) Add a Makefile target that runs it. 3) Use `target: ## Short description` so it appears in `make help`.

## Reference

| Make target | Script | Description |
|-------------|--------|-------------|
| **Setup and build** | | |
| `make setup` | `setup.sh` | Install dependencies (Node 22.x). |
| `make build` | `build.sh` | Compile the project (`npm run compile`). |
| `make clean` | `clean.sh` | Remove build artifacts and caches. `make clean ALL=1` also removes `node_modules`. |
| **Tests** | | |
| `make test` | `test.sh` | Full Electron unit tests (requires build + Electron). |
| `make test-unit` | `test-unit.sh` | Fast Node unit tests (no Electron). Optional: `./scripts/test-unit.sh --browser`. |
| `make test-integration` | `test-integration.sh` | Electron integration tests (extensions, API). |
| `make test-web-integration` | `test-web-integration.sh` | Web/browser integration tests (Playwright). |
| `make test-smoke` | `test-smoke.sh` | Smoke tests (`npm run smoketest`). |
| `make test-e2e` | `test-e2e.sh` | E2E/integration (delegates to `test-integration.sh`). |
| `./scripts/test-verify-gates-summary.sh` | `test-verify-gates-summary.sh` | Contract test for `verify-gates` JSON schema and markdown summary rendering using deterministic mocked gate runs, including malformed JSON/CLI-flag error handling (with file-path visibility in warnings), no-op paths (missing summary file / unset step-summary env), summary-file path resolution via env (`VSCODE_VERIFY_SUMMARY_FILE`) and sparse-payload rendering checks (minimal object + scalar JSON), verify-gates CLI argument/env validation checks (including `--help` content, unknown-option failure with usage output, missing option values for `--summary-json/--only/--from`, missing/invalid `--retries`, `--only` normalization/duplicate-warning/empty-list errors, `--from` selection/empty-value errors, and continue-on-failure env/flag normalization), markdown escaping checks, fallback-field derivation checks (renderer computes missing maps and gate lists from `gates[]`), result-signature stability checks (same inputs -> same signature, changed selection -> changed signature), log-file metadata checks (summary path exists + markdown includes log-file line), run/timing metadata checks (`runId`, timestamps, duration, gate-count/list alignment), run-classification/exit-reason checks (dry-run, fail-fast, success-with-retries), schema-version synchronization checks across producer/renderer/docs, workflow wiring checks for contract-step presence, and an explicit producer-vs-renderer schema-version sync check. |
| `./scripts/verify-gates.sh` | `verify-gates.sh` | Deterministic validation sweep across lint/typecheck/tests/build with retry support and per-run log/summary output. Use `./scripts/verify-gates.sh --quick` for lighter checks; run with `--help` for options/gate IDs. |
| `./scripts/publish-verify-gates-summary.sh` | `publish-verify-gates-summary.sh` | Append a verify-gates JSON summary to `GITHUB_STEP_SUMMARY` (CI step summaries). Run with `--help` for usage and env details. |
| **Lint and format** | | |
| `make lint` | `lint.sh` | ESLint + Stylelint (no fix). |
| `make fmt` | `fmt.sh` | Apply formatting fixes. |
| `make fmt-check` | `fmt.sh --check` | Check formatting only (no write). |
| `make typecheck` | `typecheck.sh` | TypeScript type checking. |
| `make hygiene` | `hygiene.sh` | Full hygiene (indentation, copyright, lint); pre-commit style. |
| **Tooling** | | |
| `make commit` | `committer` | Atomic commit: `make commit FILES="path1 path2" MSG="feat: description"`. |
| `make import-inspiration` | `import-inspiration-repos.sh` | Clone/update inspiration repos (optional `REPOS="name1 name2"`). |

## For agents and CI

- **Quick checks:** `make setup && make lint && make typecheck && make test-unit`
- **Full gate:** `make build && make test && make test-integration` (and optionally `make test-smoke`).
- **Summary-contract regression check:** run `./scripts/test-verify-gates-summary.sh` (executed in Pointer quality and nightly verify workflows before sweeps).
- **One-command sweep:** `./scripts/verify-gates.sh` (or `./scripts/verify-gates.sh --quick`).
- **Retry and logs:** set `VSCODE_VERIFY_RETRIES=<n>` (or `--retries <n>`), logs are written to `.build/logs/verify-gates/` (override via `VSCODE_VERIFY_LOG_DIR`).
- **Failure strategy:** default is fail-fast; set `VSCODE_VERIFY_CONTINUE_ON_FAILURE=1` (also accepts `true/yes/on`) or pass `--continue-on-failure` to run all selected gates before returning a failing exit code.
- **Machine-readable summary:** each run also writes `<mode>-<timestamp>.json`; override with `--summary-json <path>` or `VSCODE_VERIFY_SUMMARY_FILE`.
  - Current summary schema version: `17`.
  - Summary payload includes `schemaVersion`, `runId`, `runClassification`, `resultSignatureAlgorithm`, `resultSignature`, `exitReason`, `invocation`, `startedAt`, `completedAt`, `totalDurationSeconds`, `continueOnFailure`, `dryRun`, `gateCount`, `passedGateCount`, `failedGateCount`, `skippedGateCount`, `notRunGateCount`, `statusCounts`, `gateStatusById`, `gateExitCodeById`, `gateRetryCountById`, `gateDurationSecondsById`, `gateNotRunReasonById`, `gateAttemptCountById`, `executedGateCount`, `totalRetryCount`, `totalRetryBackoffSeconds`, `retriedGateCount`, `retriedGateIds`, `retryRatePercent`, `retryBackoffSharePercent`, `passRatePercent`, `executedDurationSeconds`, `averageExecutedDurationSeconds`, `slowestExecutedGateId`, `slowestExecutedGateDurationSeconds`, `fastestExecutedGateId`, `fastestExecutedGateDurationSeconds`, `failedGateId`, `failedGateExitCode`, `blockedByGateId`, `failedGateIds`, `failedGateExitCodes`, `passedGateIds`, `skippedGateIds`, `executedGateIds`, `notRunGateIds`, `nonSuccessGateIds`, `attentionGateIds`, plus per-gate `status`, `attempts`, `retryCount`, `retryBackoffSeconds`, `durationSeconds`, `exitCode`, `startedAt`, `completedAt`, and `notRunReason` (`null` when not applicable; fail-fast blockers are tagged as `blocked-by-fail-fast:<gate-id>`).
  - `runClassification` values: `dry-run`, `success-no-retries`, `success-with-retries`, `failed-fail-fast`, `failed-continued`.
- **GitHub step summary helper:** use `./scripts/publish-verify-gates-summary.sh` to render the JSON payload into markdown for CI run summaries.
  - The helper is fail-safe for CI `if: always()` steps: malformed/missing payload fields are rendered as warnings/placeholders instead of failing the workflow step.
  - Rendered metadata includes run mode context (`dryRun`, gate count, selected gates, failed gate) for faster CI triage.
  - Summary values are markdown-escaped to keep tables readable when commands/IDs contain special characters (pipes/backticks/newlines).
  - Rendered per-gate table includes retries/backoff and command exit code for faster root-cause triage.
  - Failed/not-run/retry metadata includes exit reason, first-failure pointers, blocking gate ID for fail-fast runs, complete failed/not-run/retried gate lists, and per-gate not-run reasons.
  - The rendered `Gate not-run reason map` is compacted to non-null entries (`none` when empty) for cleaner fail-fast diagnostics.
  - Both helper scripts print usage and exit non-zero on unknown flags/missing required option values.
- **Gate selection:** resume from a specific gate with `--from <gate-id>` or run a subset with `--only gate1,gate2`.
- **Dry-run planning:** use `--dry-run` to validate gate selection/filtering and emit summary/log metadata without executing gates.
  - `--only` tolerates whitespace and automatically ignores duplicate gate IDs.
  - Gate IDs: `lint`, `typecheck`, `test-unit`, `test`, `test-smoke`, `test-integration`, `test-e2e`, `test-web-integration`, `build`.
- **Before commit:** `make lint`, `make fmt-check` or `make hygiene`, `make typecheck`, then `make commit FILES="..." MSG="..."`.

## Linux headless stability note

- Electron test/smoke launchers auto-apply `--disable-dev-shm-usage` on Linux to reduce `/dev/shm` exhaustion failures in container/headless environments.
- To intentionally disable this mitigation for local experiments, set:
  - `VSCODE_TEST_DISABLE_DEV_SHM_WORKAROUND=1`
- Test launchers also auto-fallback to `xvfb-run -a` when Linux display detection fails (`DISPLAY` missing or points to a dead X server), so default `make test`, `make test-smoke`, and integration flows can run in headless VMs without manual wrapping.
- To bypass the internal xvfb re-exec guard (mainly for debugging launcher behavior), set:
  - `VSCODE_SKIP_XVFB_WRAPPER=1`
- Applies to:
  - `make test` (`scripts/test.sh`)
  - `make test-smoke` (`scripts/test-smoke.sh`)
  - integration extension launches via `scripts/code.sh`
  - smoke/electron automation launches (`test/automation/src/electron.ts`)
- `scripts/test.sh`, `scripts/code.sh`, and `scripts/test-smoke.sh` share launcher resilience helpers from `scripts/electron-launcher-utils.sh`:
  - auto-fallback to `xvfb-run -a` when `DISPLAY` is missing/stale (Linux)
  - binary preflight check that first attempts `chmod +x` recovery, then does a one-time `npm run electron` retry when Electron binary is missing/non-executable.

Scripts are documented at the top of each file (purpose, usage, and what they delegate to).
