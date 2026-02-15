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
- **One-command sweep:** `./scripts/verify-gates.sh` (or `./scripts/verify-gates.sh --quick`).
- **Retry and logs:** set `VSCODE_VERIFY_RETRIES=<n>` (or `--retries <n>`), logs are written to `.build/logs/verify-gates/` (override via `VSCODE_VERIFY_LOG_DIR`).
- **Machine-readable summary:** each run also writes `<mode>-<timestamp>.json`; override with `--summary-json <path>` or `VSCODE_VERIFY_SUMMARY_FILE`.
  - Summary payload includes `startedAt`, `completedAt`, `totalDurationSeconds`, plus per-gate `status`, `attempts`, and `durationSeconds`.
- **GitHub step summary helper:** use `./scripts/publish-verify-gates-summary.sh` to render the JSON payload into markdown for CI run summaries.
  - The helper is fail-safe for CI `if: always()` steps: malformed/missing payload fields are rendered as warnings/placeholders instead of failing the workflow step.
- **Gate selection:** resume from a specific gate with `--from <gate-id>` or run a subset with `--only gate1,gate2`.
- **Dry-run planning:** use `--dry-run` to validate gate selection/filtering and emit summary/log metadata without executing gates.
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
