/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { createCheckRunPayload } from '../src/cloud/checks.js';

test('createCheckRunPayload marks neutral conclusion when annotations exist', () => {
	const payload = createCheckRunPayload('abc123', 'summary', [
		{
			path: 'src/a.ts',
			startLine: 1,
			endLine: 1,
			annotationLevel: 'notice',
			message: 'note'
		}
	]);

	assert.equal(payload.conclusion, 'neutral');
	assert.equal(payload.output.annotations.length, 1);
});

test('createCheckRunPayload marks success when no annotations exist', () => {
	const payload = createCheckRunPayload('abc123', 'summary', []);
	assert.equal(payload.conclusion, 'success');
});
