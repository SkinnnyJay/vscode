/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const POINTER_SETTINGS_KEYS = [
	'pointer.providers.primary',
	'pointer.defaults.chat.provider',
	'pointer.defaults.chat.model',
	'pointer.defaults.tab.provider',
	'pointer.defaults.tab.model',
	'pointer.defaults.agent.provider',
	'pointer.defaults.agent.model',
	'pointer.tab.enabled',
	'pointer.tab.maxLatencyMs',
	'pointer.tab.debounceMs',
	'pointer.prompts.rulesProfile',
	'pointer.context.maxFiles',
	'pointer.tools.terminalPolicy'
];

function normalizeAiSettings(payload) {
	if (!payload || typeof payload !== 'object') {
		return {};
	}
	/** @type {Record<string, string | number | boolean>} */
	const normalized = {};
	for (const key of POINTER_SETTINGS_KEYS) {
		if (!(key in payload)) {
			continue;
		}
		const value = payload[key];
		if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
			normalized[key] = value;
		}
	}
	return normalized;
}

module.exports = {
	POINTER_SETTINGS_KEYS,
	normalizeAiSettings
};
