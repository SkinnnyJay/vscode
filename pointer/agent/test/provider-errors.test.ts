/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { classifyProviderError } from '../src/providers/errors.js';

test('classifyProviderError detects missing binary failures', () => {
	const result = classifyProviderError('spawn codex ENOENT');
	assert.equal(result.kind, 'missing_binary');
	assert.equal(result.retryable, false);
});

test('classifyProviderError detects auth failures', () => {
	const result = classifyProviderError('401 unauthorized token');
	assert.equal(result.kind, 'auth');
	assert.equal(result.retryable, false);
});

test('classifyProviderError detects rate limit failures', () => {
	const result = classifyProviderError('429 rate limit exceeded');
	assert.equal(result.kind, 'rate_limit');
	assert.equal(result.retryable, true);
});

test('classifyProviderError detects timeout failures', () => {
	const result = classifyProviderError(new Error('request timed out after 30s'));
	assert.equal(result.kind, 'timeout');
	assert.equal(result.retryable, true);
});
