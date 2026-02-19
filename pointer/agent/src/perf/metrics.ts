/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { Surface } from '../router/contract.js';

interface ActiveRequest {
	readonly surface: Surface;
	readonly startedAt: number;
	firstTokenAt?: number;
}

export interface CompletedRequestMetric {
	readonly requestId: string;
	readonly surface: Surface;
	readonly latencyMs: number;
	readonly ttftMs?: number;
	readonly cancelled: boolean;
}

export interface MetricsSummary {
	readonly totalRequests: number;
	readonly cancellationRate: number;
	readonly averageLatencyMs: number;
	readonly averageTtftMs: number;
}

export class RequestMetricsRecorder {
	private readonly active: Map<string, ActiveRequest>;
	private readonly completed: CompletedRequestMetric[];

	constructor() {
		this.active = new Map();
		this.completed = [];
	}

	recordRequestStart(requestId: string, surface: Surface, startedAt = Date.now()): void {
		this.active.set(requestId, {
			surface,
			startedAt
		});
	}

	recordFirstToken(requestId: string, timestamp = Date.now()): void {
		const active = this.active.get(requestId);
		if (!active || active.firstTokenAt) {
			return;
		}
		active.firstTokenAt = timestamp;
	}

	recordRequestEnd(requestId: string, cancelled: boolean, endedAt = Date.now()): void {
		const active = this.active.get(requestId);
		if (!active) {
			return;
		}
		this.active.delete(requestId);

		this.completed.push({
			requestId,
			surface: active.surface,
			latencyMs: Math.max(0, endedAt - active.startedAt),
			ttftMs: active.firstTokenAt ? Math.max(0, active.firstTokenAt - active.startedAt) : undefined,
			cancelled
		});
	}

	listCompleted(): readonly CompletedRequestMetric[] {
		return this.completed;
	}

	summarize(): MetricsSummary {
		if (this.completed.length === 0) {
			return {
				totalRequests: 0,
				cancellationRate: 0,
				averageLatencyMs: 0,
				averageTtftMs: 0
			};
		}

		const totalRequests = this.completed.length;
		const cancelled = this.completed.filter((item) => item.cancelled).length;
		const latencyTotal = this.completed.reduce((sum, item) => sum + item.latencyMs, 0);
		const ttftValues = this.completed.map((item) => item.ttftMs).filter((value): value is number => typeof value === 'number');
		const ttftTotal = ttftValues.reduce((sum, value) => sum + value, 0);

		return {
			totalRequests,
			cancellationRate: cancelled / totalRequests,
			averageLatencyMs: latencyTotal / totalRequests,
			averageTtftMs: ttftValues.length > 0 ? ttftTotal / ttftValues.length : 0
		};
	}
}
