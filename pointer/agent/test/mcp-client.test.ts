/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { McpClient, McpTransport } from '../src/mcp/client.js';

test('McpClient connects and lists tools from transport', async () => {
	const transport: McpTransport = {
		async request(method) {
			if (method === 'tools/list') {
				return [
					{ name: 'search', description: 'Search docs' }
				];
			}
			return [];
		},
		async close() {}
	};

	const client = new McpClient(() => transport);
	client.connect({
		name: 'local',
		command: 'echo'
	});

	const tools = await client.listTools();
	assert.deepEqual(tools.map((tool) => tool.name), ['search']);
	await client.close();
});

test('McpClient forwards tool call payload through transport', async () => {
	let capturedPayload;
	const transport: McpTransport = {
		async request(method, params) {
			capturedPayload = { method, params };
			return { ok: true };
		},
		async close() {}
	};

	const client = new McpClient(() => transport);
	client.connect({
		name: 'local',
		command: 'echo'
	});

	const result = await client.callTool('search', { query: 'hooks' });
	assert.deepEqual(result, { ok: true });
	assert.deepEqual(capturedPayload, {
		method: 'tools/call',
		params: {
			name: 'search',
			args: { query: 'hooks' }
		}
	});
	await client.close();
});
