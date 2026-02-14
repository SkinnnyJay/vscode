/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const vscode = require('vscode');

class PointerViewDataProvider {
	getTreeItem(element) {
		return element;
	}

	getChildren() {
		return [];
	}
}

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
	const pointerViewDataProvider = new PointerViewDataProvider();
	const pointerTree = vscode.window.createTreeView('pointer.home', {
		treeDataProvider: pointerViewDataProvider,
		showCollapseAll: false
	});
	pointerTree.message = 'Pointer AI is not configured yet. Open Command Palette and run Pointer commands to begin.';

	context.subscriptions.push(pointerTree);
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
};
