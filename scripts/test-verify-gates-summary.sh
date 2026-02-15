#!/usr/bin/env bash
# test-verify-gates-summary - Validate verify-gates summary schema/renderer contract.
# Usage: ./scripts/test-verify-gates-summary.sh
# Delegates to: ./scripts/verify-gates.sh and ./scripts/publish-verify-gates-summary.sh in controlled mock scenarios.
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
else
	ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
fi

cd "$ROOT"

tmpdir="$(mktemp -d)"
cleanup() {
	rm -rf "$tmpdir"
	unset -f make || true
}
trap cleanup EXIT

dry_summary="$tmpdir/dry.json"
dry_repeat_summary="$tmpdir/dry-repeat.json"
continue_true_summary="$tmpdir/continue-true.json"
continue_false_summary="$tmpdir/continue-false.json"
continue_flag_summary="$tmpdir/continue-flag.json"
continue_flag_step_summary="$tmpdir/continue-flag-step.md"
dedupe_summary="$tmpdir/dedupe.json"
from_summary="$tmpdir/from.json"
full_dry_summary="$tmpdir/full-dry.json"
default_mode_dry_summary="$tmpdir/default-mode-dry.json"
mode_precedence_full_summary="$tmpdir/mode-precedence-full.json"
mode_precedence_quick_summary="$tmpdir/mode-precedence-quick.json"
env_retries_summary="$tmpdir/env-retries.json"
cli_retries_override_summary="$tmpdir/cli-retries-override.json"
continue_fail_summary="$tmpdir/continue-fail.json"
continue_multi_fail_summary="$tmpdir/continue-multi-fail.json"
fail_fast_summary="$tmpdir/fail-fast.json"
retry_summary="$tmpdir/retry.json"
continue_fail_step_summary="$tmpdir/continue-fail-step.md"
continue_multi_fail_step_summary="$tmpdir/continue-multi-fail-step.md"
fail_fast_step_summary="$tmpdir/fail-fast-step.md"
retry_step_summary="$tmpdir/retry-step.md"
future_summary="$tmpdir/future.json"
future_step_summary="$tmpdir/future-step.md"
malformed_summary="$tmpdir/malformed\`name.json"
malformed_step_summary="$tmpdir/malformed-step.md"
missing_step_summary="$tmpdir/missing-step.md"
escape_summary="$tmpdir/escape.json"
escape_step_summary="$tmpdir/escape-step.md"
code_span_summary="$tmpdir/code-span.json"
code_span_step_summary="$tmpdir/code-span-step.md"
fallback_summary="$tmpdir/fallback.json"
fallback_step_summary="$tmpdir/fallback-step.md"
dry_fallback_summary="$tmpdir/dry-fallback.json"
dry_fallback_step_summary="$tmpdir/dry-fallback-step.md"
fail_fast_fallback_summary="$tmpdir/fail-fast-fallback.json"
fail_fast_fallback_step_summary="$tmpdir/fail-fast-fallback-step.md"
derived_counts_summary="$tmpdir/derived-counts.json"
derived_counts_step_summary="$tmpdir/derived-counts-step.md"
duplicate_gate_rows_summary="$tmpdir/duplicate-gate-rows.json"
duplicate_gate_rows_step_summary="$tmpdir/duplicate-gate-rows-step.md"
malformed_gate_rows_summary="$tmpdir/malformed-gate-rows.json"
malformed_gate_rows_step_summary="$tmpdir/malformed-gate-rows-step.md"
row_not_run_reason_type_summary="$tmpdir/row-not-run-reason-type.json"
row_not_run_reason_type_step_summary="$tmpdir/row-not-run-reason-type-step.md"
row_command_type_summary="$tmpdir/row-command-type.json"
row_command_type_step_summary="$tmpdir/row-command-type-step.md"
derived_lists_summary="$tmpdir/derived-lists.json"
derived_lists_step_summary="$tmpdir/derived-lists-step.md"
derived_status_map_summary="$tmpdir/derived-status-map.json"
derived_status_map_step_summary="$tmpdir/derived-status-map-step.md"
derived_dry_run_summary="$tmpdir/derived-dry-run.json"
derived_dry_run_step_summary="$tmpdir/derived-dry-run-step.md"
derived_continued_failure_summary="$tmpdir/derived-continued-failure.json"
derived_continued_failure_step_summary="$tmpdir/derived-continued-failure-step.md"
explicit_reason_summary="$tmpdir/explicit-reason.json"
explicit_reason_step_summary="$tmpdir/explicit-reason-step.md"
invalid_reason_summary="$tmpdir/invalid-reason.json"
invalid_reason_step_summary="$tmpdir/invalid-reason-step.md"
explicit_run_classification_summary="$tmpdir/explicit-run-classification.json"
explicit_run_classification_step_summary="$tmpdir/explicit-run-classification-step.md"
conflicting_reason_classification_summary="$tmpdir/conflicting-reason-classification.json"
conflicting_reason_classification_step_summary="$tmpdir/conflicting-reason-classification-step.md"
conflicting_run_state_flags_summary="$tmpdir/conflicting-run-state-flags.json"
conflicting_run_state_flags_step_summary="$tmpdir/conflicting-run-state-flags-step.md"
conflicting_classification_flags_summary="$tmpdir/conflicting-classification-flags.json"
conflicting_classification_flags_step_summary="$tmpdir/conflicting-classification-flags-step.md"
invalid_reason_with_classification_summary="$tmpdir/invalid-reason-with-classification.json"
invalid_reason_with_classification_step_summary="$tmpdir/invalid-reason-with-classification-step.md"
invalid_classification_with_reason_summary="$tmpdir/invalid-classification-with-reason.json"
invalid_classification_with_reason_step_summary="$tmpdir/invalid-classification-with-reason-step.md"
dry_run_reason_conflicts_summary="$tmpdir/dry-run-reason-conflicts.json"
dry_run_reason_conflicts_step_summary="$tmpdir/dry-run-reason-conflicts-step.md"
success_reason_conflicts_summary="$tmpdir/success-reason-conflicts.json"
success_reason_conflicts_step_summary="$tmpdir/success-reason-conflicts-step.md"
success_reason_explicit_continue_summary="$tmpdir/success-reason-explicit-continue.json"
success_reason_explicit_continue_step_summary="$tmpdir/success-reason-explicit-continue-step.md"
success_classification_explicit_continue_summary="$tmpdir/success-classification-explicit-continue.json"
success_classification_explicit_continue_step_summary="$tmpdir/success-classification-explicit-continue-step.md"
numeric_boolean_flags_summary="$tmpdir/numeric-boolean-flags.json"
numeric_boolean_flags_step_summary="$tmpdir/numeric-boolean-flags-step.md"
minimal_summary="$tmpdir/minimal.json"
minimal_step_summary="$tmpdir/minimal-step.md"
env_path_step_summary="$tmpdir/env-path-step.md"
scalar_summary="$tmpdir/scalar.json"
scalar_step_summary="$tmpdir/scalar-step.md"
append_step_summary="$tmpdir/append-step.md"
multiline_heading_step_summary="$tmpdir/multiline-heading-step.md"
blank_heading_step_summary="$tmpdir/blank-heading-step.md"
whitespace_heading_step_summary="$tmpdir/whitespace-heading-step.md"
array_summary="$tmpdir/array.json"
array_step_summary="$tmpdir/array-step.md"
null_summary="$tmpdir/null.json"
null_step_summary="$tmpdir/null-step.md"

expected_schema_version="$(sed -n 's/^SUMMARY_SCHEMA_VERSION=\([0-9][0-9]*\)$/\1/p' ./scripts/verify-gates.sh | awk 'NR==1{print;exit}')"
supported_schema_version="$(sed -n 's/^const supportedSchemaVersion = \([0-9][0-9]*\);$/\1/p' ./scripts/publish-verify-gates-summary.sh | awk 'NR==1{print;exit}')"

if [[ -z "$expected_schema_version" ]]; then
	echo "Unable to resolve SUMMARY_SCHEMA_VERSION from scripts/verify-gates.sh." >&2
	exit 1
fi

if [[ -z "$supported_schema_version" ]]; then
	echo "Unable to resolve supportedSchemaVersion from scripts/publish-verify-gates-summary.sh." >&2
	exit 1
fi

if [[ "$expected_schema_version" != "$supported_schema_version" ]]; then
	echo "Schema version mismatch: verify-gates=${expected_schema_version}, publish=${supported_schema_version}." >&2
	exit 1
fi

if ! grep -q "Current summary schema version: \`${expected_schema_version}\`." ./scripts/README.md; then
	echo "scripts/README.md summary schema version does not match ${expected_schema_version}." >&2
	exit 1
fi

if ! grep -q "./scripts/test-verify-gates-summary.sh" "./.github/workflows/pointer-quality.yml"; then
	echo "pointer-quality workflow is missing verify-gates summary contract step." >&2
	exit 1
fi

if ! grep -q "./scripts/test-verify-gates-summary.sh" "./.github/workflows/verify-gates-nightly.yml"; then
	echo "verify-gates-nightly workflow is missing verify-gates summary contract step." >&2
	exit 1
fi

VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$dry_summary" > "$tmpdir/dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$dry_repeat_summary" > "$tmpdir/dry-repeat.out"
VSCODE_VERIFY_CONTINUE_ON_FAILURE=true VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$continue_true_summary" > "$tmpdir/continue-true.out"
VSCODE_VERIFY_CONTINUE_ON_FAILURE=off VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$continue_false_summary" > "$tmpdir/continue-false.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint --continue-on-failure --dry-run --summary-json "$continue_flag_summary" > "$tmpdir/continue-flag.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only " lint , lint , typecheck " --dry-run --summary-json "$dedupe_summary" > "$tmpdir/dedupe.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --from typecheck --dry-run --summary-json "$from_summary" > "$tmpdir/from.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --full --only build --dry-run --summary-json "$full_dry_summary" > "$tmpdir/full-dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --only build --dry-run --summary-json "$default_mode_dry_summary" > "$tmpdir/default-mode-dry.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" VSCODE_VERIFY_RETRIES=2 ./scripts/verify-gates.sh --quick --only lint --dry-run --summary-json "$env_retries_summary" > "$tmpdir/env-retries.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" VSCODE_VERIFY_RETRIES=2 ./scripts/verify-gates.sh --quick --only lint --retries 0 --dry-run --summary-json "$cli_retries_override_summary" > "$tmpdir/cli-retries-override.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --full --only build --dry-run --summary-json "$mode_precedence_full_summary" > "$tmpdir/mode-precedence-full.out"
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --full --quick --only test-unit --dry-run --summary-json "$mode_precedence_quick_summary" > "$tmpdir/mode-precedence-quick.out"
if ! grep -q "Ignoring duplicate gate ids from --only: lint" "$tmpdir/dedupe.out"; then
	echo "Expected duplicate --only gate IDs warning message." >&2
	exit 1
fi

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --retries 0 --summary-json "$fail_fast_summary" > "$tmpdir/fail-fast.out" 2>&1
fail_fast_status=$?
set -e
if [[ "$fail_fast_status" -ne 1 ]]; then
	echo "Expected fail-fast run to exit with code 1, got ${fail_fast_status}." >&2
	exit 1
fi

unset -f make

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --continue-on-failure --retries 0 --summary-json "$continue_fail_summary" > "$tmpdir/continue-fail.out" 2>&1
continue_fail_status=$?
set -e
if [[ "$continue_fail_status" -ne 1 ]]; then
	echo "Expected continue-on-failure run with lint failure to exit with code 1, got ${continue_fail_status}." >&2
	exit 1
fi

unset -f make

function make() {
	if [[ "$1" == "lint" ]]; then
		return 7
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 3
	fi
	return 0
}
export -f make

set +e
VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --continue-on-failure --retries 0 --summary-json "$continue_multi_fail_summary" > "$tmpdir/continue-multi-fail.out" 2>&1
continue_multi_fail_status=$?
set -e
if [[ "$continue_multi_fail_status" -ne 1 ]]; then
	echo "Expected continue-on-failure run with multiple failures to exit with code 1, got ${continue_multi_fail_status}." >&2
	exit 1
fi

unset -f make

lint_attempt_file="$tmpdir/lint-attempt.txt"
echo "0" > "$lint_attempt_file"
function make() {
	if [[ "$1" == "lint" ]]; then
		attempt="$(<"$VERIFY_LINT_ATTEMPT_FILE")"
		attempt=$((attempt + 1))
		echo "$attempt" > "$VERIFY_LINT_ATTEMPT_FILE"
		if ((attempt == 1)); then
			return 4
		fi
		return 0
	fi
	if [[ "$1" == "typecheck" ]]; then
		return 0
	fi
	return 0
}
export -f make

VERIFY_LINT_ATTEMPT_FILE="$lint_attempt_file" VSCODE_VERIFY_LOG_DIR="$tmpdir/logs" ./scripts/verify-gates.sh --quick --only lint,typecheck --retries 1 --summary-json "$retry_summary" > "$tmpdir/retry.out"

unset -f make

GITHUB_STEP_SUMMARY="$fail_fast_step_summary" ./scripts/publish-verify-gates-summary.sh "$fail_fast_summary" "Verify Gates Fail-fast Contract Test"
GITHUB_STEP_SUMMARY="$retry_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Verify Gates Retry Contract Test"
GITHUB_STEP_SUMMARY="$continue_flag_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_flag_summary" "Verify Gates Continue-on-Failure Dry-Run Contract Test"
GITHUB_STEP_SUMMARY="$continue_fail_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_fail_summary" "Verify Gates Continue-on-Failure Failure Contract Test"
GITHUB_STEP_SUMMARY="$continue_multi_fail_step_summary" ./scripts/publish-verify-gates-summary.sh "$continue_multi_fail_summary" "Verify Gates Continue-on-Failure Multi-Failure Contract Test"

node - "$retry_summary" "$fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateStatusById;
delete payload.gateExitCodeById;
delete payload.gateRetryCountById;
delete payload.gateDurationSecondsById;
delete payload.gateNotRunReasonById;
delete payload.gateAttemptCountById;
delete payload.attentionGateIds;
delete payload.nonSuccessGateIds;
delete payload.notRunGateIds;
delete payload.failedGateIds;
delete payload.failedGateExitCodes;
delete payload.passedGateIds;
delete payload.skippedGateIds;
delete payload.executedGateIds;
delete payload.retriedGateIds;
delete payload.selectedGateIds;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$fallback_summary" "Verify Gates Fallback Contract Test"

node - "$dry_summary" "$dry_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateExitCodeById;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$dry_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$dry_fallback_summary" "Verify Gates Dry Fallback Contract Test"

node - "$fail_fast_summary" "$fail_fast_fallback_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, fallbackPath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
delete payload.gateExitCodeById;
fs.writeFileSync(fallbackPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$fail_fast_fallback_step_summary" ./scripts/publish-verify-gates-summary.sh "$fail_fast_fallback_summary" "Verify Gates Fail-fast Fallback Contract Test"

node - "$expected_schema_version" "$derived_counts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-counts-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: ' PASS ', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: ' 20260215T010000Z ', completedAt: ' 20260215T010001Z ', notRunReason: null },
		{ id: ' typecheck ', command: 'make typecheck', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 2, startedAt: ' 20260215T010001Z ', completedAt: ' 20260215T010003Z ', notRunReason: null },
		{ id: ' test-unit ', command: 'make test-unit', status: 'Skip', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: '20260215T010003Z', completedAt: '20260215T010003Z', notRunReason: null },
		{ id: ' build ', command: 'make build', status: ' Not-Run ', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: '  blocked-by-fail-fast:typecheck  ' },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_counts_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_counts_summary" "Verify Gates Derived Count Fallback Contract Test"

node - "$expected_schema_version" "$duplicate_gate_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'duplicate-gate-rows-contract',
	gates: [
		{ id: ' lint ', command: 'make lint', status: 'PASS', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T020000Z', completedAt: '20260215T020001Z', notRunReason: null },
		{ id: 'lint', command: 'make lint', status: 'pass', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 1, exitCode: 0, startedAt: '20260215T020001Z', completedAt: '20260215T020002Z', notRunReason: null },
		{ id: ' typecheck ', command: 'make typecheck', status: 'FAIL', attempts: 1, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 2, exitCode: 2, startedAt: '20260215T020002Z', completedAt: '20260215T020004Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$duplicate_gate_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$duplicate_gate_rows_summary" "Verify Gates Duplicate Gate Rows Contract Test"

node - "$expected_schema_version" "$malformed_gate_rows_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'malformed-gate-rows-contract',
	gates: [
		null,
		'not-an-object',
		42,
		{ id: ' lint ', command: 'make lint', status: ' PASS ', attempts: '1', retryCount: '0', retryBackoffSeconds: '0', durationSeconds: '1', exitCode: '0', startedAt: '20260215T030000Z', completedAt: '20260215T030001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$malformed_gate_rows_step_summary" ./scripts/publish-verify-gates-summary.sh "$malformed_gate_rows_summary" "Verify Gates Malformed Gate Rows Contract Test"

node - "$expected_schema_version" "$row_not_run_reason_type_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'row-not-run-reason-type-contract',
	gates: [
		{ id: ' build ', command: 'make build', status: ' Not-Run ', attempts: 0, retryCount: 0, retryBackoffSeconds: 0, durationSeconds: 0, exitCode: null, startedAt: null, completedAt: null, notRunReason: 7 },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$row_not_run_reason_type_step_summary" ./scripts/publish-verify-gates-summary.sh "$row_not_run_reason_type_summary" "Verify Gates Row Not-Run Reason Type Contract Test"

node - "$expected_schema_version" "$row_command_type_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'row-command-type-contract',
	gates: [
		{ id: ' lint ', command: 9, status: 'PASS', attempts: 'bad', retryCount: -1, retryBackoffSeconds: 'oops', durationSeconds: 'bad', exitCode: -1, startedAt: '20260215T040000Z', completedAt: '20260215T040001Z', notRunReason: null },
	],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$row_command_type_step_summary" ./scripts/publish-verify-gates-summary.sh "$row_command_type_summary" "Verify Gates Row Command Type Contract Test"

node - "$expected_schema_version" "$derived_lists_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-lists-contract',
	gateCount: 'bad',
	passedGateCount: 'bad',
	failedGateCount: -1,
	skippedGateCount: 'bad',
	notRunGateCount: -1,
	executedGateCount: 'bad',
	totalRetryCount: 'bad',
	totalRetryBackoffSeconds: -1,
	retriedGateCount: 'bad',
	retryRatePercent: 'bad',
	passRatePercent: 'bad',
	retryBackoffSharePercent: 'bad',
	executedDurationSeconds: 'bad',
	averageExecutedDurationSeconds: 'bad',
	totalDurationSeconds: -1,
	statusCounts: { pass: 'bad', fail: -1, skip: 'bad', 'not-run': 'bad' },
	selectedGateIds: [' lint ', 'typecheck', 'test-unit', 'build', 'typecheck', '', 42],
	passedGateIds: [' lint ', 'lint', null],
	failedGateIds: ['typecheck', 'typecheck', ' '],
	failedGateExitCodes: [2, 999],
	skippedGateIds: ['test-unit', 'test-unit'],
	notRunGateIds: ['build', false],
	executedGateIds: [' lint ', 'typecheck', 'lint'],
	retriedGateIds: [' lint ', '', 'lint', 42],
	gateDurationSecondsById: { lint: 5, typecheck: 3, 'test-unit': 0, build: 0 },
	gateAttemptCountById: { lint: 1, typecheck: 1, 'test-unit': 0, build: 0 },
	gateNotRunReasonById: { lint: null, typecheck: null, 'test-unit': null, build: 'blocked-by-fail-fast:typecheck' },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_lists_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_lists_summary" "Verify Gates Derived List Fallback Contract Test"

node - "$expected_schema_version" "$derived_status_map_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-status-map-contract',
	gateStatusById: { ' lint ': ' PASS ', typecheck: 'FAIL', build: ' Not-Run ', ignored: 'unknown', '': 'pass' },
	gateExitCodeById: { ' lint ': '-7', typecheck: '5', build: null, bad: 'x' },
	failedGateId: 'typecheck',
	failedGateExitCode: '-2',
	gateRetryCountById: { ' lint ': '2', typecheck: '0', build: 0, bad: -1 },
	gateDurationSecondsById: { ' lint ': '1', typecheck: '2', build: 0, bad: -1 },
	gateAttemptCountById: { ' lint ': '1', typecheck: 1, build: 0, bad: 'oops' },
	gateNotRunReasonById: { ' lint ': 123, typecheck: null, build: 'blocked-by-fail-fast:typecheck', bad: 5 },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_status_map_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_status_map_summary" "Verify Gates Derived Status-Map Contract Test"

node - "$expected_schema_version" "$derived_dry_run_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-dry-run-contract',
	dryRun: true,
	selectedGateIds: ['lint'],
	skippedGateIds: ['lint'],
	gateStatusById: { lint: 'skip' },
	gateExitCodeById: { lint: null },
	gateRetryCountById: { lint: 0 },
	gateDurationSecondsById: { lint: 0 },
	gateAttemptCountById: { lint: 0 },
	gateNotRunReasonById: { lint: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_dry_run_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_dry_run_summary" "Verify Gates Derived Dry-Run Contract Test"

node - "$expected_schema_version" "$derived_continued_failure_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'derived-continued-failure-contract',
	selectedGateIds: ['lint', 'typecheck'],
	passedGateIds: ['typecheck'],
	failedGateIds: ['lint'],
	executedGateIds: ['lint', 'typecheck'],
	gateStatusById: { lint: 'fail', typecheck: 'pass' },
	gateExitCodeById: { lint: 7, typecheck: 0 },
	gateRetryCountById: { lint: 0, typecheck: 0 },
	gateDurationSecondsById: { lint: 2, typecheck: 1 },
	gateAttemptCountById: { lint: 1, typecheck: 1 },
	gateNotRunReasonById: { lint: null, typecheck: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$derived_continued_failure_step_summary" ./scripts/publish-verify-gates-summary.sh "$derived_continued_failure_summary" "Verify Gates Derived Continued-Failure Contract Test"

node - "$expected_schema_version" "$explicit_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-reason-contract',
	exitReason: '  COMPLETED-WITH-FAILURES  ',
	continueOnFailure: 'off',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_reason_summary" "Verify Gates Explicit Reason Contract Test"

node - "$expected_schema_version" "$invalid_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-reason-contract',
	exitReason: 'bogus-value',
	gateStatusById: { lint: 'fail', typecheck: 'not-run' },
	gateNotRunReasonById: { lint: null, typecheck: 'blocked-by-fail-fast:lint' },
	gateExitCodeById: { lint: 9, typecheck: null },
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_reason_summary" "Verify Gates Invalid Reason Contract Test"

node - "$expected_schema_version" "$explicit_run_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'explicit-run-classification-contract',
	runClassification: '  SUCCESS-NO-RETRIES  ',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$explicit_run_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$explicit_run_classification_summary" "Verify Gates Explicit Run Classification Contract Test"

node - "$expected_schema_version" "$conflicting_reason_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-reason-classification-contract',
	exitReason: ' fail-fast ',
	runClassification: 'success-no-retries',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_reason_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_reason_classification_summary" "Verify Gates Conflicting Reason/Classification Contract Test"

node - "$expected_schema_version" "$conflicting_run_state_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-run-state-flags-contract',
	exitReason: 'fail-fast',
	runClassification: 'success-with-retries',
	success: true,
	dryRun: true,
	continueOnFailure: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_run_state_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_run_state_flags_summary" "Verify Gates Conflicting Run-State Flags Contract Test"

node - "$expected_schema_version" "$conflicting_classification_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'conflicting-classification-flags-contract',
	runClassification: 'failed-continued',
	success: 'yes',
	dryRun: 'ON',
	continueOnFailure: '0',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$conflicting_classification_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$conflicting_classification_flags_summary" "Verify Gates Conflicting Classification Flags Contract Test"

node - "$expected_schema_version" "$invalid_reason_with_classification_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-reason-with-classification-contract',
	exitReason: 'definitely-not-valid',
	runClassification: 'FAILED-FAIL-FAST',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_reason_with_classification_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_reason_with_classification_summary" "Verify Gates Invalid Reason With Classification Contract Test"

node - "$expected_schema_version" "$invalid_classification_with_reason_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'invalid-classification-with-reason-contract',
	exitReason: 'completed-with-failures',
	runClassification: 'totally-invalid',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$invalid_classification_with_reason_step_summary" ./scripts/publish-verify-gates-summary.sh "$invalid_classification_with_reason_summary" "Verify Gates Invalid Classification With Reason Contract Test"

node - "$expected_schema_version" "$dry_run_reason_conflicts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'dry-run-reason-conflicts-contract',
	exitReason: 'dry-run',
	runClassification: 'failed-fail-fast',
	success: false,
	dryRun: false,
	continueOnFailure: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$dry_run_reason_conflicts_step_summary" ./scripts/publish-verify-gates-summary.sh "$dry_run_reason_conflicts_summary" "Verify Gates Dry-Run Reason Conflicts Contract Test"

node - "$expected_schema_version" "$success_reason_conflicts_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-reason-conflicts-contract',
	exitReason: 'success',
	runClassification: 'failed-continued',
	success: false,
	dryRun: true,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_reason_conflicts_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_reason_conflicts_summary" "Verify Gates Success Reason Conflicts Contract Test"

node - "$expected_schema_version" "$success_reason_explicit_continue_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-reason-explicit-continue-contract',
	exitReason: 'success',
	runClassification: 'failed-continued',
	continueOnFailure: 'on',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_reason_explicit_continue_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_reason_explicit_continue_summary" "Verify Gates Success Reason Explicit Continue Contract Test"

node - "$expected_schema_version" "$success_classification_explicit_continue_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'success-classification-explicit-continue-contract',
	runClassification: '  SUCCESS-WITH-RETRIES  ',
	success: false,
	dryRun: true,
	continueOnFailure: 'yes',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$success_classification_explicit_continue_step_summary" ./scripts/publish-verify-gates-summary.sh "$success_classification_explicit_continue_summary" "Verify Gates Success Classification Explicit Continue Contract Test"

node - "$expected_schema_version" "$numeric_boolean_flags_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
if (!Number.isInteger(schemaVersion) || schemaVersion <= 0) {
	throw new Error(`Invalid schema version: ${schemaVersionRaw}`);
}
const payload = {
	schemaVersion,
	runId: 'numeric-boolean-flags-contract',
	success: 1,
	dryRun: 0,
	continueOnFailure: 0,
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$numeric_boolean_flags_step_summary" ./scripts/publish-verify-gates-summary.sh "$numeric_boolean_flags_summary" "Verify Gates Numeric Boolean Flags Contract Test"

node - "$expected_schema_version" "$dry_summary" "$dry_repeat_summary" "$continue_true_summary" "$continue_false_summary" "$continue_flag_summary" "$dedupe_summary" "$from_summary" "$full_dry_summary" "$default_mode_dry_summary" "$mode_precedence_full_summary" "$mode_precedence_quick_summary" "$env_retries_summary" "$cli_retries_override_summary" "$continue_fail_summary" "$continue_multi_fail_summary" "$fail_fast_summary" "$retry_summary" "$continue_fail_step_summary" "$continue_multi_fail_step_summary" "$fail_fast_step_summary" "$retry_step_summary" "$continue_flag_step_summary" "$dry_fallback_step_summary" "$fail_fast_fallback_step_summary" "$fallback_step_summary" <<'NODE'
const fs = require('node:fs');
const [expectedSchemaVersionRaw, dryPath, dryRepeatPath, continueTruePath, continueFalsePath, continueFlagPath, dedupePath, fromPath, fullDryPath, defaultModeDryPath, modePrecedenceFullPath, modePrecedenceQuickPath, envRetriesPath, cliRetriesOverridePath, continueFailPath, continueMultiFailPath, failFastPath, retryPath, continueFailStepPath, continueMultiFailStepPath, failFastStepPath, retryStepPath, continueFlagStepPath, dryFallbackStepPath, failFastFallbackStepPath, fallbackStepPath] = process.argv.slice(2);
const expectedSchemaVersion = Number.parseInt(expectedSchemaVersionRaw, 10);
if (!Number.isInteger(expectedSchemaVersion) || expectedSchemaVersion <= 0) {
	throw new Error(`Invalid expected schema version: ${expectedSchemaVersionRaw}`);
}
const dry = JSON.parse(fs.readFileSync(dryPath, 'utf8'));
const dryRepeat = JSON.parse(fs.readFileSync(dryRepeatPath, 'utf8'));
const continueTrue = JSON.parse(fs.readFileSync(continueTruePath, 'utf8'));
const continueFalse = JSON.parse(fs.readFileSync(continueFalsePath, 'utf8'));
const continueFlag = JSON.parse(fs.readFileSync(continueFlagPath, 'utf8'));
const dedupe = JSON.parse(fs.readFileSync(dedupePath, 'utf8'));
const from = JSON.parse(fs.readFileSync(fromPath, 'utf8'));
const fullDry = JSON.parse(fs.readFileSync(fullDryPath, 'utf8'));
const defaultModeDry = JSON.parse(fs.readFileSync(defaultModeDryPath, 'utf8'));
const modePrecedenceFull = JSON.parse(fs.readFileSync(modePrecedenceFullPath, 'utf8'));
const modePrecedenceQuick = JSON.parse(fs.readFileSync(modePrecedenceQuickPath, 'utf8'));
const envRetries = JSON.parse(fs.readFileSync(envRetriesPath, 'utf8'));
const cliRetriesOverride = JSON.parse(fs.readFileSync(cliRetriesOverridePath, 'utf8'));
const continueFail = JSON.parse(fs.readFileSync(continueFailPath, 'utf8'));
const continueMultiFail = JSON.parse(fs.readFileSync(continueMultiFailPath, 'utf8'));
const failFast = JSON.parse(fs.readFileSync(failFastPath, 'utf8'));
const retry = JSON.parse(fs.readFileSync(retryPath, 'utf8'));
const continueFailStep = fs.readFileSync(continueFailStepPath, 'utf8');
const continueMultiFailStep = fs.readFileSync(continueMultiFailStepPath, 'utf8');
const failFastStep = fs.readFileSync(failFastStepPath, 'utf8');
const retryStep = fs.readFileSync(retryStepPath, 'utf8');
const continueFlagStep = fs.readFileSync(continueFlagStepPath, 'utf8');
const dryFallbackStep = fs.readFileSync(dryFallbackStepPath, 'utf8');
const failFastFallbackStep = fs.readFileSync(failFastFallbackStepPath, 'utf8');
const fallbackStep = fs.readFileSync(fallbackStepPath, 'utf8');
const assertGateExitCodeSemantics = (label, summary) => {
	if (!Array.isArray(summary.gates)) {
		throw new Error(`${label} summary gates should be an array.`);
	}
	if (!summary.gateExitCodeById || typeof summary.gateExitCodeById !== 'object' || Array.isArray(summary.gateExitCodeById)) {
		throw new Error(`${label} summary gateExitCodeById should be an object.`);
	}
	for (const gate of summary.gates) {
		const gateId = gate.id;
		if (typeof gateId !== 'string' || gateId.length === 0) {
			throw new Error(`${label} summary gate missing id.`);
		}
		const status = gate.status;
		const exitCode = gate.exitCode;
		const mappedExitCode = summary.gateExitCodeById[gateId];
		const isExecuted = status === 'pass' || status === 'fail';
		if (isExecuted) {
			if (!Number.isInteger(exitCode)) {
				throw new Error(`${label} executed gate ${gateId} should have an integer exit code.`);
			}
			if (!Number.isInteger(mappedExitCode) || mappedExitCode !== exitCode) {
				throw new Error(`${label} gateExitCodeById mismatch for executed gate ${gateId}.`);
			}
			continue;
		}
		if (exitCode !== null) {
			throw new Error(`${label} non-executed gate ${gateId} should have null exit code in gate rows.`);
		}
		if (mappedExitCode !== null) {
			throw new Error(`${label} non-executed gate ${gateId} should have null exit code in gateExitCodeById.`);
		}
	}
};

if (dry.schemaVersion !== expectedSchemaVersion || continueFail.schemaVersion !== expectedSchemaVersion || continueMultiFail.schemaVersion !== expectedSchemaVersion || failFast.schemaVersion !== expectedSchemaVersion || retry.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for all runs.`);
}
if (dryRepeat.schemaVersion !== expectedSchemaVersion || continueTrue.schemaVersion !== expectedSchemaVersion || continueFalse.schemaVersion !== expectedSchemaVersion || continueFlag.schemaVersion !== expectedSchemaVersion || dedupe.schemaVersion !== expectedSchemaVersion || from.schemaVersion !== expectedSchemaVersion || fullDry.schemaVersion !== expectedSchemaVersion || defaultModeDry.schemaVersion !== expectedSchemaVersion || modePrecedenceFull.schemaVersion !== expectedSchemaVersion || modePrecedenceQuick.schemaVersion !== expectedSchemaVersion || envRetries.schemaVersion !== expectedSchemaVersion || cliRetriesOverride.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for dedupe/from runs.`);
}
for (const [label, summary] of [['dry', dry], ['dry-repeat', dryRepeat], ['continue-true', continueTrue], ['continue-false', continueFalse], ['continue-flag', continueFlag], ['dedupe', dedupe], ['from', from], ['full-dry', fullDry], ['default-mode-dry', defaultModeDry], ['mode-precedence-full', modePrecedenceFull], ['mode-precedence-quick', modePrecedenceQuick], ['env-retries', envRetries], ['cli-retries-override', cliRetriesOverride], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	const statusCounts = summary.statusCounts ?? {};
	const passCount = summary.passedGateCount ?? 0;
	const failCount = summary.failedGateCount ?? 0;
	const skipCount = summary.skippedGateCount ?? 0;
	const notRunCount = summary.notRunGateCount ?? 0;
	if (statusCounts.pass !== passCount || statusCounts.fail !== failCount || statusCounts.skip !== skipCount || statusCounts['not-run'] !== notRunCount) {
		throw new Error(`${label} summary statusCounts mismatch with scalar counters.`);
	}
	if (!Array.isArray(summary.passedGateIds) || summary.passedGateIds.length !== passCount) {
		throw new Error(`${label} passedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.failedGateIds) || summary.failedGateIds.length !== failCount) {
		throw new Error(`${label} failedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.skippedGateIds) || summary.skippedGateIds.length !== skipCount) {
		throw new Error(`${label} skippedGateIds length mismatch.`);
	}
	if (!Array.isArray(summary.notRunGateIds) || summary.notRunGateIds.length !== notRunCount) {
		throw new Error(`${label} notRunGateIds length mismatch.`);
	}
	assertGateExitCodeSemantics(label, summary);
}
if (dry.exitReason !== 'dry-run' || dry.runClassification !== 'dry-run') {
	throw new Error('Dry-run exit reason/classification mismatch.');
}
if (continueTrue.exitReason !== 'dry-run' || continueTrue.runClassification !== 'dry-run' || continueFalse.exitReason !== 'dry-run' || continueFalse.runClassification !== 'dry-run' || continueFlag.exitReason !== 'dry-run' || continueFlag.runClassification !== 'dry-run') {
	throw new Error('Continue-on-failure dry-run classification mismatch.');
}
if (typeof dry.resultSignatureAlgorithm !== 'string' || dry.resultSignatureAlgorithm.length === 0) {
	throw new Error('Dry-run resultSignatureAlgorithm should be populated.');
}
if (dry.resultSignature !== dryRepeat.resultSignature) {
	throw new Error('Repeated identical dry-runs should produce identical result signatures.');
}
if (dry.resultSignature === dedupe.resultSignature) {
	throw new Error('Different gate selections should produce different result signatures.');
}
const timestampPattern = /^\d{8}T\d{6}Z$/;
for (const [label, summary] of [['dry', dry], ['dry-repeat', dryRepeat], ['dedupe', dedupe], ['from', from], ['full-dry', fullDry], ['default-mode-dry', defaultModeDry], ['mode-precedence-full', modePrecedenceFull], ['mode-precedence-quick', modePrecedenceQuick], ['env-retries', envRetries], ['cli-retries-override', cliRetriesOverride], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	const expectedRunIdPrefix = label === 'full-dry' || label === 'default-mode-dry' || label === 'mode-precedence-full' ? 'full-' : 'quick-';
	if (typeof summary.runId !== 'string' || !summary.runId.startsWith(expectedRunIdPrefix)) {
		throw new Error(`${label} summary runId should start with ${expectedRunIdPrefix}.`);
	}
	if (!timestampPattern.test(String(summary.startedAt ?? '')) || !timestampPattern.test(String(summary.completedAt ?? ''))) {
		throw new Error(`${label} summary timestamps should match YYYYMMDDTHHMMSSZ.`);
	}
	if (!Number.isInteger(summary.totalDurationSeconds) || summary.totalDurationSeconds < 0) {
		throw new Error(`${label} summary totalDurationSeconds should be a non-negative integer.`);
	}
	if (!Number.isInteger(summary.gateCount) || !Array.isArray(summary.selectedGateIds) || summary.gateCount !== summary.selectedGateIds.length) {
		throw new Error(`${label} summary gateCount/selectedGateIds mismatch.`);
	}
}
if (!fullDry.runId.startsWith('full-') || fullDry.mode !== 'full') {
	throw new Error('Full dry-run should emit full-mode run metadata.');
}
if (fullDry.selectedGateIds.join(',') !== 'build' || fullDry.skippedGateIds.join(',') !== 'build') {
	throw new Error('Full dry-run gate selection/partition mismatch.');
}
if (defaultModeDry.mode !== 'full' || !defaultModeDry.runId.startsWith('full-')) {
	throw new Error('Default-mode dry-run should resolve to full mode metadata.');
}
if (defaultModeDry.selectedGateIds.join(',') !== 'build' || defaultModeDry.skippedGateIds.join(',') !== 'build') {
	throw new Error('Default-mode dry-run gate selection/partition mismatch.');
}
if (modePrecedenceFull.mode !== 'full' || !modePrecedenceFull.runId.startsWith('full-')) {
	throw new Error('Mode precedence should use final --full flag.');
}
if (modePrecedenceFull.selectedGateIds.join(',') !== 'build' || modePrecedenceFull.skippedGateIds.join(',') !== 'build') {
	throw new Error('Mode precedence full selection/partition mismatch.');
}
if (modePrecedenceQuick.mode !== 'quick' || !modePrecedenceQuick.runId.startsWith('quick-')) {
	throw new Error('Mode precedence should use final --quick flag.');
}
if (modePrecedenceQuick.selectedGateIds.join(',') !== 'test-unit' || modePrecedenceQuick.skippedGateIds.join(',') !== 'test-unit') {
	throw new Error('Mode precedence quick selection/partition mismatch.');
}
if (envRetries.retries !== 2 || envRetries.mode !== 'quick' || envRetries.selectedGateIds.join(',') !== 'lint') {
	throw new Error('Expected VSCODE_VERIFY_RETRIES to control retries in dry-run metadata.');
}
if (cliRetriesOverride.retries !== 0 || cliRetriesOverride.mode !== 'quick' || cliRetriesOverride.selectedGateIds.join(',') !== 'lint') {
	throw new Error('Expected --retries flag to override VSCODE_VERIFY_RETRIES.');
}
if (continueFail.continueOnFailure !== true || continueFail.dryRun !== false || continueFail.mode !== 'quick') {
	throw new Error('Continue-on-failure failure run metadata mismatch.');
}
if (continueFail.exitReason !== 'completed-with-failures' || continueFail.runClassification !== 'failed-continued') {
	throw new Error('Continue-on-failure failure exit reason/classification mismatch.');
}
if (continueFail.gateStatusById.lint !== 'fail' || continueFail.gateStatusById.typecheck !== 'pass') {
	throw new Error('Continue-on-failure failure gate status map mismatch.');
}
if (continueFail.gateAttemptCountById.lint !== 1 || continueFail.gateAttemptCountById.typecheck !== 1 || continueFail.gateRetryCountById.lint !== 0 || continueFail.gateRetryCountById.typecheck !== 0) {
	throw new Error('Continue-on-failure failure gate attempt/retry map mismatch.');
}
if (continueFail.gateExitCodeById.lint !== 7 || continueFail.gateExitCodeById.typecheck !== 0 || continueFail.failedGateExitCode !== 7) {
	throw new Error('Continue-on-failure failure exit-code metadata mismatch.');
}
if (continueFail.failedGateId !== 'lint' || continueFail.blockedByGateId !== null) {
	throw new Error('Continue-on-failure failure gate pointers mismatch.');
}
if (continueFail.failedGateIds.join(',') !== 'lint' || continueFail.failedGateExitCodes.join(',') !== '7') {
	throw new Error('Continue-on-failure failure partitions mismatch for failed gates.');
}
if (continueFail.executedGateIds.join(',') !== 'lint,typecheck' || continueFail.notRunGateIds.length !== 0) {
	throw new Error('Continue-on-failure failure executed/not-run partition mismatch.');
}
if (continueFail.nonSuccessGateIds.join(',') !== 'lint' || continueFail.attentionGateIds.join(',') !== 'lint') {
	throw new Error('Continue-on-failure failure non-success/attention partition mismatch.');
}
if (continueFail.retriedGateIds.length !== 0 || continueFail.retriedGateCount !== 0) {
	throw new Error('Continue-on-failure failure should not report retries.');
}
if (continueMultiFail.continueOnFailure !== true || continueMultiFail.dryRun !== false || continueMultiFail.mode !== 'quick') {
	throw new Error('Continue-on-failure multi-failure run metadata mismatch.');
}
if (continueMultiFail.exitReason !== 'completed-with-failures' || continueMultiFail.runClassification !== 'failed-continued') {
	throw new Error('Continue-on-failure multi-failure exit reason/classification mismatch.');
}
if (continueMultiFail.gateStatusById.lint !== 'fail' || continueMultiFail.gateStatusById.typecheck !== 'fail') {
	throw new Error('Continue-on-failure multi-failure gate status map mismatch.');
}
if (continueMultiFail.gateAttemptCountById.lint !== 1 || continueMultiFail.gateAttemptCountById.typecheck !== 1 || continueMultiFail.gateRetryCountById.lint !== 0 || continueMultiFail.gateRetryCountById.typecheck !== 0) {
	throw new Error('Continue-on-failure multi-failure gate attempt/retry map mismatch.');
}
if (continueMultiFail.gateExitCodeById.lint !== 7 || continueMultiFail.gateExitCodeById.typecheck !== 3 || continueMultiFail.failedGateExitCode !== 7) {
	throw new Error('Continue-on-failure multi-failure exit-code metadata mismatch.');
}
if (continueMultiFail.failedGateId !== 'lint' || continueMultiFail.blockedByGateId !== null) {
	throw new Error('Continue-on-failure multi-failure gate pointers mismatch.');
}
if (continueMultiFail.failedGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.failedGateExitCodes.join(',') !== '7,3') {
	throw new Error('Continue-on-failure multi-failure partitions mismatch for failed gates.');
}
if (continueMultiFail.executedGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.notRunGateIds.length !== 0) {
	throw new Error('Continue-on-failure multi-failure executed/not-run partition mismatch.');
}
if (continueMultiFail.nonSuccessGateIds.join(',') !== 'lint,typecheck' || continueMultiFail.attentionGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Continue-on-failure multi-failure non-success/attention partition mismatch.');
}
if (continueMultiFail.retriedGateIds.length !== 0 || continueMultiFail.retriedGateCount !== 0) {
	throw new Error('Continue-on-failure multi-failure should not report retries.');
}
if (!Array.isArray(failFast.executedGateIds) || failFast.executedGateCount !== failFast.executedGateIds.length) {
	throw new Error('Fail-fast executed gate count/list mismatch.');
}
if (!Array.isArray(retry.executedGateIds) || retry.executedGateCount !== retry.executedGateIds.length) {
	throw new Error('Retry-success executed gate count/list mismatch.');
}
for (const [label, summary] of [['dry', dry], ['continue-fail', continueFail], ['continue-multi-fail', continueMultiFail], ['fail-fast', failFast], ['retry', retry]]) {
	if (typeof summary.logFile !== 'string' || summary.logFile.length === 0) {
		throw new Error(`${label} summary missing logFile path.`);
	}
	if (!summary.logFile.includes('/logs/')) {
		throw new Error(`${label} logFile path should point to log directory.`);
	}
	if (!fs.existsSync(summary.logFile)) {
		throw new Error(`${label} logFile path does not exist on disk.`);
	}
}
if (continueTrue.continueOnFailure !== true) {
	throw new Error('continue-on-failure env=true normalization mismatch.');
}
if (continueFalse.continueOnFailure !== false) {
	throw new Error('continue-on-failure env=off normalization mismatch.');
}
if (continueFlag.continueOnFailure !== true) {
	throw new Error('continue-on-failure CLI flag normalization mismatch.');
}

if (dry.gateAttemptCountById.lint !== 0 || dry.gateRetryCountById.lint !== 0) {
	throw new Error('Dry-run gate attempt/retry map mismatch.');
}
if (dedupe.selectedGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Duplicate/whitespace --only normalization mismatch.');
}
if (from.selectedGateIds.join(',') !== 'typecheck,test-unit') {
	throw new Error('--from gate selection mismatch.');
}
if (from.skippedGateIds.join(',') !== 'typecheck,test-unit') {
	throw new Error('--from dry-run skipped partition mismatch.');
}

if (failFast.gateStatusById.lint !== 'fail' || failFast.gateStatusById.typecheck !== 'not-run') {
	throw new Error('Fail-fast gate status map mismatch.');
}
if (failFast.exitReason !== 'fail-fast' || failFast.runClassification !== 'failed-fail-fast') {
	throw new Error('Fail-fast exit reason/classification mismatch.');
}
if (failFast.failedGateId !== 'lint' || failFast.failedGateExitCode !== 7 || failFast.blockedByGateId !== 'lint') {
	throw new Error('Fail-fast first-failure metadata mismatch.');
}
if (failFast.nonSuccessGateIds.join(',') !== 'lint,typecheck' || failFast.attentionGateIds.join(',') !== 'lint,typecheck') {
	throw new Error('Fail-fast partition metadata mismatch.');
}
if (failFast.gateNotRunReasonById.typecheck !== 'blocked-by-fail-fast:lint') {
	throw new Error('Fail-fast not-run reason map mismatch.');
}
if (failFast.gateAttemptCountById.lint !== 1 || failFast.gateAttemptCountById.typecheck !== 0) {
	throw new Error('Fail-fast attempt map mismatch.');
}

if (retry.gateStatusById.lint !== 'pass' || retry.gateStatusById.typecheck !== 'pass') {
	throw new Error('Retry-success gate status map mismatch.');
}
if (retry.exitReason !== 'success' || retry.runClassification !== 'success-with-retries') {
	throw new Error('Retry-success exit reason/classification mismatch.');
}
if (retry.gateRetryCountById.lint !== 1 || retry.gateAttemptCountById.lint !== 2 || retry.gateAttemptCountById.typecheck !== 1) {
	throw new Error('Retry-success retry/attempt map mismatch.');
}
if (retry.attentionGateIds.join(',') !== 'lint') {
	throw new Error('Retry-success attention-gates partition mismatch.');
}
if (retry.nonSuccessGateIds.length !== 0 || retry.failedGateId !== null || retry.failedGateExitCode !== null || retry.blockedByGateId !== null) {
	throw new Error('Retry-success failure metadata should be empty.');
}

if (!/\*\*Gate not-run reason map:\*\* \{[^\n]*typecheck[^\n]*blocked-by-fail-fast:lint/.test(failFastStep)) {
	throw new Error('Fail-fast step summary missing compact not-run reason map.');
}
if (!continueFailStep.includes('**Continue on failure:** true') || !continueFailStep.includes('**Dry run:** false') || !continueFailStep.includes('**Exit reason:** completed-with-failures') || !continueFailStep.includes('**Run classification:** failed-continued')) {
	throw new Error('Continue-on-failure failure step summary metadata mismatch.');
}
if (!continueMultiFailStep.includes('**Continue on failure:** true') || !continueMultiFailStep.includes('**Dry run:** false') || !continueMultiFailStep.includes('**Exit reason:** completed-with-failures') || !continueMultiFailStep.includes('**Run classification:** failed-continued')) {
	throw new Error('Continue-on-failure multi-failure step summary metadata mismatch.');
}
if (!continueMultiFailStep.includes('**Failed gates list:** lint, typecheck') || !continueMultiFailStep.includes('**Failed gate exit codes:** 7, 3')) {
	throw new Error('Continue-on-failure multi-failure step summary failed-gate metadata mismatch.');
}
if (!/\*\*Gate attempt-count map:\*\* \{[^\n]*lint[^\n]*2[^\n]*typecheck[^\n]*1/.test(retryStep)) {
	throw new Error('Retry step summary missing attempt-count map.');
}
if (!/\*\*Gate retry-count map:\*\* \{[^\n]*lint[^\n]*1[^\n]*typecheck[^\n]*0/.test(retryStep)) {
	throw new Error('Retry step summary missing retry-count map.');
}
if (!failFastStep.includes('**Log file:** `') || !retryStep.includes('**Log file:** `')) {
	throw new Error('Step summaries should include log-file metadata line.');
}
if (continueFailStep.includes('**Schema warning:**') || continueMultiFailStep.includes('**Schema warning:**') || failFastStep.includes('**Schema warning:**') || retryStep.includes('**Schema warning:**') || continueFlagStep.includes('**Schema warning:**') || dryFallbackStep.includes('**Schema warning:**') || failFastFallbackStep.includes('**Schema warning:**') || fallbackStep.includes('**Schema warning:**')) {
	throw new Error('Did not expect schema warning for current-schema summaries.');
}
if (!continueFlagStep.includes('**Continue on failure:** true') || !continueFlagStep.includes('**Dry run:** true') || !continueFlagStep.includes('**Run classification:** dry-run')) {
	throw new Error('Continue-on-failure dry-run step summary metadata mismatch.');
}
if (!dryFallbackStep.includes('**Gate exit-code map:** {"lint":null}')) {
	throw new Error('Dry fallback summary should derive null exit code for skipped gates.');
}
if (!dryFallbackStep.includes('| `lint` | `make lint` | skip | 0 | 0 | 0 | 0 | n/a | n/a |')) {
	throw new Error('Dry fallback gate row should render non-executed exit code as n/a.');
}
if (!failFastFallbackStep.includes('**Gate exit-code map:** {"lint":7,"typecheck":null}')) {
	throw new Error('Fail-fast fallback summary should preserve executed and non-executed exit code semantics.');
}
if (!failFastFallbackStep.includes('| `typecheck` | `make typecheck` | not-run | 0 | 0 | 0 | 0 | n/a | blocked-by-fail-fast:lint |')) {
	throw new Error('Fail-fast fallback gate row should render blocked gate exit code as n/a.');
}
if (!/\*\*Gate status map:\*\* \{[^\n]*lint[^\n]*pass[^\n]*typecheck[^\n]*pass/.test(fallbackStep)) {
	throw new Error('Fallback summary did not derive gate status map from gate rows.');
}
if (!/\*\*Gate retry-count map:\*\* \{[^\n]*lint[^\n]*1[^\n]*typecheck[^\n]*0/.test(fallbackStep)) {
	throw new Error('Fallback summary did not derive retry-count map from gate rows.');
}
if (!fallbackStep.includes('**Attention gates list:** lint')) {
	throw new Error('Fallback summary did not derive attention-gate list from gate rows.');
}
if (!fallbackStep.includes('**Executed gates list:** lint, typecheck')) {
	throw new Error('Fallback summary did not derive executed-gates list from gate rows.');
}
if (!fallbackStep.includes('**Passed gates list:** lint, typecheck')) {
	throw new Error('Fallback summary did not derive passed-gates list from gate rows.');
}
if (!fallbackStep.includes('**Retried gates:** lint')) {
	throw new Error('Fallback summary did not derive retried-gates list from gate rows.');
}
if (!fallbackStep.includes('**Failed gates list:** none') || !fallbackStep.includes('**Not-run gates list:** none')) {
	throw new Error('Fallback summary did not derive failed/not-run gate lists from gate rows.');
}
NODE

if ! grep -Fq "**Gate count:** 4" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive gate count from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive passed gate count." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive failed gate count." >&2
	exit 1
fi
if ! grep -Fq "**Skipped gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive skipped gate count." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates:** 1" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive not-run gate count." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":1,\"not-run\":1}" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive statusCounts map from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, test-unit, build" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to normalize gate-row IDs when deriving selected-gates list." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$derived_counts_step_summary" || ! grep -Fq '| `typecheck` | `make typecheck` | fail |' "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary table to normalize gate-row IDs and statuses." >&2
	exit 1
fi
if ! grep -Fq "**Gate not-run reason map:** {\"build\":\"blocked-by-fail-fast:typecheck\"}" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to trim gate-row not-run reason values in reason map output." >&2
	exit 1
fi
if ! grep -Fq '| `build` | `make build` | not-run | 0 | 0 | 0 | 0 | n/a | blocked-by-fail-fast:typecheck |' "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary table to trim gate-row not-run reason values." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive executed gate count from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive total duration from gate timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Started:** 20260215T010000Z" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive started timestamp from gate rows." >&2
	exit 1
fi
if ! grep -Fq "**Completed:** 20260215T010003Z" "$derived_counts_step_summary"; then
	echo "Expected derived-count fallback summary to derive completed timestamp from gate rows." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_counts_step_summary"; then
	echo "Did not expect schema warning for derived-count fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to deduplicate normalized row IDs in selected-gates list." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates list:** lint" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to deduplicate normalized row IDs in passed-gates list." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates list:** lint, typecheck" "$duplicate_gate_rows_step_summary"; then
	echo "Expected duplicate-gate-rows summary to deduplicate normalized row IDs in executed-gates list." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$duplicate_gate_rows_step_summary"; then
	echo "Did not expect schema warning for duplicate-gate-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 1" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to count only normalized valid gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":0,\"skip\":0,\"not-run\":0}" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to derive status counts from valid normalized gate rows only." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary to derive selected gate IDs from valid normalized rows only." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `make lint` | pass |' "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary table to include normalized valid row." >&2
	exit 1
fi
if grep -Fq '| `unknown` |' "$malformed_gate_rows_step_summary"; then
	echo "Expected malformed-gate-rows summary table to ignore invalid rows without normalized IDs." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$malformed_gate_rows_step_summary"; then
	echo "Did not expect schema warning for malformed-gate-rows summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate not-run reason map:** none" "$row_not_run_reason_type_step_summary"; then
	echo "Expected row-not-run-reason-type summary to sanitize non-string row not-run reason values to null." >&2
	exit 1
fi
if ! grep -Fq '| `build` | `make build` | not-run | 0 | 0 | 0 | 0 | n/a | n/a |' "$row_not_run_reason_type_step_summary"; then
	echo "Expected row-not-run-reason-type summary table to render non-string not-run reason values as n/a." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$row_not_run_reason_type_step_summary"; then
	echo "Did not expect schema warning for row-not-run-reason-type summary." >&2
	exit 1
fi
if ! grep -Fq '| `lint` | `unknown` | pass | 0 | 0 | 0 | 0 | n/a | n/a |' "$row_command_type_step_summary"; then
	echo "Expected row-command-type summary table to sanitize non-string command and invalid numeric row fields." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint" "$row_command_type_step_summary"; then
	echo "Expected row-command-type summary to preserve normalized row ID while sanitizing command value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$row_command_type_step_summary"; then
	echo "Did not expect schema warning for row-command-type summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 4" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate count from selectedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive passed gate count from passedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate count from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit codes:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate exit codes from failedGateIds + gateExitCodeById." >&2
	exit 1
fi
if grep -Fq "999" "$derived_lists_step_summary"; then
	echo "Did not expect extra failed gate exit codes beyond failed gate IDs." >&2
	exit 1
fi
if ! grep -Fq "**Skipped gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive skipped gate count from skippedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Not-run gates:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive not-run gate count from notRunGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":1,\"not-run\":1}" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive statusCounts map from gate-id lists." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":\"pass\"" "$derived_lists_step_summary" || ! grep -Fq "\"typecheck\":\"fail\"" "$derived_lists_step_summary" || ! grep -Fq "\"test-unit\":\"skip\"" "$derived_lists_step_summary" || ! grep -Fq "\"build\":\"not-run\"" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate status map from gate-id partitions." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":null" "$derived_lists_step_summary" || ! grep -Fq "\"typecheck\":2" "$derived_lists_step_summary" || ! grep -Fq "\"test-unit\":null" "$derived_lists_step_summary" || ! grep -Fq "\"build\":null" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive normalized gate exit-code map values from failedGateIds + failedGateExitCodes." >&2
	exit 1
fi
if ! grep -Fq "**Executed gates:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive executed gate count from executedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":1,\"typecheck\":0,\"test-unit\":0,\"build\":0}" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive gate retry-count map from retriedGateIds when retry map is omitted." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive total retries from retriedGateIds fallback map." >&2
	exit 1
fi
if ! grep -Fq "**Total retry backoff:** 1s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry backoff from retry counts." >&2
	exit 1
fi
if ! grep -Fq "**Retried gate count:** 1" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retried gate count from retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retried gates:** lint" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retried gate IDs from retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retry rate (executed gates):** 50%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry rate from executed/retried counts." >&2
	exit 1
fi
if ! grep -Fq "**Pass rate (executed gates):** 50%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive pass rate from executed/passed counts." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, test-unit, build" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive non-success gates list from partition/status data." >&2
	exit 1
fi
if ! grep -Fq "**Attention gates list:** lint, typecheck, test-unit, build" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive attention gates list from non-success and retried gates." >&2
	exit 1
fi
if ! grep -Fq "**Retry backoff share (executed duration):** 12%" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive retry-backoff share from derived totals." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration total:** 8s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive executed duration total from gateDuration map." >&2
	exit 1
fi
if ! grep -Fq "**Executed duration average:** 4s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive average executed duration." >&2
	exit 1
fi
if ! grep -Fq "**Slowest executed gate:** lint" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive slowest executed gate." >&2
	exit 1
fi
if ! grep -Fq "**Fastest executed gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive fastest executed gate." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive blocked-by gate from not-run reasons." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** typecheck" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate pointer from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** 2" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed gate exit code from failedGateIds + gateExitCodeById." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 8s" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive total duration from gate duration map." >&2
	exit 1
fi
if ! grep -Fq "**Started:** unknown" "$derived_lists_step_summary" || ! grep -Fq "**Completed:** unknown" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to keep started/completed unknown without gate timestamps." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive continue-on-failure=false for fail-fast runs." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive fail-fast exit reason from blocked gate metadata." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$derived_lists_step_summary"; then
	echo "Expected derived-list fallback summary to derive failed-fail-fast run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_lists_step_summary"; then
	echo "Did not expect schema warning for derived-list fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Gate count:** 3" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive gate count from status map keys." >&2
	exit 1
fi
if ! grep -Fq "**Passed gates:** 1" "$derived_status_map_step_summary" || ! grep -Fq "**Failed gates:** 1" "$derived_status_map_step_summary" || ! grep -Fq "**Not-run gates:** 1" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive counts from status map values." >&2
	exit 1
fi
if ! grep -Fq "**Status counts:** {\"pass\":1,\"fail\":1,\"skip\":0,\"not-run\":1}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive statusCounts from normalized status map." >&2
	exit 1
fi
if ! grep -Fq "**Selected gates:** lint, typecheck, build" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive selected gates from status map keys." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":\"pass\"" "$derived_status_map_step_summary" || ! grep -Fq "\"typecheck\":\"fail\"" "$derived_status_map_step_summary" || ! grep -Fq "\"build\":\"not-run\"" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize status-map keys and values." >&2
	exit 1
fi
if ! grep -Fq "\"lint\":null" "$derived_status_map_step_summary" || ! grep -Fq "\"typecheck\":5" "$derived_status_map_step_summary" || ! grep -Fq "\"build\":null" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize gate exit-code map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate retry-count map:** {\"lint\":2,\"typecheck\":0,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize retry-count map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate duration map (s):** {\"lint\":1,\"typecheck\":2,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize duration map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Gate attempt-count map:** {\"lint\":1,\"typecheck\":1,\"build\":0}" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to normalize attempt-count map values and keys." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** typecheck" "$derived_status_map_step_summary" || ! grep -Fq "**Failed gate exit code:** 5" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive failed gate pointers from status/exit maps." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$derived_status_map_step_summary" || ! grep -Fq "**Exit reason:** fail-fast" "$derived_status_map_step_summary" || ! grep -Fq "**Run classification:** failed-fail-fast" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to infer fail-fast run-state metadata." >&2
	exit 1
fi
if ! grep -Fq "**Non-success gates list:** typecheck, build" "$derived_status_map_step_summary" || ! grep -Fq "**Attention gates list:** lint, typecheck, build" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive non-success/attention lists from status map." >&2
	exit 1
fi
if ! grep -Fq "**Total retries:** 2" "$derived_status_map_step_summary" || ! grep -Fq "**Total retry backoff:** 3s" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive retry totals from normalized retry map." >&2
	exit 1
fi
if ! grep -Fq "**Retry backoff share (executed duration):** 100%" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive retry-backoff share from normalized metrics." >&2
	exit 1
fi
if ! grep -Fq "**Total duration:** 3s" "$derived_status_map_step_summary"; then
	echo "Expected derived-status-map fallback summary to derive total duration from duration map." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_status_map_step_summary"; then
	echo "Did not expect schema warning for derived-status-map fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** true" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to infer success=true when dryRun=true and success is omitted." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** true" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to preserve dry-run flag." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** dry-run" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to derive dry-run exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** dry-run" "$derived_dry_run_step_summary"; then
	echo "Expected derived-dry-run fallback summary to derive dry-run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_dry_run_step_summary"; then
	echo "Did not expect schema warning for derived-dry-run fallback summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive success=false from failed gate evidence." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive continue-on-failure=true for completed failures." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive completed-with-failures exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed-continued classification." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** lint" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed gate pointer from failedGateIds." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate exit code:** 7" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to derive failed gate exit code from gateExitCodeById." >&2
	exit 1
fi
if ! grep -Fq "**Blocked by gate:** none" "$derived_continued_failure_step_summary"; then
	echo "Expected derived-continued-failure summary to keep blocked-by as none." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$derived_continued_failure_step_summary"; then
	echo "Did not expect schema warning for derived-continued-failure summary." >&2
	exit 1
fi
if ! grep -Fq "**Success:** false" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to derive success=false from exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to ignore conflicting explicit continue-on-failure value and follow explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to preserve explicit exit reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$explicit_reason_step_summary"; then
	echo "Expected explicit-reason summary to derive failed-continued classification from explicit exit reason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_reason_step_summary"; then
	echo "Did not expect schema warning for explicit-reason summary." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to ignore unknown explicit exitReason and derive fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to derive failed-fail-fast classification from derived fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Failed gate:** lint" "$invalid_reason_step_summary" || ! grep -Fq "**Failed gate exit code:** 9" "$invalid_reason_step_summary"; then
	echo "Expected invalid-reason summary to preserve failed gate pointers while deriving run-state." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_reason_step_summary"; then
	echo "Did not expect schema warning for invalid-reason summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to derive success from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to derive exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$explicit_run_classification_step_summary"; then
	echo "Expected explicit run-classification summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$explicit_run_classification_step_summary"; then
	echo "Did not expect schema warning for explicit run-classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to prioritize explicit exitReason for success inference." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to preserve explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$conflicting_reason_classification_step_summary"; then
	echo "Expected conflicting reason/classification summary to derive classification from explicit exitReason when explicit runClassification conflicts." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_reason_classification_step_summary"; then
	echo "Did not expect schema warning for conflicting reason/classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit success value." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit dry-run value." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to ignore conflicting explicit continue-on-failure value." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to preserve explicit fail-fast reason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$conflicting_run_state_flags_step_summary"; then
	echo "Expected conflicting run-state flags summary to derive consistent failure classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_run_state_flags_step_summary"; then
	echo "Did not expect schema warning for conflicting run-state flags summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit success value." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit dry-run value." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to ignore conflicting explicit continue-on-failure value." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to derive exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$conflicting_classification_flags_step_summary"; then
	echo "Expected conflicting classification-flags summary to preserve explicit runClassification when internally consistent." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$conflicting_classification_flags_step_summary"; then
	echo "Did not expect schema warning for conflicting classification-flags summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to derive success from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** fail-fast" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to ignore unknown explicit exitReason and derive from runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-fail-fast" "$invalid_reason_with_classification_step_summary"; then
	echo "Expected invalid-reason-with-classification summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_reason_with_classification_step_summary"; then
	echo "Did not expect schema warning for invalid-reason-with-classification summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** false" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to derive success from explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to derive continue-on-failure from explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** completed-with-failures" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to preserve explicit exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** failed-continued" "$invalid_classification_with_reason_step_summary"; then
	echo "Expected invalid-classification-with-reason summary to ignore unknown explicit runClassification and derive from explicit exitReason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$invalid_classification_with_reason_step_summary"; then
	echo "Did not expect schema warning for invalid-classification-with-reason summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to derive success=true from explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to derive dryRun=true from explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to preserve explicit continue-on-failure configuration." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** dry-run" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to preserve explicit dry-run exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** dry-run" "$dry_run_reason_conflicts_step_summary"; then
	echo "Expected dry-run-reason-conflicts summary to ignore conflicting explicit runClassification and derive dry-run classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$dry_run_reason_conflicts_step_summary"; then
	echo "Did not expect schema warning for dry-run-reason-conflicts summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to derive success=true from explicit success exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to ignore conflicting dry-run flag and derive dryRun=false for explicit success reason." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to derive continue-on-failure=false for success runs when explicit value is absent." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to preserve explicit success exitReason." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$success_reason_conflicts_step_summary"; then
	echo "Expected success-reason-conflicts summary to ignore conflicting explicit runClassification and derive success classification from explicit exitReason." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_reason_conflicts_step_summary"; then
	echo "Did not expect schema warning for success-reason-conflicts summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to preserve explicit success reason semantics." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to preserve explicit continue-on-failure configuration." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$success_reason_explicit_continue_step_summary"; then
	echo "Expected success-reason-explicit-continue summary to derive success classification despite conflicting explicit classification." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_reason_explicit_continue_step_summary"; then
	echo "Did not expect schema warning for success-reason-explicit-continue summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to ignore conflicting explicit success value and derive success=true from runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to ignore conflicting explicit dry-run value under success classification." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** true" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to preserve explicit continue-on-failure configuration for non-failure outcomes." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to derive success exit reason from explicit runClassification." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-with-retries" "$success_classification_explicit_continue_step_summary"; then
	echo "Expected success-classification-explicit-continue summary to normalize explicit runClassification value." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$success_classification_explicit_continue_step_summary"; then
	echo "Did not expect schema warning for success-classification-explicit-continue summary." >&2
	exit 1
fi

if ! grep -Fq "**Success:** true" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric success=1 to true." >&2
	exit 1
fi
if ! grep -Fq "**Dry run:** false" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric dryRun=0 to false." >&2
	exit 1
fi
if ! grep -Fq "**Continue on failure:** false" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to normalize numeric continueOnFailure=0 to false." >&2
	exit 1
fi
if ! grep -Fq "**Exit reason:** success" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to derive success exit reason from normalized numeric boolean values." >&2
	exit 1
fi
if ! grep -Fq "**Run classification:** success-no-retries" "$numeric_boolean_flags_step_summary"; then
	echo "Expected numeric-boolean-flags summary to derive success-no-retries classification from normalized numeric boolean values." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$numeric_boolean_flags_step_summary"; then
	echo "Did not expect schema warning for numeric-boolean-flags summary." >&2
	exit 1
fi

node - "$retry_summary" "$future_summary" <<'NODE'
const fs = require('node:fs');
const [sourcePath, futurePath] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
payload.schemaVersion = 99;
fs.writeFileSync(futurePath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$future_step_summary" ./scripts/publish-verify-gates-summary.sh "$future_summary" "Verify Gates Future Schema Contract Test"

node - "$supported_schema_version" "$future_step_summary" <<'NODE'
const fs = require('node:fs');
const [supportedSchemaVersionRaw, futureStepPath] = process.argv.slice(2);
const supportedSchemaVersion = Number.parseInt(supportedSchemaVersionRaw, 10);
if (!Number.isInteger(supportedSchemaVersion) || supportedSchemaVersion <= 0) {
	throw new Error(`Invalid supported schema version: ${supportedSchemaVersionRaw}`);
}
const futureStep = fs.readFileSync(futureStepPath, 'utf8');
if (!futureStep.includes(`supported ${supportedSchemaVersion}`)) {
	throw new Error(`Future-schema warning should reference supported schema ${supportedSchemaVersion}.`);
}
const warningMatches = futureStep.match(/\*\*Schema warning:\*\*/g) ?? [];
if (warningMatches.length !== 1) {
	throw new Error('Future-schema output should contain exactly one schema warning line.');
}
NODE

printf '{invalid json\n' > "$malformed_summary"
GITHUB_STEP_SUMMARY="$malformed_step_summary" ./scripts/publish-verify-gates-summary.sh "$malformed_summary" "Verify Gates Malformed Summary Contract Test"

node - "$malformed_step_summary" <<'NODE'
const fs = require('node:fs');
const [malformedStepPath] = process.argv.slice(2);
const malformedStep = fs.readFileSync(malformedStepPath, 'utf8');
if (!malformedStep.includes('Unable to parse verify-gates summary')) {
	throw new Error('Malformed-summary handling message missing from published step summary.');
}
if (!malformedStep.includes('malformed\\`name.json')) {
	throw new Error('Malformed-summary warning should include summary file path.');
}
NODE

set +e
./scripts/publish-verify-gates-summary.sh --unknown > "$tmpdir/unknown-option.out" 2>&1
unknown_option_status=$?
set -e
if [[ "$unknown_option_status" -eq 0 ]]; then
	echo "Expected publish-verify-gates-summary.sh --unknown to fail." >&2
	exit 1
fi
if ! grep -q "Unknown option" "$tmpdir/unknown-option.out"; then
	echo "Expected unknown-option output to include an explicit error message." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/unknown-option.out"; then
	echo "Expected unknown-option output to include usage text." >&2
	exit 1
fi

set +e
GITHUB_STEP_SUMMARY="$missing_step_summary" ./scripts/publish-verify-gates-summary.sh "$tmpdir/does-not-exist.json" "Missing Summary File Test" > "$tmpdir/missing-summary.out" 2>&1
missing_summary_status=$?
set -e
if [[ "$missing_summary_status" -ne 0 ]]; then
	echo "Expected missing summary file path to be a no-op success." >&2
	exit 1
fi
if [[ -f "$missing_step_summary" ]]; then
	echo "Missing summary file should not create a step summary artifact." >&2
	exit 1
fi

set +e
GITHUB_STEP_SUMMARY="" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Missing Step Summary Env Test" > "$tmpdir/missing-env.out" 2>&1
missing_env_status=$?
set -e
if [[ "$missing_env_status" -ne 0 ]]; then
	echo "Expected unset/empty GITHUB_STEP_SUMMARY handling to succeed." >&2
	exit 1
fi
if ! grep -q "GITHUB_STEP_SUMMARY is not set; skipping summary publication." "$tmpdir/missing-env.out"; then
	echo "Expected missing GITHUB_STEP_SUMMARY warning output." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --retries > "$tmpdir/missing-retries-value.out" 2>&1
missing_retries_value_status=$?
set -e
if [[ "$missing_retries_value_status" -eq 0 ]]; then
	echo "Expected --retries without a value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --retries" "$tmpdir/missing-retries-value.out"; then
	echo "Expected missing --retries value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --retries abc --dry-run > "$tmpdir/invalid-retries-alpha.out" 2>&1
invalid_retries_alpha_status=$?
set -e
if [[ "$invalid_retries_alpha_status" -eq 0 ]]; then
	echo "Expected non-numeric --retries value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid retries value 'abc'" "$tmpdir/invalid-retries-alpha.out"; then
	echo "Expected non-numeric --retries validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --retries -1 --dry-run > "$tmpdir/invalid-retries-negative.out" 2>&1
invalid_retries_negative_status=$?
set -e
if [[ "$invalid_retries_negative_status" -eq 0 ]]; then
	echo "Expected negative --retries value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid retries value '-1'" "$tmpdir/invalid-retries-negative.out"; then
	echo "Expected negative --retries validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --only lint,unknown --dry-run > "$tmpdir/unknown-gate.out" 2>&1
unknown_gate_status=$?
set -e
if [[ "$unknown_gate_status" -eq 0 ]]; then
	echo "Expected --only with unknown gate id to fail." >&2
	exit 1
fi
if ! grep -q "Unknown gate id 'unknown' for --only" "$tmpdir/unknown-gate.out"; then
	echo "Expected unknown gate id validation message." >&2
	exit 1
fi

set +e
VSCODE_VERIFY_CONTINUE_ON_FAILURE=maybe ./scripts/verify-gates.sh --quick --only lint --dry-run > "$tmpdir/invalid-continue-on-failure.out" 2>&1
invalid_continue_on_failure_status=$?
set -e
if [[ "$invalid_continue_on_failure_status" -eq 0 ]]; then
	echo "Expected invalid continue-on-failure environment value to fail." >&2
	exit 1
fi
if ! grep -q "Invalid continue-on-failure value 'maybe'" "$tmpdir/invalid-continue-on-failure.out"; then
	echo "Expected invalid continue-on-failure validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --from unknown --dry-run > "$tmpdir/unknown-from.out" 2>&1
unknown_from_status=$?
set -e
if [[ "$unknown_from_status" -eq 0 ]]; then
	echo "Expected --from unknown gate id to fail." >&2
	exit 1
fi
if ! grep -q "Unknown gate id 'unknown' for --from" "$tmpdir/unknown-from.out"; then
	echo "Expected unknown --from gate id validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --only " ,  " --dry-run > "$tmpdir/empty-only-list.out" 2>&1
empty_only_list_status=$?
set -e
if [[ "$empty_only_list_status" -eq 0 ]]; then
	echo "Expected --only with empty/whitespace gate list to fail." >&2
	exit 1
fi
if ! grep -q -- "--only produced an empty gate list" "$tmpdir/empty-only-list.out"; then
	echo "Expected empty --only list validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --quick --from "   " --dry-run > "$tmpdir/empty-from-value.out" 2>&1
empty_from_value_status=$?
set -e
if [[ "$empty_from_value_status" -eq 0 ]]; then
	echo "Expected --from with whitespace value to fail." >&2
	exit 1
fi
if ! grep -q -- "--from requires a non-empty gate id." "$tmpdir/empty-from-value.out"; then
	echo "Expected empty --from value validation message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --help > "$tmpdir/verify-help.out" 2>&1
verify_help_status=$?
set -e
if [[ "$verify_help_status" -ne 0 ]]; then
	echo "Expected verify-gates.sh --help to succeed." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/verify-help.out"; then
	echo "Expected verify-gates --help output to include usage text." >&2
	exit 1
fi
if ! grep -q "^Gate IDs:" "$tmpdir/verify-help.out"; then
	echo "Expected verify-gates --help output to include gate ID listing." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --not-a-real-option > "$tmpdir/verify-unknown-option.out" 2>&1
verify_unknown_option_status=$?
set -e
if [[ "$verify_unknown_option_status" -eq 0 ]]; then
	echo "Expected unknown verify-gates option to fail." >&2
	exit 1
fi
if ! grep -q "Unknown option: --not-a-real-option" "$tmpdir/verify-unknown-option.out"; then
	echo "Expected unknown verify-gates option validation message." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/verify-unknown-option.out"; then
	echo "Expected unknown verify-gates option output to include usage text." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --summary-json > "$tmpdir/missing-summary-json-value.out" 2>&1
missing_summary_json_value_status=$?
set -e
if [[ "$missing_summary_json_value_status" -eq 0 ]]; then
	echo "Expected --summary-json without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --summary-json." "$tmpdir/missing-summary-json-value.out"; then
	echo "Expected missing --summary-json value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --only > "$tmpdir/missing-only-value.out" 2>&1
missing_only_value_status=$?
set -e
if [[ "$missing_only_value_status" -eq 0 ]]; then
	echo "Expected --only without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --only." "$tmpdir/missing-only-value.out"; then
	echo "Expected missing --only value message." >&2
	exit 1
fi

set +e
./scripts/verify-gates.sh --from > "$tmpdir/missing-from-value.out" 2>&1
missing_from_value_status=$?
set -e
if [[ "$missing_from_value_status" -eq 0 ]]; then
	echo "Expected --from without value to fail." >&2
	exit 1
fi
if ! grep -q "Missing value for --from." "$tmpdir/missing-from-value.out"; then
	echo "Expected missing --from value message." >&2
	exit 1
fi

set +e
./scripts/publish-verify-gates-summary.sh --help > "$tmpdir/help.out" 2>&1
help_status=$?
set -e
if [[ "$help_status" -ne 0 ]]; then
	echo "Expected publish-verify-gates-summary.sh --help to succeed." >&2
	exit 1
fi
if ! grep -q "^Usage:" "$tmpdir/help.out"; then
	echo "Expected --help output to include usage text." >&2
	exit 1
fi
if ! grep -q "^GITHUB_STEP_SUMMARY" "$tmpdir/help.out"; then
	echo "Expected publisher --help output to include GITHUB_STEP_SUMMARY documentation." >&2
	exit 1
fi

node - "$expected_schema_version" "$minimal_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
fs.writeFileSync(summaryPath, JSON.stringify({ schemaVersion, success: true }, null, 2));
NODE

GITHUB_STEP_SUMMARY="$minimal_step_summary" ./scripts/publish-verify-gates-summary.sh "$minimal_summary" "Verify Gates Minimal Summary Contract Test"
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$minimal_step_summary"; then
	echo "Expected minimal summary rendering to include placeholder gate row." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$minimal_step_summary"; then
	echo "Did not expect schema warning for minimal summary payload." >&2
	exit 1
fi

printf '%s\n' "$expected_schema_version" > "$scalar_summary"
GITHUB_STEP_SUMMARY="$scalar_step_summary" ./scripts/publish-verify-gates-summary.sh "$scalar_summary" "Verify Gates Scalar Summary Contract Test"
if ! grep -q "^## Verify Gates Scalar Summary Contract Test" "$scalar_step_summary"; then
	echo "Expected scalar summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$scalar_step_summary"; then
	echo "Expected scalar summary rendering to include placeholder gate row." >&2
	exit 1
fi

printf '[]\n' > "$array_summary"
GITHUB_STEP_SUMMARY="$array_step_summary" ./scripts/publish-verify-gates-summary.sh "$array_summary" "Verify Gates Array Summary Contract Test"
if ! grep -q "^## Verify Gates Array Summary Contract Test" "$array_step_summary"; then
	echo "Expected array summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$array_step_summary"; then
	echo "Expected array summary rendering to include placeholder gate row." >&2
	exit 1
fi
if ! grep -q "\*\*Summary schema version:\*\* unknown" "$array_step_summary"; then
	echo "Expected array summary rendering to use unknown schema placeholder." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$array_step_summary"; then
	echo "Did not expect schema warning for array summary payload." >&2
	exit 1
fi

printf 'null\n' > "$null_summary"
GITHUB_STEP_SUMMARY="$null_step_summary" ./scripts/publish-verify-gates-summary.sh "$null_summary" "Verify Gates Null Summary Contract Test"
if ! grep -q "^## Verify Gates Null Summary Contract Test" "$null_step_summary"; then
	echo "Expected null summary heading to be rendered." >&2
	exit 1
fi
if ! grep -q "| \`n/a\` | \`n/a\` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |" "$null_step_summary"; then
	echo "Expected null summary rendering to include placeholder gate row." >&2
	exit 1
fi
if ! grep -q "\*\*Summary schema version:\*\* unknown" "$null_step_summary"; then
	echo "Expected null summary rendering to use unknown schema placeholder." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$null_step_summary"; then
	echo "Did not expect schema warning for null summary payload." >&2
	exit 1
fi

set +e
VSCODE_VERIFY_SUMMARY_FILE="$retry_summary" GITHUB_STEP_SUMMARY="$env_path_step_summary" ./scripts/publish-verify-gates-summary.sh > "$tmpdir/env-path.out" 2>&1
env_path_status=$?
set -e
if [[ "$env_path_status" -ne 0 ]]; then
	echo "Expected publish script without args to succeed when VSCODE_VERIFY_SUMMARY_FILE is set." >&2
	exit 1
fi
if ! grep -q "^## Verify Gates Summary" "$env_path_step_summary"; then
	echo "Expected default heading when summary heading argument is omitted." >&2
	exit 1
fi
if grep -q "\*\*Schema warning:\*\*" "$env_path_step_summary"; then
	echo "Did not expect schema warning for current schema payload." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$append_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Append Heading One"
GITHUB_STEP_SUMMARY="$append_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "Append Heading Two"
if [[ "$(grep -c "^## Append Heading One$" "$append_step_summary")" -ne 1 ]]; then
	echo "Expected appended summary to include first heading exactly once." >&2
	exit 1
fi
if [[ "$(grep -c "^## Append Heading Two$" "$append_step_summary")" -ne 1 ]]; then
	echo "Expected appended summary to include second heading exactly once." >&2
	exit 1
fi
append_heading_one_line="$(grep -n "^## Append Heading One$" "$append_step_summary" | awk -F: 'NR==1 {print $1}')"
append_heading_two_line="$(grep -n "^## Append Heading Two$" "$append_step_summary" | awk -F: 'NR==1 {print $1}')"
if [[ -z "$append_heading_one_line" ]] || [[ -z "$append_heading_two_line" ]] || ((append_heading_one_line >= append_heading_two_line)); then
	echo "Expected appended headings to appear in write order." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$multiline_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" $'Multiline Heading\nSecond Line'
if ! grep -q "^## Multiline Heading Second Line$" "$multiline_heading_step_summary"; then
	echo "Expected multiline heading to be sanitized into a single heading line." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$whitespace_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" $'  Heading\twith   mixed\t whitespace  '
if ! grep -q "^## Heading with mixed whitespace$" "$whitespace_heading_step_summary"; then
	echo "Expected mixed-whitespace heading to normalize to single spaces." >&2
	exit 1
fi

GITHUB_STEP_SUMMARY="$blank_heading_step_summary" ./scripts/publish-verify-gates-summary.sh "$retry_summary" "   "
if ! grep -q "^## Verify Gates Summary$" "$blank_heading_step_summary"; then
	echo "Expected blank heading to fall back to default heading." >&2
	exit 1
fi

node - "$expected_schema_version" "$escape_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
const payload = {
	schemaVersion,
	success: true,
	gates: [
		{
			id: 'id|with`pipe',
			command: 'echo line1\r\nline2 | `',
			status: 'pass',
			attempts: 1,
			retryCount: 0,
			retryBackoffSeconds: 0,
			durationSeconds: 0,
			exitCode: 0,
			notRunReason: null,
		}
	]
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$escape_step_summary" ./scripts/publish-verify-gates-summary.sh "$escape_summary" "Verify Gates Escape Contract Test"

node - "$escape_step_summary" <<'NODE'
const fs = require('node:fs');
const [escapeStepPath] = process.argv.slice(2);
const escapeStep = fs.readFileSync(escapeStepPath, 'utf8');
if (!escapeStep.includes('id\\|with\\`pipe')) {
	throw new Error('Expected escaped gate id in markdown table output.');
}
if (!escapeStep.includes('line1 line2 \\| \\`')) {
	throw new Error('Expected escaped/single-line command in markdown table output.');
}
if (escapeStep.includes('\r')) {
	throw new Error('Expected carriage returns to be normalized from markdown output.');
}
NODE

node - "$expected_schema_version" "$code_span_summary" <<'NODE'
const fs = require('node:fs');
const [schemaVersionRaw, summaryPath] = process.argv.slice(2);
const schemaVersion = Number.parseInt(schemaVersionRaw, 10);
const payload = {
	schemaVersion,
	success: true,
	logFile: 'path/with`tick\nline.log',
	gates: [],
};
fs.writeFileSync(summaryPath, JSON.stringify(payload, null, 2));
NODE

GITHUB_STEP_SUMMARY="$code_span_step_summary" ./scripts/publish-verify-gates-summary.sh "$code_span_summary" "Verify Gates Code Span Contract Test"

node - "$code_span_step_summary" <<'NODE'
const fs = require('node:fs');
const [codeSpanStepPath] = process.argv.slice(2);
const codeSpanStep = fs.readFileSync(codeSpanStepPath, 'utf8');
if (!codeSpanStep.includes('**Log file:** `path/with\\`tick line.log`')) {
	throw new Error('Expected escaped/single-line log-file code span output.');
}
NODE

echo "verify-gates summary contract checks passed."
