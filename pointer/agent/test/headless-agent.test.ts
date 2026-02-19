/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { runHeadlessAgent } from '../src/ci/headless-agent.js';

test('runHeadlessAgent returns patch output for CI mode', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-headless-'));
	const output = await runHeadlessAgent({
		workspacePath: workspace,
		prompt: 'fix lint issue',
		targetFile: 'src/a.ts',
		traceId: 'trace-ci'
	});

	assert.equal(output.traceId, 'trace-ci');
	assert.equal(output.files[0]?.path, 'src/a.ts');
	assert.match(output.summary, /fix lint issue/);
	await fs.rm(workspace, { recursive: true, force: true });
});
