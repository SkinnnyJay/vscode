/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * @typedef {'tab' | 'chat' | 'agent'} PointerSurface
 */

/**
 * @typedef {{
 *   kind: 'system' | 'rules' | 'pinned' | 'retrieved' | 'user' | 'tools';
 *   label: string;
 *   tokenEstimate: number;
 * }} RouterContextSource
 */

/**
 * @typedef {{
 *   surface: PointerSurface;
 *   providerId: string;
 *   modelId: string;
 *   templateId: string;
 *   userPrompt: string;
 *   context: readonly RouterContextSource[];
 * }} RouterPlanRequest
 */

/**
 * @typedef {{
 *   requestId: string;
 *   surface: PointerSurface;
 *   providerId: string;
 *   modelId: string;
 *   templateId: string;
 *   totalInputTokens: number;
 *   budgetRemaining: number;
 *   explainability: readonly string[];
 * }} RouterPlanResponse
 */

/**
 * @typedef {{
 *   traceId: string;
 *   type: 'delta' | 'done';
 *   text: string;
 * }} ChatStreamEvent
 */

/**
 * @callback RouterTransport
 * @param {RouterPlanRequest} request
 * @returns {Promise<RouterPlanResponse>}
 */

function generateRequestId() {
	return `pointer-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

/**
 * @implements {{requestPlan(request: RouterPlanRequest): Promise<RouterPlanResponse>; getLastPlan(): RouterPlanResponse | undefined}}
 */
class PointerRouterClient {
	/**
	 * @param {RouterTransport} [transport]
	 */
	constructor(transport) {
		this.transport = transport ?? this.defaultTransport;
		/** @type {RouterPlanResponse | undefined} */
		this.lastPlan = undefined;
	}

	/**
	 * @param {RouterPlanRequest} request
	 * @returns {AsyncGenerator<ChatStreamEvent>}
	 */
	async *streamChat(request) {
		const plan = await this.requestPlan(request);
		const responseText = `Router ready. ${plan.explainability.join(' | ')}`;
		const chunks = responseText.split(' ');
		for (const chunk of chunks) {
			yield {
				traceId: plan.requestId,
				type: 'delta',
				text: `${chunk} `
			};
		}
		yield {
			traceId: plan.requestId,
			type: 'done',
			text: ''
		};
	}

	/**
	 * @param {RouterPlanRequest} request
	 * @returns {Promise<RouterPlanResponse>}
	 */
	async requestPlan(request) {
		const response = await this.transport(request);
		this.lastPlan = response;
		return response;
	}

	/**
	 * @returns {RouterPlanResponse | undefined}
	 */
	getLastPlan() {
		return this.lastPlan;
	}

	/**
	 * @param {RouterPlanRequest} request
	 * @returns {Promise<RouterPlanResponse>}
	 */
	async defaultTransport(request) {
		const contextTokens = request.context.reduce((total, source) => total + source.tokenEstimate, 0);
		const promptTokens = Math.max(1, Math.ceil(request.userPrompt.length / 4));
		const totalInputTokens = contextTokens + promptTokens;
		const budget = request.surface === 'tab' ? 4096 : request.surface === 'chat' ? 16384 : 32768;

		return {
			requestId: generateRequestId(),
			surface: request.surface,
			providerId: request.providerId,
			modelId: request.modelId,
			templateId: request.templateId,
			totalInputTokens,
			budgetRemaining: Math.max(0, budget - totalInputTokens),
			explainability: [
				`surface=${request.surface}`,
				`provider=${request.providerId}`,
				`model=${request.modelId}`,
				`template=${request.templateId}`,
				`contextParts=${request.context.length}`
			]
		};
	}
}

module.exports = {
	PointerRouterClient
};
