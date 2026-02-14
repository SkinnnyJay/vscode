/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { ContextMetadataDb } from '../src/context/metadata-db.js';

test('ContextMetadataDb stores and lists metadata records', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-metadata-'));
	const db = new ContextMetadataDb(workspace);

	await db.upsert({
		relativePath: 'src/a.ts',
		tokenEstimate: 12,
		updatedAt: 1
	});
	await db.upsert({
		relativePath: 'src/b.ts',
		tokenEstimate: 8,
		updatedAt: 2,
		embedding: [0.1, 0.2]
	});

	const records = await db.list();
	assert.deepEqual(records.map((record) => record.relativePath), ['src/a.ts', 'src/b.ts']);

	await fs.rm(workspace, { recursive: true, force: true });
});

test('ContextMetadataDb updates and removes records', async () => {
	const workspace = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-metadata-'));
	const db = new ContextMetadataDb(workspace);

	await db.upsert({
		relativePath: 'src/a.ts',
		tokenEstimate: 12,
		updatedAt: 1
	});
	await db.upsert({
		relativePath: 'src/a.ts',
		tokenEstimate: 20,
		updatedAt: 2
	});
	await db.remove('src/a.ts');

	const records = await db.list();
	assert.equal(records.length, 0);
	await fs.rm(workspace, { recursive: true, force: true });
});
