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
const gateRows = gates.map((gate) => {
	const gateId = gate.id ?? 'unknown';
	const command = gate.command ?? 'unknown';
	const status = gate.status ?? 'unknown';
	const attempts = gate.attempts ?? '-';
	const durationSeconds = gate.durationSeconds ?? '-';
	return `| \`${gateId}\` | \`${command}\` | ${status} | ${attempts} | ${durationSeconds} |`;
});

const lines = [
	`## ${heading}`,
	'',
	'| Gate ID | Command | Status | Attempts | Duration (s) |',
	'| --- | --- | --- | ---: | ---: |',
	...(gateRows.length > 0 ? gateRows : ['| `n/a` | `n/a` | n/a | n/a | n/a |']),
	'',
	`**Success:** ${summary.success ?? 'unknown'}`,
	`**Dry run:** ${summary.dryRun ?? 'unknown'}`,
	`**Gate count:** ${summary.gateCount ?? gates.length}`,
	`**Failed gate:** ${summary.failedGateId ?? 'none'}`,
	`**Total duration:** ${summary.totalDurationSeconds ?? 'unknown'}s`,
	`**Started:** ${summary.startedAt ?? 'unknown'}`,
	`**Completed:** ${summary.completedAt ?? 'unknown'}`,
];

if (summary.logFile) {
	lines.push(`**Log file:** \`${summary.logFile}\``);
}

fs.appendFileSync(summaryOutputPath, lines.join('\n') + '\n');
NODE
