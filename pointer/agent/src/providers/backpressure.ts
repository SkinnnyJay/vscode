/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export class ProviderRequestQueue {
	private readonly maxConcurrent: number;
	private running: number;
	private readonly pending: Array<() => void>;

	constructor(maxConcurrent = 2) {
		this.maxConcurrent = Math.max(1, maxConcurrent);
		this.running = 0;
		this.pending = [];
	}

	private drain(): void {
		while (this.running < this.maxConcurrent && this.pending.length > 0) {
			const next = this.pending.shift();
			this.running += 1;
			next?.();
		}
	}

	async enqueue<T>(operation: () => Promise<T>): Promise<T> {
		await new Promise<void>((resolve) => {
			this.pending.push(resolve);
			this.drain();
		});

		try {
			return await operation();
		} finally {
			this.running = Math.max(0, this.running - 1);
			this.drain();
		}
	}

	getState(): { readonly running: number; readonly queued: number; readonly maxConcurrent: number } {
		return {
			running: this.running,
			queued: this.pending.length,
			maxConcurrent: this.maxConcurrent
		};
	}
}
