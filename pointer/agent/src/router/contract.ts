/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export type Surface = 'tab' | 'chat' | 'agent';

export interface RouterPolicy {
	readonly terminalToolPolicy: 'disabled' | 'confirm' | 'allow';
	readonly filesystemToolPolicy: 'diff-only' | 'confirm' | 'allow';
	readonly networkToolPolicy: 'disabled' | 'confirm' | 'allow';
	readonly maxInputTokens: number;
	readonly maxOutputTokens: number;
}

export interface RouterTemplateRef {
	readonly id: string;
	readonly version: string;
}

export interface RouterSelection {
	readonly surface: Surface;
	readonly providerId: string;
	readonly modelId: string;
	readonly template: RouterTemplateRef;
	readonly policy: RouterPolicy;
}

export interface RouterContextSource {
	readonly kind: 'system' | 'rules' | 'pinned' | 'retrieved' | 'user' | 'tools';
	readonly label: string;
	readonly tokenEstimate: number;
}

export interface RouterRequest {
	readonly requestId: string;
	readonly timestampIso: string;
	readonly selection: RouterSelection;
	readonly context: readonly RouterContextSource[];
	readonly prompt: string;
}

export interface RouterPlan {
	readonly request: RouterRequest;
	readonly totalInputTokens: number;
	readonly budgetRemaining: number;
	readonly explainability: readonly string[];
}
