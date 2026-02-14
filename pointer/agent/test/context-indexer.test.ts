/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { ContextIndexer } from '../src/context/indexer.js';

async function setupWorkspace(): Promise<string> {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-indexer-'));
	await fs.mkdir(path.join(workspace, 'src'), { recursive: true });
	await fs.writeFile(path.join(workspace, '.gitignore'), '');
	await fs.writeFile(path.join(workspace, 'src', 'a.ts'), 'a');
	return workspace;
}

test('ContextIndexer builds initial index from discovered workspace files', async () => {
	const workspace = await setupWorkspace();
	const indexer = new ContextIndexer(workspace);
	await indexer.buildInitialIndex();

	const paths = indexer.listIndex().map((item) => item.relativePath);
	assert.deepEqual(paths, ['.gitignore', 'src/a.ts']);

	await fs.rm(workspace, { recursive: true, force: true });
});

test('ContextIndexer applies incremental change and delete updates', async () => {
	const workspace = await setupWorkspace();
	const indexer = new ContextIndexer(workspace);
	await indexer.buildInitialIndex();

	indexer.applyFileChange('src/b.ts');
	assert.ok(indexer.listIndex().some((item) => item.relativePath === 'src/b.ts'));

	indexer.applyFileDelete('src/a.ts');
	assert.equal(indexer.listIndex().some((item) => item.relativePath === 'src/a.ts'), false);

	await fs.rm(workspace, { recursive: true, force: true });
});
