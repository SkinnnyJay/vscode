/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import test from 'node:test';
import { ClaudeAdapter, SpawnedClaudeProcess } from '../src/providers/claude-adapter.js';
import { ProviderStreamChunk } from '../src/providers/adapter-types.js';

function createFakeProcess() {
	const stdout = new EventEmitter();
	const stderr = new EventEmitter();
	const processEmitter = new EventEmitter() as SpawnedClaudeProcess;
	processEmitter.stdout = stdout as unknown as NodeJS.ReadableStream;
	processEmitter.stderr = stderr as unknown as NodeJS.ReadableStream;
	processEmitter.kill = () => {
		processEmitter.emit('close', 130);
		return true;
	};
	return { processEmitter, stdout, stderr };
}

test('ClaudeAdapter streams chunks and resolves aggregated output', async () => {
	const { processEmitter, stdout, stderr } = createFakeProcess();
	const adapter = new ClaudeAdapter({
		spawnProcess: () => {
			setImmediate(() => {
				stdout.emit('data', Buffer.from('alpha '));
				stderr.emit('data', Buffer.from('note '));
				stdout.emit('data', Buffer.from('beta'));
				processEmitter.emit('close', 0);
			});
			return processEmitter;
		}
	});

	/** @type {ProviderStreamChunk[]} */
	const chunks = [];
	const response = await adapter.stream(
		{
			modelId: 'claude-sonnet',
			prompt: 'Summarize'
		},
		(chunk) => chunks.push(chunk)
	);

	assert.equal(response.output, 'alpha beta');
	assert.equal(response.stderr, 'note ');
	assert.equal(response.exitCode, 0);
	assert.deepEqual(chunks.map((chunk) => chunk.stream), ['stdout', 'stderr', 'stdout']);
});

test('ClaudeAdapter supports cancellation via AbortSignal', async () => {
	const { processEmitter } = createFakeProcess();
	const abortController = new AbortController();
	let cancelledChunkSeen = false;
	const adapter = new ClaudeAdapter({
		spawnProcess: () => processEmitter
	});

	const streamPromise = adapter.stream(
		{
			modelId: 'claude-sonnet',
			prompt: 'Long run'
		},
		(chunk) => {
			if (chunk.stream === 'system' && chunk.chunk === 'cancelled') {
				cancelledChunkSeen = true;
			}
		},
		abortController.signal
	);

	abortController.abort();
	await assert.rejects(streamPromise, /Claude exited with code 130/);
	assert.equal(cancelledChunkSeen, true);
});
