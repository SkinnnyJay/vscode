/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const test = require('node:test');
const { PatchReviewStore } = require('../chat/patch-review-store.js');

test('PatchReviewStore supports apply/reject/apply-all statuses', () => {
	const store = new PatchReviewStore();
	store.setProposal([
		{ path: 'a.ts', diff: '@@ -1 +1 @@\n-a\n+b', rationale: 'change a' },
		{ path: 'b.ts', diff: '@@ -1 +1 @@\n-c\n+d', rationale: 'change b' }
	]);

	store.applyFile('a.ts');
	store.rejectFile('b.ts');
	const summary = store.getSummary();
	assert.equal(summary.applied, 1);
	assert.equal(summary.rejected, 1);
	assert.equal(summary.pending, 0);
});

test('PatchReviewStore applyAll applies remaining pending files', () => {
	const store = new PatchReviewStore();
	store.setProposal([
		{ path: 'a.ts', diff: '@@ -1 +1 @@\n-a\n+b', rationale: 'change a' },
		{ path: 'b.ts', diff: '@@ -1 +1 @@\n-c\n+d', rationale: 'change b' }
	]);

	store.rejectFile('a.ts');
	store.applyAll();
	const statuses = store.listFiles().map((file) => file.status);
	assert.deepEqual(statuses, ['rejected', 'applied']);
});

test('PatchReviewStore tracks conflict states in summary', () => {
	const store = new PatchReviewStore();
	store.setProposal([
		{ path: 'a.ts', diff: '@@ -1 +1 @@\n-a\n+b', rationale: 'change a' }
	]);

	store.markConflict('a.ts', 'missing file');
	const summary = store.getSummary();
	assert.equal(summary.conflicts, 1);
	assert.equal(store.listFiles()[0]?.status, 'conflict');
});
