#!/usr/bin/env bash
# Capture M7 memory baseline snapshots for key scenarios.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${ROOT_DIR}/docs/perf/M7-memory-snapshots.json"

node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');

function snapshot(label) {
	const memory = process.memoryUsage();
	return {
		label,
		timestamp: Date.now(),
		rssBytes: memory.rss,
		heapUsedBytes: memory.heapUsed,
		heapTotalBytes: memory.heapTotal
	};
}

const snapshots = [];
snapshots.push(snapshot('baseline-start'));

const chatBuffers = [];
for (let i = 0; i < 5000; i += 1) {
	chatBuffers.push(`chat-${i}-${'x'.repeat(128)}`);
}
snapshots.push(snapshot('after-chat-simulation'));

const indexBuffers = [];
for (let i = 0; i < 10000; i += 1) {
	indexBuffers.push({
		path: `src/file-${i}.ts`,
		content: 'y'.repeat(256)
	});
}
snapshots.push(snapshot('after-indexer-simulation'));

chatBuffers.length = 0;
indexBuffers.length = 0;
if (global.gc) {
	global.gc();
}
snapshots.push(snapshot('after-release'));

const outputPath = path.join(process.cwd(), 'docs', 'perf', 'M7-memory-snapshots.json');
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, JSON.stringify(snapshots, null, 2), 'utf8');
console.log(`Wrote ${snapshots.length} memory snapshots to ${outputPath}`);
NODE

echo "Memory baseline written to ${OUTPUT_PATH}"
