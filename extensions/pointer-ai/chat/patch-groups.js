/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const path = require('node:path');

function toDiffPreview(diff) {
	const lines = diff.split('\n');
	const before = [];
	const after = [];
	for (const line of lines) {
		if (line.startsWith('+++') || line.startsWith('---') || line.startsWith('@@')) {
			continue;
		}
		if (line.startsWith('+')) {
			after.push(line.slice(1));
		} else if (line.startsWith('-')) {
			before.push(line.slice(1));
		} else if (line.startsWith(' ')) {
			const text = line.slice(1);
			before.push(text);
			after.push(text);
		}
	}
	return {
		before: before.join('\n'),
		after: after.join('\n')
	};
}

function groupPatchFiles(files) {
	/** @type {Map<string, { id: string; label: string; files: unknown[] }>} */
	const byGroup = new Map();

	for (const file of files) {
		const directory = path.dirname(file.path).replaceAll('\\', '/');
		const id = directory === '.' ? '(root)' : directory;
		const group = byGroup.get(id) ?? {
			id,
			label: id,
			files: []
		};
		group.files.push(file);
		byGroup.set(id, group);
	}

	return [...byGroup.values()].sort((left, right) => left.id.localeCompare(right.id));
}

function buildGroupedDiffPreview(files) {
	const beforeSections = [];
	const afterSections = [];

	for (const file of files) {
		const preview = toDiffPreview(file.diff);
		beforeSections.push(`// ${file.path}\n${preview.before}`);
		afterSections.push(`// ${file.path}\n${preview.after}`);
	}

	return {
		before: beforeSections.join('\n\n'),
		after: afterSections.join('\n\n')
	};
}

module.exports = {
	toDiffPreview,
	groupPatchFiles,
	buildGroupedDiffPreview
};
