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

	const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 110);
	statusBarItem.name = 'Pointer Surface Model';
	statusBarItem.command = 'pointer.openSettings';
	statusBarItem.show();

	const openChat = vscode.commands.registerCommand('pointer.openChat', async () => {
		await vscode.commands.executeCommand('workbench.view.extension.pointer');
		await vscode.commands.executeCommand('pointer.home.focus');
	});

	const toggleTab = vscode.commands.registerCommand('pointer.toggleTab', async () => {
		await vscode.window.showInformationMessage('Pointer Tab toggle is not wired yet. This command placeholder is active.');
	});

	const selectModel = vscode.commands.registerCommand('pointer.selectModel', async () => {
		await vscode.window.showInformationMessage('Pointer model selection is not wired yet. This command placeholder is active.');
	});

	const openSettings = vscode.commands.registerCommand('pointer.openSettings', async () => {
		await vscode.commands.executeCommand('workbench.action.openSettings', 'Pointer');
	});

	const updateStatusBar = () => {
		const config = vscode.workspace.getConfiguration('pointer.defaults');
		const chatProvider = config.get('chat.provider', 'auto');
		const chatModel = config.get('chat.model', 'auto');
		const tabProvider = config.get('tab.provider', 'auto');
		const tabModel = config.get('tab.model', 'auto');
		const agentProvider = config.get('agent.provider', 'auto');
		const agentModel = config.get('agent.model', 'auto');

		statusBarItem.text = `$(sparkle) Pointer ${chatProvider}/${chatModel}`;
		statusBarItem.tooltip = [
			`Chat: ${chatProvider}/${chatModel}`,
			`Tab: ${tabProvider}/${tabModel}`,
			`Agent: ${agentProvider}/${agentModel}`
		].join('\n');
	};

	updateStatusBar();

	const configWatcher = vscode.workspace.onDidChangeConfiguration((event) => {
		if (event.affectsConfiguration('pointer.defaults')) {
			updateStatusBar();
		}
	});

	context.subscriptions.push(pointerTree, statusBarItem, configWatcher, openChat, toggleTab, selectModel, openSettings);
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
};
