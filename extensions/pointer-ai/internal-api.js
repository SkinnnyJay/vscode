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
 *   onDidChangeSelection(listener: (surface: PointerSurface, selection: SurfaceSelection) => void): vscode.Disposable;
 * }} PointerInternalApi
 */

/**
 * @returns {PointerInternalApi}
 */
function createPointerInternalApi() {
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
