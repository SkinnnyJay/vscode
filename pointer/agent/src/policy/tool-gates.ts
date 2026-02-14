/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { RouterPolicy } from '../router/contract.js';

export type ToolKind = 'terminal' | 'filesystem' | 'network';
export type ToolAction = 'execute' | 'read' | 'write' | 'apply-diff' | 'request';

export interface ToolGateDecision {
	readonly allowed: boolean;
	readonly requiresConfirmation: boolean;
	readonly reason: string;
}

function denied(reason: string): ToolGateDecision {
	return {
		allowed: false,
		requiresConfirmation: false,
		reason
	};
}

function allowed(reason: string, requiresConfirmation = false): ToolGateDecision {
	return {
		allowed: true,
		requiresConfirmation,
		reason
	};
}

export function evaluateToolGate(policy: RouterPolicy, tool: ToolKind, action: ToolAction): ToolGateDecision {
	if (tool === 'terminal') {
		if (policy.terminalToolPolicy === 'disabled') {
			return denied('Terminal tool is disabled by policy.');
		}
		if (policy.terminalToolPolicy === 'confirm') {
			return allowed('Terminal tool requires user confirmation.', true);
		}
		return allowed('Terminal tool is allowed.');
	}

	if (tool === 'network') {
		if (policy.networkToolPolicy === 'disabled') {
			return denied('Network tool is disabled by policy.');
		}
		if (policy.networkToolPolicy === 'confirm') {
			return allowed('Network tool requires user confirmation.', true);
		}
		return allowed('Network tool is allowed.');
	}

	if (policy.filesystemToolPolicy === 'diff-only') {
		if (action === 'apply-diff' || action === 'read') {
			return allowed('Filesystem tool allowed for diff-first apply flow.');
		}
		return denied('Filesystem writes are limited to diff apply flow.');
	}
	if (policy.filesystemToolPolicy === 'confirm') {
		return allowed('Filesystem tool requires user confirmation.', true);
	}
	return allowed('Filesystem tool is allowed.');
}
