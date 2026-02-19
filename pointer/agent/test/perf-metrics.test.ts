/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { RequestMetricsRecorder } from '../src/perf/metrics.js';

test('RequestMetricsRecorder tracks latency and cancellation metrics', () => {
	const recorder = new RequestMetricsRecorder();
	recorder.recordRequestStart('r1', 'chat', 0);
	recorder.recordRequestEnd('r1', false, 100);
	recorder.recordRequestStart('r2', 'tab', 0);
	recorder.recordRequestEnd('r2', true, 50);

	const summary = recorder.summarize();
	assert.equal(summary.totalRequests, 2);
	assert.equal(summary.cancellationRate, 0.5);
	assert.equal(summary.averageLatencyMs, 75);
});

test('RequestMetricsRecorder tracks chat time-to-first-token', () => {
	const recorder = new RequestMetricsRecorder();
	recorder.recordRequestStart('chat-1', 'chat', 100);
	recorder.recordFirstToken('chat-1', 140);
	recorder.recordRequestEnd('chat-1', false, 220);

	const completed = recorder.listCompleted();
	assert.equal(completed[0]?.ttftMs, 40);
	assert.equal(recorder.summarize().averageTtftMs, 40);
});
