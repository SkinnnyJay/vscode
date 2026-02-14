import { RouterConfig, RouterPolicyConfig, RouterSurfaceDefaults, defaultRouterConfig } from './config.js';
import { Surface } from './contract.js';

type UnknownRecord = Record<string, unknown>;

function isRecord(value: unknown): value is UnknownRecord {
	return typeof value === 'object' && value !== null;
}

function readNestedValue(record: unknown, path: readonly string[]): unknown {
	if (!isRecord(record)) {
		return undefined;
	}

	let current: unknown = record;
	for (const part of path) {
		if (!isRecord(current)) {
			return undefined;
		}
		current = current[part];
	}

	return current;
}

function readLayeredString(path: readonly string[], workspace: unknown, user: unknown, fallback: string): string {
	const workspaceValue = readNestedValue(workspace, path);
	if (typeof workspaceValue === 'string' && workspaceValue.trim().length > 0) {
		return workspaceValue;
	}

	const userValue = readNestedValue(user, path);
	if (typeof userValue === 'string' && userValue.trim().length > 0) {
		return userValue;
	}

	return fallback;
}

function readLayeredTokenBudget(path: readonly string[], surface: Surface, workspace: unknown, user: unknown, fallback: number): number {
	const workspaceValue = readNestedValue(workspace, [...path, surface]);
	if (typeof workspaceValue === 'number' && workspaceValue > 0) {
		return workspaceValue;
	}

	const userValue = readNestedValue(user, [...path, surface]);
	if (typeof userValue === 'number' && userValue > 0) {
		return userValue;
	}

	return fallback;
}

function readLayeredTerminalPolicy(
	path: readonly string[],
	workspace: unknown,
	user: unknown,
	fallback: RouterPolicyConfig['terminalToolPolicy']
): RouterPolicyConfig['terminalToolPolicy'] {
	const workspaceValue = readNestedValue(workspace, path);
	if (workspaceValue === 'disabled' || workspaceValue === 'confirm' || workspaceValue === 'allow') {
		return workspaceValue;
	}

	const userValue = readNestedValue(user, path);
	if (userValue === 'disabled' || userValue === 'confirm' || userValue === 'allow') {
		return userValue;
	}

	return fallback;
}

function readLayeredFilesystemPolicy(
	path: readonly string[],
	workspace: unknown,
	user: unknown,
	fallback: RouterPolicyConfig['filesystemToolPolicy']
): RouterPolicyConfig['filesystemToolPolicy'] {
	const workspaceValue = readNestedValue(workspace, path);
	if (workspaceValue === 'diff-only' || workspaceValue === 'confirm' || workspaceValue === 'allow') {
		return workspaceValue;
	}

	const userValue = readNestedValue(user, path);
	if (userValue === 'diff-only' || userValue === 'confirm' || userValue === 'allow') {
		return userValue;
	}

	return fallback;
}

function readLayeredNetworkPolicy(
	path: readonly string[],
	workspace: unknown,
	user: unknown,
	fallback: RouterPolicyConfig['networkToolPolicy']
): RouterPolicyConfig['networkToolPolicy'] {
	const workspaceValue = readNestedValue(workspace, path);
	if (workspaceValue === 'disabled' || workspaceValue === 'confirm' || workspaceValue === 'allow') {
		return workspaceValue;
	}

	const userValue = readNestedValue(user, path);
	if (userValue === 'disabled' || userValue === 'confirm' || userValue === 'allow') {
		return userValue;
	}

	return fallback;
}

function resolveSurfaceDefaults(surface: Surface, workspace: unknown, user: unknown): RouterSurfaceDefaults {
	const fallback = defaultRouterConfig.defaultsBySurface[surface];

	return {
		providerId: readLayeredString(['defaultsBySurface', surface, 'providerId'], workspace, user, fallback.providerId),
		modelId: readLayeredString(['defaultsBySurface', surface, 'modelId'], workspace, user, fallback.modelId),
		templateId: readLayeredString(['defaultsBySurface', surface, 'templateId'], workspace, user, fallback.templateId)
	};
}

export interface RouterConfigLayers {
	readonly workspaceOverrides?: unknown;
	readonly userOverrides?: unknown;
}

export function resolveRouterConfig(layers: RouterConfigLayers): RouterConfig {
	const workspace = layers.workspaceOverrides;
	const user = layers.userOverrides;

	return {
		defaultsBySurface: {
			tab: resolveSurfaceDefaults('tab', workspace, user),
			chat: resolveSurfaceDefaults('chat', workspace, user),
			agent: resolveSurfaceDefaults('agent', workspace, user)
		},
		policy: {
			terminalToolPolicy: readLayeredTerminalPolicy(['policy', 'terminalToolPolicy'], workspace, user, defaultRouterConfig.policy.terminalToolPolicy),
			filesystemToolPolicy: readLayeredFilesystemPolicy(['policy', 'filesystemToolPolicy'], workspace, user, defaultRouterConfig.policy.filesystemToolPolicy),
			networkToolPolicy: readLayeredNetworkPolicy(['policy', 'networkToolPolicy'], workspace, user, defaultRouterConfig.policy.networkToolPolicy),
			maxInputTokensBySurface: {
				tab: readLayeredTokenBudget(['policy', 'maxInputTokensBySurface'], 'tab', workspace, user, defaultRouterConfig.policy.maxInputTokensBySurface.tab),
				chat: readLayeredTokenBudget(['policy', 'maxInputTokensBySurface'], 'chat', workspace, user, defaultRouterConfig.policy.maxInputTokensBySurface.chat),
				agent: readLayeredTokenBudget(['policy', 'maxInputTokensBySurface'], 'agent', workspace, user, defaultRouterConfig.policy.maxInputTokensBySurface.agent)
			},
			maxOutputTokensBySurface: {
				tab: readLayeredTokenBudget(['policy', 'maxOutputTokensBySurface'], 'tab', workspace, user, defaultRouterConfig.policy.maxOutputTokensBySurface.tab),
				chat: readLayeredTokenBudget(['policy', 'maxOutputTokensBySurface'], 'chat', workspace, user, defaultRouterConfig.policy.maxOutputTokensBySurface.chat),
				agent: readLayeredTokenBudget(['policy', 'maxOutputTokensBySurface'], 'agent', workspace, user, defaultRouterConfig.policy.maxOutputTokensBySurface.agent)
			}
		}
	};
}
