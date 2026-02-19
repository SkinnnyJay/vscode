/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { validatePatchResponse } from '../src/patch/schema.js';

test('validatePatchResponse accepts valid diff-first patch response', () => {
	const result = validatePatchResponse({
		traceId: 'trace-1',
		summary: 'Update one file',
		files: [
			{
				path: 'src/example.ts',
				diff: '@@ -1,1 +1,1 @@\n-old\n+new',
				rationale: 'Fix bug',
				applyStrategy: 'safe'
			}
		]
	});

	assert.equal(result.valid, true);
	assert.equal(result.errors.length, 0);
});

test('validatePatchResponse rejects invalid patch schema', () => {
	const result = validatePatchResponse({
		traceId: '',
		summary: '',
		files: []
	});

	assert.equal(result.valid, false);
	assert.ok(result.errors.length >= 3);
});
