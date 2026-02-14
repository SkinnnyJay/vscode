/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface RuleDocument {
	readonly id: string;
	readonly source: 'global' | 'workspace' | 'session';
	readonly content: string;
}

export interface RuleLoadOptions {
	readonly globalRulesPath?: string;
	readonly sessionRules?: readonly RuleDocument[];
}

async function loadRulesFromDirectory(directoryPath: string, source: 'global' | 'workspace'): Promise<readonly RuleDocument[]> {
	try {
		const entries = await fs.readdir(directoryPath, { withFileTypes: true });
		const files = entries.filter((entry) => entry.isFile() && entry.name.endsWith('.md'));
		const rules: RuleDocument[] = [];

		for (const file of files.sort((left, right) => left.name.localeCompare(right.name))) {
			const fullPath = path.join(directoryPath, file.name);
			const content = await fs.readFile(fullPath, 'utf8');
			rules.push({
				id: file.name,
				source,
				content
			});
		}

		return rules;
	} catch {
		return [];
	}
}

export async function loadRuleSet(workspacePath: string, options: RuleLoadOptions = {}): Promise<readonly RuleDocument[]> {
	const globalRules = options.globalRulesPath
		? await loadRulesFromDirectory(options.globalRulesPath, 'global')
		: [];
	const workspaceRules = await loadRulesFromDirectory(path.join(workspacePath, '.pointer', 'rules'), 'workspace');
	const sessionRules = options.sessionRules ?? [];

	const byId = new Map<string, RuleDocument>();
	for (const rule of globalRules) {
		byId.set(rule.id, rule);
	}
	for (const rule of workspaceRules) {
		byId.set(rule.id, rule);
	}
	for (const rule of sessionRules) {
		byId.set(rule.id, {
			...rule,
			source: 'session'
		});
	}

	return [...byId.values()].sort((left, right) => left.id.localeCompare(right.id));
}
