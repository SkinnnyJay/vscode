/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface PromptInjectionAssessment {
	readonly risk: 'low' | 'high';
	readonly reasons: readonly string[];
}

const suspiciousPatterns: ReadonlyArray<{ readonly pattern: RegExp; readonly reason: string }> = [
	{ pattern: /ignore (all|previous) instructions/i, reason: 'Attempts to override instruction hierarchy.' },
	{ pattern: /exfiltrat|secrets?|tokens?/i, reason: 'Requests potential secret disclosure.' },
	{ pattern: /curl\s+https?:\/\//i, reason: 'Requests arbitrary network command execution.' },
	{ pattern: /(sudo|rm\s+-rf|powershell\s+-encodedcommand)/i, reason: 'Contains high-risk shell operation tokens.' }
];

export function assessPromptInjectionRisk(text: string): PromptInjectionAssessment {
	const reasons = suspiciousPatterns
		.filter((entry) => entry.pattern.test(text))
		.map((entry) => entry.reason);

	return {
		risk: reasons.length > 0 ? 'high' : 'low',
		reasons
	};
}

export function sanitizePatchPath(candidatePath: string): string | undefined {
	if (candidatePath.includes('..') || candidatePath.startsWith('/') || candidatePath.startsWith('\\')) {
		return undefined;
	}

	return candidatePath;
}
