/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const vscode = require('vscode');

/**
 * @typedef {'tab' | 'chat' | 'agent'} PointerSurface
 */

/**
 * @typedef {{
 *   providerId: string;
 *   modelId: string;
 * }} SurfaceSelection
 */

/**
 * @typedef {{
 *   apiVersion: '1.0.0';
 *   getSelection(surface: PointerSurface): SurfaceSelection;
 *   setSelection(surface: PointerSurface, selection: SurfaceSelection): void;
 *   getAllSelections(): Readonly<Record<PointerSurface, SurfaceSelection>>;
 *   requestRouterPlan(request: import('./router-client.js').RouterPlanRequest): Promise<import('./router-client.js').RouterPlanResponse>;
 *   streamChat(request: import('./router-client.js').RouterPlanRequest): AsyncGenerator<import('./router-client.js').ChatStreamEvent>;
 *   getLastRouterPlan(): import('./router-client.js').RouterPlanResponse | undefined;
 *   onDidChangeSelection(listener: (surface: PointerSurface, selection: SurfaceSelection) => void): vscode.Disposable;
 *   onDidCreateRouterPlan(listener: (plan: import('./router-client.js').RouterPlanResponse) => void): vscode.Disposable;
 * }} PointerInternalApi
 */

/**
 * @param {import('./router-client.js').PointerRouterClient} routerClient
 * @returns {PointerInternalApi}
 */
function createPointerInternalApi(routerClient) {
	const onDidChangeSelectionEmitter = new vscode.EventEmitter();
	const onDidCreateRouterPlanEmitter = new vscode.EventEmitter();

	/** @type {Record<PointerSurface, SurfaceSelection>} */
	const selections = {
		tab: { providerId: 'auto', modelId: 'auto' },
		chat: { providerId: 'auto', modelId: 'auto' },
		agent: { providerId: 'auto', modelId: 'auto' }
	};

	return {
		apiVersion: '1.0.0',
		getSelection(surface) {
			return selections[surface];
		},
		setSelection(surface, selection) {
			selections[surface] = selection;
			onDidChangeSelectionEmitter.fire({ surface, selection });
		},
		getAllSelections() {
			return selections;
		},
		async requestRouterPlan(request) {
			const plan = await routerClient.requestPlan(request);
			onDidCreateRouterPlanEmitter.fire(plan);
			return plan;
		},
		streamChat(request) {
			return routerClient.streamChat(request);
		},
		getLastRouterPlan() {
			return routerClient.getLastPlan();
		},
		onDidChangeSelection(listener) {
			return onDidChangeSelectionEmitter.event((event) => {
				listener(event.surface, event.selection);
			});
		},
		onDidCreateRouterPlan(listener) {
			return onDidCreateRouterPlanEmitter.event((plan) => {
				listener(plan);
			});
		}
	};
}

module.exports = {
	createPointerInternalApi
};
