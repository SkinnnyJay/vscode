/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { createChatStream } from '../src/chat/protocol.js';

test('createChatStream yields delta chunks followed by done event', async () => {
	const events = [];

	for await (const event of createChatStream(['hello ', 'world'], 'trace-1')) {
		events.push(event);
	}

	assert.deepEqual(
		events.map((event) => event.type),
		['delta', 'delta', 'done']
	);
	assert.equal(events[0]?.traceId, 'trace-1');
	assert.equal(events[1]?.text, 'world');
});
