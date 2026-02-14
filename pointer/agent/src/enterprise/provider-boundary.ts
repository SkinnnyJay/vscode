/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { EnterprisePolicyBundle } from './policy-bundles.js';

export interface ProviderBoundaryDecision {
	readonly allowed: boolean;
	readonly reason: string;
}

export function evaluateProviderBoundary(
	providerId: string,
	requestedDataBoundary: EnterprisePolicyBundle['dataBoundary'],
	policyBundle: EnterprisePolicyBundle
): ProviderBoundaryDecision {
	if (!policyBundle.providerAllowlist.includes(providerId)) {
		return {
			allowed: false,
			reason: `Provider ${providerId} is not allowlisted by enterprise policy.`
		};
	}
	if (requestedDataBoundary !== policyBundle.dataBoundary) {
		return {
			allowed: false,
			reason: `Requested boundary ${requestedDataBoundary} conflicts with enforced boundary ${policyBundle.dataBoundary}.`
		};
	}

	return {
		allowed: true,
		reason: 'Provider and data boundary are allowed.'
	};
}
