/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export type ProviderErrorKind = 'missing_binary' | 'auth' | 'rate_limit' | 'timeout' | 'unknown';

export interface ProviderErrorClassification {
	readonly kind: ProviderErrorKind;
	readonly message: string;
	readonly retryable: boolean;
}

function toMessage(error: unknown): string {
	if (error instanceof Error) {
		return error.message;
	}
	if (typeof error === 'string') {
		return error;
	}
	return 'Unknown provider error';
}

export function classifyProviderError(error: unknown): ProviderErrorClassification {
	const message = toMessage(error);
	const lower = message.toLowerCase();

	if (lower.includes('enoent') || lower.includes('command not found')) {
		return {
			kind: 'missing_binary',
			message,
			retryable: false
		};
	}

	if (lower.includes('401') || lower.includes('403') || lower.includes('unauthorized') || lower.includes('authentication')) {
		return {
			kind: 'auth',
			message,
			retryable: false
		};
	}

	if (lower.includes('429') || lower.includes('rate limit') || lower.includes('quota')) {
		return {
			kind: 'rate_limit',
			message,
			retryable: true
		};
	}

	if (lower.includes('timeout') || lower.includes('timed out')) {
		return {
			kind: 'timeout',
			message,
			retryable: true
		};
	}

	return {
		kind: 'unknown',
		message,
		retryable: false
	};
}
