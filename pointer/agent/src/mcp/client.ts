/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { ChildProcessWithoutNullStreams, spawn } from 'node:child_process';
import readline from 'node:readline';

export interface McpServerConfig {
	readonly name: string;
	readonly command: string;
	readonly args?: readonly string[];
}

export interface McpTool {
	readonly name: string;
	readonly description: string;
}

export interface McpTransport {
	request(method: string, params?: unknown): Promise<unknown>;
	close(): Promise<void>;
}

class JsonRpcProcessTransport implements McpTransport {
	private readonly process: ChildProcessWithoutNullStreams;
	private readonly pending: Map<number, { resolve: (value: unknown) => void; reject: (reason?: unknown) => void }>;
	private idCounter: number;

	constructor(config: McpServerConfig) {
		this.process = spawn(config.command, [...(config.args ?? [])], {
			stdio: 'pipe',
			windowsHide: true
		});
		this.pending = new Map();
		this.idCounter = 0;

		const lineReader = readline.createInterface({
			input: this.process.stdout
		});
		lineReader.on('line', (line) => {
			try {
				const parsed = JSON.parse(line) as { id?: number; result?: unknown; error?: unknown };
				if (typeof parsed.id !== 'number') {
					return;
				}
				const pending = this.pending.get(parsed.id);
				if (!pending) {
					return;
				}
				this.pending.delete(parsed.id);
				if (parsed.error) {
					pending.reject(parsed.error);
				} else {
					pending.resolve(parsed.result);
				}
			} catch {
				// ignore malformed server output
			}
		});
	}

	request(method: string, params?: unknown): Promise<unknown> {
		const id = this.idCounter++;
		const payload = JSON.stringify({
			jsonrpc: '2.0',
			id,
			method,
			params
		});

		return new Promise((resolve, reject) => {
			this.pending.set(id, { resolve, reject });
			this.process.stdin.write(`${payload}\n`);
		});
	}

	async close(): Promise<void> {
		this.process.kill('SIGTERM');
	}
}

export type McpTransportFactory = (config: McpServerConfig) => McpTransport;

export class McpClient {
	private readonly transportFactory: McpTransportFactory;
	private transport: McpTransport | undefined;

	constructor(transportFactory?: McpTransportFactory) {
		this.transportFactory = transportFactory ?? ((config) => new JsonRpcProcessTransport(config));
	}

	connect(config: McpServerConfig): void {
		this.transport = this.transportFactory(config);
	}

	private assertConnected(): McpTransport {
		if (!this.transport) {
			throw new Error('MCP client is not connected.');
		}
		return this.transport;
	}

	async listTools(): Promise<readonly McpTool[]> {
		const transport = this.assertConnected();
		const response = await transport.request('tools/list');
		if (!Array.isArray(response)) {
			return [];
		}
		return response
			.filter((entry): entry is McpTool => Boolean(entry && typeof entry === 'object' && 'name' in entry && 'description' in entry));
	}

	async callTool(name: string, args: Record<string, unknown>): Promise<unknown> {
		const transport = this.assertConnected();
		return transport.request('tools/call', {
			name,
			args
		});
	}

	async close(): Promise<void> {
		if (!this.transport) {
			return;
		}
		await this.transport.close();
		this.transport = undefined;
	}
}
