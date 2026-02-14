/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface ChatStreamRequest {
	readonly sessionId: string;
	readonly providerId: string;
	readonly modelId: string;
	readonly userMessage: string;
	readonly traceId: string;
	readonly contextLabels: readonly string[];
}

export interface ChatStreamChunk {
	readonly traceId: string;
	readonly type: 'delta' | 'done';
	readonly text: string;
}

export async function* createChatStream(chunks: readonly string[], traceId: string): AsyncGenerator<ChatStreamChunk> {
	for (const chunk of chunks) {
		yield {
			traceId,
			type: 'delta',
			text: chunk
		};
	}

	yield {
		traceId,
		type: 'done',
		text: ''
	};
}
