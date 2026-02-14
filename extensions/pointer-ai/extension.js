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
		return [
			new vscode.TreeItem('Pointer is ready. Open Command Palette for actions.', vscode.TreeItemCollapsibleState.None)
		];
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

	context.subscriptions.push(pointerTree);
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
};
