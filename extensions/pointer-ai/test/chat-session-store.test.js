/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const assert = require('node:assert/strict');
const test = require('node:test');
const { ChatSessionStore } = require('../chat/session-store.js');

test('ChatSessionStore supports create rename and delete lifecycle', () => {
	const store = new ChatSessionStore();
	const created = store.createSession('Planning');

	store.renameSession(created.id, 'Planning Renamed');
	assert.equal(store.listSessions()[0].name, 'Planning Renamed');

	store.deleteSession(created.id);
	assert.ok(store.listSessions().length >= 1);
});

test('ChatSessionStore appends and streams assistant messages', () => {
	const store = new ChatSessionStore();
	store.addUserMessage('hello');
	const assistantId = store.startAssistantMessage();
	assert.ok(assistantId);

	store.appendAssistantChunk(assistantId, 'chunk 1 ');
	store.appendAssistantChunk(assistantId, 'chunk 2');
	store.finalizeAssistantMessage(assistantId);

	const messages = store.listMessages();
	assert.equal(messages.length, 2);
	assert.equal(messages[1].text, 'chunk 1 chunk 2');
	assert.equal(messages[1].streaming, undefined);
});

test('ChatSessionStore tracks pinned context chips with remove support', () => {
	const store = new ChatSessionStore();
	const contextId = store.addPinnedContext('file.ts', '/workspace/file.ts', 'file');
	assert.ok(contextId);
	assert.equal(store.listPinnedContext().length, 1);

	store.removePinnedContext(contextId);
	assert.equal(store.listPinnedContext().length, 0);
});
