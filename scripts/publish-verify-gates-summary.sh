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

const gatesFromSummary = Array.isArray(summary.gates) ? summary.gates : [];
const normalizeNonEmptyString = (value) => {
	if (typeof value !== 'string') {
		return null;
	}
	const normalizedValue = value.trim();
	return normalizedValue.length > 0 ? normalizedValue : null;
};
const normalizeBoolean = (value) => {
	if (typeof value === 'boolean') {
		return value;
	}
	if (typeof value === 'number') {
		if (value === 1) {
			return true;
		}
		if (value === 0) {
			return false;
		}
		return null;
	}
	if (typeof value !== 'string') {
		return null;
	}
	const normalizedValue = value.trim().toLowerCase();
	if (normalizedValue === '1' || normalizedValue === 'true' || normalizedValue === 'yes' || normalizedValue === 'on') {
		return true;
	}
	if (normalizedValue === '0' || normalizedValue === 'false' || normalizedValue === 'no' || normalizedValue === 'off') {
		return false;
	}
	return null;
};
const normalizeKnownValue = (value, allowedValues) => {
	const normalizedValue = normalizeNonEmptyString(value);
	if (!normalizedValue) {
		return null;
	}
	const canonicalValue = normalizedValue.toLowerCase();
	return allowedValues.includes(canonicalValue) ? canonicalValue : null;
};
const normalizeGateStatusValue = (value) => normalizeKnownValue(value, ['pass', 'fail', 'skip', 'not-run']);
const gates = gatesFromSummary.reduce((normalizedGates, gate) => {
	const gateObject = gate && typeof gate === 'object' ? gate : {};
	const gateId = normalizeNonEmptyString(gateObject.id);
	if (gateId === null) {
		return normalizedGates;
	}
	normalizedGates.push({
		...gateObject,
		id: gateId,
		status: normalizeGateStatusValue(gateObject.status) ?? gateObject.status,
		notRunReason: typeof gateObject.notRunReason === 'string'
			? (normalizeNonEmptyString(gateObject.notRunReason) ?? null)
			: null,
	});
	return normalizedGates;
}, []);
const normalizeGateIdList = (value) => {
	if (!Array.isArray(value)) {
		return null;
	}
	const seenGateIds = new Set();
	const normalizedGateIds = [];
	for (const gateIdValue of value) {
		if (typeof gateIdValue !== 'string') {
			continue;
		}
		const normalizedGateId = gateIdValue.trim();
		if (normalizedGateId.length === 0 || seenGateIds.has(normalizedGateId)) {
			continue;
		}
		seenGateIds.add(normalizedGateId);
		normalizedGateIds.push(normalizedGateId);
	}
	return normalizedGateIds;
};
const normalizeNonNegativeInteger = (value) => {
	if (typeof value === 'number' && Number.isFinite(value) && Number.isInteger(value) && value >= 0) {
		return value;
	}
	if (typeof value === 'string' && /^\d+$/.test(value.trim())) {
		return Number.parseInt(value.trim(), 10);
	}
	return null;
};
const normalizeInteger = (value) => {
	if (typeof value === 'number' && Number.isFinite(value) && Number.isInteger(value)) {
		return value;
	}
	if (typeof value === 'string' && /^-?\d+$/.test(value.trim())) {
		return Number.parseInt(value.trim(), 10);
	}
	return null;
};
const normalizeIntegerList = (value, normalizeValue = normalizeInteger) => {
	if (!Array.isArray(value)) {
		return null;
	}
	const normalizedValues = [];
	for (const item of value) {
		const normalizedValue = normalizeValue(item);
		if (normalizedValue === null) {
			continue;
		}
		normalizedValues.push(normalizedValue);
	}
	return normalizedValues;
};
const uniqueGateIds = (gateIds) => {
	const seenGateIds = new Set();
	const orderedGateIds = [];
	for (const gateId of gateIds) {
		if (typeof gateId !== 'string' || gateId.length === 0 || seenGateIds.has(gateId)) {
			continue;
		}
		seenGateIds.add(gateId);
		orderedGateIds.push(gateId);
	}
	return orderedGateIds;
};
const normalizeGateRetryCountMap = (value) => {
	if (!value || typeof value !== 'object' || Array.isArray(value)) {
		return null;
	}
	const normalizedMap = {};
	for (const [gateIdValue, retryCountValue] of Object.entries(value)) {
		if (typeof gateIdValue !== 'string') {
			continue;
		}
		const gateId = gateIdValue.trim();
		const retryCount = normalizeNonNegativeInteger(retryCountValue);
		if (gateId.length === 0 || retryCount === null) {
			continue;
		}
		normalizedMap[gateId] = retryCount;
	}
	return normalizedMap;
};
const normalizeGateIntegerMap = (value, { allowNullValues, normalizeValue }) => {
	if (!value || typeof value !== 'object' || Array.isArray(value)) {
		return null;
	}
	const normalizedMap = {};
	for (const [gateIdValue, rawValue] of Object.entries(value)) {
		if (typeof gateIdValue !== 'string') {
			continue;
		}
		const gateId = gateIdValue.trim();
		if (gateId.length === 0) {
			continue;
		}
		if (allowNullValues && rawValue === null) {
			normalizedMap[gateId] = null;
			continue;
		}
		const normalizedValue = normalizeValue(rawValue);
		if (normalizedValue === null) {
			continue;
		}
		normalizedMap[gateId] = normalizedValue;
	}
	return normalizedMap;
};
const normalizeGateReasonMap = (value) => {
	if (!value || typeof value !== 'object' || Array.isArray(value)) {
		return null;
	}
	const normalizedMap = {};
	for (const [gateIdValue, reasonValue] of Object.entries(value)) {
		if (typeof gateIdValue !== 'string') {
			continue;
		}
		const gateId = gateIdValue.trim();
		if (gateId.length === 0) {
			continue;
		}
		if (reasonValue === null) {
			normalizedMap[gateId] = null;
			continue;
		}
		if (typeof reasonValue === 'string') {
			const normalizedReason = reasonValue.trim();
			if (normalizedReason.length === 0) {
				normalizedMap[gateId] = null;
			} else {
				normalizedMap[gateId] = normalizedReason;
			}
		}
	}
	return normalizedMap;
};
const passedGateIdsFromSummary = normalizeGateIdList(summary.passedGateIds);
const failedGateIdsFromSummary = normalizeGateIdList(summary.failedGateIds);
const skippedGateIdsFromSummary = normalizeGateIdList(summary.skippedGateIds);
const notRunGateIdsFromSummary = normalizeGateIdList(summary.notRunGateIds);
const selectedGateIdsFromSummary = normalizeGateIdList(summary.selectedGateIds);
const executedGateIdsFromSummary = normalizeGateIdList(summary.executedGateIds);
const retriedGateIdsFromSummary = normalizeGateIdList(summary.retriedGateIds);
const nonSuccessGateIdsFromSummary = normalizeGateIdList(summary.nonSuccessGateIds);
const attentionGateIdsFromSummary = normalizeGateIdList(summary.attentionGateIds);
const normalizeGateStatusMap = (value) => {
	if (!value || typeof value !== 'object' || Array.isArray(value)) {
		return null;
	}
	const normalizedMap = {};
	for (const [gateIdValue, statusValue] of Object.entries(value)) {
		if (typeof gateIdValue !== 'string') {
			continue;
		}
		const gateId = gateIdValue.trim();
		const normalizedStatus = normalizeKnownValue(statusValue, ['pass', 'fail', 'skip', 'not-run']);
		if (gateId.length === 0 || normalizedStatus === null) {
			continue;
		}
		normalizedMap[gateId] = normalizedStatus;
	}
	return normalizedMap;
};
const gateStatusByIdFromSummary = normalizeGateStatusMap(summary.gateStatusById);
const derivedStatusCounts = gates.reduce((accumulator, gate) => {
	const status = gate?.status;
	if (status === 'pass' || status === 'fail' || status === 'skip' || status === 'not-run') {
		accumulator[status] += 1;
	}
	return accumulator;
}, { pass: 0, fail: 0, skip: 0, 'not-run': 0 });
const derivedStatusCountsFromStatusMap = gateStatusByIdFromSummary
	? Object.values(gateStatusByIdFromSummary).reduce((accumulator, status) => {
		accumulator[status] += 1;
		return accumulator;
	}, { pass: 0, fail: 0, skip: 0, 'not-run': 0 })
	: null;
const rawStatusCountsInput = summary.statusCounts && typeof summary.statusCounts === 'object' && !Array.isArray(summary.statusCounts)
	? summary.statusCounts
	: null;
const rawStatusCounts = {
	pass: normalizeNonNegativeInteger(rawStatusCountsInput?.pass),
	fail: normalizeNonNegativeInteger(rawStatusCountsInput?.fail),
	skip: normalizeNonNegativeInteger(rawStatusCountsInput?.skip),
	'not-run': normalizeNonNegativeInteger(rawStatusCountsInput?.['not-run']),
};
const rawStatusCountsHasValues = Object.values(rawStatusCounts).some((value) => value !== null);
const passedGateCountFromSummary = normalizeNonNegativeInteger(summary.passedGateCount);
const failedGateCountFromSummary = normalizeNonNegativeInteger(summary.failedGateCount);
const skippedGateCountFromSummary = normalizeNonNegativeInteger(summary.skippedGateCount);
const notRunGateCountFromSummary = normalizeNonNegativeInteger(summary.notRunGateCount);
const passedGateCount = passedGateCountFromSummary ?? rawStatusCounts.pass ?? passedGateIdsFromSummary?.length ?? derivedStatusCountsFromStatusMap?.pass ?? derivedStatusCounts.pass;
const failedGateCount = failedGateCountFromSummary ?? rawStatusCounts.fail ?? failedGateIdsFromSummary?.length ?? derivedStatusCountsFromStatusMap?.fail ?? derivedStatusCounts.fail;
const skippedGateCount = skippedGateCountFromSummary ?? rawStatusCounts.skip ?? skippedGateIdsFromSummary?.length ?? derivedStatusCountsFromStatusMap?.skip ?? derivedStatusCounts.skip;
const notRunGateCount = notRunGateCountFromSummary ?? rawStatusCounts['not-run'] ?? notRunGateIdsFromSummary?.length ?? derivedStatusCountsFromStatusMap?.['not-run'] ?? derivedStatusCounts['not-run'];
const statusCounts = {
	pass: rawStatusCounts.pass ?? passedGateCount,
	fail: rawStatusCounts.fail ?? failedGateCount,
	skip: rawStatusCounts.skip ?? skippedGateCount,
	'not-run': rawStatusCounts['not-run'] ?? notRunGateCount,
};
const normalizeGateIdValue = (value) => normalizeNonEmptyString(value);
const gateIdsFromRows = (predicate) => {
	const gateIds = [];
	for (const gate of gates) {
		if (!predicate(gate)) {
			continue;
		}
		const gateId = normalizeGateIdValue(gate.id);
		if (gateId !== null) {
			gateIds.push(gateId);
		}
	}
	return uniqueGateIds(gateIds);
};
const gateMapFromRows = (valueSelector) => {
	const gateMap = {};
	for (const gate of gates) {
		const gateId = normalizeGateIdValue(gate.id);
		if (gateId === null) {
			continue;
		}
		gateMap[gateId] = valueSelector(gate);
	}
	return gateMap;
};
const selectedGateIds = selectedGateIdsFromSummary
	? selectedGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows(() => true)
		: Object.keys(gateStatusByIdFromSummary ?? {}));
const selectedGateIdsLabel = selectedGateIds.length > 0 ? selectedGateIds.join(', ') : 'none';
const failedGateIds = failedGateIdsFromSummary
	? failedGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows((gate) => gate.status === 'fail')
		: Object.entries(gateStatusByIdFromSummary ?? {}).filter(([, status]) => status === 'fail').map(([gateId]) => gateId));
const failedGateIdsLabel = failedGateIds.length > 0 ? failedGateIds.join(', ') : 'none';
const failedGateExitCodesFromSummary = normalizeIntegerList(summary.failedGateExitCodes, normalizeNonNegativeInteger);
const passedGateIds = passedGateIdsFromSummary
	? passedGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows((gate) => gate.status === 'pass')
		: Object.entries(gateStatusByIdFromSummary ?? {}).filter(([, status]) => status === 'pass').map(([gateId]) => gateId));
const passedGateIdsLabel = passedGateIds.length > 0 ? passedGateIds.join(', ') : 'none';
const skippedGateIds = skippedGateIdsFromSummary
	? skippedGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows((gate) => gate.status === 'skip')
		: Object.entries(gateStatusByIdFromSummary ?? {}).filter(([, status]) => status === 'skip').map(([gateId]) => gateId));
const skippedGateIdsLabel = skippedGateIds.length > 0 ? skippedGateIds.join(', ') : 'none';
const executedGateIds = executedGateIdsFromSummary
	? executedGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows((gate) => gate.status === 'pass' || gate.status === 'fail')
		: Object.entries(gateStatusByIdFromSummary ?? {}).filter(([, status]) => status === 'pass' || status === 'fail').map(([gateId]) => gateId));
const executedGateIdsLabel = executedGateIds.length > 0 ? executedGateIds.join(', ') : 'none';
const executedGateCount = normalizeNonNegativeInteger(summary.executedGateCount) ?? executedGateIdsFromSummary?.length ?? executedGateIds.length;
const gateCount = normalizeNonNegativeInteger(summary.gateCount) ?? selectedGateIdsFromSummary?.length ?? selectedGateIds.length ?? gates.length;
const notRunGateIds = notRunGateIdsFromSummary
	? notRunGateIdsFromSummary
	: (gates.length > 0
		? gateIdsFromRows((gate) => gate.status === 'not-run')
		: Object.entries(gateStatusByIdFromSummary ?? {}).filter(([, status]) => status === 'not-run').map(([gateId]) => gateId));
const notRunGateIdsLabel = notRunGateIds.length > 0 ? notRunGateIds.join(', ') : 'none';
const knownGateIdsForMaps = uniqueGateIds([
	...selectedGateIds,
	...passedGateIds,
	...failedGateIds,
	...skippedGateIds,
	...notRunGateIds,
	...executedGateIds,
	...gateIdsFromRows(() => true),
]);
const applyKnownGateDefaults = (mapValue, defaultValue) => {
	const normalizedMap = { ...mapValue };
	for (const gateId of knownGateIdsForMaps) {
		if (!(gateId in normalizedMap)) {
			normalizedMap[gateId] = defaultValue;
		}
	}
	return normalizedMap;
};
const buildStatusMapFromGateIdLists = () => {
	const statusPriority = { 'not-run': 1, skip: 2, pass: 3, fail: 4 };
	const statusByGateId = {};
	const assignStatus = (gateIds, status) => {
		for (const gateId of gateIds) {
			if (typeof gateId !== 'string' || gateId.length === 0) {
				continue;
			}
			const currentStatus = statusByGateId[gateId];
			if (!currentStatus || statusPriority[status] > statusPriority[currentStatus]) {
				statusByGateId[gateId] = status;
			}
		}
	};
	assignStatus(notRunGateIds, 'not-run');
	assignStatus(skippedGateIds, 'skip');
	assignStatus(passedGateIds, 'pass');
	assignStatus(failedGateIds, 'fail');
	return statusByGateId;
};
const gateStatusById = gateStatusByIdFromSummary
	? gateStatusByIdFromSummary
	: (gates.length > 0
		? gateMapFromRows((gate) => gate.status ?? 'unknown')
		: buildStatusMapFromGateIdLists());
const buildGateExitCodeMapFromSparseData = () => {
	const gateExitCodeMap = {};
	const allGateIds = [];
	for (const gateId of [...selectedGateIds, ...failedGateIds, ...passedGateIds, ...skippedGateIds, ...notRunGateIds]) {
		if (typeof gateId !== 'string' || gateId.length === 0 || allGateIds.includes(gateId)) {
			continue;
		}
		allGateIds.push(gateId);
	}
	for (const gateId of allGateIds) {
		gateExitCodeMap[gateId] = null;
	}
	if (failedGateExitCodesFromSummary !== null) {
		for (let i = 0; i < failedGateIds.length; i += 1) {
			const failedGateId = failedGateIds[i];
			const failedExitCode = failedGateExitCodesFromSummary[i];
			if (typeof failedGateId !== 'string' || failedGateId.length === 0) {
				continue;
			}
			const normalizedFailedExitCode = normalizeNonNegativeInteger(failedExitCode);
			if (normalizedFailedExitCode !== null) {
				gateExitCodeMap[failedGateId] = normalizedFailedExitCode;
			}
		}
	}
	const summaryFailedGateId = normalizeNonEmptyString(summary.failedGateId);
	const summaryFailedGateExitCode = normalizeNonNegativeInteger(summary.failedGateExitCode);
	if (summaryFailedGateId && summaryFailedGateExitCode !== null) {
		gateExitCodeMap[summaryFailedGateId] = summaryFailedGateExitCode;
	}
	return gateExitCodeMap;
};
const gateExitCodeByIdFromSummary = normalizeGateIntegerMap(summary.gateExitCodeById, { allowNullValues: true, normalizeValue: normalizeNonNegativeInteger });
const gateExitCodeById = gateExitCodeByIdFromSummary
	? applyKnownGateDefaults(gateExitCodeByIdFromSummary, null)
	: (gates.length > 0
		? gateMapFromRows((gate) => normalizeNonNegativeInteger(gate.exitCode) ?? null)
		: buildGateExitCodeMapFromSparseData());
const failedGateExitCodes = failedGateIds
	.map((gateId, index) => {
		const explicitExitCode = failedGateExitCodesFromSummary?.[index];
		if (explicitExitCode !== null && explicitExitCode !== undefined) {
			return explicitExitCode;
		}
		const mappedExitCode = gateExitCodeById[gateId];
		return mappedExitCode === null || mappedExitCode === undefined ? null : mappedExitCode;
	})
	.filter((exitCode) => exitCode !== null && exitCode !== undefined);
const failedGateExitCodesLabel = failedGateExitCodes.length > 0 ? failedGateExitCodes.join(', ') : 'none';
const gateRetryCountByIdFromSummary = normalizeGateRetryCountMap(summary.gateRetryCountById);
const buildRetryCountMapFromSparseData = () => {
	const retryCountByGateId = {};
	const allGateIds = uniqueGateIds([
		...selectedGateIds,
		...passedGateIds,
		...failedGateIds,
		...skippedGateIds,
		...notRunGateIds,
		...executedGateIds,
		...(retriedGateIdsFromSummary ?? []),
	]);
	for (const gateId of allGateIds) {
		retryCountByGateId[gateId] = 0;
	}
	if (retriedGateIdsFromSummary) {
		for (const gateId of retriedGateIdsFromSummary) {
			retryCountByGateId[gateId] = 1;
		}
	}
	return retryCountByGateId;
};
const gateRetryCountById = gateRetryCountByIdFromSummary
	? applyKnownGateDefaults(gateRetryCountByIdFromSummary, 0)
	: (gates.length > 0
		? gateMapFromRows((gate) => normalizeNonNegativeInteger(gate.retryCount) ?? 0)
		: buildRetryCountMapFromSparseData());
const gateDurationSecondsByIdFromSummary = normalizeGateIntegerMap(summary.gateDurationSecondsById, { allowNullValues: false, normalizeValue: normalizeNonNegativeInteger });
const gateDurationSecondsById = gateDurationSecondsByIdFromSummary
	? applyKnownGateDefaults(gateDurationSecondsByIdFromSummary, 0)
	: gateMapFromRows((gate) => normalizeNonNegativeInteger(gate.durationSeconds) ?? 0);
const gateNotRunReasonByIdFromSummary = normalizeGateReasonMap(summary.gateNotRunReasonById);
const gateNotRunReasonById = gateNotRunReasonByIdFromSummary
	? applyKnownGateDefaults(gateNotRunReasonByIdFromSummary, null)
	: gateMapFromRows((gate) => typeof gate.notRunReason === 'string' ? gate.notRunReason : null);
const gateAttemptCountByIdFromSummary = normalizeGateIntegerMap(summary.gateAttemptCountById, { allowNullValues: false, normalizeValue: normalizeNonNegativeInteger });
const gateAttemptCountById = gateAttemptCountByIdFromSummary
	? applyKnownGateDefaults(gateAttemptCountByIdFromSummary, 0)
	: gateMapFromRows((gate) => normalizeNonNegativeInteger(gate.attempts) ?? 0);
const toIntegerOrNull = normalizeInteger;
const normalizeSummaryTimestamp = (value) => {
	if (typeof value !== 'string') {
		return null;
	}
	return /^\d{8}T\d{6}Z$/.test(value) ? value : null;
};
const timestampToEpochSeconds = (timestamp) => {
	const normalizedTimestamp = normalizeSummaryTimestamp(timestamp);
	if (!normalizedTimestamp) {
		return null;
	}
	const year = Number.parseInt(normalizedTimestamp.slice(0, 4), 10);
	const month = Number.parseInt(normalizedTimestamp.slice(4, 6), 10);
	const day = Number.parseInt(normalizedTimestamp.slice(6, 8), 10);
	const hour = Number.parseInt(normalizedTimestamp.slice(9, 11), 10);
	const minute = Number.parseInt(normalizedTimestamp.slice(11, 13), 10);
	const second = Number.parseInt(normalizedTimestamp.slice(13, 15), 10);
	const millisecondsSinceEpoch = Date.UTC(year, month - 1, day, hour, minute, second);
	return Number.isFinite(millisecondsSinceEpoch) ? Math.floor(millisecondsSinceEpoch / 1000) : null;
};
const computeRetryBackoffSeconds = (retryCount) => {
	const normalizedRetryCount = toIntegerOrNull(retryCount);
	if (normalizedRetryCount === null || normalizedRetryCount <= 0) {
		return 0;
	}
	return 2 ** normalizedRetryCount - 1;
};
const sumIntegerValues = (values) => values.reduce((total, value) => {
	const normalizedValue = toIntegerOrNull(value);
	if (normalizedValue === null) {
		return total;
	}
	return total + normalizedValue;
}, 0);
const retriedGateIds = retriedGateIdsFromSummary
	? retriedGateIdsFromSummary
	: Object.entries(gateRetryCountById)
		.filter(([gateId, retryCount]) => gateId.length > 0 && (toIntegerOrNull(retryCount) ?? 0) > 0)
		.map(([gateId]) => gateId);
const nonSuccessGateIds = nonSuccessGateIdsFromSummary
	? nonSuccessGateIdsFromSummary
	: (() => {
		if (gates.length > 0) {
			return gateIdsFromRows((gate) => gate.status !== 'pass');
		}
		if (selectedGateIds.length > 0) {
			return selectedGateIds.filter((gateId) => {
				const status = gateStatusById[gateId];
				return status !== undefined && status !== 'pass';
			});
		}
		return uniqueGateIds([...failedGateIds, ...skippedGateIds, ...notRunGateIds]);
	})();
const attentionGateIds = attentionGateIdsFromSummary
	? attentionGateIdsFromSummary
	: (() => {
		if (selectedGateIds.length > 0) {
			return selectedGateIds.filter((gateId) => nonSuccessGateIds.includes(gateId) || retriedGateIds.includes(gateId));
		}
		return uniqueGateIds([...nonSuccessGateIds, ...retriedGateIds]);
	})();
const retriedGateIdsLabel = retriedGateIds.length > 0 ? retriedGateIds.join(', ') : 'none';
const nonSuccessGateIdsLabel = nonSuccessGateIds.length > 0 ? nonSuccessGateIds.join(', ') : 'none';
const attentionGateIdsLabel = attentionGateIds.length > 0 ? attentionGateIds.join(', ') : 'none';
const retriedGateCount = normalizeNonNegativeInteger(summary.retriedGateCount) ?? retriedGateIds.length;
const totalRetryCount = normalizeNonNegativeInteger(summary.totalRetryCount) ?? sumIntegerValues(Object.values(gateRetryCountById));
const totalRetryBackoffSeconds = normalizeNonNegativeInteger(summary.totalRetryBackoffSeconds) ?? Object.values(gateRetryCountById).reduce((total, retryCount) => total + computeRetryBackoffSeconds(retryCount), 0);
const executedDurationSeconds = normalizeNonNegativeInteger(summary.executedDurationSeconds) ?? executedGateIds.reduce((total, gateId) => {
	const durationSeconds = toIntegerOrNull(gateDurationSecondsById[gateId]) ?? 0;
	return total + durationSeconds;
}, 0);
const averageExecutedDurationSeconds = normalizeNonNegativeInteger(summary.averageExecutedDurationSeconds) ?? (executedGateCount > 0 ? Math.floor(executedDurationSeconds / executedGateCount) : null);
const retryRatePercent = normalizeNonNegativeInteger(summary.retryRatePercent) ?? (executedGateCount > 0 ? Math.floor((retriedGateCount * 100) / executedGateCount) : null);
const passRatePercent = normalizeNonNegativeInteger(summary.passRatePercent) ?? (executedGateCount > 0 ? Math.floor((passedGateCount * 100) / executedGateCount) : null);
const retryBackoffSharePercent = normalizeNonNegativeInteger(summary.retryBackoffSharePercent) ?? (executedDurationSeconds > 0 ? Math.floor((totalRetryBackoffSeconds * 100) / executedDurationSeconds) : null);
const executedGateDurations = executedGateIds.map((gateId) => ({ gateId, durationSeconds: toIntegerOrNull(gateDurationSecondsById[gateId]) ?? 0 }));
const slowestExecutedGate = executedGateDurations.reduce((slowestGate, gateDuration) => {
	if (!slowestGate) {
		return gateDuration;
	}
	return gateDuration.durationSeconds > slowestGate.durationSeconds ? gateDuration : slowestGate;
}, null);
const fastestExecutedGate = executedGateDurations.reduce((fastestGate, gateDuration) => {
	if (!fastestGate) {
		return gateDuration;
	}
	return gateDuration.durationSeconds < fastestGate.durationSeconds ? gateDuration : fastestGate;
}, null);
const failedGateId = normalizeNonEmptyString(summary.failedGateId) ?? failedGateIds[0] ?? 'none';
const failedGateExitCode = normalizeNonNegativeInteger(summary.failedGateExitCode) ?? failedGateExitCodes[0] ?? 'none';
const blockedByGateId = normalizeNonEmptyString(summary.blockedByGateId) ?? (() => {
	for (const reason of Object.values(gateNotRunReasonById)) {
		if (typeof reason === 'string' && reason.startsWith('blocked-by-fail-fast:')) {
			return reason.slice('blocked-by-fail-fast:'.length);
		}
	}
	return 'none';
})();
const startedAt = normalizeSummaryTimestamp(summary.startedAt) ?? (() => {
	let earliestTimestamp = null;
	for (const gate of gates) {
		const gateStartedAt = normalizeSummaryTimestamp(gate.startedAt);
		if (!gateStartedAt) {
			continue;
		}
		if (earliestTimestamp === null || gateStartedAt < earliestTimestamp) {
			earliestTimestamp = gateStartedAt;
		}
	}
	return earliestTimestamp;
})();
const completedAt = normalizeSummaryTimestamp(summary.completedAt) ?? (() => {
	let latestTimestamp = null;
	for (const gate of gates) {
		const gateCompletedAt = normalizeSummaryTimestamp(gate.completedAt);
		if (!gateCompletedAt) {
			continue;
		}
		if (latestTimestamp === null || gateCompletedAt > latestTimestamp) {
			latestTimestamp = gateCompletedAt;
		}
	}
	return latestTimestamp;
})();
const totalDurationSeconds = (() => {
	const explicitTotalDurationSeconds = normalizeNonNegativeInteger(summary.totalDurationSeconds);
	if (explicitTotalDurationSeconds !== null) {
		return explicitTotalDurationSeconds;
	}
	const startedAtEpochSeconds = timestampToEpochSeconds(startedAt);
	const completedAtEpochSeconds = timestampToEpochSeconds(completedAt);
	if (startedAtEpochSeconds !== null && completedAtEpochSeconds !== null && completedAtEpochSeconds >= startedAtEpochSeconds) {
		return completedAtEpochSeconds - startedAtEpochSeconds;
	}
	const derivedDurationFromGateMap = sumIntegerValues(Object.values(gateDurationSecondsById));
	if (derivedDurationFromGateMap > 0 || gateCount > 0) {
		return derivedDurationFromGateMap;
	}
	return 'unknown';
})();
const hasOutcomeEvidence = gates.length > 0
	|| gateStatusByIdFromSummary !== null
	|| passedGateIdsFromSummary !== null
	|| failedGateIdsFromSummary !== null
	|| skippedGateIdsFromSummary !== null
	|| notRunGateIdsFromSummary !== null
	|| passedGateCountFromSummary !== null
	|| failedGateCountFromSummary !== null
	|| skippedGateCountFromSummary !== null
	|| notRunGateCountFromSummary !== null
	|| rawStatusCountsHasValues;
const explicitDryRun = normalizeBoolean(summary.dryRun);
const explicitExitReason = normalizeKnownValue(summary.exitReason, ['dry-run', 'success', 'fail-fast', 'completed-with-failures']);
const explicitRunClassification = normalizeKnownValue(summary.runClassification, ['dry-run', 'success-no-retries', 'success-with-retries', 'failed-fail-fast', 'failed-continued']);
const exitReasonForRunClassification = (runClassification) => {
	switch (runClassification) {
		case 'dry-run':
			return 'dry-run';
		case 'success-no-retries':
		case 'success-with-retries':
			return 'success';
		case 'failed-fail-fast':
			return 'fail-fast';
		case 'failed-continued':
			return 'completed-with-failures';
		default:
			return null;
	}
};
const exitReasonFromRunClassification = exitReasonForRunClassification(explicitRunClassification);
const runClassificationFromSummary = explicitRunClassification !== null
	&& explicitExitReason !== null
	&& exitReasonFromRunClassification !== explicitExitReason
	? null
	: explicitRunClassification;
const explicitDryRunFromSummary = explicitDryRun !== null
	&& (
		(explicitExitReason !== null && explicitDryRun !== (explicitExitReason === 'dry-run'))
		|| (explicitExitReason === null && runClassificationFromSummary !== null && explicitDryRun !== (runClassificationFromSummary === 'dry-run'))
	)
	? null
	: explicitDryRun;
const successForExplicitExitReason = (() => {
	switch (explicitExitReason) {
		case 'dry-run':
		case 'success':
			return true;
		case 'fail-fast':
		case 'completed-with-failures':
			return false;
		default:
			return null;
	}
})();
const successForRunClassification = (() => {
	switch (runClassificationFromSummary) {
		case 'dry-run':
		case 'success-no-retries':
		case 'success-with-retries':
			return true;
		case 'failed-fail-fast':
		case 'failed-continued':
			return false;
		default:
			return null;
	}
})();
const explicitSuccessFromSummary = normalizeBoolean(summary.success);
const explicitSuccess = explicitSuccessFromSummary !== null
	&& (
		(successForExplicitExitReason !== null && explicitSuccessFromSummary !== successForExplicitExitReason)
		|| (successForExplicitExitReason === null && successForRunClassification !== null && explicitSuccessFromSummary !== successForRunClassification)
		|| (successForExplicitExitReason === null && successForRunClassification === null && explicitDryRunFromSummary === true && explicitSuccessFromSummary !== true)
	)
	? null
	: explicitSuccessFromSummary;
const successValue = explicitSuccess !== null
	? explicitSuccess
	: (explicitDryRunFromSummary === true
		? true
		: (successForExplicitExitReason !== null
			? successForExplicitExitReason
			: (successForRunClassification !== null
				? successForRunClassification
				: (hasOutcomeEvidence ? failedGateCount === 0 : 'unknown'))));
const derivedExitReason = explicitExitReason ?? exitReasonFromRunClassification ?? (() => {
	if (explicitDryRun === true) {
		return 'dry-run';
	}
	if (successValue === 'unknown') {
		return 'unknown';
	}
	if (successValue === true) {
		return 'success';
	}
	if (blockedByGateId !== 'none') {
		return 'fail-fast';
	}
	return 'completed-with-failures';
})();
const derivedRunClassification = runClassificationFromSummary ?? (() => {
	switch (derivedExitReason) {
		case 'dry-run':
			return 'dry-run';
		case 'success':
			return totalRetryCount > 0 ? 'success-with-retries' : 'success-no-retries';
		case 'fail-fast':
			return 'failed-fail-fast';
		case 'completed-with-failures':
			return 'failed-continued';
		default:
			return 'unknown';
	}
})();
const dryRunValue = explicitDryRunFromSummary !== null
	? explicitDryRunFromSummary
	: (derivedExitReason === 'unknown' ? 'unknown' : derivedExitReason === 'dry-run');
const continueOnFailureForExplicitExitReason = (() => {
	switch (explicitExitReason) {
		case 'completed-with-failures':
			return true;
		case 'fail-fast':
			return false;
		default:
			return null;
	}
})();
const continueOnFailureForRunClassification = (() => {
	switch (runClassificationFromSummary) {
		case 'failed-continued':
			return true;
		case 'failed-fail-fast':
			return false;
		default:
			return null;
	}
})();
const explicitContinueOnFailureFromSummary = normalizeBoolean(summary.continueOnFailure);
const explicitContinueOnFailure = explicitContinueOnFailureFromSummary !== null
	&& (
		(continueOnFailureForExplicitExitReason !== null && explicitContinueOnFailureFromSummary !== continueOnFailureForExplicitExitReason)
		|| (continueOnFailureForExplicitExitReason === null && continueOnFailureForRunClassification !== null && explicitContinueOnFailureFromSummary !== continueOnFailureForRunClassification)
	)
	? null
	: explicitContinueOnFailureFromSummary;
const continueOnFailureValue = explicitContinueOnFailure !== null
	? explicitContinueOnFailure
	: (derivedExitReason === 'completed-with-failures'
		? true
		: (derivedExitReason === 'fail-fast' || derivedExitReason === 'success' || derivedExitReason === 'dry-run' ? false : 'unknown'));
const gateNotRunReasonEntries = Object.entries(gateNotRunReasonById).filter(([, reason]) => typeof reason === 'string' && reason.length > 0);
const gateNotRunReasonMapLabel = gateNotRunReasonEntries.length > 0 ? JSON.stringify(Object.fromEntries(gateNotRunReasonEntries)) : 'none';
const sanitizeCell = (value) => String(value).replace(/\r?\n/g, ' ').replace(/\|/g, '\\|');
const sanitizeCodeCell = (value) => sanitizeCell(value).replace(/`/g, '\\`');
const gateRows = gates.map((gate) => {
	const gateId = normalizeGateIdValue(gate.id) ?? 'unknown';
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
	`**Success:** ${successValue}`,
	`**Summary schema version:** ${summary.schemaVersion ?? 'unknown'}`,
	`**Run ID:** ${sanitizeCell(summary.runId ?? 'unknown')}`,
	`**Run classification:** ${sanitizeCell(derivedRunClassification)}`,
	`**Result signature algorithm:** ${sanitizeCell(summary.resultSignatureAlgorithm ?? 'unknown')}`,
	`**Result signature:** ${sanitizeCell(summary.resultSignature ?? 'unknown')}`,
	`**Exit reason:** ${sanitizeCell(derivedExitReason)}`,
	`**Invocation:** ${sanitizeCell(summary.invocation ?? 'unknown')}`,
	`**Continue on failure:** ${continueOnFailureValue}`,
	`**Dry run:** ${dryRunValue}`,
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
	`**Total retries:** ${totalRetryCount}`,
	`**Total retry backoff:** ${totalRetryBackoffSeconds}s`,
	`**Retried gate count:** ${retriedGateCount}`,
	`**Retried gates:** ${sanitizeCell(retriedGateIdsLabel)}`,
	`**Executed gates list:** ${sanitizeCell(executedGateIdsLabel)}`,
	`**Passed gates list:** ${sanitizeCell(passedGateIdsLabel)}`,
	`**Skipped gates list:** ${sanitizeCell(skippedGateIdsLabel)}`,
	`**Retry rate (executed gates):** ${retryRatePercent === null ? 'n/a' : `${retryRatePercent}%`}`,
	`**Retry backoff share (executed duration):** ${retryBackoffSharePercent === null ? 'n/a' : `${retryBackoffSharePercent}%`}`,
	`**Pass rate (executed gates):** ${passRatePercent === null ? 'n/a' : `${passRatePercent}%`}`,
	`**Executed duration total:** ${executedDurationSeconds}s`,
	`**Executed duration average:** ${averageExecutedDurationSeconds === null ? 'n/a' : `${averageExecutedDurationSeconds}s`}`,
	`**Slowest executed gate:** ${sanitizeCell(summary.slowestExecutedGateId ?? slowestExecutedGate?.gateId ?? 'n/a')}`,
	`**Slowest executed gate duration:** ${summary.slowestExecutedGateDurationSeconds === null || summary.slowestExecutedGateDurationSeconds === undefined ? (slowestExecutedGate ? `${slowestExecutedGate.durationSeconds}s` : 'n/a') : `${summary.slowestExecutedGateDurationSeconds}s`}`,
	`**Fastest executed gate:** ${sanitizeCell(summary.fastestExecutedGateId ?? fastestExecutedGate?.gateId ?? 'n/a')}`,
	`**Fastest executed gate duration:** ${summary.fastestExecutedGateDurationSeconds === null || summary.fastestExecutedGateDurationSeconds === undefined ? (fastestExecutedGate ? `${fastestExecutedGate.durationSeconds}s` : 'n/a') : `${summary.fastestExecutedGateDurationSeconds}s`}`,
	`**Selected gates:** ${sanitizeCell(selectedGateIdsLabel)}`,
	`**Failed gates list:** ${sanitizeCell(failedGateIdsLabel)}`,
	`**Failed gate exit codes:** ${sanitizeCell(failedGateExitCodesLabel)}`,
	`**Not-run gates list:** ${sanitizeCell(notRunGateIdsLabel)}`,
	`**Non-success gates list:** ${sanitizeCell(nonSuccessGateIdsLabel)}`,
	`**Attention gates list:** ${sanitizeCell(attentionGateIdsLabel)}`,
	`**Blocked by gate:** ${sanitizeCell(blockedByGateId)}`,
	`**Failed gate:** ${sanitizeCell(failedGateId)}`,
	`**Failed gate exit code:** ${sanitizeCell(failedGateExitCode)}`,
	`**Total duration:** ${totalDurationSeconds === 'unknown' ? 'unknown' : `${totalDurationSeconds}s`}`,
	`**Started:** ${startedAt ?? 'unknown'}`,
	`**Completed:** ${completedAt ?? 'unknown'}`,
];

if (summary.logFile) {
	lines.push(`**Log file:** \`${sanitizeInlineCode(summary.logFile)}\``);
}

if (typeof summary.schemaVersion === 'number' && summary.schemaVersion > supportedSchemaVersion) {
	lines.push(`**Schema warning:** summary schema version ${summary.schemaVersion} is newer than supported ${supportedSchemaVersion}; some fields may be omitted.`);
}

fs.appendFileSync(summaryOutputPath, lines.join('\n') + '\n');
NODE
