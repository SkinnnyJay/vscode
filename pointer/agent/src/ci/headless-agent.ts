/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { AgentPatchResponse } from '../patch/schema.js';
import { loadCiPolicyRuntime } from './policy-secrets.js';

export interface HeadlessAgentInput {
	readonly workspacePath: string;
	readonly prompt: string;
	readonly traceId?: string;
	readonly targetFile?: string;
}

function createTraceId(): string {
	return `ci-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

export async function runHeadlessAgent(input: HeadlessAgentInput): Promise<AgentPatchResponse> {
	const runtime = await loadCiPolicyRuntime(input.workspacePath);
	const traceId = input.traceId ?? createTraceId();
	const targetFile = input.targetFile ?? 'README.md';
	const providerHint = runtime.policy.allowedProviders[0] ?? 'auto';

	return {
		traceId,
		summary: `Headless CI patch proposal for prompt: ${input.prompt}`,
		files: [
			{
				path: targetFile,
				diff: '@@ -1,1 +1,1 @@\n-old\n+new',
				rationale: `Generated in CI mode with provider=${providerHint}`,
				applyStrategy: 'safe'
			}
		]
	};
}
