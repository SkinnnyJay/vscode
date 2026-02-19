/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';
import { runHeadlessAgent } from '../ci/headless-agent.js';

interface CliArgs {
	readonly workspacePath: string;
	readonly prompt: string;
	readonly outputPath?: string;
	readonly targetFile?: string;
}

function parseArgs(argv: readonly string[]): CliArgs {
	const args = [...argv];
	const workspacePath = process.cwd();
	let prompt = '';
	let outputPath: string | undefined;
	let targetFile: string | undefined;

	while (args.length > 0) {
		const token = args.shift();
		if (token === '--prompt') {
			prompt = args.shift() ?? '';
			continue;
		}
		if (token === '--output') {
			outputPath = args.shift();
			continue;
		}
		if (token === '--target-file') {
			targetFile = args.shift();
		}
	}

	if (!prompt) {
		throw new Error('Missing required --prompt argument');
	}

	return {
		workspacePath,
		prompt,
		outputPath,
		targetFile
	};
}

async function main(): Promise<void> {
	const args = parseArgs(process.argv.slice(2));
	const response = await runHeadlessAgent({
		workspacePath: args.workspacePath,
		prompt: args.prompt,
		targetFile: args.targetFile
	});

	const payload = JSON.stringify(response, null, 2);
	if (args.outputPath) {
		const resolvedPath = path.isAbsolute(args.outputPath)
			? args.outputPath
			: path.join(args.workspacePath, args.outputPath);
		await fs.writeFile(resolvedPath, payload, 'utf8');
		process.stdout.write(`${resolvedPath}\n`);
		return;
	}
	process.stdout.write(`${payload}\n`);
}

void main();
