/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { dedupeAndMergeChunks, lexicalRetrieve } from '../src/context/retrieval.js';

test('lexicalRetrieve ranks chunks by lexical overlap score', () => {
	const chunks = [
		{ path: 'a.ts', content: 'render button component', tokenEstimate: 3 },
		{ path: 'b.ts', content: 'render render list', tokenEstimate: 3 },
		{ path: 'c.ts', content: 'network request client', tokenEstimate: 3 }
	];

	const results = lexicalRetrieve('render', chunks, 2);
	assert.deepEqual(results.map((chunk) => chunk.path), ['b.ts', 'a.ts']);
});

test('dedupeAndMergeChunks removes duplicates and merges contiguous chunks', () => {
	const merged = dedupeAndMergeChunks([
		{ path: 'a.ts', content: 'line one', tokenEstimate: 2 },
		{ path: 'a.ts', content: 'line two', tokenEstimate: 3 },
		{ path: 'a.ts', content: 'line two', tokenEstimate: 3 },
		{ path: 'b.ts', content: 'other', tokenEstimate: 1 }
	]);

	assert.equal(merged.length, 2);
	assert.equal(merged[0]?.path, 'a.ts');
	assert.match(merged[0]?.content ?? '', /line one/);
	assert.match(merged[0]?.content ?? '', /line two/);
	assert.equal(merged[0]?.tokenEstimate, 5);
});
