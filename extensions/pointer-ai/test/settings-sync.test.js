/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const test = require('node:test');
const { normalizeAiSettings } = require('../settings-sync.js');

test('normalizeAiSettings keeps only supported pointer AI setting keys', () => {
	const normalized = normalizeAiSettings({
		'pointer.defaults.chat.provider': 'codex',
		'pointer.tab.enabled': true,
		'some.other.setting': 'ignored'
	});

	assert.deepEqual(normalized, {
		'pointer.defaults.chat.provider': 'codex',
		'pointer.tab.enabled': true
	});
});

test('normalizeAiSettings rejects non-object payloads', () => {
	assert.deepEqual(normalizeAiSettings(null), {});
	assert.deepEqual(normalizeAiSettings('nope'), {});
});
