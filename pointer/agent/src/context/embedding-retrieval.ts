/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { ContextMetadataRecord } from './metadata-db.js';

export interface EmbeddingRetrievalOptions {
	readonly enabled: boolean;
	readonly maxResults?: number;
}

function cosineSimilarity(left: readonly number[], right: readonly number[]): number {
	if (left.length !== right.length || left.length === 0) {
		return 0;
	}

	let dot = 0;
	let leftNorm = 0;
	let rightNorm = 0;

	for (let index = 0; index < left.length; index += 1) {
		dot += left[index] * right[index];
		leftNorm += left[index] ** 2;
		rightNorm += right[index] ** 2;
	}

	if (leftNorm === 0 || rightNorm === 0) {
		return 0;
	}
	return dot / (Math.sqrt(leftNorm) * Math.sqrt(rightNorm));
}

export function retrieveByEmbedding(
	queryEmbedding: readonly number[],
	records: readonly ContextMetadataRecord[],
	options: EmbeddingRetrievalOptions
): readonly ContextMetadataRecord[] {
	if (!options.enabled) {
		return [];
	}

	const maxResults = options.maxResults ?? 8;
	return [...records]
		.filter((record) => Boolean(record.embedding))
		.map((record) => ({
			record,
			score: cosineSimilarity(queryEmbedding, record.embedding ?? [])
		}))
		.filter((entry) => entry.score > 0)
		.sort((a, b) => b.score - a.score)
		.slice(0, maxResults)
		.map((entry) => entry.record);
}
