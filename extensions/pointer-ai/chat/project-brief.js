/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const fs = require('node:fs/promises');
const path = require('node:path');

async function loadProjectBrief(workspacePath) {
	const briefPath = path.join(workspacePath, '.pointer', 'project-brief.md');
	try {
		const content = await fs.readFile(briefPath, 'utf8');
		return content.trim();
	} catch {
		return '';
	}
}

async function saveProjectBrief(workspacePath, briefText) {
	const pointerDirectory = path.join(workspacePath, '.pointer');
	await fs.mkdir(pointerDirectory, { recursive: true });
	const briefPath = path.join(pointerDirectory, 'project-brief.md');
	await fs.writeFile(briefPath, `${briefText.trim()}\n`, 'utf8');
}

module.exports = {
	loadProjectBrief,
	saveProjectBrief
};
