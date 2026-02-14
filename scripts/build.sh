#!/usr/bin/env bash
# build — Compile the project (Code - OSS / Pointer IDE).
# Usage: ./scripts/build.sh
# Delegates to: npm run compile (gulp compile).
# Called by: make build
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

echo "Building..."
npm run compile
