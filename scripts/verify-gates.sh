#!/usr/bin/env bash
# verify-gates - Run a deterministic validation sweep.
# Usage: ./scripts/verify-gates.sh [--quick|--full] [--retries <n>] [--summary-json <path>] [--from <gate-id>] [--only <gate-id[,gate-id...]>]
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
RUN_ID=""
RUN_START_EPOCH_SECONDS="$(date +%s)"
SUMMARY_FILE=""
FROM_GATE_ID=""
ONLY_GATE_IDS_RAW=""
DRY_RUN=0
FAILED_GATE_ID=""

print_usage() {
	cat <<'USAGE'
Usage: ./scripts/verify-gates.sh [options]

Options:
--quick                     Run quick gate set (lint, typecheck, test-unit).
--full                      Run full gate set (default).
--retries <n>               Retry count per gate (default: VSCODE_VERIFY_RETRIES or 1).
--summary-json <path>       Write run summary JSON to path.
--from <gate-id>            Start execution from matching gate ID.
--only <id[,id...]>         Run only listed gate IDs.
--dry-run                   Resolve and report selected gates without executing commands.
-h, --help                  Show this help message.

Gate IDs:
lint typecheck test-unit test test-smoke test-integration test-e2e test-web-integration build
USAGE
}

while (($# > 0)); do
	case "$1" in
		-h|--help)
			print_usage
			exit 0
			;;
		--quick)
			MODE="quick"
			;;
		--full)
			MODE="full"
			;;
		--retries)
			if (($# < 2)); then
				echo "Missing value for --retries." >&2
				print_usage >&2
				exit 1
			fi
			shift
			RETRIES="${1:-}"
			;;
		--summary-json)
			if (($# < 2)); then
				echo "Missing value for --summary-json." >&2
				print_usage >&2
				exit 1
			fi
			shift
			SUMMARY_FILE="${1:-}"
			;;
		--from)
			if (($# < 2)); then
				echo "Missing value for --from." >&2
				print_usage >&2
				exit 1
			fi
			shift
			FROM_GATE_ID="${1:-}"
			;;
		--only)
			if (($# < 2)); then
				echo "Missing value for --only." >&2
				print_usage >&2
				exit 1
			fi
			shift
			ONLY_GATE_IDS_RAW="${1:-}"
			;;
		--dry-run)
			DRY_RUN=1
			;;
		*)
			echo "Unknown option: $1" >&2
			print_usage >&2
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

RUN_ID="${MODE}-${RUN_TIMESTAMP}"

declare -a gate_ids
declare -a gate_commands
if [[ "$MODE" == "quick" ]]; then
	gate_ids=("lint" "typecheck" "test-unit")
	gate_commands=("make lint" "make typecheck" "make test-unit")
else
	gate_ids=("lint" "typecheck" "test-unit" "test" "test-smoke" "test-integration" "test-e2e" "test-web-integration" "build")
	gate_commands=("make lint" "make typecheck" "make test-unit" "make test" "make test-smoke" "make test-integration" "make test-e2e" "make test-web-integration" "make build")
fi

find_gate_index() {
	local target_id="$1"
	for index in "${!gate_ids[@]}"; do
		if [[ "${gate_ids[$index]}" == "$target_id" ]]; then
			echo "$index"
			return 0
		fi
	done
	return 1
}

trim_whitespace() {
	local value="$1"
	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	printf '%s' "$value"
}

if [[ -n "$ONLY_GATE_IDS_RAW" ]]; then
	IFS=',' read -r -a requested_gate_ids <<< "$ONLY_GATE_IDS_RAW"
	declare -a filtered_gate_ids=()
	declare -a filtered_gate_commands=()
	declare -a duplicate_gate_ids=()

	for requested_gate_id in "${requested_gate_ids[@]}"; do
		requested_gate_id="$(trim_whitespace "$requested_gate_id")"
		if [[ -z "$requested_gate_id" ]]; then
			continue
		fi

		if ! gate_index="$(find_gate_index "$requested_gate_id")"; then
			echo "Unknown gate id '$requested_gate_id' for --only. Available gate ids: ${gate_ids[*]}" >&2
			exit 1
		fi

		selected_gate_id="${gate_ids[$gate_index]}"
		already_selected=0
		for existing_gate_id in "${filtered_gate_ids[@]}"; do
			if [[ "$existing_gate_id" == "$selected_gate_id" ]]; then
				already_selected=1
				break
			fi
		done

		if [[ "$already_selected" == "1" ]]; then
			duplicate_gate_ids+=("$selected_gate_id")
			continue
		fi

		filtered_gate_ids+=("${gate_ids[$gate_index]}")
		filtered_gate_commands+=("${gate_commands[$gate_index]}")
	done

	if ((${#filtered_gate_ids[@]} == 0)); then
		echo "--only produced an empty gate list. Provide at least one valid gate id." >&2
		exit 1
	fi

	if ((${#duplicate_gate_ids[@]} > 0)); then
		echo "Ignoring duplicate gate ids from --only: ${duplicate_gate_ids[*]}"
	fi

	gate_ids=("${filtered_gate_ids[@]}")
	gate_commands=("${filtered_gate_commands[@]}")
fi

if [[ -n "$FROM_GATE_ID" ]]; then
	FROM_GATE_ID="$(trim_whitespace "$FROM_GATE_ID")"
	if [[ -z "$FROM_GATE_ID" ]]; then
		echo "--from requires a non-empty gate id." >&2
		exit 1
	fi
	if ! from_index="$(find_gate_index "$FROM_GATE_ID")"; then
		echo "Unknown gate id '$FROM_GATE_ID' for --from. Available gate ids: ${gate_ids[*]}" >&2
		exit 1
	fi

	gate_ids=("${gate_ids[@]:from_index}")
	gate_commands=("${gate_commands[@]:from_index}")
fi

LOG_DIR="${VSCODE_VERIFY_LOG_DIR:-$ROOT/.build/logs/verify-gates}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${RUN_ID}.log"
if [[ -z "$SUMMARY_FILE" ]]; then
	SUMMARY_FILE="$LOG_DIR/${RUN_ID}.json"
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
	echo "  Run ID: ${RUN_ID}"
	echo "  Mode: ${MODE} (retries=${RETRIES}, dryRun=$([[ "$DRY_RUN" == "1" ]] && echo "true" || echo "false"))"
	echo "  Gate count: ${#gate_commands[@]}"
	for i in "${!gate_commands[@]}"; do
		printf "  - %-20s status=%-4s attempts=%s duration=%ss command=%s\n" "${gate_ids[$i]}" "${gate_results[$i]}" "${gate_attempt_counts[$i]}" "${gate_durations_seconds[$i]}" "${gate_commands[$i]}"
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

write_selected_gate_ids_json() {
	local gate_index
	for gate_index in "${!gate_ids[@]}"; do
		local delimiter=","
		if ((gate_index == ${#gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${gate_ids[$gate_index]}")\"${delimiter}"
	done
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
		echo "  \"runId\": \"$(json_escape "$RUN_ID")\","
		echo "  \"mode\": \"$(json_escape "$MODE")\","
		echo "  \"retries\": ${RETRIES},"
		echo "  \"dryRun\": $([[ "$DRY_RUN" == "1" ]] && echo "true" || echo "false"),"
		echo "  \"success\": ${run_success},"
		echo "  \"gateCount\": ${#gate_ids[@]},"
		if [[ -n "$FAILED_GATE_ID" ]]; then
			echo "  \"failedGateId\": \"$(json_escape "$FAILED_GATE_ID")\","
		else
			echo "  \"failedGateId\": null,"
		fi
		echo "  \"selectedGateIds\": ["
		write_selected_gate_ids_json
		echo "  ],"
		echo "  \"startedAt\": \"$(json_escape "$RUN_TIMESTAMP")\","
		echo "  \"completedAt\": \"$(json_escape "$completed_timestamp")\","
		echo "  \"totalDurationSeconds\": ${total_duration_seconds},"
		echo "  \"logFile\": \"$(json_escape "$LOG_FILE")\","
		echo "  \"gates\": ["
		for i in "${!gate_commands[@]}"; do
			local delimiter=","
			if ((i == ${#gate_commands[@]} - 1)); then
				delimiter=""
			fi
			echo "    {\"id\":\"$(json_escape "${gate_ids[$i]}")\",\"command\":\"$(json_escape "${gate_commands[$i]}")\",\"status\":\"$(json_escape "${gate_results[$i]}")\",\"attempts\":${gate_attempt_counts[$i]},\"durationSeconds\":${gate_durations_seconds[$i]}}${delimiter}"
		done
		echo "  ]"
		echo "}"
	} > "$SUMMARY_FILE"
}

echo "Running '${MODE}' verification sweep with retries=$RETRIES"
echo "Selected gates: ${gate_ids[*]}"

if [[ "$DRY_RUN" == "1" ]]; then
	echo "Dry run mode enabled - commands will not be executed."
	for i in "${!gate_commands[@]}"; do
		gate_results+=("skip")
		gate_durations_seconds+=("0")
		gate_attempt_counts+=("0")
	done
	print_summary
	write_summary_json "true"
	echo
	echo "Verification sweep dry run completed successfully."
	exit 0
fi

for i in "${!gate_commands[@]}"; do
	if run_gate "${gate_commands[$i]}"; then
		gate_results+=("pass")
		gate_durations_seconds+=("$RUN_GATE_DURATION_SECONDS")
		gate_attempt_counts+=("$RUN_GATE_ATTEMPTS")
		continue
	fi

	gate_results+=("fail")
	gate_durations_seconds+=("$RUN_GATE_DURATION_SECONDS")
	gate_attempt_counts+=("$RUN_GATE_ATTEMPTS")
	FAILED_GATE_ID="${gate_ids[$i]}"
	print_summary
	write_summary_json "false"
	exit 1
done

print_summary
write_summary_json "true"
echo
echo "Verification sweep completed successfully."
