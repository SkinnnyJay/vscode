/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

export type HookEventType =
	| 'prePrompt'
	| 'postPrompt'
	| 'preTool'
	| 'postTool'
	| 'prePatch'
	| 'postPatch'
	| 'preTab'
	| 'postTab';

export interface HookExecutionPolicy {
	readonly allowPromptMutation: boolean;
	readonly allowPromptRedaction: boolean;
}

export interface HookContext<TPayload> {
	readonly eventType: HookEventType;
	readonly payload: TPayload;
	readonly policy: HookExecutionPolicy;
}

export interface HookResult<TPayload> {
	readonly block?: boolean;
	readonly payload?: TPayload;
	readonly redactedFields?: readonly string[];
}

export interface HookReport {
	readonly eventType: HookEventType;
	readonly hookName: string;
	readonly timedOut: boolean;
	readonly failed: boolean;
	readonly blocked: boolean;
}

export interface HookDispatchResult<TPayload> {
	readonly blocked: boolean;
	readonly payload: TPayload;
	readonly reports: readonly HookReport[];
}

export type HookHandler<TPayload> = (context: HookContext<TPayload>) => Promise<HookResult<TPayload> | undefined>;

interface RegisteredHook<TPayload> {
	readonly name: string;
	readonly eventType: HookEventType;
	readonly handler: HookHandler<TPayload>;
}

function withTimeout<T>(
	promise: Promise<T>,
	timeoutMs: number
): Promise<{ readonly timedOut: boolean; readonly failed: boolean; readonly value?: T }> {
	return new Promise((resolve) => {
		const timer = setTimeout(() => resolve({ timedOut: true, failed: false }), timeoutMs);
		void promise
			.then((value) => resolve({ timedOut: false, failed: false, value }))
			.catch(() => resolve({ timedOut: false, failed: true }))
			.finally(() => clearTimeout(timer));
	});
}

export class HookDispatcher<TPayload> {
	private readonly hooks: RegisteredHook<TPayload>[];

	constructor() {
		this.hooks = [];
	}

	register(eventType: HookEventType, name: string, handler: HookHandler<TPayload>): void {
		this.hooks.push({
			eventType,
			name,
			handler
		});
	}

	async dispatch(
		eventType: HookEventType,
		payload: TPayload,
		policy: HookExecutionPolicy,
		timeoutMs = 250
	): Promise<HookDispatchResult<TPayload>> {
		let currentPayload = payload;
		const reports: HookReport[] = [];

		for (const hook of this.hooks.filter((entry) => entry.eventType === eventType)) {
			const outcome = await withTimeout(
				hook.handler({
					eventType,
					payload: currentPayload,
					policy
				}),
				timeoutMs
			);

			if (outcome.timedOut) {
				reports.push({
					eventType,
					hookName: hook.name,
					timedOut: true,
					failed: false,
					blocked: false
				});
				continue;
			}

			const result = outcome.value;
			if (outcome.failed) {
				reports.push({
					eventType,
					hookName: hook.name,
					timedOut: false,
					failed: true,
					blocked: false
				});
				continue;
			}
			if (!result) {
				reports.push({
					eventType,
					hookName: hook.name,
					timedOut: false,
					failed: false,
					blocked: false
				});
				continue;
			}

			if (result.payload) {
				const canModify = eventType === 'prePrompt' ? policy.allowPromptMutation : true;
				if (canModify) {
					currentPayload = result.payload;
				}
			}
			if (result.redactedFields && result.redactedFields.length > 0 && policy.allowPromptRedaction) {
				const payloadWithText = currentPayload as unknown as { text?: unknown };
				if (typeof payloadWithText.text === 'string') {
					let redactedText = payloadWithText.text;
					for (const field of result.redactedFields) {
						const pattern = new RegExp(field, 'gi');
						redactedText = redactedText.replace(pattern, '[REDACTED]');
					}
					currentPayload = {
						...(currentPayload as unknown as Record<string, unknown>),
						text: redactedText
					} as TPayload;
				}
			}

			if (result.block) {
				reports.push({
					eventType,
					hookName: hook.name,
					timedOut: false,
					failed: false,
					blocked: true
				});
				return {
					blocked: true,
					payload: currentPayload,
					reports
				};
			}

			reports.push({
				eventType,
				hookName: hook.name,
				timedOut: false,
				failed: false,
				blocked: false
			});
		}

		return {
			blocked: false,
			payload: currentPayload,
			reports
		};
	}
}
