/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const { EventEmitter } = require('node:events');

class SessionStoreEmitter {
	constructor() {
		this.emitter = new EventEmitter();
	}

	event(listener) {
		this.emitter.on('change', listener);
		return {
			dispose: () => this.emitter.off('change', listener)
		};
	}

	fire(payload) {
		this.emitter.emit('change', payload);
	}
}

function createSessionId() {
	return `session-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

function createMessageId() {
	return `message-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

function createContextId() {
	return `context-${Date.now()}-${Math.floor(Math.random() * 100000).toString(16)}`;
}

function createSession(name) {
	return {
		id: createSessionId(),
		name,
		messages: [],
		pinnedContext: []
	};
}

class ChatSessionStore {
	constructor() {
		this.onDidChangeEmitter = new SessionStoreEmitter();
		this.onDidChange = this.onDidChangeEmitter.event;
		this.sessions = [createSession('New Chat')];
		this.activeSessionId = this.sessions[0].id;
	}

	listSessions() {
		return this.sessions;
	}

	getActiveSession() {
		return this.sessions.find((session) => session.id === this.activeSessionId) ?? this.sessions[0];
	}

	setActiveSession(sessionId) {
		const session = this.sessions.find((item) => item.id === sessionId);
		if (!session) {
			return;
		}
		this.activeSessionId = sessionId;
		this.onDidChangeEmitter.fire(undefined);
	}

	createSession(name = 'New Chat') {
		const session = createSession(name);
		this.sessions.unshift(session);
		this.activeSessionId = session.id;
		this.onDidChangeEmitter.fire(undefined);
		return session;
	}

	renameSession(sessionId, newName) {
		const trimmed = newName.trim();
		if (!trimmed) {
			return;
		}
		const session = this.sessions.find((item) => item.id === sessionId);
		if (!session) {
			return;
		}
		session.name = trimmed;
		this.onDidChangeEmitter.fire(undefined);
	}

	deleteSession(sessionId) {
		const next = this.sessions.filter((item) => item.id !== sessionId);
		if (next.length === 0) {
			next.push(createSession('New Chat'));
		}
		this.sessions = next;
		if (!next.some((item) => item.id === this.activeSessionId)) {
			this.activeSessionId = next[0].id;
		}
		this.onDidChangeEmitter.fire(undefined);
	}

	listMessages(sessionId = this.activeSessionId) {
		const session = this.sessions.find((item) => item.id === sessionId);
		return session?.messages ?? [];
	}

	addUserMessage(text) {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return undefined;
		}

		const message = {
			id: createMessageId(),
			role: 'user',
			text
		};
		activeSession.messages.push(message);
		this.onDidChangeEmitter.fire(undefined);
		return message.id;
	}

	startAssistantMessage() {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return undefined;
		}

		const message = {
			id: createMessageId(),
			role: 'assistant',
			text: '',
			streaming: true
		};
		activeSession.messages.push(message);
		this.onDidChangeEmitter.fire(undefined);
		return message.id;
	}

	appendAssistantChunk(messageId, chunk) {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return;
		}

		const message = activeSession.messages.find((item) => item.id === messageId && item.role === 'assistant');
		if (!message) {
			return;
		}
		message.text = `${message.text}${chunk}`;
		this.onDidChangeEmitter.fire(undefined);
	}

	finalizeAssistantMessage(messageId) {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return;
		}

		const message = activeSession.messages.find((item) => item.id === messageId && item.role === 'assistant');
		if (!message) {
			return;
		}
		delete message.streaming;
		this.onDidChangeEmitter.fire(undefined);
	}

	listPinnedContext(sessionId = this.activeSessionId) {
		const session = this.sessions.find((item) => item.id === sessionId);
		return session?.pinnedContext ?? [];
	}

	addPinnedContext(label, value, source) {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return undefined;
		}
		const contextItem = {
			id: createContextId(),
			label,
			value,
			source,
			tokenEstimate: Math.max(1, Math.ceil(value.length / 4))
		};
		activeSession.pinnedContext.push(contextItem);
		this.onDidChangeEmitter.fire(undefined);
		return contextItem.id;
	}

	removePinnedContext(contextId) {
		const activeSession = this.getActiveSession();
		if (!activeSession) {
			return;
		}

		activeSession.pinnedContext = activeSession.pinnedContext.filter((item) => item.id !== contextId);
		this.onDidChangeEmitter.fire(undefined);
	}
}

module.exports = {
	ChatSessionStore
};
