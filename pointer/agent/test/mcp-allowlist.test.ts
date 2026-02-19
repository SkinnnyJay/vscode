/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { isMcpToolAllowed, loadWorkspaceToolAllowlist } from '../src/mcp/allowlist.js';

test('loadWorkspaceToolAllowlist loads workspace tool allowlist file', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-mcp-allow-'));
	await fs.mkdir(path.join(workspace, '.pointer'), { recursive: true });
	await fs.writeFile(path.join(workspace, '.pointer', 'mcp-allowlist.json'), JSON.stringify({ tools: ['search'] }), 'utf8');

	const allowlist = await loadWorkspaceToolAllowlist(workspace);
	assert.equal(isMcpToolAllowed('search', allowlist), true);
	assert.equal(isMcpToolAllowed('exec', allowlist), false);
	await fs.rm(workspace, { recursive: true, force: true });
});

test('loadWorkspaceToolAllowlist defaults to empty list when file is missing', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-mcp-allow-'));
	const allowlist = await loadWorkspaceToolAllowlist(workspace);
	assert.equal(allowlist.tools.length, 0);
	await fs.rm(workspace, { recursive: true, force: true });
});
