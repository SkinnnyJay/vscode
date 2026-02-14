/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { assemblePromptParts, buildPromptText, estimatePromptTokens, PromptPart } from '../src/router/prompt-assembly.js';

function createPart(kind: PromptPart['kind'], label: string, tokenEstimate = 1): PromptPart {
	return {
		kind,
		label,
		content: `${label} content`,
		tokenEstimate
	};
}

test('assemblePromptParts orders parts by fixed prompt sequence', () => {
	const parts = assemblePromptParts({
		tools: [createPart('tools', 'tools1')],
		user: [createPart('user', 'user1')],
		system: [createPart('system', 'system1')],
		retrieved: [createPart('retrieved', 'retrieved1')],
		pinned: [createPart('pinned', 'pinned1')],
		rules: [createPart('rules', 'rules1')]
	});

	assert.deepEqual(parts.map((part) => part.kind), ['system', 'rules', 'pinned', 'retrieved', 'user', 'tools']);
});

test('assemblePromptParts preserves relative ordering within each part group', () => {
	const parts = assemblePromptParts({
		system: [createPart('system', 's1'), createPart('system', 's2')],
		user: [createPart('user', 'u1'), createPart('user', 'u2')]
	});

	assert.deepEqual(parts.map((part) => part.label), ['s1', 's2', 'u1', 'u2']);
});

test('buildPromptText and estimatePromptTokens produce deterministic output', () => {
	const parts = assemblePromptParts({
		system: [createPart('system', 'sys', 10)],
		user: [createPart('user', 'usr', 5)]
	});

	const text = buildPromptText(parts);
	assert.match(text, /\[\[SYSTEM:sys\]\]/);
	assert.match(text, /\[\[USER:usr\]\]/);
	assert.equal(estimatePromptTokens(parts), 15);
});
