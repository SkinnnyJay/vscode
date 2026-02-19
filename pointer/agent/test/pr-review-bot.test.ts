/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { runPullRequestReviewBot } from '../src/cloud/pr-review-bot.js';

test('runPullRequestReviewBot returns annotations and check payload', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-pr-review-'));
	const result = await runPullRequestReviewBot({
		workspacePath: workspace,
		pullRequestNumber: 42,
		headSha: 'abc123',
		diffSummary: 'updated parser'
	});

	assert.match(result.summary, /PR #42/);
	assert.equal(result.checkRun.headSha, 'abc123');
	assert.ok(result.annotations.length >= 1);
	await fs.rm(workspace, { recursive: true, force: true });
});
