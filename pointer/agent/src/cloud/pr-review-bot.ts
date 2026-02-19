/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { runHeadlessAgent } from '../ci/headless-agent.js';
import { buildPatchAnnotations, PullRequestAnnotation } from './annotations.js';
import { createCheckRunPayload, GitHubCheckRunPayload } from './checks.js';

export interface PullRequestReviewInput {
	readonly workspacePath: string;
	readonly pullRequestNumber: number;
	readonly headSha: string;
	readonly diffSummary: string;
}

export interface PullRequestReviewResult {
	readonly summary: string;
	readonly annotations: readonly PullRequestAnnotation[];
	readonly checkRun: GitHubCheckRunPayload;
}

export async function runPullRequestReviewBot(input: PullRequestReviewInput): Promise<PullRequestReviewResult> {
	const patch = await runHeadlessAgent({
		workspacePath: input.workspacePath,
		prompt: `Review pull request #${input.pullRequestNumber}: ${input.diffSummary}`,
		targetFile: 'PR_REVIEW.md'
	});
	const annotations = buildPatchAnnotations(patch);
	const summary = `Pointer reviewed PR #${input.pullRequestNumber} and produced ${annotations.length} annotation(s).`;

	return {
		summary,
		annotations,
		checkRun: createCheckRunPayload(input.headSha, summary, annotations)
	};
}
