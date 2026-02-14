/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const path = require('node:path');
const fs = require('node:fs/promises');
const vscode = require('vscode');
const { createPointerInternalApi } = require('./internal-api.js');
const { PointerRouterClient } = require('./router-client.js');
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

class ChatSessionTreeDataProvider {
	/**
	 * @param {ChatSessionStore} sessionStore
	 */
	constructor(sessionStore) {
		this.sessionStore = sessionStore;
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		this.storeWatcher = sessionStore.onDidChange(() => this.onDidChangeTreeDataEmitter.fire(undefined));
	}

	dispose() {
		this.storeWatcher.dispose();
		this.onDidChangeTreeDataEmitter.dispose();
	}

	getTreeItem(element) {
		const item = new vscode.TreeItem(element.name, vscode.TreeItemCollapsibleState.None);
		item.id = element.id;
		item.contextValue = 'pointerChatSession';
		return item;
	}

	getChildren() {
		return this.sessionStore.listSessions();
	}
}

class ChatMessageTreeDataProvider {
	/**
	 * @param {ChatSessionStore} sessionStore
	 */
	constructor(sessionStore) {
		this.sessionStore = sessionStore;
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		this.storeWatcher = sessionStore.onDidChange(() => this.onDidChangeTreeDataEmitter.fire(undefined));
	}

	dispose() {
		this.storeWatcher.dispose();
		this.onDidChangeTreeDataEmitter.dispose();
	}

	getTreeItem(element) {
		return element;
	}

	getChildren() {
		const session = this.sessionStore.getActiveSession();
		if (!session) {
			return [];
		}
		return this.sessionStore.listMessages(session.id).map((message) => {
			const rolePrefix = message.role === 'user' ? 'You' : 'Pointer';
			const suffix = message.streaming ? ' (streaming)' : '';
			const body = message.text.length > 0 ? message.text : '...';
			const item = new vscode.TreeItem(`${rolePrefix}: ${body}${suffix}`, vscode.TreeItemCollapsibleState.None);
			item.description = message.role;
			item.tooltip = body;
			return item;
		});
	}
}

class ChatContextChipTreeDataProvider {
	/**
	 * @param {ChatSessionStore} sessionStore
	 */
	constructor(sessionStore) {
		this.sessionStore = sessionStore;
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		this.storeWatcher = sessionStore.onDidChange(() => this.onDidChangeTreeDataEmitter.fire(undefined));
	}

	dispose() {
		this.storeWatcher.dispose();
		this.onDidChangeTreeDataEmitter.dispose();
	}

	getTreeItem(element) {
		const item = new vscode.TreeItem(element.label, vscode.TreeItemCollapsibleState.None);
		item.id = element.id;
		item.description = `${element.source} | ~${element.tokenEstimate} tokens`;
		item.contextValue = 'pointerPinnedContext';
		item.tooltip = element.value;
		return item;
	}

	getChildren() {
		return this.sessionStore.listPinnedContext();
	}
}

class PatchReviewTreeDataProvider {
	/**
	 * @param {PatchReviewStore} patchReviewStore
	 */
	constructor(patchReviewStore) {
		this.patchReviewStore = patchReviewStore;
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		this.storeWatcher = patchReviewStore.onDidChange(() => this.onDidChangeTreeDataEmitter.fire(undefined));
	}

	dispose() {
		this.storeWatcher.dispose();
		this.onDidChangeTreeDataEmitter.dispose();
	}

	getTreeItem(element) {
		const icon = element.status === 'applied'
			? '$(check)'
			: element.status === 'rejected'
				? '$(x)'
				: element.status === 'conflict'
					? '$(warning)'
					: '$(diff)';
		const item = new vscode.TreeItem(`${icon} ${element.path}`, vscode.TreeItemCollapsibleState.None);
		item.id = element.path;
		item.contextValue = 'pointerPatchFile';
		item.description = `${element.status} - ${element.rationale}`;
		item.tooltip = element.diff;
		if (element.status === 'conflict' && element.conflictReason) {
			item.tooltip = `${element.diff}\n\nConflict: ${element.conflictReason}`;
		}
		return item;
	}

	getChildren() {
		return this.patchReviewStore.listFiles();
	}
}

class RulesAuditTreeDataProvider {
	constructor() {
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		/** @type {vscode.TreeItem[]} */
		this.items = [
			new vscode.TreeItem('No rules loaded', vscode.TreeItemCollapsibleState.None)
		];
	}

	setRules(ruleItems) {
		this.items = ruleItems.length > 0 ? ruleItems : [
			new vscode.TreeItem('No rules found for active workspace/profile', vscode.TreeItemCollapsibleState.None)
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

class McpAuditTreeDataProvider {
	constructor() {
		this.onDidChangeTreeDataEmitter = new vscode.EventEmitter();
		this.onDidChangeTreeData = this.onDidChangeTreeDataEmitter.event;
		/** @type {vscode.TreeItem[]} */
		this.items = [
			new vscode.TreeItem('No MCP servers configured', vscode.TreeItemCollapsibleState.None)
		];
	}

	setItems(items) {
		this.items = items.length > 0 ? items : [
			new vscode.TreeItem('No MCP servers configured', vscode.TreeItemCollapsibleState.None)
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

function toDiffPreview(diff) {
	const lines = diff.split('\n');
	const before = [];
	const after = [];
	for (const line of lines) {
		if (line.startsWith('+++') || line.startsWith('---') || line.startsWith('@@')) {
			continue;
		}
		if (line.startsWith('+')) {
			after.push(line.slice(1));
		} else if (line.startsWith('-')) {
			before.push(line.slice(1));
		} else if (line.startsWith(' ')) {
			const text = line.slice(1);
			before.push(text);
			after.push(text);
		}
	}
	return {
		before: before.join('\n'),
		after: after.join('\n')
	};
}

function parseStructuredChatInput(rawInput) {
	const trimmed = rawInput.trim();
	if (!trimmed.startsWith('/')) {
		return {
			displayMessage: rawInput,
			prompt: rawInput,
			workflow: 'freeform'
		};
	}

	if (trimmed.startsWith('/explain ')) {
		const payload = trimmed.slice('/explain '.length);
		return {
			displayMessage: rawInput,
			prompt: `Explain the following code or behavior:\n${payload}`,
			workflow: 'explain'
		};
	}
	if (trimmed.startsWith('/fix ')) {
		const payload = trimmed.slice('/fix '.length);
		return {
			displayMessage: rawInput,
			prompt: `Propose a fix with rationale and patch suggestions:\n${payload}`,
			workflow: 'fix'
		};
	}
	if (trimmed.startsWith('/test ')) {
		const payload = trimmed.slice('/test '.length);
		return {
			displayMessage: rawInput,
			prompt: `Design and describe targeted tests for:\n${payload}`,
			workflow: 'test'
		};
	}

	return {
		displayMessage: rawInput,
		prompt: rawInput,
		workflow: 'freeform'
	};
}

function delay(milliseconds) {
	return new Promise((resolve) => setTimeout(resolve, milliseconds));
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
	const { createInlineCompletionProvider } = require('./tab/inline-completion-provider.js');
	const { ChatSessionStore } = require('./chat/session-store.js');
	const { PatchReviewStore } = require('./chat/patch-review-store.js');
	const routerClient = new PointerRouterClient();
	const internalApi = createPointerInternalApi(routerClient);
	const chatSessionStore = new ChatSessionStore();
	const patchReviewStore = new PatchReviewStore();

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
	const chatSessionProvider = new ChatSessionTreeDataProvider(chatSessionStore);
	const chatSessionTree = vscode.window.createTreeView('pointer.chatSessions', {
		treeDataProvider: chatSessionProvider,
		showCollapseAll: false
	});
	chatSessionTree.message = 'Chat sessions';
	const chatMessageProvider = new ChatMessageTreeDataProvider(chatSessionStore);
	const chatMessageTree = vscode.window.createTreeView('pointer.chatMessages', {
		treeDataProvider: chatMessageProvider,
		showCollapseAll: false
	});
	chatMessageTree.message = 'Messages';
	const chatContextProvider = new ChatContextChipTreeDataProvider(chatSessionStore);
	const chatContextTree = vscode.window.createTreeView('pointer.chatContext', {
		treeDataProvider: chatContextProvider,
		showCollapseAll: false
	});
	chatContextTree.message = 'Pinned context';
	const patchReviewProvider = new PatchReviewTreeDataProvider(patchReviewStore);
	const patchReviewTree = vscode.window.createTreeView('pointer.patchReview', {
		treeDataProvider: patchReviewProvider,
		showCollapseAll: false
	});
	patchReviewTree.message = 'Agent patch proposals';
	const rulesAuditProvider = new RulesAuditTreeDataProvider();
	const rulesAuditTree = vscode.window.createTreeView('pointer.rulesAudit', {
		treeDataProvider: rulesAuditProvider,
		showCollapseAll: false
	});
	rulesAuditTree.message = 'Applied rules';
	const mcpAuditProvider = new McpAuditTreeDataProvider();
	const mcpAuditTree = vscode.window.createTreeView('pointer.mcp', {
		treeDataProvider: mcpAuditProvider,
		showCollapseAll: false
	});
	mcpAuditTree.message = 'MCP servers and permissions';
	let activeChatAbortController;
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

	const selectChatProvider = vscode.commands.registerCommand('pointer.chat.selectProvider', async () => {
		const picked = await vscode.window.showQuickPick(
			[
				{ label: 'auto', description: 'Automatic provider routing' },
				{ label: 'codex', description: 'OpenAI Codex CLI' },
				{ label: 'claude', description: 'Claude Code CLI' },
				{ label: 'opencode', description: 'OpenCode CLI' }
			],
			{
				title: 'Select chat provider'
			}
		);
		if (!picked) {
			return;
		}
		await vscode.workspace.getConfiguration('pointer.defaults').update('chat.provider', picked.label, vscode.ConfigurationTarget.Global);
	});

	const selectChatModel = vscode.commands.registerCommand('pointer.chat.selectModel', async () => {
		const providerId = internalApi.getSelection('chat').providerId;
		const optionsByProvider = {
			auto: ['auto'],
			codex: ['gpt-5-codex', 'gpt-4.1'],
			claude: ['claude-sonnet-4', 'claude-opus-4'],
			opencode: ['opencode-large', 'opencode-fast']
		};
		const options = optionsByProvider[providerId] ?? ['auto'];
		const picked = await vscode.window.showQuickPick(options.map((label) => ({ label })), {
			title: `Select chat model (${providerId})`
		});
		if (!picked) {
			return;
		}
		await vscode.workspace.getConfiguration('pointer.defaults').update('chat.model', picked.label, vscode.ConfigurationTarget.Global);
	});

	const openSettings = vscode.commands.registerCommand('pointer.openSettings', async () => {
		await vscode.commands.executeCommand('workbench.action.openSettings', 'Pointer');
	});

	const cancelTabCompletion = vscode.commands.registerCommand('pointer.tab.cancel', async () => {
		inlineCompletion.cancelPending();
	});

	const acceptPartialTabCompletion = vscode.commands.registerCommand('pointer.tab.acceptPartial', async () => {
		const editor = vscode.window.activeTextEditor;
		if (!editor) {
			return;
		}
		const suggestionText = inlineCompletion.getLastSuggestionText();
		if (!suggestionText) {
			return;
		}
		const partial = (suggestionText.match(/^\S+\s?/) ?? [suggestionText])[0];
		await editor.edit((editBuilder) => {
			editBuilder.insert(editor.selection.active, partial);
		});
	});

	const createChatSession = vscode.commands.registerCommand('pointer.chat.newSession', async () => {
		const value = await vscode.window.showInputBox({
			prompt: 'Session name',
			placeHolder: 'New Chat'
		});
		chatSessionStore.createSession(value && value.trim().length > 0 ? value : 'New Chat');
	});

	const renameChatSession = vscode.commands.registerCommand('pointer.chat.renameSession', async (session) => {
		const value = await vscode.window.showInputBox({
			prompt: 'Rename session',
			value: session?.name ?? 'Chat'
		});
		if (value && session?.id) {
			chatSessionStore.renameSession(session.id, value);
		}
	});

	const deleteChatSession = vscode.commands.registerCommand('pointer.chat.deleteSession', async (session) => {
		if (!session?.id) {
			return;
		}
		const confirm = await vscode.window.showWarningMessage(
			`Delete chat session "${session.name}"?`,
			{ modal: true },
			'Delete'
		);
		if (confirm === 'Delete') {
			chatSessionStore.deleteSession(session.id);
		}
	});

	const exportChatSessions = vscode.commands.registerCommand('pointer.chat.exportSessions', async () => {
		const target = await vscode.window.showSaveDialog({
			defaultUri: vscode.Uri.file('pointer-sessions.json'),
			filters: {
				JSON: ['json']
			}
		});
		if (!target) {
			return;
		}
		const payload = chatSessionStore.exportSessions();
		await fs.writeFile(target.fsPath, JSON.stringify(payload, null, 2), 'utf8');
		void vscode.window.showInformationMessage(`Exported Pointer sessions to ${target.fsPath}`);
	});

	const importChatSessions = vscode.commands.registerCommand('pointer.chat.importSessions', async () => {
		const files = await vscode.window.showOpenDialog({
			canSelectMany: false,
			filters: {
				JSON: ['json']
			}
		});
		const target = files?.[0];
		if (!target) {
			return;
		}
		const payload = JSON.parse(await fs.readFile(target.fsPath, 'utf8'));
		const imported = chatSessionStore.importSessions(payload);
		if (!imported) {
			void vscode.window.showWarningMessage('Selected file did not contain valid Pointer sessions.');
		}
	});

	const sendChatMessage = vscode.commands.registerCommand('pointer.chat.sendMessage', async () => {
		const value = await vscode.window.showInputBox({
			prompt: 'Send message to Pointer',
			placeHolder: 'Ask Pointer...'
		});
		if (!value || value.trim().length === 0) {
			return;
		}
		const parsedInput = parseStructuredChatInput(value);

		activeChatAbortController?.abort();
		activeChatAbortController = new AbortController();
		chatMessageTree.message = 'Streaming response...';

		chatSessionStore.addUserMessage(parsedInput.displayMessage);
		const assistantMessageId = chatSessionStore.startAssistantMessage();
		if (!assistantMessageId) {
			chatMessageTree.message = 'Messages';
			return;
		}

		try {
			const chatSelection = internalApi.getSelection('chat');
			const stream = internalApi.streamChat({
				surface: 'chat',
				providerId: chatSelection.providerId,
				modelId: chatSelection.modelId,
				templateId: 'chat-default',
				userPrompt: parsedInput.prompt,
				context: chatSessionStore.listPinnedContext().map((item) => ({
					kind: item.source === 'selection' ? 'retrieved' : item.source === 'file' ? 'pinned' : 'rules',
					label: item.label,
					tokenEstimate: Math.max(1, Math.ceil(item.value.length / 4))
				}))
			});
			if (parsedInput.workflow !== 'freeform') {
				chatSessionStore.appendAssistantChunk(assistantMessageId, `[workflow:${parsedInput.workflow}] `);
			}

			for await (const event of stream) {
				if (activeChatAbortController.signal.aborted) {
					chatSessionStore.appendAssistantChunk(assistantMessageId, '\n[Cancelled]');
					chatSessionStore.finalizeAssistantMessage(assistantMessageId);
					chatMessageTree.message = 'Message cancelled';
					return;
				}
				if (event.type === 'delta') {
					chatSessionStore.appendAssistantChunk(assistantMessageId, event.text);
					await delay(20);
				}
			}

			chatSessionStore.finalizeAssistantMessage(assistantMessageId);
			const preferredPatchFile = chatSessionStore.listPinnedContext().find((item) => item.source === 'file');
			const targetPath = preferredPatchFile?.value ?? 'src/example.ts';
			patchReviewStore.setProposal([
				{
					path: targetPath,
					diff: '@@ -1,1 +1,1 @@\n-old\n+new',
					rationale: 'Apply suggested refactor from chat response'
				}
			]);
			chatMessageTree.message = 'Messages';
		} catch (error) {
			chatSessionStore.appendAssistantChunk(assistantMessageId, `\n[Error] ${error instanceof Error ? error.message : 'Unknown failure'}`);
			chatSessionStore.finalizeAssistantMessage(assistantMessageId);
			chatMessageTree.message = 'Error during response streaming';
		}
	});

	const cancelChatMessage = vscode.commands.registerCommand('pointer.chat.cancelMessage', async () => {
		activeChatAbortController?.abort();
	});

	const attachCurrentFile = vscode.commands.registerCommand('pointer.chat.attachCurrentFile', async () => {
		const editor = vscode.window.activeTextEditor;
		if (!editor) {
			return;
		}
		const filePath = editor.document.uri.fsPath;
		chatSessionStore.addPinnedContext(path.basename(filePath), filePath, 'file');
	});

	const attachCurrentSelection = vscode.commands.registerCommand('pointer.chat.attachSelection', async () => {
		const editor = vscode.window.activeTextEditor;
		if (!editor) {
			return;
		}
		const selectedText = editor.document.getText(editor.selection);
		if (!selectedText || selectedText.trim().length === 0) {
			return;
		}
		const label = selectedText.length > 30 ? `${selectedText.slice(0, 30)}...` : selectedText;
		chatSessionStore.addPinnedContext(label, selectedText, 'selection');
	});

	const pinCustomContext = vscode.commands.registerCommand('pointer.chat.pinContext', async () => {
		const value = await vscode.window.showInputBox({
			prompt: 'Pin context text'
		});
		if (!value || value.trim().length === 0) {
			return;
		}
		const label = value.length > 30 ? `${value.slice(0, 30)}...` : value;
		chatSessionStore.addPinnedContext(label, value, 'manual');
	});

	const removePinnedContext = vscode.commands.registerCommand('pointer.chat.removePinnedContext', async (contextItem) => {
		if (contextItem?.id) {
			chatSessionStore.removePinnedContext(contextItem.id);
		}
	});

	const openContextExcludes = vscode.commands.registerCommand('pointer.context.openExcludes', async () => {
		const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
		if (!workspaceFolder) {
			void vscode.window.showWarningMessage('Open a workspace folder to edit Pointer excludes.');
			return;
		}
		const pointerDirectory = path.join(workspaceFolder.uri.fsPath, '.pointer');
		const excludesPath = path.join(pointerDirectory, 'excludes');
		await fs.mkdir(pointerDirectory, { recursive: true });
		try {
			await fs.access(excludesPath);
		} catch {
			await fs.writeFile(excludesPath, '# One pattern per line\n', 'utf8');
		}
		const document = await vscode.workspace.openTextDocument(vscode.Uri.file(excludesPath));
		await vscode.window.showTextDocument(document);
	});

	const refreshRulesAudit = vscode.commands.registerCommand('pointer.rules.refresh', async () => {
		const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
		if (!workspaceFolder) {
			rulesAuditProvider.setRules([]);
			return;
		}
		const rulesDirectory = path.join(workspaceFolder.uri.fsPath, '.pointer', 'rules');
		const rulesProfile = vscode.workspace.getConfiguration('pointer.prompts').get('rulesProfile', 'workspace');
		try {
			const entries = await fs.readdir(rulesDirectory, { withFileTypes: true });
			const ruleItems = entries
				.filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
				.sort((left, right) => left.name.localeCompare(right.name))
				.map((entry) => {
					const item = new vscode.TreeItem(entry.name, vscode.TreeItemCollapsibleState.None);
					item.description = `workspace | profile=${rulesProfile}`;
					return item;
				});
			rulesAuditProvider.setRules(ruleItems);
		} catch {
			rulesAuditProvider.setRules([]);
		}
	});

	const refreshMcpAudit = vscode.commands.registerCommand('pointer.mcp.refresh', async () => {
		const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
		if (!workspaceFolder) {
			mcpAuditProvider.setItems([]);
			return;
		}
		const pointerDirectory = path.join(workspaceFolder.uri.fsPath, '.pointer');
		const serversPath = path.join(pointerDirectory, 'mcp-servers.json');
		const allowlistPath = path.join(pointerDirectory, 'mcp-allowlist.json');
		try {
			const serverPayload = JSON.parse(await fs.readFile(serversPath, 'utf8'));
			const allowlistPayload = JSON.parse(await fs.readFile(allowlistPath, 'utf8'));
			const servers = Array.isArray(serverPayload.servers) ? serverPayload.servers : [];
			const allowlist = Array.isArray(allowlistPayload.tools) ? allowlistPayload.tools : [];
			const items = [];
			for (const server of servers) {
				const serverItem = new vscode.TreeItem(`Server: ${server.name ?? 'unknown'}`, vscode.TreeItemCollapsibleState.None);
				serverItem.description = server.command ?? '';
				items.push(serverItem);
			}
			for (const tool of allowlist) {
				const toolItem = new vscode.TreeItem(`Allowed tool: ${tool}`, vscode.TreeItemCollapsibleState.None);
				toolItem.description = 'workspace allowlist';
				items.push(toolItem);
			}
			mcpAuditProvider.setItems(items);
		} catch {
			mcpAuditProvider.setItems([]);
		}
	});

	const openPatchDiff = vscode.commands.registerCommand('pointer.patch.openDiff', async (patchFile) => {
		if (!patchFile?.diff || !patchFile?.path) {
			return;
		}
		const preview = toDiffPreview(patchFile.diff);
		const beforeDocument = await vscode.workspace.openTextDocument({ content: preview.before || '' });
		const afterDocument = await vscode.workspace.openTextDocument({ content: preview.after || '' });
		await vscode.commands.executeCommand(
			'vscode.diff',
			beforeDocument.uri,
			afterDocument.uri,
			`Patch Preview: ${patchFile.path}`
		);
	});

	const applyPatchFile = vscode.commands.registerCommand('pointer.patch.applyFile', async (patchFile) => {
		if (!patchFile?.path) {
			return;
		}
		const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
		if (!workspaceFolder) {
			patchReviewStore.markConflict(patchFile.path, 'No workspace folder available for apply.');
			void vscode.window.showWarningMessage(`Cannot apply patch for ${patchFile.path}: workspace folder unavailable.`);
			return;
		}
		const candidatePath = path.isAbsolute(patchFile.path)
			? patchFile.path
			: path.join(workspaceFolder.uri.fsPath, patchFile.path);
		try {
			await vscode.workspace.fs.stat(vscode.Uri.file(candidatePath));
		} catch {
			patchReviewStore.markConflict(patchFile.path, 'Target file does not exist.');
			void vscode.window.showWarningMessage(`Cannot apply patch for ${patchFile.path}: target file missing.`);
			return;
		}
		patchReviewStore.applyFile(patchFile.path);
	});

	const rejectPatchFile = vscode.commands.registerCommand('pointer.patch.rejectFile', async (patchFile) => {
		if (!patchFile?.path) {
			return;
		}
		patchReviewStore.rejectFile(patchFile.path);
	});

	const applyAllPatchFiles = vscode.commands.registerCommand('pointer.patch.applyAll', async () => {
		patchReviewStore.applyAll();
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
	void refreshRulesAudit();
	void refreshMcpAudit();

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
		if (event.affectsConfiguration('pointer.prompts.rulesProfile')) {
			void refreshRulesAudit();
		}
	});
	const typingCancelWatcher = vscode.workspace.onDidChangeTextDocument(() => {
		inlineCompletion.cancelPending();
	});
	const sessionSelectionWatcher = chatSessionTree.onDidChangeSelection((event) => {
		const selected = event.selection[0];
		if (selected?.id) {
			chatSessionStore.setActiveSession(selected.id);
		}
	});

	const routerPlanWatcher = internalApi.onDidCreateRouterPlan((plan) => {
		routerContextViewProvider.refreshFromPlan(plan);
	});
	const patchReviewWatcher = patchReviewStore.onDidChange(() => {
		const summary = patchReviewStore.getSummary();
		if (summary.total > 0) {
			void vscode.window.setStatusBarMessage(
				`Pointer patches - pending: ${summary.pending}, applied: ${summary.applied}, rejected: ${summary.rejected}, conflicts: ${summary.conflicts}`,
				3000
			);
			if (summary.conflicts > 0) {
				void vscode.window.showWarningMessage('Pointer patch apply conflicts detected. Review conflicted files before applying all.');
			}
		}
	});

	context.subscriptions.push(
		pointerTree,
		contextSentTree,
		chatSessionTree,
		chatSessionProvider,
		chatMessageTree,
		chatMessageProvider,
		chatContextTree,
		chatContextProvider,
		patchReviewTree,
		patchReviewProvider,
		rulesAuditTree,
		mcpAuditTree,
		inlineCompletionRegistration,
		statusBarItem,
		configWatcher,
		typingCancelWatcher,
		routerPlanWatcher,
		openChat,
		toggleTab,
		selectModel,
		selectChatProvider,
		selectChatModel,
		openSettings,
		cancelTabCompletion,
		acceptPartialTabCompletion,
		createChatSession,
		renameChatSession,
		deleteChatSession,
		exportChatSessions,
		importChatSessions,
		sendChatMessage,
		cancelChatMessage,
		attachCurrentFile,
		attachCurrentSelection,
		pinCustomContext,
		removePinnedContext,
		openContextExcludes,
		refreshRulesAudit,
		refreshMcpAudit,
		openPatchDiff,
		applyPatchFile,
		rejectPatchFile,
		applyAllPatchFiles,
		patchReviewWatcher,
		sessionSelectionWatcher
	);
	return internalApi;
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
};
