/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { spawn } from 'node:child_process';
import { Readable } from 'node:stream';
import { ProviderAdapter, ProviderRequest, ProviderResponse, ProviderStreamChunk } from './adapter-types.js';
import { classifyProviderError } from './errors.js';

export interface SpawnedOpenCodeProcess {
	readonly stdout: Readable | null;
	readonly stderr: Readable | null;
	kill(signal?: NodeJS.Signals): boolean;
	on(event: 'error', listener: (error: Error) => void): this;
	on(event: 'close', listener: (code: number | null) => void): this;
}

export type SpawnOpenCodeProcess = (command: string, args: readonly string[]) => SpawnedOpenCodeProcess;

export interface OpenCodeAdapterOptions {
	readonly binaryName?: string;
	readonly spawnProcess?: SpawnOpenCodeProcess;
}

function defaultSpawnProcess(command: string, args: readonly string[]): SpawnedOpenCodeProcess {
	return spawn(command, [...args], {
		stdio: ['ignore', 'pipe', 'pipe'],
		windowsHide: true
	});
}

export class OpenCodeAdapter implements ProviderAdapter {
	private readonly binaryName: string;
	private readonly spawnProcess: SpawnOpenCodeProcess;

	constructor(options: OpenCodeAdapterOptions = {}) {
		this.binaryName = options.binaryName ?? 'opencode';
		this.spawnProcess = options.spawnProcess ?? defaultSpawnProcess;
	}

	async stream(
		request: ProviderRequest,
		onChunk: (chunk: ProviderStreamChunk) => void,
		signal?: AbortSignal
	): Promise<ProviderResponse> {
		const args = this.buildArgs(request);
		const child = this.spawnProcess(this.binaryName, args);

		return await new Promise<ProviderResponse>((resolve, reject) => {
			let stdout = '';
			let stderr = '';
			let settled = false;

			const finalize = (fn: () => void) => {
				if (settled) {
					return;
				}
				settled = true;
				if (signal) {
					signal.removeEventListener('abort', onAbort);
				}
				fn();
			};

			const onAbort = () => {
				onChunk({ stream: 'system', chunk: 'cancelled' });
				child.kill('SIGTERM');
			};

			if (signal) {
				if (signal.aborted) {
					onAbort();
				}
				signal.addEventListener('abort', onAbort);
			}

			child.stdout?.on('data', (value) => {
				const text = value.toString();
				stdout += text;
				onChunk({ stream: 'stdout', chunk: text });
			});

			child.stderr?.on('data', (value) => {
				const text = value.toString();
				stderr += text;
				onChunk({ stream: 'stderr', chunk: text });
			});

			child.on('error', (error) => {
				finalize(() => reject(new Error(classifyProviderError(error).message)));
			});

			child.on('close', (exitCode) => {
				const normalizedExitCode = exitCode ?? 0;
				if (normalizedExitCode === 0) {
					finalize(() => resolve({ output: stdout, stderr, exitCode: normalizedExitCode }));
					return;
				}

				const classified = classifyProviderError(stderr || stdout || `OpenCode exited with code ${normalizedExitCode}`);
				finalize(() => reject(new Error(`${classified.kind}: ${classified.message}`)));
			});
		});
	}

	private buildArgs(request: ProviderRequest): readonly string[] {
		const outputFormat = request.outputFormat ?? (request.jsonMode ? 'json' : 'text');
		const args: string[] = ['--model', request.modelId, '--prompt', request.prompt];
		if (outputFormat !== 'text') {
			args.push('--output', outputFormat);
		}
		if (request.extraArgs && request.extraArgs.length > 0) {
			args.push(...request.extraArgs);
		}
		return args;
	}
}
