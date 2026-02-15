#!/usr/bin/env bash
# verify-gates - Run a deterministic validation sweep.
# Usage: ./scripts/verify-gates.sh [--quick|--full] [--retries <n>] [--summary-json <path>]
# Delegates to: make lint/typecheck/test-* and make build targets.
# Emits run logs to .build/logs/verify-gates (configurable via VSCODE_VERIFY_LOG_DIR).
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
else
	ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
fi

MODE="full"
RETRIES="${VSCODE_VERIFY_RETRIES:-1}"
RUN_TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
RUN_START_EPOCH_SECONDS="$(date +%s)"
SUMMARY_FILE=""

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
		--summary-json)
			shift
			SUMMARY_FILE="${1:-}"
			;;
		*)
			echo "Unknown option: $1" >&2
			echo "Usage: ./scripts/verify-gates.sh [--quick|--full] [--retries <n>] [--summary-json <path>]" >&2
			exit 1
			;;
	esac
	shift
done

if ! [[ "$RETRIES" =~ ^[0-9]+$ ]]; then
	echo "Invalid retries value '$RETRIES' (expected non-negative integer)." >&2
	exit 1
fi

if [[ -z "$SUMMARY_FILE" ]]; then
	SUMMARY_FILE="${VSCODE_VERIFY_SUMMARY_FILE:-}"
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

LOG_DIR="${VSCODE_VERIFY_LOG_DIR:-$ROOT/.build/logs/verify-gates}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${MODE}-${RUN_TIMESTAMP}.log"
if [[ -z "$SUMMARY_FILE" ]]; then
	SUMMARY_FILE="$LOG_DIR/${MODE}-${RUN_TIMESTAMP}.json"
fi
exec > >(tee -a "$LOG_FILE") 2>&1

declare -a gate_results
declare -a gate_durations_seconds
declare -a gate_attempt_counts

run_gate() {
	local command="$1"
	local attempt=1
	local max_attempts=$((RETRIES + 1))
	local start_epoch_seconds
	local end_epoch_seconds

	start_epoch_seconds="$(date +%s)"

	while ((attempt <= max_attempts)); do
		echo
		echo ">>> [$attempt/$max_attempts] $command"
		if eval "$command"; then
			end_epoch_seconds="$(date +%s)"
			RUN_GATE_DURATION_SECONDS=$((end_epoch_seconds - start_epoch_seconds))
			RUN_GATE_ATTEMPTS="$attempt"
			return 0
		fi

		if ((attempt == max_attempts)); then
			end_epoch_seconds="$(date +%s)"
			RUN_GATE_DURATION_SECONDS=$((end_epoch_seconds - start_epoch_seconds))
			RUN_GATE_ATTEMPTS="$attempt"
			echo "Gate failed after $max_attempts attempt(s): $command" >&2
			return 1
		fi

		local backoff_seconds=$((2 ** (attempt - 1)))
		echo "Gate failed, retrying in ${backoff_seconds}s: $command" >&2
		sleep "$backoff_seconds"
		attempt=$((attempt + 1))
	done
}

print_summary() {
	local completed_epoch_seconds
	completed_epoch_seconds="$(date +%s)"
	local total_duration_seconds
	total_duration_seconds=$((completed_epoch_seconds - RUN_START_EPOCH_SECONDS))

	echo
	echo "Verification summary:"
	for i in "${!gates[@]}"; do
		printf "  - %-26s status=%-4s attempts=%s duration=%ss\n" "${gates[$i]}" "${gate_results[$i]}" "${gate_attempt_counts[$i]}" "${gate_durations_seconds[$i]}"
	done
	echo "  Total duration: ${total_duration_seconds}s"
	echo "  Log file: $LOG_FILE"
	echo "  Summary file: $SUMMARY_FILE"
}

json_escape() {
	local value="$1"
	value="${value//\\/\\\\}"
	value="${value//\"/\\\"}"
	value="${value//$'\n'/\\n}"
	value="${value//$'\r'/\\r}"
	value="${value//$'\t'/\\t}"
	printf '%s' "$value"
}

write_summary_json() {
	local run_success="$1"
	local completed_timestamp
	completed_timestamp="$(date -u +"%Y%m%dT%H%M%SZ")"
	local completed_epoch_seconds
	completed_epoch_seconds="$(date +%s)"
	local total_duration_seconds
	total_duration_seconds=$((completed_epoch_seconds - RUN_START_EPOCH_SECONDS))

	mkdir -p "$(dirname "$SUMMARY_FILE")"
	{
		echo "{"
		echo "  \"mode\": \"$(json_escape "$MODE")\","
		echo "  \"retries\": ${RETRIES},"
		echo "  \"success\": ${run_success},"
		echo "  \"startedAt\": \"$(json_escape "$RUN_TIMESTAMP")\","
		echo "  \"completedAt\": \"$(json_escape "$completed_timestamp")\","
		echo "  \"totalDurationSeconds\": ${total_duration_seconds},"
		echo "  \"logFile\": \"$(json_escape "$LOG_FILE")\","
		echo "  \"gates\": ["
		for i in "${!gates[@]}"; do
			local delimiter=","
			if ((i == ${#gates[@]} - 1)); then
				delimiter=""
			fi
			echo "    {\"command\":\"$(json_escape "${gates[$i]}")\",\"status\":\"$(json_escape "${gate_results[$i]}")\",\"attempts\":${gate_attempt_counts[$i]},\"durationSeconds\":${gate_durations_seconds[$i]}}${delimiter}"
		done
		echo "  ]"
		echo "}"
	} > "$SUMMARY_FILE"
}

echo "Running '${MODE}' verification sweep with retries=$RETRIES"
for gate in "${gates[@]}"; do
	if run_gate "$gate"; then
		gate_results+=("pass")
		gate_durations_seconds+=("$RUN_GATE_DURATION_SECONDS")
		gate_attempt_counts+=("$RUN_GATE_ATTEMPTS")
		continue
	fi

	gate_results+=("fail")
	gate_durations_seconds+=("$RUN_GATE_DURATION_SECONDS")
	gate_attempt_counts+=("$RUN_GATE_ATTEMPTS")
	print_summary
	write_summary_json "false"
	exit 1
done

print_summary
write_summary_json "true"
echo
echo "Verification sweep completed successfully."
