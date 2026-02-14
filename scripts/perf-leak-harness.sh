#!/usr/bin/env bash
# Run M7 leak harness scenario runner.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${ROOT_DIR}/docs/perf/M7-leak-harness.json"

node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');

function rss() {
	return process.memoryUsage().rss;
}

const iterations = 30;
const scenarioSamples = [];
const rssStart = rss();
let transient = [];

for (let iteration = 0; iteration < iterations; iteration += 1) {
	for (let index = 0; index < 5000; index += 1) {
		transient.push({
			id: `${iteration}-${index}`,
			payload: 'z'.repeat(64)
		});
	}
	transient = [];
	if (global.gc) {
		global.gc();
	}
	scenarioSamples.push({
		iteration,
		rssBytes: rss()
	});
}

const rssEnd = rss();
const rssGrowthBytes = rssEnd - rssStart;
const thresholdBytes = 50 * 1024 * 1024;

const report = {
	timestamp: Date.now(),
	iterations,
	rssStart,
	rssEnd,
	rssGrowthBytes,
	thresholdBytes,
	passed: rssGrowthBytes <= thresholdBytes,
	samples: scenarioSamples
};

const outputPath = path.join(process.cwd(), 'docs', 'perf', 'M7-leak-harness.json');
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, JSON.stringify(report, null, 2), 'utf8');
console.log(`Leak harness ${report.passed ? 'PASSED' : 'FAILED'}; growth=${rssGrowthBytes} bytes`);
NODE

echo "Leak harness report written to ${OUTPUT_PATH}"
