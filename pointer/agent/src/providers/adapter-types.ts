/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface ProviderRequest {
	readonly modelId: string;
	readonly prompt: string;
	readonly jsonMode?: boolean;
	readonly outputFormat?: 'text' | 'json' | 'table';
	readonly extraArgs?: readonly string[];
}

export interface ProviderResponse {
	readonly output: string;
	readonly stderr: string;
	readonly exitCode: number;
}

export interface ProviderStreamChunk {
	readonly stream: 'stdout' | 'stderr' | 'system';
	readonly chunk: string;
}

export interface ProviderAdapter {
	stream(
		request: ProviderRequest,
		onChunk: (chunk: ProviderStreamChunk) => void,
		signal?: AbortSignal
	): Promise<ProviderResponse>;
}
