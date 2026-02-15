#!/usr/bin/env bash
# verify-gates - Run a deterministic validation sweep.
# Usage: ./scripts/verify-gates.sh [--quick|--full] [--retries <n>]
# Delegates to: make lint/typecheck/test-* and make build targets.
# Called by: make verify-gates
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
else
	ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
fi

MODE="full"
RETRIES="${VSCODE_VERIFY_RETRIES:-1}"

while (($# > 0)); do
	case "$1" in
		--quick)
			MODE="quick"
			;;
		--full)
			MODE="full"
			;;
		--retries)
			shift
			RETRIES="${1:-}"
			;;
		*)
			echo "Unknown option: $1" >&2
			echo "Usage: ./scripts/verify-gates.sh [--quick|--full] [--retries <n>]" >&2
			exit 1
			;;
	esac
	shift
done

if ! [[ "$RETRIES" =~ ^[0-9]+$ ]]; then
	echo "Invalid retries value '$RETRIES' (expected non-negative integer)." >&2
	exit 1
fi

cd "$ROOT"

declare -a gates
if [[ "$MODE" == "quick" ]]; then
	gates=(
		"make lint"
		"make typecheck"
		"make test-unit"
	)
else
	gates=(
		"make lint"
		"make typecheck"
		"make test-unit"
		"make test"
		"make test-smoke"
		"make test-integration"
		"make test-e2e"
		"make test-web-integration"
		"make build"
	)
fi

run_gate() {
	local command="$1"
	local attempt=1
	local max_attempts=$((RETRIES + 1))

	while ((attempt <= max_attempts)); do
		echo
		echo ">>> [$attempt/$max_attempts] $command"
		if eval "$command"; then
			return 0
		fi

		if ((attempt == max_attempts)); then
			echo "Gate failed after $max_attempts attempt(s): $command" >&2
			return 1
		fi

		local backoff_seconds=$((2 ** (attempt - 1)))
		echo "Gate failed, retrying in ${backoff_seconds}s: $command" >&2
		sleep "$backoff_seconds"
		attempt=$((attempt + 1))
	done
}

echo "Running '${MODE}' verification sweep with retries=$RETRIES"
for gate in "${gates[@]}"; do
	run_gate "$gate"
done

echo
echo "Verification sweep completed successfully."
