/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface AgentPatchFile {
	readonly path: string;
	readonly diff: string;
	readonly rationale: string;
	readonly applyStrategy: 'safe' | 'three-way';
}

export interface AgentPatchResponse {
	readonly traceId: string;
	readonly summary: string;
	readonly files: readonly AgentPatchFile[];
}

export interface PatchValidationResult {
	readonly valid: boolean;
	readonly errors: readonly string[];
}

export function validatePatchResponse(response: AgentPatchResponse): PatchValidationResult {
	const errors: string[] = [];

	if (!response.traceId.trim()) {
		errors.push('traceId is required');
	}
	if (!response.summary.trim()) {
		errors.push('summary is required');
	}
	if (response.files.length === 0) {
		errors.push('files must include at least one patch file');
	}

	for (const [index, file] of response.files.entries()) {
		if (!file.path.trim()) {
			errors.push(`files[${index}].path is required`);
		}
		if (!file.diff.includes('@@')) {
			errors.push(`files[${index}].diff must include unified diff hunks`);
		}
		if (!file.rationale.trim()) {
			errors.push(`files[${index}].rationale is required`);
		}
	}

	return {
		valid: errors.length === 0,
		errors
	};
}
