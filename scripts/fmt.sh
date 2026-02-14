#!/usr/bin/env bash
# fmt — Run formatting checks (and fix where supported).
# Usage: ./scripts/fmt.sh [--check]
#   Default: apply fixes (ESLint --fix, Stylelint --fix).
#   --check  Only check; do not modify files (fails if formatting would change).
# Upstream Code - OSS uses editor format-on-save and hygiene for pre-commit; this script
# runs automated fix where available. For full hygiene (copyright, indentation, etc.) use: npm run hygiene.
# Called by: make fmt, make fmt-check
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

CHECK_ONLY=false
for arg in "$@"; do
	case "$arg" in
		--check) CHECK_ONLY=true ;;
	esac
done

if [ "$CHECK_ONLY" = true ]; then
	echo "Running format check (no modifications)..."
	npm run eslint
	npm run stylelint
	echo "Format check done."
else
	echo "Applying ESLint and Stylelint fixes..."
	npx eslint . --fix 2>/dev/null || npm run eslint
	npx stylelint "src/**/*.css" --fix 2>/dev/null || true
	echo "Format done."
fi
