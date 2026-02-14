/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { retrieveByEmbedding } from '../src/context/embedding-retrieval.js';

test('retrieveByEmbedding returns no results when disabled', () => {
	const results = retrieveByEmbedding([1, 0], [
		{ relativePath: 'a.ts', tokenEstimate: 1, updatedAt: 1, embedding: [1, 0] }
	], {
		enabled: false
	});
	assert.equal(results.length, 0);
});

test('retrieveByEmbedding ranks records by cosine similarity', () => {
	const results = retrieveByEmbedding([1, 0], [
		{ relativePath: 'a.ts', tokenEstimate: 1, updatedAt: 1, embedding: [1, 0] },
		{ relativePath: 'b.ts', tokenEstimate: 1, updatedAt: 1, embedding: [0.5, 0.5] },
		{ relativePath: 'c.ts', tokenEstimate: 1, updatedAt: 1, embedding: [0, 1] }
	], {
		enabled: true,
		maxResults: 2
	});

	assert.deepEqual(results.map((record) => record.relativePath), ['a.ts', 'b.ts']);
});
