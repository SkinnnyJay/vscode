/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface DiscoveryOptions {
	readonly workspacePath: string;
	readonly pointerExcludes?: readonly string[];
}

function normalizePattern(raw: string): string | undefined {
	const trimmed = raw.trim();
	if (!trimmed || trimmed.startsWith('#')) {
		return undefined;
	}
	return trimmed.replaceAll('\\', '/');
}

function matchesPattern(relativePath: string, pattern: string): boolean {
	const normalizedPath = relativePath.replaceAll('\\', '/');
	if (pattern.endsWith('/')) {
		const prefix = pattern.slice(0, -1);
		return normalizedPath === prefix || normalizedPath.startsWith(`${prefix}/`);
	}
	if (pattern.includes('*')) {
		const escaped = pattern
			.replace(/[.+?^${}()|[\]\\]/g, '\\$&')
			.replaceAll('*', '.*');
		const regex = new RegExp(`^${escaped}$`);
		return regex.test(normalizedPath);
	}
	if (normalizedPath === pattern) {
		return true;
	}
	return normalizedPath.split('/').includes(pattern);
}

async function readPatterns(filePath: string): Promise<readonly string[]> {
	try {
		const content = await fs.readFile(filePath, 'utf8');
		return content
			.split('\n')
			.map((line) => normalizePattern(line))
			.filter((line): line is string => Boolean(line));
	} catch {
		return [];
	}
}

async function walkDirectory(
	rootPath: string,
	directoryPath: string,
	patterns: readonly string[],
	output: string[]
): Promise<void> {
	const entries = await fs.readdir(directoryPath, { withFileTypes: true });

	for (const entry of entries) {
		const absolutePath = path.join(directoryPath, entry.name);
		const relativePath = path.relative(rootPath, absolutePath).replaceAll('\\', '/');

		if (patterns.some((pattern) => matchesPattern(relativePath, pattern))) {
			continue;
		}

		if (entry.isDirectory()) {
			await walkDirectory(rootPath, absolutePath, patterns, output);
			continue;
		}
		if (entry.isFile()) {
			output.push(relativePath);
		}
	}
}

export async function discoverWorkspaceFiles(options: DiscoveryOptions): Promise<readonly string[]> {
	const gitignorePatterns = await readPatterns(path.join(options.workspacePath, '.gitignore'));
	const pointerExcludePatterns = await readPatterns(path.join(options.workspacePath, '.pointer', 'excludes'));
	const explicitPointerPatterns = (options.pointerExcludes ?? [])
		.map((line) => normalizePattern(line))
		.filter((line): line is string => Boolean(line));
	const ignoredPatterns = [...gitignorePatterns, ...pointerExcludePatterns, ...explicitPointerPatterns];

	const files: string[] = [];
	await walkDirectory(options.workspacePath, options.workspacePath, ignoredPatterns, files);
	return files.sort();
}
