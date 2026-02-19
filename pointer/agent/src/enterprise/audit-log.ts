/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export interface EnterpriseAuditLogEntry {
	readonly timestampIso: string;
	readonly traceId: string;
	readonly actor: 'user' | 'ci' | 'service';
	readonly action: 'prompt' | 'patch' | 'tool' | 'policy';
	readonly providerId: string;
	readonly modelId: string;
	readonly outcome: 'allowed' | 'blocked' | 'error';
	readonly details: string;
}

export class EnterpriseAuditLog {
	private readonly entries: EnterpriseAuditLogEntry[];

	constructor() {
		this.entries = [];
	}

	append(entry: EnterpriseAuditLogEntry): void {
		this.entries.push(entry);
	}

	list(): readonly EnterpriseAuditLogEntry[] {
		return this.entries;
	}
}
