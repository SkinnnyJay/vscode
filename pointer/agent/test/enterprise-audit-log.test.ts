/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import assert from 'node:assert/strict';
import test from 'node:test';
import { EnterpriseAuditLog } from '../src/enterprise/audit-log.js';

test('EnterpriseAuditLog stores append-only entries', () => {
	const auditLog = new EnterpriseAuditLog();
	auditLog.append({
		timestampIso: '2026-02-14T00:00:00.000Z',
		traceId: 'trace-1',
		actor: 'ci',
		action: 'patch',
		providerId: 'codex',
		modelId: 'gpt-5-codex',
		outcome: 'allowed',
		details: 'Patch proposed'
	});

	assert.equal(auditLog.list().length, 1);
	assert.equal(auditLog.list()[0]?.traceId, 'trace-1');
});
