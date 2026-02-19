/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export type PromptPartKind = 'system' | 'rules' | 'pinned' | 'retrieved' | 'user' | 'tools';

export interface PromptPart {
	readonly kind: PromptPartKind;
	readonly label: string;
	readonly content: string;
	readonly tokenEstimate: number;
}

export interface PromptAssemblyInput {
	readonly system?: readonly PromptPart[];
	readonly rules?: readonly PromptPart[];
	readonly pinned?: readonly PromptPart[];
	readonly retrieved?: readonly PromptPart[];
	readonly user?: readonly PromptPart[];
	readonly tools?: readonly PromptPart[];
}

const promptOrdering: readonly PromptPartKind[] = ['system', 'rules', 'pinned', 'retrieved', 'user', 'tools'];

function readPromptParts(input: PromptAssemblyInput, kind: PromptPartKind): readonly PromptPart[] {
	switch (kind) {
		case 'system':
			return input.system ?? [];
		case 'rules':
			return input.rules ?? [];
		case 'pinned':
			return input.pinned ?? [];
		case 'retrieved':
			return input.retrieved ?? [];
		case 'user':
			return input.user ?? [];
		case 'tools':
			return input.tools ?? [];
	}
}

export function assemblePromptParts(input: PromptAssemblyInput): readonly PromptPart[] {
	const ordered = promptOrdering.flatMap((kind) => readPromptParts(input, kind));
	return ordered;
}

export function buildPromptText(parts: readonly PromptPart[]): string {
	return parts
		.map((part) => `[[${part.kind.toUpperCase()}:${part.label}]]\n${part.content}`)
		.join('\n\n');
}

export function estimatePromptTokens(parts: readonly PromptPart[]): number {
	return parts.reduce((sum, part) => sum + part.tokenEstimate, 0);
}
