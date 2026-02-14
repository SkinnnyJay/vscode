/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { createChatTraceEntry, createTraceId, ChatTraceLog } from '../src/chat/tracing.js';
import { RouterPlan } from '../src/router/contract.js';

function createPlan(): RouterPlan {
	return {
		request: {
			requestId: 'req-1',
			timestampIso: '2026-02-14T00:00:00.000Z',
			selection: {
				surface: 'chat',
				providerId: 'codex',
				modelId: 'gpt-5-codex',
				template: {
					id: 'chat-default',
					version: '1'
				},
				policy: {
					terminalToolPolicy: 'confirm',
					filesystemToolPolicy: 'diff-only',
					networkToolPolicy: 'disabled',
					maxInputTokens: 1024,
					maxOutputTokens: 1024
				}
			},
			context: [{ kind: 'rules', label: 'rules', tokenEstimate: 10 }],
			prompt: 'hello'
		},
		totalInputTokens: 42,
		budgetRemaining: 900,
		explainability: []
	};
}

test('createTraceId returns prefixed trace identifier', () => {
	const traceId = createTraceId();
	assert.match(traceId, /^trace-/);
});

test('createChatTraceEntry captures session/plan metadata', () => {
	const entry = createChatTraceEntry(
		{
			sessionId: 'session-1',
			traceId: 'trace-1',
			providerId: 'codex',
			modelId: 'gpt-5-codex',
			userMessage: 'hello',
			contextLabels: ['rules']
		},
		createPlan(),
		'2026-02-14T01:00:00.000Z'
	);

	assert.equal(entry.traceId, 'trace-1');
	assert.equal(entry.contextCount, 1);
	assert.equal(entry.totalInputTokens, 42);
	assert.equal(entry.timestampIso, '2026-02-14T01:00:00.000Z');
});

test('ChatTraceLog stores appended entries', () => {
	const log = new ChatTraceLog();
	log.append({
		traceId: 'trace-1',
		sessionId: 'session-1',
		requestId: 'req-1',
		providerId: 'codex',
		modelId: 'gpt-5-codex',
		totalInputTokens: 42,
		contextCount: 1,
		timestampIso: '2026-02-14T01:00:00.000Z'
	});

	assert.equal(log.list().length, 1);
	assert.equal(log.list()[0]?.traceId, 'trace-1');
});
