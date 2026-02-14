#!/usr/bin/env bash
# hygiene — Run full pre-commit hygiene (indentation, copyright, ESLint, Stylelint).
# Usage: ./scripts/hygiene.sh
# Delegates to: npm run hygiene (gulp hygiene).
# Called by: make hygiene
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

npm run hygiene
