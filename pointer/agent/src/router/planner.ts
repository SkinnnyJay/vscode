/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { RouterContextSource, RouterPlan, RouterRequest, RouterSelection } from './contract.js';

export interface CreateRouterPlanInput {
	readonly selection: RouterSelection;
	readonly prompt: string;
	readonly context: readonly RouterContextSource[];
	readonly requestId?: string;
	readonly timestampIso?: string;
}

function generateRequestId(): string {
	return `router-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

function estimatePromptTokens(prompt: string): number {
	return Math.max(1, Math.ceil(prompt.length / 4));
}

function fitContextWithinBudget(
	context: readonly RouterContextSource[],
	initialTokenCost: number,
	maxInputTokens: number
): { readonly included: readonly RouterContextSource[]; readonly dropped: readonly RouterContextSource[]; readonly totalInputTokens: number } {
	const included: RouterContextSource[] = [];
	const dropped: RouterContextSource[] = [];
	let runningTotal = initialTokenCost;

	for (const source of context) {
		if (runningTotal + source.tokenEstimate <= maxInputTokens) {
			included.push(source);
			runningTotal += source.tokenEstimate;
		} else {
			dropped.push(source);
		}
	}

	return {
		included,
		dropped,
		totalInputTokens: runningTotal
	};
}

export function createRouterPlan(input: CreateRouterPlanInput): RouterPlan {
	const requestId = input.requestId ?? generateRequestId();
	const timestampIso = input.timestampIso ?? new Date().toISOString();
	const promptTokens = estimatePromptTokens(input.prompt);
	const maxInputTokens = input.selection.policy.maxInputTokens;

	const fitted = fitContextWithinBudget(input.context, promptTokens, maxInputTokens);
	const budgetRemaining = Math.max(0, maxInputTokens - fitted.totalInputTokens);
	const explainability: string[] = [
		`surface=${input.selection.surface}`,
		`provider=${input.selection.providerId}`,
		`model=${input.selection.modelId}`,
		`maxInputTokens=${maxInputTokens}`,
		`promptTokens=${promptTokens}`,
		`includedContext=${fitted.included.length}`,
		`droppedContext=${fitted.dropped.length}`,
		`budgetRemaining=${budgetRemaining}`
	];

	if (fitted.dropped.length > 0) {
		explainability.push(`droppedLabels=${fitted.dropped.map((source) => source.label).join(',')}`);
	}

	const request: RouterRequest = {
		requestId,
		timestampIso,
		selection: input.selection,
		context: fitted.included,
		prompt: input.prompt
	};

	return {
		request,
		totalInputTokens: fitted.totalInputTokens,
		budgetRemaining,
		explainability
	};
}
