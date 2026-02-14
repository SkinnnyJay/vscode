/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { RouterPlan } from '../router/contract.js';
import { ChatStreamRequest } from './protocol.js';

export interface ChatTraceEntry {
	readonly traceId: string;
	readonly sessionId: string;
	readonly requestId: string;
	readonly providerId: string;
	readonly modelId: string;
	readonly totalInputTokens: number;
	readonly contextCount: number;
	readonly timestampIso: string;
}

export function createTraceId(): string {
	return `trace-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

export function createChatTraceEntry(
	request: ChatStreamRequest,
	plan: RouterPlan,
	timestampIso: string = new Date().toISOString()
): ChatTraceEntry {
	return {
		traceId: request.traceId,
		sessionId: request.sessionId,
		requestId: plan.request.requestId,
		providerId: request.providerId,
		modelId: request.modelId,
		totalInputTokens: plan.totalInputTokens,
		contextCount: plan.request.context.length,
		timestampIso
	};
}

export class ChatTraceLog {
	private readonly entries: ChatTraceEntry[];

	constructor() {
		this.entries = [];
	}

	append(entry: ChatTraceEntry): void {
		this.entries.push(entry);
	}

	list(): readonly ChatTraceEntry[] {
		return this.entries;
	}
}
