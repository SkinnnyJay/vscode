/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { loadRuleSet } from '../src/rules/loader.js';

async function setupRuleWorkspace(): Promise<{ readonly workspace: string; readonly globalRules: string }> {
	const root = await fs.mkdtemp(path.join(os.tmpdir(), 'pointer-rules-'));
	const workspace = path.join(root, 'workspace');
	const globalRules = path.join(root, 'global-rules');
	await fs.mkdir(path.join(workspace, '.pointer', 'rules'), { recursive: true });
	await fs.mkdir(globalRules, { recursive: true });

	await fs.writeFile(path.join(globalRules, 'safety.md'), 'global safety');
	await fs.writeFile(path.join(workspace, '.pointer', 'rules', 'style.md'), 'workspace style');
	await fs.writeFile(path.join(workspace, '.pointer', 'rules', 'safety.md'), 'workspace safety');
	return { workspace, globalRules };
}

test('loadRuleSet loads workspace rules from .pointer/rules', async () => {
	const { workspace } = await setupRuleWorkspace();
	const rules = await loadRuleSet(workspace);

	assert.deepEqual(rules.map((rule) => rule.id), ['safety.md', 'style.md']);
	assert.equal(rules.find((rule) => rule.id === 'style.md')?.source, 'workspace');
	await fs.rm(path.dirname(workspace), { recursive: true, force: true });
});

test('loadRuleSet applies precedence global -> workspace -> session', async () => {
	const { workspace, globalRules } = await setupRuleWorkspace();
	const rules = await loadRuleSet(workspace, {
		globalRulesPath: globalRules,
		sessionRules: [
			{
				id: 'safety.md',
				source: 'session',
				content: 'session safety override'
			}
		]
	});

	const safetyRule = rules.find((rule) => rule.id === 'safety.md');
	assert.equal(safetyRule?.source, 'session');
	assert.equal(safetyRule?.content, 'session safety override');
	await fs.rm(path.dirname(workspace), { recursive: true, force: true });
});
