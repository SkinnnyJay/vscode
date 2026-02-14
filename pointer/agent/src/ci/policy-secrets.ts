/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface CiPolicyBundle {
	readonly allowedProviders: readonly string[];
	readonly dataBoundary: 'workspace-only' | 'workspace-and-selected-secrets';
	readonly allowedSecretEnvKeys: readonly string[];
}

export interface CiPolicyRuntime {
	readonly policy: CiPolicyBundle;
	readonly availableSecrets: Readonly<Record<string, string>>;
}

const defaultPolicy: CiPolicyBundle = {
	allowedProviders: ['codex', 'claude', 'opencode'],
	dataBoundary: 'workspace-only',
	allowedSecretEnvKeys: []
};

export async function loadCiPolicyBundle(workspacePath: string): Promise<CiPolicyBundle> {
	const filePath = path.join(workspacePath, '.pointer', 'ci-policy.json');
	try {
		const content = await fs.readFile(filePath, 'utf8');
		const parsed = JSON.parse(content) as Partial<CiPolicyBundle>;
		return {
			allowedProviders: parsed.allowedProviders ?? defaultPolicy.allowedProviders,
			dataBoundary: parsed.dataBoundary ?? defaultPolicy.dataBoundary,
			allowedSecretEnvKeys: parsed.allowedSecretEnvKeys ?? defaultPolicy.allowedSecretEnvKeys
		};
	} catch {
		return defaultPolicy;
	}
}

export async function loadCiPolicyRuntime(
	workspacePath: string,
	environment: NodeJS.ProcessEnv = process.env
): Promise<CiPolicyRuntime> {
	const policy = await loadCiPolicyBundle(workspacePath);
	const availableSecrets: Record<string, string> = {};
	for (const key of policy.allowedSecretEnvKeys) {
		const value = environment[key];
		if (typeof value === 'string' && value.length > 0) {
			availableSecrets[key] = value;
		}
	}

	return {
		policy,
		availableSecrets
	};
}
