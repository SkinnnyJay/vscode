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
CONTINUE_ON_FAILURE="${VSCODE_VERIFY_CONTINUE_ON_FAILURE:-0}"
RUN_TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
RUN_ID=""
RUN_START_EPOCH_SECONDS="$(date +%s)"
SUMMARY_SCHEMA_VERSION=8
SUMMARY_FILE=""
FROM_GATE_ID=""
ONLY_GATE_IDS_RAW=""
DRY_RUN=0
FAILED_GATE_ID=""
FAILED_GATE_EXIT_CODE=""
BLOCKING_GATE_ID=""
RUN_EXIT_REASON=""
INVOCATION=""
declare -a ORIGINAL_ARGS=("$@")

print_usage() {
	cat <<'USAGE'
Usage: ./scripts/verify-gates.sh [options]

Options:
--quick                     Run quick gate set (lint, typecheck, test-unit).
--full                      Run full gate set (default).
--retries <n>               Retry count per gate (default: VSCODE_VERIFY_RETRIES or 1).
--continue-on-failure       Execute remaining gates after a failure; exit non-zero at end if any gate failed.
--summary-json <path>       Write run summary JSON to path.
--from <gate-id>            Start execution from matching gate ID.
--only <id[,id...]>         Run only listed gate IDs.
--dry-run                   Resolve and report selected gates without executing commands.
-h, --help                  Show this help message.

Gate IDs:
lint typecheck test-unit test test-smoke test-integration test-e2e test-web-integration build
USAGE
}

normalize_boolean_flag() {
	local raw_value="$1"
	local flag_label="$2"
	local normalized_value="${raw_value,,}"

	case "$normalized_value" in
		1|true|yes|on)
			echo "1"
			return 0
			;;
		0|false|no|off)
			echo "0"
			return 0
			;;
		*)
			echo "Invalid ${flag_label} value '$raw_value' (expected one of: 0,1,true,false,yes,no,on,off)." >&2
			return 1
			;;
	esac
}

build_invocation() {
	local rendered="./scripts/verify-gates.sh"
	local arg
	for arg in "${ORIGINAL_ARGS[@]}"; do
		local quoted_arg
		printf -v quoted_arg "%q" "$arg"
		rendered+=" ${quoted_arg}"
	done
	echo "$rendered"
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
		--continue-on-failure)
			CONTINUE_ON_FAILURE=1
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

if ! CONTINUE_ON_FAILURE="$(normalize_boolean_flag "$CONTINUE_ON_FAILURE" "continue-on-failure")"; then
	exit 1
fi

if [[ -z "$SUMMARY_FILE" ]]; then
	SUMMARY_FILE="${VSCODE_VERIFY_SUMMARY_FILE:-}"
fi

cd "$ROOT"

RUN_ID="${MODE}-${RUN_TIMESTAMP}"
INVOCATION="$(build_invocation)"

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
declare -a gate_exit_codes
declare -a gate_started_at
declare -a gate_completed_at
declare -a gate_not_run_reasons
for i in "${!gate_commands[@]}"; do
	gate_results+=("not-run")
	gate_durations_seconds+=("0")
	gate_attempt_counts+=("0")
	gate_exit_codes+=("0")
	gate_started_at+=("")
	gate_completed_at+=("")
	gate_not_run_reasons+=("")
done

run_gate() {
	local command="$1"
	local attempt=1
	local max_attempts=$((RETRIES + 1))
	local start_epoch_seconds
	local end_epoch_seconds

	start_epoch_seconds="$(date +%s)"
	RUN_GATE_STARTED_AT="$(date -u +"%Y%m%dT%H%M%SZ")"

	while ((attempt <= max_attempts)); do
		echo
		echo ">>> [$attempt/$max_attempts] $command"
		if eval "$command"; then
			end_epoch_seconds="$(date +%s)"
			RUN_GATE_DURATION_SECONDS=$((end_epoch_seconds - start_epoch_seconds))
			RUN_GATE_ATTEMPTS="$attempt"
			RUN_GATE_EXIT_CODE="0"
			RUN_GATE_COMPLETED_AT="$(date -u +"%Y%m%dT%H%M%SZ")"
			return 0
		else
			local attempt_exit_code="$?"

			if ((attempt == max_attempts)); then
				end_epoch_seconds="$(date +%s)"
				RUN_GATE_DURATION_SECONDS=$((end_epoch_seconds - start_epoch_seconds))
				RUN_GATE_ATTEMPTS="$attempt"
				RUN_GATE_EXIT_CODE="$attempt_exit_code"
				RUN_GATE_COMPLETED_AT="$(date -u +"%Y%m%dT%H%M%SZ")"
				echo "Gate failed after $max_attempts attempt(s): $command" >&2
				return 1
			fi

			local backoff_seconds=$((2 ** (attempt - 1)))
			echo "Gate failed, retrying in ${backoff_seconds}s: $command" >&2
			sleep "$backoff_seconds"
			attempt=$((attempt + 1))
		fi
	done
}

print_summary() {
	local completed_epoch_seconds
	completed_epoch_seconds="$(date +%s)"
	local total_duration_seconds
	total_duration_seconds=$((completed_epoch_seconds - RUN_START_EPOCH_SECONDS))
	local pass_count
	pass_count="$(count_gate_status "pass")"
	local fail_count
	fail_count="$(count_gate_status "fail")"
	local skip_count
	skip_count="$(count_gate_status "skip")"
	local not_run_count
	not_run_count="$(count_gate_status "not-run")"
	local executed_count
	executed_count="$(count_executed_gates)"
	local pass_rate_percent
	pass_rate_percent="$(compute_pass_rate_percent "$executed_count" "$pass_count")"
	local executed_duration_seconds
	executed_duration_seconds="$(compute_executed_duration_seconds)"
	local average_executed_duration_seconds
	average_executed_duration_seconds="$(compute_average_executed_duration_seconds "$executed_duration_seconds" "$executed_count")"
	local fastest_executed_gate_index
	fastest_executed_gate_index="$(find_fastest_executed_gate_index)"
	local slowest_executed_gate_index
	slowest_executed_gate_index="$(find_slowest_executed_gate_index)"
	local total_retry_count
	total_retry_count="$(compute_total_retry_count)"
	local total_retry_backoff_seconds
	total_retry_backoff_seconds="$(compute_total_retry_backoff_seconds)"
	local retried_gate_count
	retried_gate_count="$(count_retried_gates)"
	local retried_gate_labels
	retried_gate_labels="$(collect_retried_gate_labels)"
	local retry_rate_percent
	retry_rate_percent="$(compute_retry_rate_percent "$executed_count" "$retried_gate_count")"
	local retry_backoff_share_percent
	retry_backoff_share_percent="$(compute_retry_backoff_share_percent "$executed_duration_seconds" "$total_retry_backoff_seconds")"
	local run_classification
	run_classification="$(compute_run_classification)"
	local result_signature_algorithm
	result_signature_algorithm="$(compute_result_signature_algorithm)"
	local result_signature
	result_signature="$(compute_result_signature "$result_signature_algorithm")"
	local failed_gate_labels
	failed_gate_labels="$(collect_failed_gate_labels)"

	echo
	echo "Verification summary:"
	echo "  Run ID: ${RUN_ID}"
	echo "  Invocation: ${INVOCATION}"
	echo "  Summary schema version: ${SUMMARY_SCHEMA_VERSION}"
	echo "  Exit reason: ${RUN_EXIT_REASON}"
	echo "  Run classification: ${run_classification}"
	echo "  Result signature algorithm: ${result_signature_algorithm}"
	echo "  Result signature: ${result_signature}"
	echo "  Mode: ${MODE} (retries=${RETRIES}, dryRun=$([[ "$DRY_RUN" == "1" ]] && echo "true" || echo "false"), continueOnFailure=$([[ "$CONTINUE_ON_FAILURE" == "1" ]] && echo "true" || echo "false"))"
	echo "  Gate count: ${#gate_commands[@]}"
	echo "  Gate outcomes: pass=${pass_count} fail=${fail_count} skip=${skip_count} not-run=${not_run_count}"
	echo "  Retry totals: retries=${total_retry_count} backoff=${total_retry_backoff_seconds}s"
	echo "  Retried gates: ${retried_gate_count} (${retried_gate_labels})"
	if ((retry_rate_percent >= 0)); then
		echo "  Retry rate (executed gates): ${retry_rate_percent}%"
	else
		echo "  Retry rate (executed gates): n/a"
	fi
	if ((retry_backoff_share_percent >= 0)); then
		echo "  Retry backoff share (executed duration): ${retry_backoff_share_percent}%"
	else
		echo "  Retry backoff share (executed duration): n/a"
	fi
	if ((pass_rate_percent >= 0)); then
		echo "  Pass rate (executed gates): ${pass_rate_percent}%"
	else
		echo "  Pass rate (executed gates): n/a"
	fi
	echo "  Executed duration total: ${executed_duration_seconds}s"
	if ((average_executed_duration_seconds >= 0)); then
		echo "  Executed duration average: ${average_executed_duration_seconds}s"
	else
		echo "  Executed duration average: n/a"
	fi
	if ((slowest_executed_gate_index >= 0)); then
		local slowest_executed_gate_id="${gate_ids[$slowest_executed_gate_index]}"
		local slowest_executed_gate_duration_seconds="${gate_durations_seconds[$slowest_executed_gate_index]}"
		echo "  Slowest executed gate: ${slowest_executed_gate_id} (${slowest_executed_gate_duration_seconds}s)"
	else
		echo "  Slowest executed gate: n/a"
	fi
	if ((fastest_executed_gate_index >= 0)); then
		local fastest_executed_gate_id="${gate_ids[$fastest_executed_gate_index]}"
		local fastest_executed_gate_duration_seconds="${gate_durations_seconds[$fastest_executed_gate_index]}"
		echo "  Fastest executed gate: ${fastest_executed_gate_id} (${fastest_executed_gate_duration_seconds}s)"
	else
		echo "  Fastest executed gate: n/a"
	fi
	echo "  Failed gates: ${failed_gate_labels}"
	for i in "${!gate_commands[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		local retry_backoff_seconds
		retry_backoff_seconds="$(compute_gate_retry_backoff_seconds_by_index "$retry_count")"
		printf "  - %-20s status=%-7s attempts=%s retries=%s backoff=%ss duration=%ss exitCode=%s command=%s\n" "${gate_ids[$i]}" "${gate_results[$i]}" "${gate_attempt_counts[$i]}" "${retry_count}" "${retry_backoff_seconds}" "${gate_durations_seconds[$i]}" "${gate_exit_codes[$i]}" "${gate_commands[$i]}"
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

count_gate_status() {
	local target_status="$1"
	local count=0
	local gate_status
	for gate_status in "${gate_results[@]}"; do
		if [[ "$gate_status" == "$target_status" ]]; then
			count=$((count + 1))
		fi
	done
	echo "$count"
}

count_executed_gates() {
	local passed_count
	passed_count="$(count_gate_status "pass")"
	local failed_count
	failed_count="$(count_gate_status "fail")"
	echo $((passed_count + failed_count))
}

compute_pass_rate_percent() {
	local executed_count="$1"
	local passed_count="$2"
	if ((executed_count == 0)); then
		echo "-1"
		return 0
	fi

	echo $((passed_count * 100 / executed_count))
}

compute_retry_rate_percent() {
	local executed_gate_count="$1"
	local retried_gate_count="$2"
	if ((executed_gate_count == 0)); then
		echo "-1"
		return 0
	fi

	echo $((retried_gate_count * 100 / executed_gate_count))
}

compute_retry_backoff_share_percent() {
	local executed_duration_seconds="$1"
	local total_retry_backoff_seconds="$2"
	if ((executed_duration_seconds == 0)); then
		echo "-1"
		return 0
	fi

	echo $((total_retry_backoff_seconds * 100 / executed_duration_seconds))
}

compute_run_classification() {
	local total_retry_count
	total_retry_count="$(compute_total_retry_count)"

	case "$RUN_EXIT_REASON" in
		dry-run)
			echo "dry-run"
			;;
		success)
			if ((total_retry_count > 0)); then
				echo "success-with-retries"
			else
				echo "success-no-retries"
			fi
			;;
		fail-fast)
			echo "failed-fail-fast"
			;;
		completed-with-failures)
			echo "failed-continued"
			;;
		*)
			echo "unknown"
			;;
	esac
}

compute_executed_duration_seconds() {
	local total=0
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" != "pass" ]] && [[ "${gate_results[$i]}" != "fail" ]]; then
			continue
		fi

		total=$((total + gate_durations_seconds[$i]))
	done

	echo "$total"
}

compute_average_executed_duration_seconds() {
	local executed_duration_seconds="$1"
	local executed_gate_count="$2"
	if ((executed_gate_count == 0)); then
		echo "-1"
		return 0
	fi

	echo $((executed_duration_seconds / executed_gate_count))
}

compute_gate_retry_count_by_index() {
	local gate_index="$1"
	local gate_status="${gate_results[$gate_index]}"
	if [[ "$gate_status" != "pass" ]] && [[ "$gate_status" != "fail" ]]; then
		echo "0"
		return 0
	fi

	local attempts="${gate_attempt_counts[$gate_index]}"
	if ((attempts <= 1)); then
		echo "0"
		return 0
	fi

	echo $((attempts - 1))
}

compute_gate_retry_backoff_seconds_by_index() {
	local retry_count="$1"
	if ((retry_count <= 0)); then
		echo "0"
		return 0
	fi

	echo $((2 ** retry_count - 1))
}

compute_total_retry_count() {
	local total_retry_count=0
	local i
	for i in "${!gate_results[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		total_retry_count=$((total_retry_count + retry_count))
	done

	echo "$total_retry_count"
}

compute_total_retry_backoff_seconds() {
	local total_backoff_seconds=0
	local i
	for i in "${!gate_results[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		local retry_backoff_seconds
		retry_backoff_seconds="$(compute_gate_retry_backoff_seconds_by_index "$retry_count")"
		total_backoff_seconds=$((total_backoff_seconds + retry_backoff_seconds))
	done

	echo "$total_backoff_seconds"
}

count_retried_gates() {
	local retried_gate_count=0
	local i
	for i in "${!gate_results[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		if ((retry_count > 0)); then
			retried_gate_count=$((retried_gate_count + 1))
		fi
	done

	echo "$retried_gate_count"
}

collect_retried_gate_labels() {
	local labels=""
	local i
	for i in "${!gate_results[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		if ((retry_count <= 0)); then
			continue
		fi

		local label="${gate_ids[$i]}(retries=${retry_count})"
		if [[ -n "$labels" ]]; then
			labels+=", "
		fi
		labels+="$label"
	done

	if [[ -z "$labels" ]]; then
		echo "none"
		return 0
	fi

	echo "$labels"
}

write_retried_gate_ids_json() {
	local -a retried_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		if ((retry_count > 0)); then
			retried_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!retried_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#retried_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${retried_gate_ids[$i]}")\"${delimiter}"
	done
}

find_slowest_executed_gate_index() {
	local slowest_index="-1"
	local slowest_duration="-1"
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" != "pass" ]] && [[ "${gate_results[$i]}" != "fail" ]]; then
			continue
		fi

		local gate_duration="${gate_durations_seconds[$i]}"
		if ((gate_duration > slowest_duration)); then
			slowest_duration="$gate_duration"
			slowest_index="$i"
		fi
	done

	echo "$slowest_index"
}

find_fastest_executed_gate_index() {
	local fastest_index="-1"
	local fastest_duration="-1"
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" != "pass" ]] && [[ "${gate_results[$i]}" != "fail" ]]; then
			continue
		fi

		local gate_duration="${gate_durations_seconds[$i]}"
		if ((fastest_index == -1)) || ((gate_duration < fastest_duration)); then
			fastest_duration="$gate_duration"
			fastest_index="$i"
		fi
	done

	echo "$fastest_index"
}

collect_failed_gate_labels() {
	local labels=""
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" != "fail" ]]; then
			continue
		fi

		local label="${gate_ids[$i]}(exitCode=${gate_exit_codes[$i]})"
		if [[ -n "$labels" ]]; then
			labels+=", "
		fi
		labels+="$label"
	done

	if [[ -z "$labels" ]]; then
		echo "none"
		return 0
	fi

	echo "$labels"
}

write_failed_gate_ids_json() {
	local -a failed_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "fail" ]]; then
			failed_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!failed_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#failed_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${failed_gate_ids[$i]}")\"${delimiter}"
	done
}

write_passed_gate_ids_json() {
	local -a passed_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "pass" ]]; then
			passed_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!passed_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#passed_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${passed_gate_ids[$i]}")\"${delimiter}"
	done
}

write_skipped_gate_ids_json() {
	local -a skipped_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "skip" ]]; then
			skipped_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!skipped_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#skipped_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${skipped_gate_ids[$i]}")\"${delimiter}"
	done
}

write_failed_gate_exit_codes_json() {
	local -a failed_gate_exit_codes=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "fail" ]]; then
			failed_gate_exit_codes+=("${gate_exit_codes[$i]}")
		fi
	done

	for i in "${!failed_gate_exit_codes[@]}"; do
		local delimiter=","
		if ((i == ${#failed_gate_exit_codes[@]} - 1)); then
			delimiter=""
		fi
		echo "    ${failed_gate_exit_codes[$i]}${delimiter}"
	done
}

write_executed_gate_ids_json() {
	local -a executed_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "pass" ]] || [[ "${gate_results[$i]}" == "fail" ]]; then
			executed_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!executed_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#executed_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${executed_gate_ids[$i]}")\"${delimiter}"
	done
}

write_not_run_gate_ids_json() {
	local -a not_run_gate_ids=()
	local i
	for i in "${!gate_results[@]}"; do
		if [[ "${gate_results[$i]}" == "not-run" ]]; then
			not_run_gate_ids+=("${gate_ids[$i]}")
		fi
	done

	for i in "${!not_run_gate_ids[@]}"; do
		local delimiter=","
		if ((i == ${#not_run_gate_ids[@]} - 1)); then
			delimiter=""
		fi
		echo "    \"$(json_escape "${not_run_gate_ids[$i]}")\"${delimiter}"
	done
}

compute_result_signature() {
	local algorithm="${1:-$(compute_result_signature_algorithm)}"
	local payload=""
	local i
	for i in "${!gate_commands[@]}"; do
		local retry_count
		retry_count="$(compute_gate_retry_count_by_index "$i")"
		payload+="${gate_ids[$i]}|${gate_results[$i]}|${gate_attempt_counts[$i]}|${retry_count}|${gate_exit_codes[$i]}|${gate_durations_seconds[$i]};"
	done

	case "$algorithm" in
		sha256sum)
			printf '%s' "$payload" | sha256sum | awk '{print $1}'
			;;
		shasum-256)
			printf '%s' "$payload" | shasum -a 256 | awk '{print $1}'
			;;
		cksum)
			printf '%s' "$payload" | cksum | awk '{print $1}'
			;;
		*)
			printf '%s' "$payload" | cksum | awk '{print $1}'
			;;
	esac
}

compute_result_signature_algorithm() {
	if command -v sha256sum > /dev/null 2>&1; then
		echo "sha256sum"
		return 0
	fi

	if command -v shasum > /dev/null 2>&1; then
		echo "shasum-256"
		return 0
	fi

	echo "cksum"
}

mark_remaining_not_run_reasons() {
	local start_index="$1"
	local reason="$2"
	local i
	for ((i = start_index; i < ${#gate_results[@]}; i++)); do
		if [[ "${gate_results[$i]}" == "not-run" ]] && [[ -z "${gate_not_run_reasons[$i]}" ]]; then
			gate_not_run_reasons[$i]="$reason"
		fi
	done
}

json_optional_timestamp() {
	local value="$1"
	if [[ -z "$value" ]]; then
		echo "null"
		return 0
	fi

	echo "\"$(json_escape "$value")\""
}

json_optional_string() {
	local value="$1"
	if [[ -z "$value" ]]; then
		echo "null"
		return 0
	fi

	echo "\"$(json_escape "$value")\""
}

write_summary_json() {
	local run_success="$1"
	local completed_timestamp
	completed_timestamp="$(date -u +"%Y%m%dT%H%M%SZ")"
	local completed_epoch_seconds
	completed_epoch_seconds="$(date +%s)"
	local total_duration_seconds
	total_duration_seconds=$((completed_epoch_seconds - RUN_START_EPOCH_SECONDS))
	local passed_gate_count
	passed_gate_count="$(count_gate_status "pass")"
	local failed_gate_count
	failed_gate_count="$(count_gate_status "fail")"
	local skipped_gate_count
	skipped_gate_count="$(count_gate_status "skip")"
	local not_run_gate_count
	not_run_gate_count="$(count_gate_status "not-run")"
	local executed_gate_count
	executed_gate_count="$(count_executed_gates)"
	local pass_rate_percent
	pass_rate_percent="$(compute_pass_rate_percent "$executed_gate_count" "$passed_gate_count")"
	local executed_duration_seconds
	executed_duration_seconds="$(compute_executed_duration_seconds)"
	local average_executed_duration_seconds
	average_executed_duration_seconds="$(compute_average_executed_duration_seconds "$executed_duration_seconds" "$executed_gate_count")"
	local fastest_executed_gate_index
	fastest_executed_gate_index="$(find_fastest_executed_gate_index)"
	local slowest_executed_gate_index
	slowest_executed_gate_index="$(find_slowest_executed_gate_index)"
	local total_retry_count
	total_retry_count="$(compute_total_retry_count)"
	local total_retry_backoff_seconds
	total_retry_backoff_seconds="$(compute_total_retry_backoff_seconds)"
	local retried_gate_count
	retried_gate_count="$(count_retried_gates)"
	local retry_rate_percent
	retry_rate_percent="$(compute_retry_rate_percent "$executed_gate_count" "$retried_gate_count")"
	local retry_backoff_share_percent
	retry_backoff_share_percent="$(compute_retry_backoff_share_percent "$executed_duration_seconds" "$total_retry_backoff_seconds")"
	local run_classification
	run_classification="$(compute_run_classification)"
	local result_signature_algorithm
	result_signature_algorithm="$(compute_result_signature_algorithm)"
	local result_signature
	result_signature="$(compute_result_signature "$result_signature_algorithm")"

	mkdir -p "$(dirname "$SUMMARY_FILE")"
	{
		echo "{"
		echo "  \"schemaVersion\": ${SUMMARY_SCHEMA_VERSION},"
		echo "  \"runId\": \"$(json_escape "$RUN_ID")\","
		echo "  \"invocation\": \"$(json_escape "$INVOCATION")\","
		echo "  \"exitReason\": \"$(json_escape "$RUN_EXIT_REASON")\","
		echo "  \"runClassification\": \"$(json_escape "$run_classification")\","
		echo "  \"resultSignatureAlgorithm\": \"$(json_escape "$result_signature_algorithm")\","
		echo "  \"resultSignature\": \"$(json_escape "$result_signature")\","
		echo "  \"mode\": \"$(json_escape "$MODE")\","
		echo "  \"retries\": ${RETRIES},"
		echo "  \"continueOnFailure\": $([[ "$CONTINUE_ON_FAILURE" == "1" ]] && echo "true" || echo "false"),"
		echo "  \"dryRun\": $([[ "$DRY_RUN" == "1" ]] && echo "true" || echo "false"),"
		echo "  \"success\": ${run_success},"
		echo "  \"gateCount\": ${#gate_ids[@]},"
		echo "  \"passedGateCount\": ${passed_gate_count},"
		echo "  \"failedGateCount\": ${failed_gate_count},"
		echo "  \"skippedGateCount\": ${skipped_gate_count},"
		echo "  \"notRunGateCount\": ${not_run_gate_count},"
		echo "  \"statusCounts\": {\"pass\": ${passed_gate_count}, \"fail\": ${failed_gate_count}, \"skip\": ${skipped_gate_count}, \"not-run\": ${not_run_gate_count}},"
		echo "  \"executedGateCount\": ${executed_gate_count},"
		echo "  \"totalRetryCount\": ${total_retry_count},"
		echo "  \"totalRetryBackoffSeconds\": ${total_retry_backoff_seconds},"
		echo "  \"retriedGateCount\": ${retried_gate_count},"
		if ((retry_rate_percent >= 0)); then
			echo "  \"retryRatePercent\": ${retry_rate_percent},"
		else
			echo "  \"retryRatePercent\": null,"
		fi
		if ((retry_backoff_share_percent >= 0)); then
			echo "  \"retryBackoffSharePercent\": ${retry_backoff_share_percent},"
		else
			echo "  \"retryBackoffSharePercent\": null,"
		fi
		echo "  \"executedDurationSeconds\": ${executed_duration_seconds},"
		if ((pass_rate_percent >= 0)); then
			echo "  \"passRatePercent\": ${pass_rate_percent},"
		else
			echo "  \"passRatePercent\": null,"
		fi
		if ((average_executed_duration_seconds >= 0)); then
			echo "  \"averageExecutedDurationSeconds\": ${average_executed_duration_seconds},"
		else
			echo "  \"averageExecutedDurationSeconds\": null,"
		fi
		if ((slowest_executed_gate_index >= 0)); then
			echo "  \"slowestExecutedGateId\": \"$(json_escape "${gate_ids[$slowest_executed_gate_index]}")\","
			echo "  \"slowestExecutedGateDurationSeconds\": ${gate_durations_seconds[$slowest_executed_gate_index]},"
		else
			echo "  \"slowestExecutedGateId\": null,"
			echo "  \"slowestExecutedGateDurationSeconds\": null,"
		fi
		if ((fastest_executed_gate_index >= 0)); then
			echo "  \"fastestExecutedGateId\": \"$(json_escape "${gate_ids[$fastest_executed_gate_index]}")\","
			echo "  \"fastestExecutedGateDurationSeconds\": ${gate_durations_seconds[$fastest_executed_gate_index]},"
		else
			echo "  \"fastestExecutedGateId\": null,"
			echo "  \"fastestExecutedGateDurationSeconds\": null,"
		fi
		if [[ -n "$FAILED_GATE_ID" ]]; then
			echo "  \"failedGateId\": \"$(json_escape "$FAILED_GATE_ID")\","
		else
			echo "  \"failedGateId\": null,"
		fi
		if [[ -n "$FAILED_GATE_EXIT_CODE" ]]; then
			echo "  \"failedGateExitCode\": ${FAILED_GATE_EXIT_CODE},"
		else
			echo "  \"failedGateExitCode\": null,"
		fi
		if [[ -n "$BLOCKING_GATE_ID" ]]; then
			echo "  \"blockedByGateId\": \"$(json_escape "$BLOCKING_GATE_ID")\","
		else
			echo "  \"blockedByGateId\": null,"
		fi
		echo "  \"failedGateIds\": ["
		write_failed_gate_ids_json
		echo "  ],"
		echo "  \"passedGateIds\": ["
		write_passed_gate_ids_json
		echo "  ],"
		echo "  \"skippedGateIds\": ["
		write_skipped_gate_ids_json
		echo "  ],"
		echo "  \"failedGateExitCodes\": ["
		write_failed_gate_exit_codes_json
		echo "  ],"
		echo "  \"executedGateIds\": ["
		write_executed_gate_ids_json
		echo "  ],"
		echo "  \"retriedGateIds\": ["
		write_retried_gate_ids_json
		echo "  ],"
		echo "  \"notRunGateIds\": ["
		write_not_run_gate_ids_json
		echo "  ],"
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
			local started_at_json
			started_at_json="$(json_optional_timestamp "${gate_started_at[$i]}")"
			local completed_at_json
			completed_at_json="$(json_optional_timestamp "${gate_completed_at[$i]}")"
			local not_run_reason_json
			not_run_reason_json="$(json_optional_string "${gate_not_run_reasons[$i]}")"
			local retry_count
			retry_count="$(compute_gate_retry_count_by_index "$i")"
			local retry_backoff_seconds
			retry_backoff_seconds="$(compute_gate_retry_backoff_seconds_by_index "$retry_count")"
			echo "    {\"id\":\"$(json_escape "${gate_ids[$i]}")\",\"command\":\"$(json_escape "${gate_commands[$i]}")\",\"status\":\"$(json_escape "${gate_results[$i]}")\",\"attempts\":${gate_attempt_counts[$i]},\"retryCount\":${retry_count},\"retryBackoffSeconds\":${retry_backoff_seconds},\"durationSeconds\":${gate_durations_seconds[$i]},\"exitCode\":${gate_exit_codes[$i]},\"startedAt\":${started_at_json},\"completedAt\":${completed_at_json},\"notRunReason\":${not_run_reason_json}}${delimiter}"
		done
		echo "  ]"
		echo "}"
	} > "$SUMMARY_FILE"
}

echo "Running '${MODE}' verification sweep with retries=$RETRIES continueOnFailure=$([[ "$CONTINUE_ON_FAILURE" == "1" ]] && echo "true" || echo "false")"
echo "Selected gates: ${gate_ids[*]}"

if [[ "$DRY_RUN" == "1" ]]; then
	RUN_EXIT_REASON="dry-run"
	echo "Dry run mode enabled - commands will not be executed."
	for i in "${!gate_commands[@]}"; do
		gate_results[$i]="skip"
		gate_durations_seconds[$i]="0"
		gate_attempt_counts[$i]="0"
		gate_exit_codes[$i]="0"
		gate_started_at[$i]="$RUN_TIMESTAMP"
		gate_completed_at[$i]="$RUN_TIMESTAMP"
	done
	print_summary
	write_summary_json "true"
	echo
	echo "Verification sweep dry run completed successfully."
	exit 0
fi

any_gate_failed=0
for i in "${!gate_commands[@]}"; do
	if run_gate "${gate_commands[$i]}"; then
		gate_results[$i]="pass"
		gate_durations_seconds[$i]="$RUN_GATE_DURATION_SECONDS"
		gate_attempt_counts[$i]="$RUN_GATE_ATTEMPTS"
		gate_exit_codes[$i]="$RUN_GATE_EXIT_CODE"
		gate_started_at[$i]="$RUN_GATE_STARTED_AT"
		gate_completed_at[$i]="$RUN_GATE_COMPLETED_AT"
		continue
	fi

	gate_results[$i]="fail"
	gate_durations_seconds[$i]="$RUN_GATE_DURATION_SECONDS"
	gate_attempt_counts[$i]="$RUN_GATE_ATTEMPTS"
	gate_exit_codes[$i]="$RUN_GATE_EXIT_CODE"
	gate_started_at[$i]="$RUN_GATE_STARTED_AT"
	gate_completed_at[$i]="$RUN_GATE_COMPLETED_AT"
	if [[ -z "$FAILED_GATE_ID" ]]; then
		FAILED_GATE_ID="${gate_ids[$i]}"
		FAILED_GATE_EXIT_CODE="$RUN_GATE_EXIT_CODE"
	fi
	any_gate_failed=1
	if [[ "$CONTINUE_ON_FAILURE" == "1" ]]; then
		continue
	fi

	RUN_EXIT_REASON="fail-fast"
	BLOCKING_GATE_ID="${gate_ids[$i]}"
	mark_remaining_not_run_reasons "$((i + 1))" "blocked-by-fail-fast:${BLOCKING_GATE_ID}"
	print_summary
	write_summary_json "false"
	exit 1
done

if [[ "$any_gate_failed" == "1" ]]; then
	RUN_EXIT_REASON="completed-with-failures"
	print_summary
	write_summary_json "false"
	exit 1
fi

RUN_EXIT_REASON="success"
print_summary
write_summary_json "true"
echo
echo "Verification sweep completed successfully."
