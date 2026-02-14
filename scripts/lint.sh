#!/usr/bin/env bash
# lint — Run ESLint and Stylelint (no fix).
# Usage: ./scripts/lint.sh
# Delegates to: npm run eslint, npm run stylelint.
# Called by: make lint
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

echo "Running ESLint..."
npm run eslint
echo "Running Stylelint..."
npm run stylelint
echo "Lint finished."
