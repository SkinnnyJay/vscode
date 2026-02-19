/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { PullRequestAnnotation } from './annotations.js';

export interface GitHubCheckRunPayload {
	readonly name: string;
	readonly headSha: string;
	readonly status: 'completed';
	readonly conclusion: 'success' | 'neutral' | 'failure';
	readonly output: {
		readonly title: string;
		readonly summary: string;
		readonly annotations: readonly PullRequestAnnotation[];
	};
}

export function createCheckRunPayload(
	headSha: string,
	summary: string,
	annotations: readonly PullRequestAnnotation[]
): GitHubCheckRunPayload {
	return {
		name: 'pointer-pr-review',
		headSha,
		status: 'completed',
		conclusion: annotations.length > 0 ? 'neutral' : 'success',
		output: {
			title: 'Pointer PR review',
			summary,
			annotations
		}
	};
}
