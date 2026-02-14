/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const test = require('node:test');
const { buildGroupedDiffPreview, groupPatchFiles } = require('../chat/patch-groups.js');

test('groupPatchFiles groups patch files by directory', () => {
	const groups = groupPatchFiles([
		{ path: 'src/a.ts', diff: '@@ -1 +1 @@\n-a\n+b' },
		{ path: 'src/b.ts', diff: '@@ -1 +1 @@\n-c\n+d' },
		{ path: 'README.md', diff: '@@ -1 +1 @@\n-old\n+new' }
	]);

	assert.deepEqual(groups.map((group) => group.id), ['(root)', 'src']);
	assert.equal(groups[1]?.files.length, 2);
});

test('buildGroupedDiffPreview combines per-file previews for grouped view', () => {
	const preview = buildGroupedDiffPreview([
		{ path: 'src/a.ts', diff: '@@ -1 +1 @@\n-a\n+b' },
		{ path: 'src/b.ts', diff: '@@ -1 +1 @@\n-c\n+d' }
	]);

	assert.match(preview.before, /src\/a\.ts/);
	assert.match(preview.after, /src\/b\.ts/);
});
