/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { AgentPatchResponse } from '../patch/schema.js';

export interface PullRequestAnnotation {
	readonly path: string;
	readonly startLine: number;
	readonly endLine: number;
	readonly annotationLevel: 'notice' | 'warning' | 'failure';
	readonly message: string;
	readonly suggestion?: string;
}

export function buildPatchAnnotations(response: AgentPatchResponse): readonly PullRequestAnnotation[] {
	return response.files.map((file) => ({
		path: file.path,
		startLine: 1,
		endLine: 1,
		annotationLevel: 'notice',
		message: file.rationale,
		suggestion: file.diff
	}));
}
