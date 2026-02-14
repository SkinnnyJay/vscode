/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface ContextChunk {
	readonly path: string;
	readonly content: string;
	readonly tokenEstimate: number;
}

function tokenize(text: string): readonly string[] {
	return text
		.toLowerCase()
		.split(/[^a-z0-9_]+/)
		.filter((token) => token.length > 1);
}

function lexicalScore(queryTokens: readonly string[], contentTokens: readonly string[]): number {
	let score = 0;
	for (const token of queryTokens) {
		const occurrences = contentTokens.filter((candidate) => candidate === token).length;
		score += occurrences;
	}
	return score;
}

export function lexicalRetrieve(query: string, chunks: readonly ContextChunk[], maxResults = 8): readonly ContextChunk[] {
	const queryTokens = tokenize(query);
	if (queryTokens.length === 0) {
		return [];
	}

	return [...chunks]
		.map((chunk) => ({
			chunk,
			score: lexicalScore(queryTokens, tokenize(chunk.content))
		}))
		.filter((entry) => entry.score > 0)
		.sort((a, b) => b.score - a.score)
		.slice(0, maxResults)
		.map((entry) => entry.chunk);
}

export function dedupeAndMergeChunks(chunks: readonly ContextChunk[]): readonly ContextChunk[] {
	const seen = new Set<string>();
	const merged: ContextChunk[] = [];

	for (const chunk of chunks) {
		const dedupeKey = `${chunk.path}::${chunk.content}`;
		if (seen.has(dedupeKey)) {
			continue;
		}
		seen.add(dedupeKey);

		const previous = merged[merged.length - 1];
		if (previous && previous.path === chunk.path) {
			merged[merged.length - 1] = {
				path: chunk.path,
				content: `${previous.content}\n${chunk.content}`,
				tokenEstimate: previous.tokenEstimate + chunk.tokenEstimate
			};
			continue;
		}

		merged.push(chunk);
	}

	return merged;
}
