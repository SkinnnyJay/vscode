/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * @typedef {{
 *   enabled: boolean;
 *   providerId: string;
 *   modelId: string;
 *   rulesProfile: string;
 *   maxLatencyMs: number;
 *   debounceMs: number;
 * }} TabCompletionConfig
 */

/**
 * @typedef {{
 *   uri: string;
 *   linePrefix: string;
 *   lineSuffix: string;
 *   line: number;
 *   character: number;
 *   selectionsCount: number;
 * }} TabCompletionRequest
 */

/**
 * @typedef {{
 *   isCancellationRequested?: boolean;
 *   onCancellationRequested?: (callback: () => void) => void;
 * }} CancellationLike
 */

/**
 * @typedef {{
 *   text: string;
 *   fromCache: boolean;
 *   latencyMs: number;
 * }} TabCompletionResult
 */

class PointerTabCompletionEngine {
	/**
	 * @param {{
	 *   requestPlan: (input: {
	 *     providerId: string;
	 *     modelId: string;
	 *     prompt: string;
	 *   }) => Promise<void>;
	 *   getConfig: () => TabCompletionConfig;
	 *   now?: () => number;
	 *   wait?: (ms: number) => Promise<void>;
	 * }} options
	 */
	constructor(options) {
		this.requestPlan = options.requestPlan;
		this.getConfig = options.getConfig;
		this.now = options.now ?? (() => Date.now());
		this.wait = options.wait ?? ((ms) => new Promise((resolve) => setTimeout(resolve, ms)));
		/** @type {Map<string, TabCompletionResult>} */
		this.cache = new Map();
		this.pendingAbortController = undefined;
	}

	cancelPending() {
		this.pendingAbortController?.abort();
	}

	/**
	 * @param {TabCompletionRequest} request
	 * @param {CancellationLike} [cancellation]
	 * @returns {Promise<TabCompletionResult | undefined>}
	 */
	async provide(request, cancellation) {
		const config = this.getConfig();
		if (!config.enabled || request.selectionsCount > 1) {
			return undefined;
		}

		const requestStarted = this.now();
		const cacheKey = this.createCacheKey(request, config);
		const cached = this.cache.get(cacheKey);
		if (cached) {
			return {
				...cached,
				fromCache: true,
				latencyMs: this.now() - requestStarted
			};
		}

		if (cancellation?.isCancellationRequested) {
			return undefined;
		}

		await this.wait(config.debounceMs);
		if (cancellation?.isCancellationRequested) {
			return undefined;
		}

		this.pendingAbortController?.abort();
		this.pendingAbortController = new AbortController();
		const activeAbort = this.pendingAbortController;
		cancellation?.onCancellationRequested?.(() => activeAbort.abort());

		const prompt = this.buildPrivacyScopedPrompt(request);
		await this.requestPlan({
			providerId: config.providerId,
			modelId: config.modelId,
			prompt
		});

		if (activeAbort.signal.aborted) {
			return undefined;
		}

		const suggestedText = this.deriveSuggestion(request.linePrefix);
		if (!suggestedText) {
			return undefined;
		}

		const result = {
			text: suggestedText,
			fromCache: false,
			latencyMs: this.now() - requestStarted
		};
		if (result.latencyMs <= config.maxLatencyMs) {
			this.cache.set(cacheKey, result);
		}
		return result;
	}

	/**
	 * @param {TabCompletionRequest} request
	 * @param {TabCompletionConfig} config
	 */
	createCacheKey(request, config) {
		const prefixKey = request.linePrefix.slice(-80);
		const suffixKey = request.lineSuffix.slice(0, 24);
		return [
			request.uri,
			request.line,
			request.character,
			prefixKey,
			suffixKey,
			config.providerId,
			config.modelId,
			config.rulesProfile
		].join('|');
	}

	/**
	 * @param {TabCompletionRequest} request
	 */
	buildPrivacyScopedPrompt(request) {
		const scopedPrefix = request.linePrefix.slice(-120);
		const scopedSuffix = request.lineSuffix.slice(0, 40);
		return `${scopedPrefix}<cursor>${scopedSuffix}`;
	}

	/**
	 * @param {string} linePrefix
	 */
	deriveSuggestion(linePrefix) {
		if (linePrefix.endsWith('console.')) {
			return 'log()';
		}
		if (linePrefix.endsWith('.')) {
			return 'toString()';
		}
		if (linePrefix.trimEnd().endsWith('=>')) {
			return ' {\n\t\n}';
		}
		return '';
	}
}

module.exports = {
	PointerTabCompletionEngine
};
