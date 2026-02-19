/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { HookDispatcher } from '../src/hooks/dispatcher.js';

interface PromptPayload {
	text: string;
}

test('HookDispatcher supports prePrompt payload mutation when policy allows it', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('prePrompt', 'mutate', async (context) => ({
		payload: {
			text: `${context.payload.text} [mutated]`
		}
	}));

	const result = await dispatcher.dispatch('prePrompt', { text: 'hello' }, {
		allowPromptMutation: true,
		allowPromptRedaction: true
	});

	assert.equal(result.payload.text, 'hello [mutated]');
});

test('HookDispatcher blocks modifications when policy forbids prompt mutation', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('prePrompt', 'mutate', async () => ({
		payload: {
			text: 'should-not-apply'
		}
	}));

	const result = await dispatcher.dispatch('prePrompt', { text: 'hello' }, {
		allowPromptMutation: false,
		allowPromptRedaction: true
	});

	assert.equal(result.payload.text, 'hello');
});

test('HookDispatcher allows hooks to block event execution', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('preTool', 'blocker', async () => ({ block: true }));

	const result = await dispatcher.dispatch('preTool', { text: 'hello' }, {
		allowPromptMutation: true,
		allowPromptRedaction: true
	});

	assert.equal(result.blocked, true);
	assert.equal(result.reports[0]?.blocked, true);
});

test('HookDispatcher records hook timeout and safe-failure behavior', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('prePrompt', 'slow-hook', async () => {
		await new Promise((resolve) => setTimeout(resolve, 20));
		return {
			payload: {
				text: 'late'
			}
		};
	});

	const result = await dispatcher.dispatch('prePrompt', { text: 'hello' }, {
		allowPromptMutation: true,
		allowPromptRedaction: true
	}, 1);

	assert.equal(result.blocked, false);
	assert.equal(result.payload.text, 'hello');
	assert.equal(result.reports[0]?.timedOut, true);
});

test('HookDispatcher records hook failure without crashing dispatch', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('prePrompt', 'failing-hook', async () => {
		throw new Error('boom');
	});

	const result = await dispatcher.dispatch('prePrompt', { text: 'hello' }, {
		allowPromptMutation: true,
		allowPromptRedaction: true
	});

	assert.equal(result.blocked, false);
	assert.equal(result.payload.text, 'hello');
	assert.equal(result.reports[0]?.failed, true);
});

test('HookDispatcher can redact prompt fields when policy allows', async () => {
	const dispatcher = new HookDispatcher<PromptPayload>();
	dispatcher.register('prePrompt', 'redactor', async () => ({
		redactedFields: ['apikey']
	}));

	const result = await dispatcher.dispatch('prePrompt', { text: 'my apikey is 123' }, {
		allowPromptMutation: true,
		allowPromptRedaction: true
	});

	assert.match(result.payload.text, /\[REDACTED\]/);
});
