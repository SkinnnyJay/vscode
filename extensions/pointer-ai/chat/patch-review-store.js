/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

const { EventEmitter } = require('node:events');

class PatchReviewEmitter {
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

class PatchReviewStore {
	constructor() {
		this.onDidChangeEmitter = new PatchReviewEmitter();
		this.onDidChange = this.onDidChangeEmitter.event;
		this.files = [];
	}

	setProposal(files) {
		this.files = files.map((file) => ({
			...file,
			status: 'pending'
		}));
		this.onDidChangeEmitter.fire(undefined);
	}

	listFiles() {
		return this.files;
	}

	applyFile(filePath) {
		const file = this.files.find((item) => item.path === filePath);
		if (!file) {
			return;
		}
		file.status = 'applied';
		this.onDidChangeEmitter.fire(undefined);
	}

	rejectFile(filePath) {
		const file = this.files.find((item) => item.path === filePath);
		if (!file) {
			return;
		}
		file.status = 'rejected';
		this.onDidChangeEmitter.fire(undefined);
	}

	markConflict(filePath, reason) {
		const file = this.files.find((item) => item.path === filePath);
		if (!file) {
			return;
		}
		file.status = 'conflict';
		file.conflictReason = reason;
		this.onDidChangeEmitter.fire(undefined);
	}

	applyAll() {
		for (const file of this.files) {
			if (file.status === 'pending') {
				file.status = 'applied';
			}
		}
		this.onDidChangeEmitter.fire(undefined);
	}

	getSummary() {
		const total = this.files.length;
		const applied = this.files.filter((file) => file.status === 'applied').length;
		const rejected = this.files.filter((file) => file.status === 'rejected').length;
		const pending = this.files.filter((file) => file.status === 'pending').length;
		const conflicts = this.files.filter((file) => file.status === 'conflict').length;
		return { total, applied, rejected, pending, conflicts };
	}
}

module.exports = {
	PatchReviewStore
};
