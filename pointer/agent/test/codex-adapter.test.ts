/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import test from 'node:test';
import { CodexAdapter, SpawnedProcess } from '../src/providers/codex-adapter.js';
import { ProviderStreamChunk } from '../src/providers/adapter-types.js';

function createFakeProcess() {
	const stdout = new EventEmitter();
	const stderr = new EventEmitter();
	const processEmitter = new EventEmitter() as SpawnedProcess;
	processEmitter.stdout = stdout as unknown as NodeJS.ReadableStream;
	processEmitter.stderr = stderr as unknown as NodeJS.ReadableStream;
	processEmitter.kill = () => {
		processEmitter.emit('close', 130);
		return true;
	};
	return { processEmitter, stdout, stderr };
}

test('CodexAdapter streams stdout/stderr chunks and resolves response', async () => {
	const { processEmitter, stdout, stderr } = createFakeProcess();
	const adapter = new CodexAdapter({
		spawnProcess: () => {
			setImmediate(() => {
				stdout.emit('data', Buffer.from('hello '));
				stderr.emit('data', Buffer.from('warn '));
				stdout.emit('data', Buffer.from('world'));
				processEmitter.emit('close', 0);
			});
			return processEmitter;
		}
	});

	/** @type {ProviderStreamChunk[]} */
	const chunks = [];
	const response = await adapter.stream(
		{
			modelId: 'gpt',
			prompt: 'Say hello'
		},
		(chunk) => chunks.push(chunk)
	);

	assert.equal(response.output, 'hello world');
	assert.equal(response.stderr, 'warn ');
	assert.equal(response.exitCode, 0);
	assert.deepEqual(
		chunks.map((chunk) => chunk.stream),
		['stdout', 'stderr', 'stdout']
	);
});

test('CodexAdapter supports cancellation through AbortSignal', async () => {
	const { processEmitter } = createFakeProcess();
	const abortController = new AbortController();
	let cancelledChunkSeen = false;
	const adapter = new CodexAdapter({
		spawnProcess: () => processEmitter
	});

	const streamPromise = adapter.stream(
		{
			modelId: 'gpt',
			prompt: 'Long running prompt'
		},
		(chunk) => {
			if (chunk.stream === 'system' && chunk.chunk === 'cancelled') {
				cancelledChunkSeen = true;
			}
		},
		abortController.signal
	);

	abortController.abort();

	await assert.rejects(streamPromise, /Codex exited with code 130/);
	assert.equal(cancelledChunkSeen, true);
});
