/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const vscode = require('vscode');
const { PointerTabCompletionEngine } = require('./tab-completion-engine.js');

/**
 * @param {import('../internal-api.js').PointerInternalApi} internalApi
 */
function createInlineCompletionProvider(internalApi) {
	const engine = new PointerTabCompletionEngine({
		requestPlan: async ({ providerId, modelId, prompt }) => {
			await internalApi.requestRouterPlan({
				surface: 'tab',
				providerId,
				modelId,
				templateId: 'tab-default',
				userPrompt: prompt,
				context: []
			});
		},
		getConfig: () => {
			const tabConfig = vscode.workspace.getConfiguration('pointer.tab');
			const defaultsConfig = vscode.workspace.getConfiguration('pointer.defaults');
			return {
				enabled: tabConfig.get('enabled', true),
				providerId: defaultsConfig.get('tab.provider', 'auto'),
				modelId: defaultsConfig.get('tab.model', 'auto'),
				rulesProfile: vscode.workspace.getConfiguration('pointer.prompts').get('rulesProfile', 'workspace'),
				maxLatencyMs: tabConfig.get('maxLatencyMs', 400),
				debounceMs: tabConfig.get('debounceMs', 80)
			};
		}
	});

	/** @type {vscode.InlineCompletionItemProvider} */
	const provider = {
		async provideInlineCompletionItems(document, position, _context, token) {
			const editor = vscode.window.activeTextEditor;
			const selectionsCount = editor?.selections.length ?? 1;
			if (selectionsCount > 1) {
				return { items: [] };
			}

			const lineText = document.lineAt(position.line).text;
			const linePrefix = lineText.slice(0, position.character);
			const lineSuffix = lineText.slice(position.character);
			const suggestion = await engine.provide(
				{
					uri: document.uri.toString(),
					linePrefix,
					lineSuffix,
					line: position.line,
					character: position.character,
					selectionsCount
				},
				{
					isCancellationRequested: token.isCancellationRequested,
					onCancellationRequested: (callback) => token.onCancellationRequested(callback)
				}
			);

			if (!suggestion || !suggestion.text) {
				return { items: [] };
			}

			return {
				items: [
					new vscode.InlineCompletionItem(
						suggestion.text,
						new vscode.Range(position.line, position.character, position.line, position.character)
					)
				]
			};
		}
	};

	return {
		provider,
		cancelPending: () => engine.cancelPending(),
		engine
	};
}

module.exports = {
	createInlineCompletionProvider
};
