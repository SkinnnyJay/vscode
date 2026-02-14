/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface ProviderCapabilities {
	readonly providerId: string;
	readonly supportsTab: boolean;
	readonly supportsTools: boolean;
	readonly supportsJsonMode: boolean;
	readonly supportsLongContext: boolean;
	readonly supportsStreaming: boolean;
	readonly supportsCancellation: boolean;
}

const providerCapabilitiesRegistry: Readonly<Record<string, ProviderCapabilities>> = {
	codex: {
		providerId: 'codex',
		supportsTab: true,
		supportsTools: true,
		supportsJsonMode: true,
		supportsLongContext: true,
		supportsStreaming: true,
		supportsCancellation: true
	},
	claude: {
		providerId: 'claude',
		supportsTab: true,
		supportsTools: true,
		supportsJsonMode: false,
		supportsLongContext: true,
		supportsStreaming: true,
		supportsCancellation: true
	},
	opencode: {
		providerId: 'opencode',
		supportsTab: true,
		supportsTools: true,
		supportsJsonMode: true,
		supportsLongContext: true,
		supportsStreaming: true,
		supportsCancellation: true
	}
};

function defaultCapabilities(providerId: string): ProviderCapabilities {
	return {
		providerId,
		supportsTab: false,
		supportsTools: false,
		supportsJsonMode: false,
		supportsLongContext: false,
		supportsStreaming: false,
		supportsCancellation: false
	};
}

export function getProviderCapabilities(providerId: string): ProviderCapabilities {
	return providerCapabilitiesRegistry[providerId] ?? defaultCapabilities(providerId);
}

export function listProviderCapabilities(): readonly ProviderCapabilities[] {
	return Object.values(providerCapabilitiesRegistry);
}
