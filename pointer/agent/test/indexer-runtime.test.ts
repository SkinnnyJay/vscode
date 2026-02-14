/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { startIndexerOffCriticalPath } from '../src/context/indexer-runtime.js';

test('startIndexerOffCriticalPath defers indexer startup off immediate path', async () => {
	const events: string[] = [];
	const fakeIndexer = {
		async buildInitialIndex() {
			events.push('build');
		},
		startWatching() {
			events.push('watch');
		}
	};

	events.push('before');
	const startup = startIndexerOffCriticalPath(fakeIndexer);
	events.push('after');
	await startup;

	assert.deepEqual(events, ['before', 'after', 'build', 'watch']);
});
