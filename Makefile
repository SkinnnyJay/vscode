# Pointer IDE — Makefile
#
# Each target below delegates to a script in ./scripts. When adding a new command:
#   1. Add the script under scripts/ (e.g. scripts/my-command.sh) and make it executable.
#   2. Add a target here that invokes that script (see examples below).
#   3. Document the script’s purpose and usage in a comment at the top of the script file.
#
# Run `make help` to list available commands.
# Agents and devs: use these targets for build, test, lint, and format; scripts can wrap
# package.json scripts or VSCode/Code-OSS build steps.

SCRIPTS_DIR := ./scripts

.PHONY: help setup build test test-unit test-integration test-web-integration test-smoke test-e2e clean lint fmt fmt-check typecheck hygiene commit import-inspiration

# Default target: show help
help: ## Show this help
	@echo "Pointer IDE — available commands (each runs a script in $(SCRIPTS_DIR)/):"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) 2>/dev/null | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-22s %s\n", $$1, $$2}' || true
	@echo ""
	@echo "To add a command: 1) add script in $(SCRIPTS_DIR)/  2) add target here that runs it  3) use 'target: ## Short description' so it appears above."

# -----------------------------------------------------------------------------
# Setup and build
# -----------------------------------------------------------------------------

setup: ## Install dependencies / bootstrap dev environment (Node 22.x)
	@$(SCRIPTS_DIR)/setup.sh

build: ## Compile the project (npm run compile)
	@$(SCRIPTS_DIR)/build.sh

clean: ## Remove build artifacts and caches; use make clean ALL=1 to also remove node_modules
	@$(SCRIPTS_DIR)/clean.sh $(if $(ALL),--all,)

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

test: ## Run full Electron unit test suite (requires build + electron)
	@$(SCRIPTS_DIR)/test.sh

test-unit: ## Run fast unit tests (Node; no Electron). Use script args for --browser
	@$(SCRIPTS_DIR)/test-unit.sh

test-integration: ## Run Electron integration tests (extensions, API tests)
	@$(SCRIPTS_DIR)/test-integration.sh

test-web-integration: ## Run web/browser integration tests (Playwright)
	@$(SCRIPTS_DIR)/test-web-integration.sh

test-smoke: ## Run smoke tests (launch and basic sanity)
	@$(SCRIPTS_DIR)/test-smoke.sh

test-e2e: ## Run E2E/integration tests (delegates to test-integration.sh)
	@$(SCRIPTS_DIR)/test-e2e.sh

# -----------------------------------------------------------------------------
# Lint, format, typecheck
# -----------------------------------------------------------------------------

lint: ## Run ESLint and Stylelint (no fix)
	@$(SCRIPTS_DIR)/lint.sh

fmt: ## Apply formatting fixes (ESLint --fix, Stylelint --fix)
	@$(SCRIPTS_DIR)/fmt.sh

fmt-check: ## Check formatting only (no modifications)
	@$(SCRIPTS_DIR)/fmt.sh --check

typecheck: ## Run TypeScript type checking (build + src)
	@$(SCRIPTS_DIR)/typecheck.sh

hygiene: ## Run full hygiene (indentation, copyright, lint) — pre-commit style
	@$(SCRIPTS_DIR)/hygiene.sh

# -----------------------------------------------------------------------------
# Commit and tooling
# -----------------------------------------------------------------------------

commit: ## Atomic commit: FILES="path1 path2" MSG="feat: description"
	@test -n "$(FILES)" && test -n "$(MSG)" || (echo "Usage: make commit FILES=\"path1 path2\" MSG=\"feat: description\""; exit 1)
	@$(SCRIPTS_DIR)/committer -m "$(MSG)" $(FILES)

import-inspiration: ## Clone or update inspiration repos (optional REPOS="name1 name2"); list in scratchpad/research/inspiration-forked-projects/repos.json
	@$(SCRIPTS_DIR)/import-inspiration-repos.sh $(REPOS)

