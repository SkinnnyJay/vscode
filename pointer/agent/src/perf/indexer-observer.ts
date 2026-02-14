/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { promises as fs } from 'node:fs';
import path from 'node:path';

export interface IndexerObserverOptions {
	readonly workspacePath: string;
	readonly enabled: boolean;
}

export interface IndexerSample {
	readonly timestamp: number;
	readonly rssBytes: number;
	readonly heapUsedBytes: number;
	readonly userCpuMicros: number;
	readonly systemCpuMicros: number;
}

export class IndexerObserver {
	private readonly workspacePath: string;
	private readonly enabled: boolean;
	private readonly samples: IndexerSample[];

	constructor(options: IndexerObserverOptions) {
		this.workspacePath = options.workspacePath;
		this.enabled = options.enabled;
		this.samples = [];
	}

	captureSample(timestamp = Date.now()): void {
		if (!this.enabled) {
			return;
		}
		const memory = process.memoryUsage();
		const cpu = process.cpuUsage();
		this.samples.push({
			timestamp,
			rssBytes: memory.rss,
			heapUsedBytes: memory.heapUsed,
			userCpuMicros: cpu.user,
			systemCpuMicros: cpu.system
		});
	}

	listSamples(): readonly IndexerSample[] {
		return this.samples;
	}

	async flushToDisk(): Promise<void> {
		if (!this.enabled) {
			return;
		}
		const perfDirectory = path.join(this.workspacePath, 'docs', 'perf');
		await fs.mkdir(perfDirectory, { recursive: true });
		const outputPath = path.join(perfDirectory, 'indexer-observer.log.json');
		await fs.writeFile(outputPath, JSON.stringify(this.samples, null, 2), 'utf8');
	}
}
