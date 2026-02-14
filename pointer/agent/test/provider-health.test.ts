/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { checkProviderHealth, CommandRunner, testProvider } from '../src/providers/health.js';

test('checkProviderHealth returns healthy response when command succeeds', async () => {
	const runner: CommandRunner = {
		async run() {
			return { stdout: 'codex 1.2.3\n', stderr: '' };
		}
	};

	const result = await checkProviderHealth(
		{
			providerId: 'codex',
			binaryName: 'codex'
		},
		runner
	);

	assert.equal(result.status, 'healthy');
	assert.match(result.detail, /codex 1.2.3/);
});

test('checkProviderHealth classifies missing binary and includes install hint', async () => {
	const runner: CommandRunner = {
		async run() {
			const error = new Error('spawn codex ENOENT') as Error & { code: string };
			error.code = 'ENOENT';
			throw error;
		}
	};

	const result = await checkProviderHealth(
		{
			providerId: 'codex',
			binaryName: 'codex',
			installHint: 'Install codex CLI'
		},
		runner
	);

	assert.equal(result.status, 'missing_binary');
	assert.equal(result.installHint, 'Install codex CLI');
});

test('testProvider invokes health check with --help', async () => {
	/** @type {readonly string[] | undefined} */
	let recordedArgs;
	const runner: CommandRunner = {
		async run(_binaryName, args) {
			recordedArgs = args;
			return { stdout: 'help output', stderr: '' };
		}
	};

	await testProvider(
		{
			providerId: 'claude',
			binaryName: 'claude'
		},
		runner
	);

	assert.deepEqual(recordedArgs, ['--help']);
});
