#!/usr/bin/env bash
# publish-verify-gates-summary - Append verify-gates JSON summary to GitHub step summary.
# Usage: ./scripts/publish-verify-gates-summary.sh [summary-json-path] [summary-heading]
# Defaults to VSCODE_VERIFY_SUMMARY_FILE when path is omitted.
set -euo pipefail

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

const summary = JSON.parse(fs.readFileSync(summaryPath, 'utf8'));
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
	...gateRows,
	'',
	`**Success:** ${summary.success}`,
	`**Total duration:** ${summary.totalDurationSeconds}s`,
	`**Started:** ${summary.startedAt}`,
	`**Completed:** ${summary.completedAt}`,
];

if (summary.logFile) {
	lines.push(`**Log file:** \`${summary.logFile}\``);
}

fs.appendFileSync(summaryOutputPath, lines.join('\n') + '\n');
NODE
