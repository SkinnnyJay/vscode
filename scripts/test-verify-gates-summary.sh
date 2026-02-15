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
fail_fast_summary="$tmpdir/fail-fast.json"
retry_summary="$tmpdir/retry.json"
fail_fast_step_summary="$tmpdir/fail-fast-step.md"
retry_step_summary="$tmpdir/retry-step.md"
future_summary="$tmpdir/future.json"
future_step_summary="$tmpdir/future-step.md"
malformed_summary="$tmpdir/malformed.json"
malformed_step_summary="$tmpdir/malformed-step.md"
missing_step_summary="$tmpdir/missing-step.md"
escape_summary="$tmpdir/escape.json"
escape_step_summary="$tmpdir/escape-step.md"
fallback_summary="$tmpdir/fallback.json"
fallback_step_summary="$tmpdir/fallback-step.md"
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

node - "$expected_schema_version" "$dry_summary" "$dry_repeat_summary" "$continue_true_summary" "$continue_false_summary" "$continue_flag_summary" "$dedupe_summary" "$from_summary" "$full_dry_summary" "$fail_fast_summary" "$retry_summary" "$fail_fast_step_summary" "$retry_step_summary" "$continue_flag_step_summary" "$fallback_step_summary" <<'NODE'
const fs = require('node:fs');
const [expectedSchemaVersionRaw, dryPath, dryRepeatPath, continueTruePath, continueFalsePath, continueFlagPath, dedupePath, fromPath, fullDryPath, failFastPath, retryPath, failFastStepPath, retryStepPath, continueFlagStepPath, fallbackStepPath] = process.argv.slice(2);
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
const failFast = JSON.parse(fs.readFileSync(failFastPath, 'utf8'));
const retry = JSON.parse(fs.readFileSync(retryPath, 'utf8'));
const failFastStep = fs.readFileSync(failFastStepPath, 'utf8');
const retryStep = fs.readFileSync(retryStepPath, 'utf8');
const continueFlagStep = fs.readFileSync(continueFlagStepPath, 'utf8');
const fallbackStep = fs.readFileSync(fallbackStepPath, 'utf8');

if (dry.schemaVersion !== expectedSchemaVersion || failFast.schemaVersion !== expectedSchemaVersion || retry.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for all runs.`);
}
if (dryRepeat.schemaVersion !== expectedSchemaVersion || continueTrue.schemaVersion !== expectedSchemaVersion || continueFalse.schemaVersion !== expectedSchemaVersion || continueFlag.schemaVersion !== expectedSchemaVersion || dedupe.schemaVersion !== expectedSchemaVersion || from.schemaVersion !== expectedSchemaVersion || fullDry.schemaVersion !== expectedSchemaVersion) {
	throw new Error(`Expected schema version ${expectedSchemaVersion} for dedupe/from runs.`);
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
for (const [label, summary] of [['dry', dry], ['dry-repeat', dryRepeat], ['dedupe', dedupe], ['from', from], ['full-dry', fullDry], ['fail-fast', failFast], ['retry', retry]]) {
	const expectedRunIdPrefix = label === 'full-dry' ? 'full-' : 'quick-';
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
if (!Array.isArray(failFast.executedGateIds) || failFast.executedGateCount !== failFast.executedGateIds.length) {
	throw new Error('Fail-fast executed gate count/list mismatch.');
}
if (!Array.isArray(retry.executedGateIds) || retry.executedGateCount !== retry.executedGateIds.length) {
	throw new Error('Retry-success executed gate count/list mismatch.');
}
for (const [label, summary] of [['dry', dry], ['fail-fast', failFast], ['retry', retry]]) {
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
if (!/\*\*Gate attempt-count map:\*\* \{[^\n]*lint[^\n]*2[^\n]*typecheck[^\n]*1/.test(retryStep)) {
	throw new Error('Retry step summary missing attempt-count map.');
}
if (!/\*\*Gate retry-count map:\*\* \{[^\n]*lint[^\n]*1[^\n]*typecheck[^\n]*0/.test(retryStep)) {
	throw new Error('Retry step summary missing retry-count map.');
}
if (!failFastStep.includes('**Log file:** `') || !retryStep.includes('**Log file:** `')) {
	throw new Error('Step summaries should include log-file metadata line.');
}
if (!continueFlagStep.includes('**Continue on failure:** true') || !continueFlagStep.includes('**Dry run:** true') || !continueFlagStep.includes('**Run classification:** dry-run')) {
	throw new Error('Continue-on-failure dry-run step summary metadata mismatch.');
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
if (!malformedStep.includes('malformed.json')) {
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
			command: 'echo line1\nline2 | `',
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
NODE

echo "verify-gates summary contract checks passed."
