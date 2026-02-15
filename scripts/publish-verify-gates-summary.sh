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
const supportedSchemaVersion = 18;
const sanitizeHeading = (value) => String(value ?? '').replace(/\s+/g, ' ').trim();
const sanitizeInlineCode = (value) => String(value ?? '').replace(/\r?\n/g, ' ').replace(/`/g, '\\`');
const renderedHeading = sanitizeHeading(heading) || 'Verify Gates Summary';

if (!summaryPath || !summaryOutputPath) {
	process.exit(0);
}

let parsedSummary;
try {
	parsedSummary = JSON.parse(fs.readFileSync(summaryPath, 'utf8'));
} catch (error) {
	const message = error instanceof Error ? error.message : String(error);
	fs.appendFileSync(summaryOutputPath, `## ${renderedHeading}\n\nUnable to parse verify-gates summary at \`${sanitizeInlineCode(summaryPath)}\`: ${message}\n`);
	process.exit(0);
}

const summary = parsedSummary ?? {};

const gates = Array.isArray(summary.gates) ? summary.gates : [];
const passedGateIdsFromSummary = Array.isArray(summary.passedGateIds) ? summary.passedGateIds : null;
const failedGateIdsFromSummary = Array.isArray(summary.failedGateIds) ? summary.failedGateIds : null;
const skippedGateIdsFromSummary = Array.isArray(summary.skippedGateIds) ? summary.skippedGateIds : null;
const notRunGateIdsFromSummary = Array.isArray(summary.notRunGateIds) ? summary.notRunGateIds : null;
const selectedGateIdsFromSummary = Array.isArray(summary.selectedGateIds) ? summary.selectedGateIds : null;
const executedGateIdsFromSummary = Array.isArray(summary.executedGateIds) ? summary.executedGateIds : null;
const derivedStatusCounts = gates.reduce((accumulator, gate) => {
	const status = gate?.status;
	if (status === 'pass' || status === 'fail' || status === 'skip' || status === 'not-run') {
		accumulator[status] += 1;
	}
	return accumulator;
}, { pass: 0, fail: 0, skip: 0, 'not-run': 0 });
const rawStatusCounts = summary.statusCounts && typeof summary.statusCounts === 'object' && !Array.isArray(summary.statusCounts)
	? summary.statusCounts
	: {};
const passedGateCount = summary.passedGateCount ?? rawStatusCounts.pass ?? passedGateIdsFromSummary?.length ?? derivedStatusCounts.pass;
const failedGateCount = summary.failedGateCount ?? rawStatusCounts.fail ?? failedGateIdsFromSummary?.length ?? derivedStatusCounts.fail;
const skippedGateCount = summary.skippedGateCount ?? rawStatusCounts.skip ?? skippedGateIdsFromSummary?.length ?? derivedStatusCounts.skip;
const notRunGateCount = summary.notRunGateCount ?? rawStatusCounts['not-run'] ?? notRunGateIdsFromSummary?.length ?? derivedStatusCounts['not-run'];
const statusCounts = {
	pass: rawStatusCounts.pass ?? passedGateCount,
	fail: rawStatusCounts.fail ?? failedGateCount,
	skip: rawStatusCounts.skip ?? skippedGateCount,
	'not-run': rawStatusCounts['not-run'] ?? notRunGateCount,
};
const selectedGateIds = selectedGateIdsFromSummary
	? selectedGateIdsFromSummary
	: gates.map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const selectedGateIdsLabel = selectedGateIds.length > 0 ? selectedGateIds.join(', ') : 'none';
const failedGateIds = failedGateIdsFromSummary
	? failedGateIdsFromSummary
	: gates.filter((gate) => gate.status === 'fail').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const failedGateIdsLabel = failedGateIds.length > 0 ? failedGateIds.join(', ') : 'none';
const retriedGateIds = Array.isArray(summary.retriedGateIds)
	? summary.retriedGateIds
	: gates.filter((gate) => (gate.retryCount ?? 0) > 0).map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const retriedGateIdsLabel = retriedGateIds.length > 0 ? retriedGateIds.join(', ') : 'none';
const passedGateIds = passedGateIdsFromSummary
	? passedGateIdsFromSummary
	: gates.filter((gate) => gate.status === 'pass').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const passedGateIdsLabel = passedGateIds.length > 0 ? passedGateIds.join(', ') : 'none';
const skippedGateIds = skippedGateIdsFromSummary
	? skippedGateIdsFromSummary
	: gates.filter((gate) => gate.status === 'skip').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const skippedGateIdsLabel = skippedGateIds.length > 0 ? skippedGateIds.join(', ') : 'none';
const executedGateIds = executedGateIdsFromSummary
	? executedGateIdsFromSummary
	: gates.filter((gate) => gate.status === 'pass' || gate.status === 'fail').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const executedGateIdsLabel = executedGateIds.length > 0 ? executedGateIds.join(', ') : 'none';
const executedGateCount = summary.executedGateCount ?? executedGateIdsFromSummary?.length ?? executedGateIds.length;
const gateCount = summary.gateCount ?? selectedGateIdsFromSummary?.length ?? selectedGateIds.length ?? gates.length;
const notRunGateIds = notRunGateIdsFromSummary
	? notRunGateIdsFromSummary
	: gates.filter((gate) => gate.status === 'not-run').map((gate) => gate.id).filter((gateId) => typeof gateId === 'string');
const notRunGateIdsLabel = notRunGateIds.length > 0 ? notRunGateIds.join(', ') : 'none';
const nonSuccessGateIds = Array.isArray(summary.nonSuccessGateIds)
	? summary.nonSuccessGateIds
	: gates
		.filter((gate) => gate.status !== 'pass')
		.map((gate) => gate.id)
		.filter((gateId) => typeof gateId === 'string');
const nonSuccessGateIdsLabel = nonSuccessGateIds.length > 0 ? nonSuccessGateIds.join(', ') : 'none';
const attentionGateIds = Array.isArray(summary.attentionGateIds)
	? summary.attentionGateIds
	: gates
		.filter((gate) => gate.status !== 'pass' || (gate.retryCount ?? 0) > 0)
		.map((gate) => gate.id)
		.filter((gateId) => typeof gateId === 'string');
const attentionGateIdsLabel = attentionGateIds.length > 0 ? attentionGateIds.join(', ') : 'none';
const gateStatusById = summary.gateStatusById && typeof summary.gateStatusById === 'object' && !Array.isArray(summary.gateStatusById)
	? summary.gateStatusById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.status ?? 'unknown']),
	);
const gateExitCodeById = summary.gateExitCodeById && typeof summary.gateExitCodeById === 'object' && !Array.isArray(summary.gateExitCodeById)
	? summary.gateExitCodeById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.exitCode ?? null]),
	);
const failedGateExitCodes = Array.isArray(summary.failedGateExitCodes)
	? summary.failedGateExitCodes
	: failedGateIds
		.map((gateId) => gateExitCodeById[gateId])
		.filter((exitCode) => exitCode !== null && exitCode !== undefined);
const failedGateExitCodesLabel = failedGateExitCodes.length > 0 ? failedGateExitCodes.join(', ') : 'none';
const gateRetryCountById = summary.gateRetryCountById && typeof summary.gateRetryCountById === 'object' && !Array.isArray(summary.gateRetryCountById)
	? summary.gateRetryCountById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.retryCount ?? 0]),
	);
const gateDurationSecondsById = summary.gateDurationSecondsById && typeof summary.gateDurationSecondsById === 'object' && !Array.isArray(summary.gateDurationSecondsById)
	? summary.gateDurationSecondsById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.durationSeconds ?? 0]),
	);
const gateNotRunReasonById = summary.gateNotRunReasonById && typeof summary.gateNotRunReasonById === 'object' && !Array.isArray(summary.gateNotRunReasonById)
	? summary.gateNotRunReasonById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.notRunReason ?? null]),
	);
const gateAttemptCountById = summary.gateAttemptCountById && typeof summary.gateAttemptCountById === 'object' && !Array.isArray(summary.gateAttemptCountById)
	? summary.gateAttemptCountById
	: Object.fromEntries(
		gates
			.filter((gate) => typeof gate.id === 'string')
			.map((gate) => [gate.id, gate.attempts ?? 0]),
	);
const gateNotRunReasonEntries = Object.entries(gateNotRunReasonById).filter(([, reason]) => typeof reason === 'string' && reason.length > 0);
const gateNotRunReasonMapLabel = gateNotRunReasonEntries.length > 0 ? JSON.stringify(Object.fromEntries(gateNotRunReasonEntries)) : 'none';
const sanitizeCell = (value) => String(value).replace(/\r?\n/g, ' ').replace(/\|/g, '\\|');
const sanitizeCodeCell = (value) => sanitizeCell(value).replace(/`/g, '\\`');
const gateRows = gates.map((gate) => {
	const gateId = gate.id ?? 'unknown';
	const command = gate.command ?? 'unknown';
	const status = gate.status ?? 'unknown';
	const attempts = gate.attempts ?? '-';
	const retryCount = gate.retryCount ?? '-';
	const retryBackoffSeconds = gate.retryBackoffSeconds ?? '-';
	const durationSeconds = gate.durationSeconds ?? '-';
	const exitCode = gate.exitCode === null || gate.exitCode === undefined ? 'n/a' : gate.exitCode;
	const notRunReason = gate.notRunReason ?? 'n/a';
	return `| \`${sanitizeCodeCell(gateId)}\` | \`${sanitizeCodeCell(command)}\` | ${sanitizeCell(status)} | ${sanitizeCell(attempts)} | ${sanitizeCell(retryCount)} | ${sanitizeCell(retryBackoffSeconds)} | ${sanitizeCell(durationSeconds)} | ${sanitizeCell(exitCode)} | ${sanitizeCell(notRunReason)} |`;
});

const lines = [
	`## ${renderedHeading}`,
	'',
	'| Gate ID | Command | Status | Attempts | Retries | Retry backoff (s) | Duration (s) | Exit code | Not-run reason |',
	'| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |',
	...(gateRows.length > 0 ? gateRows : ['| `n/a` | `n/a` | n/a | n/a | n/a | n/a | n/a | n/a | n/a |']),
	'',
	`**Success:** ${summary.success ?? 'unknown'}`,
	`**Summary schema version:** ${summary.schemaVersion ?? 'unknown'}`,
	`**Run ID:** ${sanitizeCell(summary.runId ?? 'unknown')}`,
	`**Run classification:** ${sanitizeCell(summary.runClassification ?? 'unknown')}`,
	`**Result signature algorithm:** ${sanitizeCell(summary.resultSignatureAlgorithm ?? 'unknown')}`,
	`**Result signature:** ${sanitizeCell(summary.resultSignature ?? 'unknown')}`,
	`**Exit reason:** ${sanitizeCell(summary.exitReason ?? 'unknown')}`,
	`**Invocation:** ${sanitizeCell(summary.invocation ?? 'unknown')}`,
	`**Continue on failure:** ${summary.continueOnFailure ?? 'unknown'}`,
	`**Dry run:** ${summary.dryRun ?? 'unknown'}`,
	`**Gate count:** ${gateCount}`,
	`**Passed gates:** ${passedGateCount}`,
	`**Failed gates:** ${failedGateCount}`,
	`**Skipped gates:** ${skippedGateCount}`,
	`**Not-run gates:** ${notRunGateCount}`,
	`**Status counts:** ${sanitizeCell(JSON.stringify(statusCounts))}`,
	`**Gate status map:** ${sanitizeCell(JSON.stringify(gateStatusById))}`,
	`**Gate exit-code map:** ${sanitizeCell(JSON.stringify(gateExitCodeById))}`,
	`**Gate retry-count map:** ${sanitizeCell(JSON.stringify(gateRetryCountById))}`,
	`**Gate duration map (s):** ${sanitizeCell(JSON.stringify(gateDurationSecondsById))}`,
	`**Gate not-run reason map:** ${sanitizeCell(gateNotRunReasonMapLabel)}`,
	`**Gate attempt-count map:** ${sanitizeCell(JSON.stringify(gateAttemptCountById))}`,
	`**Executed gates:** ${executedGateCount}`,
	`**Total retries:** ${summary.totalRetryCount ?? 'unknown'}`,
	`**Total retry backoff:** ${summary.totalRetryBackoffSeconds ?? 'unknown'}s`,
	`**Retried gate count:** ${summary.retriedGateCount ?? retriedGateIds.length}`,
	`**Retried gates:** ${sanitizeCell(retriedGateIdsLabel)}`,
	`**Executed gates list:** ${sanitizeCell(executedGateIdsLabel)}`,
	`**Passed gates list:** ${sanitizeCell(passedGateIdsLabel)}`,
	`**Skipped gates list:** ${sanitizeCell(skippedGateIdsLabel)}`,
	`**Retry rate (executed gates):** ${summary.retryRatePercent ?? 'n/a'}${summary.retryRatePercent === null || summary.retryRatePercent === undefined ? '' : '%'}`,
	`**Retry backoff share (executed duration):** ${summary.retryBackoffSharePercent ?? 'n/a'}${summary.retryBackoffSharePercent === null || summary.retryBackoffSharePercent === undefined ? '' : '%'}`,
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
	`**Non-success gates list:** ${sanitizeCell(nonSuccessGateIdsLabel)}`,
	`**Attention gates list:** ${sanitizeCell(attentionGateIdsLabel)}`,
	`**Blocked by gate:** ${sanitizeCell(summary.blockedByGateId ?? 'none')}`,
	`**Failed gate:** ${sanitizeCell(summary.failedGateId ?? 'none')}`,
	`**Failed gate exit code:** ${sanitizeCell(summary.failedGateExitCode ?? 'none')}`,
	`**Total duration:** ${summary.totalDurationSeconds ?? 'unknown'}s`,
	`**Started:** ${summary.startedAt ?? 'unknown'}`,
	`**Completed:** ${summary.completedAt ?? 'unknown'}`,
];

if (summary.logFile) {
	lines.push(`**Log file:** \`${sanitizeInlineCode(summary.logFile)}\``);
}

if (typeof summary.schemaVersion === 'number' && summary.schemaVersion > supportedSchemaVersion) {
	lines.push(`**Schema warning:** summary schema version ${summary.schemaVersion} is newer than supported ${supportedSchemaVersion}; some fields may be omitted.`);
}

fs.appendFileSync(summaryOutputPath, lines.join('\n') + '\n');
NODE
