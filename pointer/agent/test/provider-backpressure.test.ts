/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { ProviderRequestQueue } from '../src/providers/backpressure.js';

test('ProviderRequestQueue enforces max concurrency', async () => {
	const queue = new ProviderRequestQueue(1);
	const executionOrder: string[] = [];

	const first = queue.enqueue(async () => {
		executionOrder.push('first-start');
		await new Promise((resolve) => setTimeout(resolve, 20));
		executionOrder.push('first-end');
	});

	const second = queue.enqueue(async () => {
		executionOrder.push('second-start');
		executionOrder.push('second-end');
	});

	await Promise.all([first, second]);
	assert.deepEqual(executionOrder, ['first-start', 'first-end', 'second-start', 'second-end']);
});

test('ProviderRequestQueue exposes queue state', async () => {
	const queue = new ProviderRequestQueue(2);
	const operation = queue.enqueue(async () => {
		await new Promise((resolve) => setTimeout(resolve, 5));
	});

	const state = queue.getState();
	assert.equal(state.maxConcurrent, 2);
	assert.ok(state.running >= 0);
	await operation;
});
