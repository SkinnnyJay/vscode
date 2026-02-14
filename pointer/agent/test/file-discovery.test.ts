/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { discoverWorkspaceFiles } from '../src/context/file-discovery.js';

async function setupWorkspace(): Promise<string> {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-discovery-'));
	await fs.mkdir(path.join(workspace, '.pointer'), { recursive: true });
	await fs.mkdir(path.join(workspace, 'src'), { recursive: true });
	await fs.mkdir(path.join(workspace, 'dist'), { recursive: true });
	await fs.writeFile(path.join(workspace, '.gitignore'), 'dist/\n*.log\n');
	await fs.writeFile(path.join(workspace, '.pointer', 'excludes'), 'src/private.ts\n');
	await fs.writeFile(path.join(workspace, 'src', 'index.ts'), 'export {};');
	await fs.writeFile(path.join(workspace, 'src', 'private.ts'), 'secret');
	await fs.writeFile(path.join(workspace, 'dist', 'bundle.js'), 'ignored');
	await fs.writeFile(path.join(workspace, 'notes.log'), 'ignored');
	return workspace;
}

test('discoverWorkspaceFiles respects .gitignore and .pointer excludes', async () => {
	const workspace = await setupWorkspace();
	const files = await discoverWorkspaceFiles({ workspacePath: workspace });

	assert.deepEqual(files, ['.gitignore', '.pointer/excludes', 'src/index.ts']);
	await fs.rm(workspace, { recursive: true, force: true });
});

test('discoverWorkspaceFiles respects explicit pointer excludes option', async () => {
	const workspace = await setupWorkspace();
	const files = await discoverWorkspaceFiles({
		workspacePath: workspace,
		pointerExcludes: ['src/index.ts']
	});

	assert.deepEqual(files, ['.gitignore', '.pointer/excludes']);
	await fs.rm(workspace, { recursive: true, force: true });
});
