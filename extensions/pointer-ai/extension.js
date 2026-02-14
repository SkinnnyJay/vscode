/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const vscode = require('vscode');
const { createPointerInternalApi } = require('./internal-api.js');
const { PointerRouterClient } = require('./router-client.js');
const { createInlineCompletionProvider } = require('./tab/inline-completion-provider.js');
const SETTINGS_SCHEMA_VERSION_KEY = 'pointer.settingsSchemaVersion';
const CURRENT_SETTINGS_SCHEMA_VERSION = 1;

class PointerViewDataProvider {
	getTreeItem(element) {
		return element;
	}

	getChildren() {
		return [];
	}
}

class RouterContextViewDataProvider {
	constructor() {
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		/** @type {vscode.TreeItem[]} */
		this.items = [
			new vscode.TreeItem('No router plan yet. Trigger a Pointer command to populate context.', vscode.TreeItemCollapsibleState.None)
		];
	}

	refreshFromPlan(plan) {
		const contextItems = plan.explainability.map((entry) => {
			const item = new vscode.TreeItem(entry, vscode.TreeItemCollapsibleState.None);
			item.tooltip = `plan:${plan.requestId}`;
			return item;
		});

		this.items = contextItems.length > 0 ? contextItems : [
			new vscode.TreeItem('Router plan had no explainability entries.', vscode.TreeItemCollapsibleState.None)
		];
		this.onDidChangeTreeDataEmitter.fire(undefined);
	}

	getTreeItem(element) {
		return element;
	}

	getChildren() {
		return this.items;
	}
}

/**
 * @param {vscode.ExtensionContext} context
 */
async function migratePointerSettings(context) {
	const currentVersion = context.globalState.get(SETTINGS_SCHEMA_VERSION_KEY, 0);
	if (currentVersion < CURRENT_SETTINGS_SCHEMA_VERSION) {
		// Placeholder migration path for future settings shape changes.
		await context.globalState.update(SETTINGS_SCHEMA_VERSION_KEY, CURRENT_SETTINGS_SCHEMA_VERSION);
	}
}

/**
 * @returns {string[]}
 */
function validatePointerDefaultsConfiguration() {
	const config = vscode.workspace.getConfiguration('pointer.defaults');
	const keys = [
		'chat.provider',
		'chat.model',
		'tab.provider',
		'tab.model',
		'agent.provider',
		'agent.model'
	];

	return keys.filter((key) => {
		const value = config.get(key, 'auto');
		return typeof value !== 'string' || value.trim().length === 0;
	});
}

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
	void migratePointerSettings(context);
	void vscode.commands.executeCommand('setContext', 'pointer.workspaceTrusted', vscode.workspace.isTrusted);
	const routerClient = new PointerRouterClient();
	const internalApi = createPointerInternalApi(routerClient);

	const pointerViewDataProvider = new PointerViewDataProvider();
	const pointerTree = vscode.window.createTreeView('pointer.home', {
		treeDataProvider: pointerViewDataProvider,
		showCollapseAll: false
	});
	pointerTree.message = 'Pointer AI is not configured yet. Open Command Palette and run Pointer commands to begin.';
	const routerContextViewProvider = new RouterContextViewDataProvider();
	const contextSentTree = vscode.window.createTreeView('pointer.contextSent', {
		treeDataProvider: routerContextViewProvider,
		showCollapseAll: false
	});
	contextSentTree.message = 'Shows explainability data from the last router plan.';
	const inlineCompletion = createInlineCompletionProvider(internalApi);
	const inlineCompletionRegistration = vscode.languages.registerInlineCompletionItemProvider(
		{ scheme: 'file' },
		inlineCompletion.provider
	);

	const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 110);
	statusBarItem.name = 'Pointer Surface Model';
	statusBarItem.command = 'pointer.openSettings';
	statusBarItem.show();

	const openChat = vscode.commands.registerCommand('pointer.openChat', async () => {
		await vscode.commands.executeCommand('workbench.view.extension.pointer');
		await vscode.commands.executeCommand('pointer.home.focus');
		const chatSelection = internalApi.getSelection('chat');
		await internalApi.requestRouterPlan({
			surface: 'chat',
			providerId: chatSelection.providerId,
			modelId: chatSelection.modelId,
			templateId: 'chat-default',
			userPrompt: 'Open chat shell',
			context: [
				{ kind: 'system', label: 'pointer-system', tokenEstimate: 8 },
				{ kind: 'user', label: 'pointer-user', tokenEstimate: 6 }
			]
		});
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

	const cancelTabCompletion = vscode.commands.registerCommand('pointer.tab.cancel', async () => {
		inlineCompletion.cancelPending();
	});

	const updateStatusBar = () => {
		const chatSelection = internalApi.getSelection('chat');
		const tabSelection = internalApi.getSelection('tab');
		const agentSelection = internalApi.getSelection('agent');
		const copilotCompatibility = vscode.workspace.getConfiguration('pointer.compatibility').get('enableCopilotVisibility', false);

		statusBarItem.text = `$(sparkle) Pointer ${chatSelection.providerId}/${chatSelection.modelId}${copilotCompatibility ? ' +Copilot' : ''}`;
		statusBarItem.tooltip = [
			`Chat: ${chatSelection.providerId}/${chatSelection.modelId}`,
			`Tab: ${tabSelection.providerId}/${tabSelection.modelId}`,
			`Agent: ${agentSelection.providerId}/${agentSelection.modelId}`,
			`Copilot Compatibility: ${copilotCompatibility ? 'Enabled' : 'Disabled'}`
		].join('\n');
	};

	const syncSelectionsFromConfig = () => {
		const defaultsConfig = vscode.workspace.getConfiguration('pointer.defaults');

		internalApi.setSelection('chat', {
			providerId: defaultsConfig.get('chat.provider', 'auto'),
			modelId: defaultsConfig.get('chat.model', 'auto')
		});
		internalApi.setSelection('tab', {
			providerId: defaultsConfig.get('tab.provider', 'auto'),
			modelId: defaultsConfig.get('tab.model', 'auto')
		});
		internalApi.setSelection('agent', {
			providerId: defaultsConfig.get('agent.provider', 'auto'),
			modelId: defaultsConfig.get('agent.model', 'auto')
		});
	};

	syncSelectionsFromConfig();
	updateStatusBar();

	const invalidKeys = validatePointerDefaultsConfiguration();
	if (invalidKeys.length > 0) {
		void vscode.window.showWarningMessage(`Pointer settings validation: invalid values detected for ${invalidKeys.join(', ')}. Falling back to automatic defaults.`);
	}
	if (!vscode.workspace.isTrusted) {
		void vscode.window.showWarningMessage('Pointer workspace rules/config are disabled until this workspace is trusted.');
	}

	const configWatcher = vscode.workspace.onDidChangeConfiguration((event) => {
		if (event.affectsConfiguration('pointer.defaults')) {
			syncSelectionsFromConfig();
			updateStatusBar();
		}
		if (event.affectsConfiguration('pointer.compatibility')) {
			updateStatusBar();
		}
	});
	const typingCancelWatcher = vscode.workspace.onDidChangeTextDocument(() => {
		inlineCompletion.cancelPending();
	});

	const routerPlanWatcher = internalApi.onDidCreateRouterPlan((plan) => {
		routerContextViewProvider.refreshFromPlan(plan);
	});

	context.subscriptions.push(
		pointerTree,
		contextSentTree,
		inlineCompletionRegistration,
		statusBarItem,
		configWatcher,
		typingCancelWatcher,
		routerPlanWatcher,
		openChat,
		toggleTab,
		selectModel,
		openSettings,
		cancelTabCompletion
	);
	return internalApi;
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
};
