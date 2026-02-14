/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const test = require('node:test');
const { PointerTabCompletionEngine } = require('../tab/tab-completion-engine.js');

test('PointerTabCompletionEngine returns inline suggestion on happy path', async () => {
	let requestPlanCalls = 0;
	const engine = new PointerTabCompletionEngine({
		requestPlan: async () => {
			requestPlanCalls += 1;
		},
		getConfig: () => ({
			enabled: true,
			providerId: 'auto',
			modelId: 'auto',
			rulesProfile: 'workspace',
			maxLatencyMs: 400,
			debounceMs: 0
		}),
		wait: async () => {}
	});

	const result = await engine.provide({
		uri: 'file:///tmp/sample.ts',
		linePrefix: 'console.',
		lineSuffix: '',
		line: 1,
		character: 8,
		selectionsCount: 1
	});

	assert.equal(requestPlanCalls, 1);
	assert.equal(result?.text, 'log()');
});

test('PointerTabCompletionEngine supports cancellation before request execution', async () => {
	let requestPlanCalls = 0;
	const engine = new PointerTabCompletionEngine({
		requestPlan: async () => {
			requestPlanCalls += 1;
		},
		getConfig: () => ({
			enabled: true,
			providerId: 'auto',
			modelId: 'auto',
			rulesProfile: 'workspace',
			maxLatencyMs: 400,
			debounceMs: 50
		}),
		wait: async () => {}
	});

	const result = await engine.provide(
		{
			uri: 'file:///tmp/sample.ts',
			linePrefix: 'value.',
			lineSuffix: '',
			line: 1,
			character: 6,
			selectionsCount: 1
		},
		{
			isCancellationRequested: true
		}
	);

	assert.equal(result, undefined);
	assert.equal(requestPlanCalls, 0);
});

test('PointerTabCompletionEngine uses cache and keeps latency within budget in smoke check', async () => {
	let requestPlanCalls = 0;
	let ticks = 0;
	const engine = new PointerTabCompletionEngine({
		requestPlan: async () => {
			requestPlanCalls += 1;
		},
		getConfig: () => ({
			enabled: true,
			providerId: 'auto',
			modelId: 'auto',
			rulesProfile: 'workspace',
			maxLatencyMs: 400,
			debounceMs: 0
		}),
		now: () => ticks++,
		wait: async () => {}
	});

	await engine.provide({
		uri: 'file:///tmp/sample.ts',
		linePrefix: 'value.',
		lineSuffix: '',
		line: 1,
		character: 6,
		selectionsCount: 1
	});

	const cached = await engine.provide({
		uri: 'file:///tmp/sample.ts',
		linePrefix: 'value.',
		lineSuffix: '',
		line: 1,
		character: 6,
		selectionsCount: 1
	});

	assert.equal(requestPlanCalls, 1);
	assert.equal(cached?.fromCache, true);
	assert.ok((cached?.latencyMs ?? 999) <= 400);
});
