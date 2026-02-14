/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface WorkspaceToolAllowlist {
	readonly tools: readonly string[];
}

export async function loadWorkspaceToolAllowlist(workspacePath: string): Promise<WorkspaceToolAllowlist> {
	const filePath = path.join(workspacePath, '.pointer', 'mcp-allowlist.json');
	try {
		const content = await fs.readFile(filePath, 'utf8');
		const parsed = JSON.parse(content) as WorkspaceToolAllowlist;
		return {
			tools: parsed.tools ?? []
		};
	} catch {
		return {
			tools: []
		};
	}
}

export function isMcpToolAllowed(toolName: string, allowlist: WorkspaceToolAllowlist): boolean {
	return allowlist.tools.includes(toolName);
}
