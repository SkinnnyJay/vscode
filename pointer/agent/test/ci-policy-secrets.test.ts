/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { loadCiPolicyBundle, loadCiPolicyRuntime } from '../src/ci/policy-secrets.js';

test('loadCiPolicyBundle returns defaults when file is missing', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-ci-policy-'));
	const policy = await loadCiPolicyBundle(workspace);
	assert.deepEqual(policy.allowedProviders, ['codex', 'claude', 'opencode']);
	await fs.rm(workspace, { recursive: true, force: true });
});

test('loadCiPolicyRuntime reads allowlisted secrets from environment', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-ci-policy-'));
	await fs.mkdir(path.join(workspace, '.pointer'), { recursive: true });
	await fs.writeFile(path.join(workspace, '.pointer', 'ci-policy.json'), JSON.stringify({
		allowedProviders: ['codex'],
		dataBoundary: 'workspace-and-selected-secrets',
		allowedSecretEnvKeys: ['POINTER_TOKEN']
	}), 'utf8');

	const runtime = await loadCiPolicyRuntime(workspace, {
		POINTER_TOKEN: 'secret-token',
		OTHER_KEY: 'ignored'
	});
	assert.deepEqual(runtime.policy.allowedProviders, ['codex']);
	assert.deepEqual(runtime.availableSecrets, { POINTER_TOKEN: 'secret-token' });
	await fs.rm(workspace, { recursive: true, force: true });
});
