/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface EnterprisePolicyBundle {
	readonly id: string;
	readonly name: string;
	readonly providerAllowlist: readonly string[];
	readonly dataBoundary: 'workspace-only' | 'workspace-and-selected-secrets' | 'enterprise-vault';
	readonly auditEnabled: boolean;
}

export const defaultEnterprisePolicyBundle: EnterprisePolicyBundle = {
	id: 'default',
	name: 'Default Enterprise Policy',
	providerAllowlist: ['codex', 'claude', 'opencode'],
	dataBoundary: 'workspace-only',
	auditEnabled: true
};

export function resolveEnterprisePolicyBundle(
	override: Partial<EnterprisePolicyBundle> | undefined
): EnterprisePolicyBundle {
	return {
		id: override?.id ?? defaultEnterprisePolicyBundle.id,
		name: override?.name ?? defaultEnterprisePolicyBundle.name,
		providerAllowlist: override?.providerAllowlist ?? defaultEnterprisePolicyBundle.providerAllowlist,
		dataBoundary: override?.dataBoundary ?? defaultEnterprisePolicyBundle.dataBoundary,
		auditEnabled: override?.auditEnabled ?? defaultEnterprisePolicyBundle.auditEnabled
	};
}
