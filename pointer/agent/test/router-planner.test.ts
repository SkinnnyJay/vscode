/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { createRouterPlan } from '../src/router/planner.js';
import { RouterSelection } from '../src/router/contract.js';

function createSelection(maxInputTokens: number): RouterSelection {
	return {
		surface: 'chat',
		providerId: 'auto',
		modelId: 'auto',
		template: {
			id: 'chat-default',
			version: '1'
		},
		policy: {
			terminalToolPolicy: 'confirm',
			filesystemToolPolicy: 'diff-only',
			networkToolPolicy: 'confirm',
			maxInputTokens,
			maxOutputTokens: 1024
		}
	};
}

test('createRouterPlan enforces input token budget and drops excess context', () => {
	const plan = createRouterPlan({
		selection: createSelection(40),
		prompt: 'hello world',
		context: [
			{ kind: 'rules', label: 'rules', tokenEstimate: 12 },
			{ kind: 'pinned', label: 'pinned', tokenEstimate: 14 },
			{ kind: 'retrieved', label: 'retrieved', tokenEstimate: 20 }
		],
		requestId: 'req-1',
		timestampIso: '2026-02-14T00:00:00.000Z'
	});

	assert.equal(plan.request.context.length, 2);
	assert.deepEqual(plan.request.context.map((source) => source.label), ['rules', 'pinned']);
	assert.match(plan.explainability.join('|'), /droppedContext=1/);
	assert.match(plan.explainability.join('|'), /droppedLabels=retrieved/);
	assert.ok(plan.totalInputTokens <= plan.request.selection.policy.maxInputTokens);
});

test('createRouterPlan includes all context when token budget allows it', () => {
	const plan = createRouterPlan({
		selection: createSelection(256),
		prompt: 'short',
		context: [
			{ kind: 'system', label: 'system', tokenEstimate: 5 },
			{ kind: 'user', label: 'user', tokenEstimate: 6 }
		]
	});

	assert.equal(plan.request.context.length, 2);
	assert.equal(plan.budgetRemaining, 256 - plan.totalInputTokens);
	assert.match(plan.explainability.join('|'), /droppedContext=0/);
});
