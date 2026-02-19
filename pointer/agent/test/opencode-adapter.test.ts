/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import test from 'node:test';
import { OpenCodeAdapter, SpawnedOpenCodeProcess } from '../src/providers/opencode-adapter.js';

function createFakeProcess() {
	const stdout = new EventEmitter();
	const stderr = new EventEmitter();
	const processEmitter = new EventEmitter() as SpawnedOpenCodeProcess;
	processEmitter.stdout = stdout as unknown as NodeJS.ReadableStream;
	processEmitter.stderr = stderr as unknown as NodeJS.ReadableStream;
	processEmitter.kill = () => {
		processEmitter.emit('close', 130);
		return true;
	};
	return { processEmitter, stdout, stderr };
}

test('OpenCodeAdapter sends --output json in JSON mode', async () => {
	const { processEmitter, stdout } = createFakeProcess();
	/** @type {readonly string[] | undefined} */
	let recordedArgs;
	const adapter = new OpenCodeAdapter({
		spawnProcess: (_command, args) => {
			recordedArgs = args;
			setImmediate(() => {
				stdout.emit('data', Buffer.from('{"ok":true}'));
				processEmitter.emit('close', 0);
			});
			return processEmitter;
		}
	});

	const response = await adapter.stream(
		{
			modelId: 'opencode-large',
			prompt: 'Respond in json',
			outputFormat: 'json'
		},
		() => {}
	);

	assert.equal(response.output, '{"ok":true}');
	assert.deepEqual(recordedArgs, ['--model', 'opencode-large', '--prompt', 'Respond in json', '--output', 'json']);
});

test('OpenCodeAdapter supports explicit table mode output argument', async () => {
	const { processEmitter, stdout } = createFakeProcess();
	/** @type {readonly string[] | undefined} */
	let recordedArgs;
	const adapter = new OpenCodeAdapter({
		spawnProcess: (_command, args) => {
			recordedArgs = args;
			setImmediate(() => {
				stdout.emit('data', Buffer.from('TABLE'));
				processEmitter.emit('close', 0);
			});
			return processEmitter;
		}
	});

	await adapter.stream(
		{
			modelId: 'opencode-large',
			prompt: 'Respond in table',
			outputFormat: 'table'
		},
		() => {}
	);

	assert.deepEqual(recordedArgs, ['--model', 'opencode-large', '--prompt', 'Respond in table', '--output', 'table']);
});
