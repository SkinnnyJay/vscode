#!/usr/bin/env bash
# publish-verify-gates-summary - Append verify-gates JSON summary to GitHub step summary.
# Usage: ./scripts/publish-verify-gates-summary.sh [summary-json-path] [summary-heading]
# Defaults to VSCODE_VERIFY_SUMMARY_FILE when path is omitted.
set -euo pipefail

print_usage() {
	cat <<'USAGE'
Usage: ./scripts/publish-verify-gates-summary.sh [summary-json-path] [summary-heading]

Arguments:
summary-json-path    Optional path to verify-gates summary JSON.
Defaults to VSCODE_VERIFY_SUMMARY_FILE.
summary-heading      Optional markdown heading text.
Defaults to "Verify Gates Summary".

Environment:
GITHUB_STEP_SUMMARY  Target markdown file to append.
USAGE
}

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
	print_usage
	exit 0
fi

if [[ -n "${1:-}" ]] && [[ "${1:0:1}" == "-" ]]; then
	echo "Unknown option: $1" >&2
	print_usage >&2
	exit 1
fi

SUMMARY_FILE_PATH="${1:-${VSCODE_VERIFY_SUMMARY_FILE:-}}"
SUMMARY_HEADING="${2:-Verify Gates Summary}"

if [[ -z "$SUMMARY_FILE_PATH" ]] || [[ ! -f "$SUMMARY_FILE_PATH" ]]; then
	exit 0
fi

if [[ -z "${GITHUB_STEP_SUMMARY:-}" ]]; then
	echo "GITHUB_STEP_SUMMARY is not set; skipping summary publication." >&2
	exit 0
fi

SUMMARY_FILE_PATH="$SUMMARY_FILE_PATH" SUMMARY_HEADING="$SUMMARY_HEADING" node <<'NODE'
const fs = require('fs');

const summaryPath = process.env.SUMMARY_FILE_PATH;
const heading = process.env.SUMMARY_HEADING;
const summaryOutputPath = process.env.GITHUB_STEP_SUMMARY;
const supportedSchemaVersion = 5;

if (!summaryPath || !summaryOutputPath) {
	process.exit(0);
}

let summary;
try {
	summary = JSON.parse(fs.readFileSync(summaryPath, 'utf8'));
} catch (error) {
	const message = error instanceof Error ? error.message : String(error);
	fs.appendFileSync(summaryOutputPath, `## ${heading}\n\nUnable to parse verify-gates summary at \`${summaryPath}\`: ${message}\n`);
	process.exit(0);
}

const gates = Array.isArray(summary.gates) ? summary.gates : [];
const selectedGateIds = Array.isArray(summary.selectedGateIds)
	? summary.selectedGateIds
	: gates.map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const selectedGateIdsLabel = selectedGateIds.length > 0 ? selectedGateIds.join(', ') : 'none';
const failedGateIds = Array.isArray(summary.failedGateIds)
	? summary.failedGateIds
	: gates.filter((gate) => gate.status === 'fail').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const failedGateIdsLabel = failedGateIds.length > 0 ? failedGateIds.join(', ') : 'none';
const failedGateExitCodes = Array.isArray(summary.failedGateExitCodes)
	? summary.failedGateExitCodes
	: gates.filter((gate) => gate.status === 'fail').map((gate) => gate.exitCode);
const failedGateExitCodesLabel = failedGateExitCodes.length > 0 ? failedGateExitCodes.join(', ') : 'none';
const retriedGateIds = Array.isArray(summary.retriedGateIds)
	? summary.retriedGateIds
	: gates.filter((gate) => (gate.retryCount ?? 0) > 0).map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const retriedGateIdsLabel = retriedGateIds.length > 0 ? retriedGateIds.join(', ') : 'none';
const notRunGateIds = Array.isArray(summary.notRunGateIds)
	? summary.notRunGateIds
	: gates.filter((gate) => gate.status === 'not-run').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const notRunGateIdsLabel = notRunGateIds.length > 0 ? notRunGateIds.join(', ') : 'none';
const sanitizeCell = (value) => String(value).replace(/\n/g, ' ').replace(/\|/g, '\\|');
const sanitizeCodeCell = (value) => sanitizeCell(value).replace(/`/g, '\\`');
const gateRows = gates.map((gate) => {
	const gateId = gate.id ?? 'unknown';
	const command = gate.command ?? 'unknown';
	const status = gate.status ?? 'unknown';
	const attempts = gate.attempts ?? '-';
	const retryCount = gate.retryCount ?? '-';
	const retryBackoffSeconds = gate.retryBackoffSeconds ?? '-';
	const durationSeconds = gate.durationSeconds ?? '-';
	const exitCode = gate.exitCode ?? 'unknown';
	const notRunReason = gate.notRunReason ?? 'n/a';
	return `| \`${sanitizeCodeCell(gateId)}\` | \`${sanitizeCodeCell(command)}\` | ${sanitizeCell(status)} | ${sanitizeCell(attempts)} | ${sanitizeCell(retryCount)} | ${sanitizeCell(retryBackoffSeconds)} | ${sanitizeCell(durationSeconds)} | ${sanitizeCell(exitCode)} | ${sanitizeCell(notRunReason)} |`;
});

const lines = [
	`## ${heading}`,
	'',
	'| Gate ID | Command | Status | Attempts | Retries | Retry backoff (s) | Duration (s) | Exit code | Not-run reason |',
	'| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |',
	...(gateRows.length > 0 ? gateRows : ['| `n/a` | `n/a` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |']),
	'',
	`**Success:** ${summary.success ?? 'unknown'}`,
	`**Summary schema version:** ${summary.schemaVersion ?? 'unknown'}`,
	`**Run ID:** ${sanitizeCell(summary.runId ?? 'unknown')}`,
	`**Exit reason:** ${sanitizeCell(summary.exitReason ?? 'unknown')}`,
	`**Invocation:** ${sanitizeCell(summary.invocation ?? 'unknown')}`,
	`**Continue on failure:** ${summary.continueOnFailure ?? 'unknown'}`,
	`**Dry run:** ${summary.dryRun ?? 'unknown'}`,
	`**Gate count:** ${summary.gateCount ?? gates.length}`,
	`**Passed gates:** ${summary.passedGateCount ?? 'unknown'}`,
	`**Failed gates:** ${summary.failedGateCount ?? 'unknown'}`,
	`**Skipped gates:** ${summary.skippedGateCount ?? 'unknown'}`,
	`**Not-run gates:** ${summary.notRunGateCount ?? 'unknown'}`,
	`**Executed gates:** ${summary.executedGateCount ?? 'unknown'}`,
	`**Total retries:** ${summary.totalRetryCount ?? 'unknown'}`,
	`**Total retry backoff:** ${summary.totalRetryBackoffSeconds ?? 'unknown'}s`,
	`**Retried gate count:** ${summary.retriedGateCount ?? retriedGateIds.length}`,
	`**Retried gates:** ${sanitizeCell(retriedGateIdsLabel)}`,
	`**Pass rate (executed gates):** ${summary.passRatePercent ?? 'n/a'}${summary.passRatePercent === null || summary.passRatePercent === undefined ? '' : '%'}`,
	`**Executed duration total:** ${summary.executedDurationSeconds ?? 'unknown'}s`,
	`**Executed duration average:** ${summary.averageExecutedDurationSeconds === null || summary.averageExecutedDurationSeconds === undefined ? 'n/a' : `${summary.averageExecutedDurationSeconds}s`}`,
	`**Slowest executed gate:** ${sanitizeCell(summary.slowestExecutedGateId ?? 'n/a')}`,
	`**Slowest executed gate duration:** ${summary.slowestExecutedGateDurationSeconds === null || summary.slowestExecutedGateDurationSeconds === undefined ? 'n/a' : `${summary.slowestExecutedGateDurationSeconds}s`}`,
	`**Fastest executed gate:** ${sanitizeCell(summary.fastestExecutedGateId ?? 'n/a')}`,
	`**Fastest executed gate duration:** ${summary.fastestExecutedGateDurationSeconds === null || summary.fastestExecutedGateDurationSeconds === undefined ? 'n/a' : `${summary.fastestExecutedGateDurationSeconds}s`}`,
	`**Selected gates:** ${sanitizeCell(selectedGateIdsLabel)}`,
	`**Failed gates list:** ${sanitizeCell(failedGateIdsLabel)}`,
	`**Failed gate exit codes:** ${sanitizeCell(failedGateExitCodesLabel)}`,
	`**Not-run gates list:** ${sanitizeCell(notRunGateIdsLabel)}`,
	`**Failed gate:** ${sanitizeCell(summary.failedGateId ?? 'none')}`,
	`**Failed gate exit code:** ${sanitizeCell(summary.failedGateExitCode ?? 'none')}`,
	`**Total duration:** ${summary.totalDurationSeconds ?? 'unknown'}s`,
	`**Started:** ${summary.startedAt ?? 'unknown'}`,
	`**Completed:** ${summary.completedAt ?? 'unknown'}`,
];

if (summary.logFile) {
	lines.push(`**Log file:** \`${summary.logFile}\``);
}

if (typeof summary.schemaVersion === 'number' && summary.schemaVersion > supportedSchemaVersion) {
	lines.push(`**Schema warning:** summary schema version ${summary.schemaVersion} is newer than supported ${supportedSchemaVersion}; some fields may be omitted.`);
}

fs.appendFileSync(summaryOutputPath, lines.join('\n') + '\n');
NODE
