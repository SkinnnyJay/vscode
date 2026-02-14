/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { evaluateProviderBoundary } from '../src/enterprise/provider-boundary.js';
import { resolveEnterprisePolicyBundle } from '../src/enterprise/policy-bundles.js';

test('evaluateProviderBoundary blocks non-allowlisted providers', () => {
	const policy = resolveEnterprisePolicyBundle({
		providerAllowlist: ['codex'],
		dataBoundary: 'workspace-only'
	});
	const decision = evaluateProviderBoundary('claude', 'workspace-only', policy);
	assert.equal(decision.allowed, false);
});

test('evaluateProviderBoundary blocks data boundary mismatch', () => {
	const policy = resolveEnterprisePolicyBundle({
		providerAllowlist: ['codex'],
		dataBoundary: 'enterprise-vault'
	});
	const decision = evaluateProviderBoundary('codex', 'workspace-only', policy);
	assert.equal(decision.allowed, false);
});

test('evaluateProviderBoundary allows matching provider and boundary', () => {
	const policy = resolveEnterprisePolicyBundle({
		providerAllowlist: ['codex'],
		dataBoundary: 'workspace-only'
	});
	const decision = evaluateProviderBoundary('codex', 'workspace-only', policy);
	assert.equal(decision.allowed, true);
});
