#!/usr/bin/env bash
# clean — Remove build artifacts, caches, and compiled output.
# Usage: ./scripts/clean.sh [--all]
#   --all  Also remove node_modules (full clean; requires npm install afterward).
# Called by: make clean
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

REMOVE_NODE_MODULES=false
for arg in "$@"; do
	case "$arg" in
		--all) REMOVE_NODE_MODULES=true ;;
	esac
done

echo "Cleaning build artifacts and caches..."

# Out dir (main compile output)
rm -rf out 2>/dev/null || true

# Gulp / build output
rm -rf .build 2>/dev/null || true

# Test and extension build outputs
rm -rf test/unit/browser/out 2>/dev/null || true
rm -rf test/smoke/out 2>/dev/null || true
rm -rf test/automation/out 2>/dev/null || true
rm -rf test/integration/browser/out 2>/dev/null || true

# Common cache dirs
rm -rf node_modules/.cache 2>/dev/null || true

# Optional: full clean
if [ "$REMOVE_NODE_MODULES" = true ]; then
	echo "Removing node_modules..."
	rm -rf node_modules
	echo "Done. Run make setup to reinstall dependencies."
else
	echo "Done. Use ./scripts/clean.sh --all to also remove node_modules."
fi
