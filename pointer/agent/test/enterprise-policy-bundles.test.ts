/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { defaultEnterprisePolicyBundle, resolveEnterprisePolicyBundle } from '../src/enterprise/policy-bundles.js';

test('resolveEnterprisePolicyBundle applies overrides on default policy', () => {
	const resolved = resolveEnterprisePolicyBundle({
		id: 'enterprise-a',
		providerAllowlist: ['codex'],
		dataBoundary: 'enterprise-vault'
	});

	assert.equal(resolved.id, 'enterprise-a');
	assert.deepEqual(resolved.providerAllowlist, ['codex']);
	assert.equal(resolved.dataBoundary, 'enterprise-vault');
});

test('defaultEnterprisePolicyBundle keeps audit enabled by default', () => {
	assert.equal(defaultEnterprisePolicyBundle.auditEnabled, true);
});
