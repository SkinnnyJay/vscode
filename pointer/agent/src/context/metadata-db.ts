/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface ContextMetadataRecord {
	readonly relativePath: string;
	readonly tokenEstimate: number;
	readonly updatedAt: number;
	readonly embedding?: readonly number[];
}

interface MetadataFileShape {
	readonly records: readonly ContextMetadataRecord[];
}

export class ContextMetadataDb {
	private readonly dbPath: string;

	constructor(workspacePath: string) {
		this.dbPath = path.join(workspacePath, '.pointer', 'context-metadata.json');
	}

	private async ensureDirectory(): Promise<void> {
		await fs.mkdir(path.dirname(this.dbPath), { recursive: true });
	}

	private async readFile(): Promise<MetadataFileShape> {
		try {
			const content = await fs.readFile(this.dbPath, 'utf8');
			const parsed = JSON.parse(content) as MetadataFileShape;
			return parsed;
		} catch {
			return { records: [] };
		}
	}

	private async writeFile(shape: MetadataFileShape): Promise<void> {
		await this.ensureDirectory();
		await fs.writeFile(this.dbPath, JSON.stringify(shape, null, 2), 'utf8');
	}

	async upsert(record: ContextMetadataRecord): Promise<void> {
		const current = await this.readFile();
		const next = current.records.filter((item) => item.relativePath !== record.relativePath);
		next.push(record);
		await this.writeFile({ records: next });
	}

	async remove(relativePath: string): Promise<void> {
		const current = await this.readFile();
		const next = current.records.filter((item) => item.relativePath !== relativePath);
		await this.writeFile({ records: next });
	}

	async list(): Promise<readonly ContextMetadataRecord[]> {
		const current = await this.readFile();
		return [...current.records].sort((a, b) => a.relativePath.localeCompare(b.relativePath));
	}
}
