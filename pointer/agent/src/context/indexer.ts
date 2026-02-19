/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { watch, FSWatcher } from 'node:fs';
import path from 'node:path';
import { discoverWorkspaceFiles } from './file-discovery.js';

export interface IndexedFileMetadata {
	readonly relativePath: string;
	readonly updatedAt: number;
}

export class ContextIndexer {
	private readonly workspacePath: string;
	private readonly index: Map<string, IndexedFileMetadata>;
	private watcher: FSWatcher | undefined;

	constructor(workspacePath: string) {
		this.workspacePath = workspacePath;
		this.index = new Map();
	}

	async buildInitialIndex(): Promise<void> {
		const files = await discoverWorkspaceFiles({ workspacePath: this.workspacePath });
		const now = Date.now();
		for (const file of files) {
			this.index.set(file, {
				relativePath: file,
				updatedAt: now
			});
		}
	}

	startWatching(): void {
		if (this.watcher) {
			return;
		}
		this.watcher = watch(this.workspacePath, { recursive: true }, (_eventType, filename) => {
			if (!filename) {
				return;
			}
			const relativePath = filename.replaceAll('\\', '/');
			this.applyFileChange(relativePath);
		});
	}

	stopWatching(): void {
		this.watcher?.close();
		this.watcher = undefined;
	}

	applyFileChange(relativePath: string): void {
		const normalized = path.normalize(relativePath).replaceAll('\\', '/');
		this.index.set(normalized, {
			relativePath: normalized,
			updatedAt: Date.now()
		});
	}

	applyFileDelete(relativePath: string): void {
		const normalized = path.normalize(relativePath).replaceAll('\\', '/');
		this.index.delete(normalized);
	}

	listIndex(): readonly IndexedFileMetadata[] {
		return [...this.index.values()].sort((a, b) => a.relativePath.localeCompare(b.relativePath));
	}
}
