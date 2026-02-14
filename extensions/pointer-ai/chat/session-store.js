/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const vscode = require('vscode');

function createSessionId() {
	return `session-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

class ChatSessionStore {
	constructor() {
		this.onDidChangeEmitter = new vscode.EventEmitter();
		this.onDidChange = this.onDidChangeEmitter.event;
		this.sessions = [
			{
				id: createSessionId(),
				name: 'New Chat'
			}
		];
	}

	listSessions() {
		return this.sessions;
	}

	createSession(name = 'New Chat') {
		const session = {
			id: createSessionId(),
			name
		};
		this.sessions.unshift(session);
		this.onDidChangeEmitter.fire(undefined);
		return session;
	}
}

module.exports = {
	ChatSessionStore
};
