/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { evaluateToolGate } from '../src/policy/tool-gates.js';
import { RouterPolicy } from '../src/router/contract.js';

function createPolicy(overrides: Partial<RouterPolicy>): RouterPolicy {
	return {
		terminalToolPolicy: 'confirm',
		filesystemToolPolicy: 'diff-only',
		networkToolPolicy: 'disabled',
		maxInputTokens: 1024,
		maxOutputTokens: 1024,
		...overrides
	};
}

test('terminal tool is gated by confirm-by-default policy', () => {
	const decision = evaluateToolGate(createPolicy({ terminalToolPolicy: 'confirm' }), 'terminal', 'execute');
	assert.equal(decision.allowed, true);
	assert.equal(decision.requiresConfirmation, true);
});

test('filesystem writes are blocked unless diff apply flow is used', () => {
	const blockedWrite = evaluateToolGate(createPolicy({ filesystemToolPolicy: 'diff-only' }), 'filesystem', 'write');
	assert.equal(blockedWrite.allowed, false);

	const allowedDiff = evaluateToolGate(createPolicy({ filesystemToolPolicy: 'diff-only' }), 'filesystem', 'apply-diff');
	assert.equal(allowedDiff.allowed, true);
	assert.equal(allowedDiff.requiresConfirmation, false);
});

test('network tool defaults to disabled or confirm policy', () => {
	const disabledDecision = evaluateToolGate(createPolicy({ networkToolPolicy: 'disabled' }), 'network', 'request');
	assert.equal(disabledDecision.allowed, false);

	const confirmDecision = evaluateToolGate(createPolicy({ networkToolPolicy: 'confirm' }), 'network', 'request');
	assert.equal(confirmDecision.allowed, true);
	assert.equal(confirmDecision.requiresConfirmation, true);
});
