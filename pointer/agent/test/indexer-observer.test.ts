/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { IndexerObserver } from '../src/perf/indexer-observer.js';

test('IndexerObserver captures and flushes samples when enabled', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-indexer-observer-'));
	const observer = new IndexerObserver({
		workspacePath: workspace,
		enabled: true
	});

	observer.captureSample(1);
	assert.equal(observer.listSamples().length, 1);
	await observer.flushToDisk();

	const outputPath = path.join(workspace, 'docs', 'perf', 'indexer-observer.log.json');
	const exists = await fs.readFile(outputPath, 'utf8');
	assert.match(exists, /rssBytes/);
	await fs.rm(workspace, { recursive: true, force: true });
});

test('IndexerObserver does not persist samples when disabled', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-indexer-observer-'));
	const observer = new IndexerObserver({
		workspacePath: workspace,
		enabled: false
	});

	observer.captureSample(1);
	assert.equal(observer.listSamples().length, 0);
	await observer.flushToDisk();

	await assert.rejects(async () => fs.readFile(path.join(workspace, 'docs', 'perf', 'indexer-observer.log.json'), 'utf8'));
	await fs.rm(workspace, { recursive: true, force: true });
});
