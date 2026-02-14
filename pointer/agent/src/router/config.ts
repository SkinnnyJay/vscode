/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { Surface } from './contract.js';

export interface RouterSurfaceDefaults {
	readonly providerId: string;
	readonly modelId: string;
	readonly templateId: string;
}

export interface RouterPolicyConfig {
	readonly terminalToolPolicy: 'disabled' | 'confirm' | 'allow';
	readonly filesystemToolPolicy: 'diff-only' | 'confirm' | 'allow';
	readonly networkToolPolicy: 'disabled' | 'confirm' | 'allow';
	readonly maxInputTokensBySurface: Readonly<Record<Surface, number>>;
	readonly maxOutputTokensBySurface: Readonly<Record<Surface, number>>;
}

export interface RouterConfig {
	readonly defaultsBySurface: Readonly<Record<Surface, RouterSurfaceDefaults>>;
	readonly policy: RouterPolicyConfig;
}

export const defaultRouterConfig: RouterConfig = {
	defaultsBySurface: {
		tab: { providerId: 'auto', modelId: 'auto', templateId: 'tab-default' },
		chat: { providerId: 'auto', modelId: 'auto', templateId: 'chat-default' },
		agent: { providerId: 'auto', modelId: 'auto', templateId: 'agent-default' }
	},
	policy: {
		terminalToolPolicy: 'confirm',
		filesystemToolPolicy: 'diff-only',
		networkToolPolicy: 'confirm',
		maxInputTokensBySurface: {
			tab: 4096,
			chat: 16384,
			agent: 32768
		},
		maxOutputTokensBySurface: {
			tab: 512,
			chat: 2048,
			agent: 4096
		}
	}
};

type UnknownRecord = Record<string, unknown>;

function isRecord(value: unknown): value is UnknownRecord {
	return typeof value === 'object' && value !== null;
}

function readString(value: unknown, fallback: string): string {
	return typeof value === 'string' && value.trim().length > 0 ? value : fallback;
}

function readSurfaceDefaults(value: unknown, fallback: RouterSurfaceDefaults): RouterSurfaceDefaults {
	if (!isRecord(value)) {
		return fallback;
	}

	return {
		providerId: readString(value.providerId, fallback.providerId),
		modelId: readString(value.modelId, fallback.modelId),
		templateId: readString(value.templateId, fallback.templateId)
	};
}

function readTokenBudget(
	value: unknown,
	fallback: Readonly<Record<Surface, number>>
): Readonly<Record<Surface, number>> {
	if (!isRecord(value)) {
		return fallback;
	}

	const tab = typeof value.tab === 'number' && value.tab > 0 ? value.tab : fallback.tab;
	const chat = typeof value.chat === 'number' && value.chat > 0 ? value.chat : fallback.chat;
	const agent = typeof value.agent === 'number' && value.agent > 0 ? value.agent : fallback.agent;

	return { tab, chat, agent };
}

function readTerminalPolicy(value: unknown, fallback: RouterPolicyConfig['terminalToolPolicy']): RouterPolicyConfig['terminalToolPolicy'] {
	return value === 'disabled' || value === 'confirm' || value === 'allow' ? value : fallback;
}

function readFilesystemPolicy(
	value: unknown,
	fallback: RouterPolicyConfig['filesystemToolPolicy']
): RouterPolicyConfig['filesystemToolPolicy'] {
	return value === 'diff-only' || value === 'confirm' || value === 'allow' ? value : fallback;
}

function readNetworkPolicy(value: unknown, fallback: RouterPolicyConfig['networkToolPolicy']): RouterPolicyConfig['networkToolPolicy'] {
	return value === 'disabled' || value === 'confirm' || value === 'allow' ? value : fallback;
}

export function parseRouterConfig(raw: unknown): RouterConfig {
	if (!isRecord(raw)) {
		return defaultRouterConfig;
	}

	const rawDefaults = isRecord(raw.defaultsBySurface) ? raw.defaultsBySurface : {};
	const rawPolicy = isRecord(raw.policy) ? raw.policy : {};

	return {
		defaultsBySurface: {
			tab: readSurfaceDefaults(rawDefaults.tab, defaultRouterConfig.defaultsBySurface.tab),
			chat: readSurfaceDefaults(rawDefaults.chat, defaultRouterConfig.defaultsBySurface.chat),
			agent: readSurfaceDefaults(rawDefaults.agent, defaultRouterConfig.defaultsBySurface.agent)
		},
		policy: {
			terminalToolPolicy: readTerminalPolicy(rawPolicy.terminalToolPolicy, defaultRouterConfig.policy.terminalToolPolicy),
			filesystemToolPolicy: readFilesystemPolicy(rawPolicy.filesystemToolPolicy, defaultRouterConfig.policy.filesystemToolPolicy),
			networkToolPolicy: readNetworkPolicy(rawPolicy.networkToolPolicy, defaultRouterConfig.policy.networkToolPolicy),
			maxInputTokensBySurface: readTokenBudget(rawPolicy.maxInputTokensBySurface, defaultRouterConfig.policy.maxInputTokensBySurface),
			maxOutputTokensBySurface: readTokenBudget(rawPolicy.maxOutputTokensBySurface, defaultRouterConfig.policy.maxOutputTokensBySurface)
		}
	};
}
