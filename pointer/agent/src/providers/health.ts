/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);

export type ProviderHealthStatus = 'healthy' | 'missing_binary' | 'error';

export interface ProviderHealthResult {
	readonly providerId: string;
	readonly status: ProviderHealthStatus;
	readonly binaryName: string;
	readonly detail: string;
	readonly installHint?: string;
}

export interface ProviderHealthCheckInput {
	readonly providerId: string;
	readonly binaryName: string;
	readonly args?: readonly string[];
	readonly installHint?: string;
}

export interface CommandRunner {
	run(binaryName: string, args: readonly string[]): Promise<{ readonly stdout: string; readonly stderr: string }>;
}

export const defaultCommandRunner: CommandRunner = {
	async run(binaryName, args) {
		const response = await execFileAsync(binaryName, [...args], { timeout: 10_000, windowsHide: true });
		return {
			stdout: response.stdout ?? '',
			stderr: response.stderr ?? ''
		};
	}
};

function classifyHealthError(error: unknown): ProviderHealthStatus {
	if (typeof error === 'object' && error !== null) {
		const withCode = error as { code?: unknown };
		if (withCode.code === 'ENOENT') {
			return 'missing_binary';
		}
	}

	return 'error';
}

function toHealthDetail(error: unknown): string {
	if (error instanceof Error) {
		return error.message;
	}
	return 'Unknown provider health error';
}

export async function checkProviderHealth(
	input: ProviderHealthCheckInput,
	runner: CommandRunner = defaultCommandRunner
): Promise<ProviderHealthResult> {
	const args = input.args ?? ['--version'];

	try {
		const response = await runner.run(input.binaryName, args);
		const detail = response.stdout.trim() || response.stderr.trim() || 'Provider responded successfully.';
		return {
			providerId: input.providerId,
			status: 'healthy',
			binaryName: input.binaryName,
			detail
		};
	} catch (error) {
		const status = classifyHealthError(error);
		return {
			providerId: input.providerId,
			status,
			binaryName: input.binaryName,
			detail: toHealthDetail(error),
			installHint: status === 'missing_binary' ? input.installHint : undefined
		};
	}
}

export async function testProvider(
	input: ProviderHealthCheckInput,
	runner: CommandRunner = defaultCommandRunner
): Promise<ProviderHealthResult> {
	return checkProviderHealth({ ...input, args: ['--help'] }, runner);
}
