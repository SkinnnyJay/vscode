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
 *   getLastRouterPlan(): import('./router-client.js').RouterPlanResponse | undefined;
 *   onDidChangeSelection(listener: (surface: PointerSurface, selection: SurfaceSelection) => void): vscode.Disposable;
 * }} PointerInternalApi
 */

/**
 * @param {import('./router-client.js').PointerRouterClient} routerClient
 * @returns {PointerInternalApi}
 */
function createPointerInternalApi(routerClient) {
	const onDidChangeSelectionEmitter = new vscode.EventEmitter();

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
		requestRouterPlan(request) {
			return routerClient.requestPlan(request);
		},
		getLastRouterPlan() {
			return routerClient.getLastPlan();
		},
		onDidChangeSelection(listener) {
			return onDidChangeSelectionEmitter.event((event) => {
				listener(event.surface, event.selection);
			});
		}
	};
}

module.exports = {
	createPointerInternalApi
};
