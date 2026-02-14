/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { loadProjectBrief, saveProjectBrief } = require('../chat/project-brief.js');

test('project brief can be saved and loaded from workspace file', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-brief-'));
	await saveProjectBrief(workspace, 'Core mission and coding intent');
	const loaded = await loadProjectBrief(workspace);
	assert.equal(loaded, 'Core mission and coding intent');
	await fs.rm(workspace, { recursive: true, force: true });
});

test('loading project brief returns empty string when unset', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-brief-'));
	const loaded = await loadProjectBrief(workspace);
	assert.equal(loaded, '');
	await fs.rm(workspace, { recursive: true, force: true });
});
