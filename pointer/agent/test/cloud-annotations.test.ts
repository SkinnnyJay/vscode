/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { buildPatchAnnotations } from '../src/cloud/annotations.js';

test('buildPatchAnnotations maps patch files to PR annotations', () => {
	const annotations = buildPatchAnnotations({
		traceId: 'trace-1',
		summary: 'patch',
		files: [
			{
				path: 'src/a.ts',
				diff: '@@ -1 +1 @@\n-a\n+b',
				rationale: 'update a',
				applyStrategy: 'safe'
			}
		]
	});

	assert.equal(annotations.length, 1);
	assert.equal(annotations[0]?.path, 'src/a.ts');
	assert.equal(annotations[0]?.annotationLevel, 'notice');
});
