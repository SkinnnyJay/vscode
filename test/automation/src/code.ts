/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import * as cp from 'child_process';
import * as os from 'os';
import { existsSync } from 'fs';
import * as playwright from 'playwright';
import { IElement, ILocaleInfo, ILocalizedStrings, ILogFile } from './driver';
import { Logger, measureAndLog } from './logger';
import { launch as launchPlaywrightBrowser } from './playwrightBrowser';
import { PlaywrightDriver } from './playwrightDriver';
import { launch as launchPlaywrightElectron } from './playwrightElectron';
import { teardown } from './processes';
import { Quality } from './application';

export interface LaunchOptions {
	// Allows you to override the Playwright instance
	playwright?: typeof playwright;
	codePath?: string;
	readonly workspacePath?: string;
	userDataDir?: string;
	readonly extensionsPath?: string;
	readonly logger: Logger;
	logsPath: string;
	crashesPath: string;
	readonly videosPath?: string;
	verbose?: boolean;
	useInMemorySecretStorage?: boolean;
	readonly extraArgs?: string[];
	readonly remote?: boolean;
	readonly web?: boolean;
	readonly tracing?: boolean;
	snapshots?: boolean;
	readonly headless?: boolean;
	readonly browser?: 'chromium' | 'webkit' | 'firefox' | 'chromium-msedge' | 'chromium-chrome';
	readonly quality: Quality;
	version: { major: number; minor: number; patch: number };
	readonly extensionDevelopmentPath?: string;
}

interface ICodeInstance {
	kill: () => Promise<void>;
}

const instances = new Set<ICodeInstance>();

function registerInstance(process: cp.ChildProcess, logger: Logger, type: 'electron' | 'server'): { safeToKill: Promise<void> } {
	const instance = { kill: () => teardown(process, logger) };
	instances.add(instance);

	const safeToKill = new Promise<void>(resolve => {
		process.stdout?.on('data', data => {
			const output = data.toString();
			if (output.indexOf('calling app.quit()') >= 0 && type === 'electron') {
				setTimeout(() => resolve(), 500 /* give Electron some time to actually terminate fully */);
			}
			logger.log(`[${type}] stdout: ${output}`);
		});
		process.stderr?.on('data', error => logger.log(`[${type}] stderr: ${error}`));
	});

	process.once('exit', (code, signal) => {
		logger.log(`[${type}] Process terminated (pid: ${process.pid}, code: ${code}, signal: ${signal})`);

		instances.delete(instance);
	});

	return { safeToKill };
}

async function teardownAll(signal?: number) {
	stopped = true;

	for (const instance of instances) {
		await instance.kill();
	}

	if (typeof signal === 'number') {
		process.exit(signal);
	}
}

let stopped = false;
process.on('exit', () => teardownAll());
process.on('SIGINT', () => teardownAll(128 + 2)); 	 // https://nodejs.org/docs/v14.16.0/api/process.html#process_signal_events
process.on('SIGTERM', () => teardownAll(128 + 15)); // same as above

export async function launch(options: LaunchOptions): Promise<Code> {
	if (stopped) {
		throw new Error('Smoke test process has terminated, refusing to spawn Code');
	}

	// Browser smoke tests
	if (options.web) {
		const { serverProcess, driver } = await measureAndLog(() => launchPlaywrightBrowser(options), 'launch playwright (browser)', options.logger);
		registerInstance(serverProcess, options.logger, 'server');

		return new Code(driver, options.logger, serverProcess, undefined, options.quality, options.version);
	}

	// Electron smoke tests (playwright)
	else {
		const { electronProcess, driver } = await measureAndLog(() => launchPlaywrightElectron(options), 'launch playwright (electron)', options.logger);
		const { safeToKill } = registerInstance(electronProcess, options.logger, 'electron');

		return new Code(driver, options.logger, electronProcess, safeToKill, options.quality, options.version);
	}
}

export class Code {

	private static readonly recentFailuresSummarySchemaVersion = 1;
	private static readonly recentScriptResponsesSummarySchemaVersion = 1;
	private static readonly recentCdpScriptLoadsSummarySchemaVersion = 1;
	private static readonly recentFailuresDisplayLimit = 8;

	readonly driver: PlaywrightDriver;

	constructor(
		driver: PlaywrightDriver,
		readonly logger: Logger,
		private readonly mainProcess: cp.ChildProcess,
		private readonly safeToKill: Promise<void> | undefined,
		readonly quality: Quality,
		readonly version: { major: number; minor: number; patch: number }
	) {
		this.driver = new Proxy(driver, {
			get(target, prop) {
				if (typeof prop === 'symbol') {
					throw new Error('Invalid usage');
				}

				// eslint-disable-next-line local/code-no-any-casts
				const targetProp = (target as any)[prop];
				if (typeof targetProp !== 'function') {
					return targetProp;
				}

				return function (this: any, ...args: any[]) {
					logger.log(`${prop}`, ...args.filter(a => typeof a === 'string'));
					return targetProp.apply(this, args);
				};
			}
		});
	}

	get editContextEnabled(): boolean {
		return !(this.quality === Quality.Stable && this.version.major === 1 && this.version.minor < 101);
	}

	async startTracing(name?: string): Promise<void> {
		return await this.driver.startTracing(name);
	}

	async stopTracing(name?: string, persist: boolean = false): Promise<void> {
		return await this.driver.stopTracing(name, persist);
	}

	/**
	 * Dispatch a keybinding to the application.
	 * @param keybinding The keybinding to dispatch, e.g. 'ctrl+shift+p'.
	 * @param accept The acceptance function to await before returning. Wherever
	 * possible this should verify that the keybinding did what was expected,
	 * otherwise it will likely be a cause of difficult to investigate race
	 * conditions. This is particularly insidious when used in the automation
	 * library as it can surface across many test suites.
	 *
	 * This requires an async function even when there's no implementation to
	 * force the author to think about the accept callback and prevent mistakes
	 * like not making it async.
	 */
	async dispatchKeybinding(keybinding: string, accept: () => Promise<void>): Promise<void> {
		await this.driver.sendKeybinding(keybinding, accept);
	}

	async didFinishLoad(): Promise<void> {
		return this.driver.didFinishLoad();
	}

	async exit(): Promise<void> {
		return measureAndLog(() => new Promise<void>(resolve => {
			const pid = this.mainProcess.pid!;

			let done = false;

			// Start the exit flow via driver
			this.driver.close();

			let safeToKill = false;
			this.safeToKill?.then(() => {
				this.logger.log('Smoke test exit(): safeToKill() called');
				safeToKill = true;
			});

			// Await the exit of the application
			(async () => {
				let retries = 0;
				while (!done) {
					retries++;

					if (safeToKill) {
						this.logger.log('Smoke test exit(): call did not terminate the process yet, but safeToKill is true, so we can kill it');
						this.kill(pid);
					}

					switch (retries) {

						// after 10 seconds: forcefully kill
						case 20: {
							this.logger.log('Smoke test exit(): call did not terminate process after 10s, forcefully exiting the application...');
							this.kill(pid);
							break;
						}

						// after 20 seconds: give up
						case 40: {
							this.logger.log('Smoke test exit(): call did not terminate process after 20s, giving up');
							this.kill(pid);
							done = true;
							resolve();
							break;
						}
					}

					try {
						process.kill(pid, 0); // throws an exception if the process doesn't exist anymore.
						await this.wait(500);
					} catch (error) {
						this.logger.log('Smoke test exit(): call terminated process successfully');

						done = true;
						resolve();
					}
				}
			})();
		}), 'Code#exit()', this.logger);
	}

	private kill(pid: number): void {
		try {
			process.kill(pid, 0); // throws an exception if the process doesn't exist anymore.
		} catch (e) {
			this.logger.log('Smoke test kill(): returning early because process does not exist anymore');
			return;
		}

		try {
			this.logger.log(`Smoke test kill(): Trying to SIGTERM process: ${pid}`);
			process.kill(pid);
		} catch (e) {
			this.logger.log('Smoke test kill(): SIGTERM failed', e);
		}
	}

	async getElement(selector: string): Promise<IElement | undefined> {
		return (await this.driver.getElements(selector))?.[0];
	}

	async getElements(selector: string, recursive: boolean): Promise<IElement[] | undefined> {
		return this.driver.getElements(selector, recursive);
	}

	async waitForTextContent(selector: string, textContent?: string, accept?: (result: string) => boolean, retryCount?: number): Promise<string> {
		accept = accept || (result => textContent !== undefined ? textContent === result : !!result);

		return await this.poll(
			() => this.driver.getElements(selector).then(els => els.length > 0 ? Promise.resolve(els[0].textContent) : Promise.reject(new Error('Element not found for textContent'))),
			s => accept!(typeof s === 'string' ? s : ''),
			`get text content '${selector}'`,
			retryCount
		);
	}

	async waitAndClick(selector: string, xoffset?: number, yoffset?: number, retryCount: number = 200): Promise<void> {
		await this.poll(() => this.driver.click(selector, xoffset, yoffset), () => true, `click '${selector}'`, retryCount);
	}

	async waitForSetValue(selector: string, value: string): Promise<void> {
		await this.poll(() => this.driver.setValue(selector, value), () => true, `set value '${selector}'`);
	}

	async waitForElements(selector: string, recursive: boolean, accept: (result: IElement[]) => boolean = result => result.length > 0): Promise<IElement[]> {
		return await this.poll(() => this.driver.getElements(selector, recursive), accept, `get elements '${selector}'`);
	}

	async waitForElement(selector: string, accept: (result: IElement | undefined) => boolean = result => !!result, retryCount: number = 200): Promise<IElement> {
		return await this.poll<IElement>(() => this.driver.getElements(selector).then(els => els[0]), accept, `get element '${selector}'`, retryCount);
	}

	async waitForActiveElement(selector: string, retryCount: number = 200): Promise<void> {
		await this.poll(() => this.driver.isActiveElement(selector), r => r, `is active element '${selector}'`, retryCount);
	}

	async waitForTitle(accept: (title: string) => boolean): Promise<void> {
		await this.poll(() => this.driver.getTitle(), accept, `get title`);
	}

	async waitForTypeInEditor(selector: string, text: string): Promise<void> {
		await this.poll(() => this.driver.typeInEditor(selector, text), () => true, `type in editor '${selector}'`);
	}

	async waitForEditorSelection(selector: string, accept: (selection: { selectionStart: number; selectionEnd: number }) => boolean): Promise<void> {
		await this.poll(() => this.driver.getEditorSelection(selector), accept, `get editor selection '${selector}'`);
	}

	async waitForTerminalBuffer(selector: string, accept: (result: string[]) => boolean): Promise<void> {
		await this.poll(() => this.driver.getTerminalBuffer(selector), accept, `get terminal buffer '${selector}'`);
	}

	async writeInTerminal(selector: string, value: string): Promise<void> {
		await this.poll(() => this.driver.writeInTerminal(selector, value), () => true, `writeInTerminal '${selector}'`);
	}

	async whenWorkbenchRestored(): Promise<void> {
		await this.poll(() => this.driver.whenWorkbenchRestored(), () => true, `when workbench restored`);
	}

	getLocaleInfo(): Promise<ILocaleInfo> {
		return this.driver.getLocaleInfo();
	}

	getLocalizedStrings(): Promise<ILocalizedStrings> {
		return this.driver.getLocalizedStrings();
	}

	getLogs(): Promise<ILogFile[]> {
		return this.driver.getLogs();
	}

	wait(millis: number): Promise<void> {
		return this.driver.wait(millis);
	}

	private async poll<T>(
		fn: () => Promise<T>,
		acceptFn: (result: T) => boolean,
		timeoutMessage: string,
		retryCount = 200,
		retryInterval = 100 // millis
	): Promise<T> {
		let trial = 1;
		let lastError: string = '';
		const isWorkbenchStartupWait = timeoutMessage.includes(`get element '.monaco-workbench'`);

		while (true) {
			if (isWorkbenchStartupWait) {
				const pageError = this.driver.getLastPageError();
				if (pageError?.includes('Failed to fetch dynamically imported module')) {
					const allRecentFailures = this.driver.getRecentRequestFailures();
					const recentFailures = allRecentFailures.slice(-Code.recentFailuresDisplayLimit);
					const recentFailureCapacity = this.driver.getRecentRequestFailureCapacity();
					const totalObservedRequestFailures = this.driver.getTotalRecordedRequestFailureCount();
					const droppedRecentRequestFailures = this.driver.getDroppedRecentRequestFailureCount();
					const allRecentScriptResponses = this.driver.getRecentScriptResponses();
					const recentScriptResponses = allRecentScriptResponses.slice(-Code.recentFailuresDisplayLimit);
					const recentScriptResponseCapacity = this.driver.getRecentScriptResponseCapacity();
					const totalObservedScriptResponses = this.driver.getTotalRecordedScriptResponseCount();
					const droppedRecentScriptResponses = this.driver.getDroppedRecentScriptResponseCount();
					const allRecentCdpScriptLoads = this.driver.getRecentCdpScriptLoads();
					const recentCdpScriptLoads = allRecentCdpScriptLoads.slice(-Code.recentFailuresDisplayLimit);
					const recentCdpScriptLoadCapacity = this.driver.getRecentCdpScriptLoadCapacity();
					const totalObservedCdpScriptLoads = this.driver.getTotalRecordedCdpScriptLoadCount();
					const droppedRecentCdpScriptLoads = this.driver.getDroppedRecentCdpScriptLoadCount();
					const failureSummaryData = this.summarizeRecentRequestFailures(recentFailures);
					const scriptResponseSummaryData = this.summarizeRecentEntries(recentScriptResponses);
					const cdpScriptLoadSummaryData = this.summarizeRecentEntries(recentCdpScriptLoads);
					const displayWindowSuffix = `, displayLimit=${Code.recentFailuresDisplayLimit}, bufferCapacity=${recentFailureCapacity}, showingLast=${recentFailures.length}/${allRecentFailures.length}, observedEvents=${totalObservedRequestFailures}, droppedEvents=${droppedRecentRequestFailures}`;
					const scriptResponseWindowSuffix = `, displayLimit=${Code.recentFailuresDisplayLimit}, bufferCapacity=${recentScriptResponseCapacity}, showingLast=${recentScriptResponses.length}/${allRecentScriptResponses.length}, observedEvents=${totalObservedScriptResponses}, droppedEvents=${droppedRecentScriptResponses}`;
					const cdpScriptLoadWindowSuffix = `, displayLimit=${Code.recentFailuresDisplayLimit}, bufferCapacity=${recentCdpScriptLoadCapacity}, showingLast=${recentCdpScriptLoads.length}/${allRecentCdpScriptLoads.length}, observedEvents=${totalObservedCdpScriptLoads}, droppedEvents=${droppedRecentCdpScriptLoads}`;
					const failureSummary = recentFailures.length
						? `\nRecent request failures (schemaVersion=${Code.recentFailuresSummarySchemaVersion}, ${failureSummaryData.totalCount} events, ${failureSummaryData.uniqueCount} unique, ${failureSummaryData.sourceSummary}${displayWindowSuffix}, signature=${failureSummaryData.signature}):\n${failureSummaryData.formattedFailures}\nEnd of recent request failures.\n`
						: '';
					const scriptResponseSummary = recentScriptResponses.length
						? `\nRecent script responses (schemaVersion=${Code.recentScriptResponsesSummarySchemaVersion}, ${scriptResponseSummaryData.totalCount} events, ${scriptResponseSummaryData.uniqueCount} unique${scriptResponseWindowSuffix}, signature=${scriptResponseSummaryData.signature}):\n${scriptResponseSummaryData.formattedEntries}\nEnd of recent script responses.\n`
						: '';
					const cdpScriptLoadSummary = recentCdpScriptLoads.length
						? `\nRecent CDP script loads (schemaVersion=${Code.recentCdpScriptLoadsSummarySchemaVersion}, ${cdpScriptLoadSummaryData.totalCount} events, ${cdpScriptLoadSummaryData.uniqueCount} unique${cdpScriptLoadWindowSuffix}, signature=${cdpScriptLoadSummaryData.signature}):\n${cdpScriptLoadSummaryData.formattedEntries}\nEnd of recent CDP script loads.\n`
						: '';
					const importTargetUrl = this.extractImportTargetUrlFromError(pageError);
					const importTargetFilePath = this.extractImportTargetPathFromError(pageError);
					const importTargetStatus = importTargetFilePath
						? `\nImport target on disk: ${importTargetFilePath} (exists=${existsSync(importTargetFilePath)})`
						: '';
					const importTargetLatestScriptResponse = importTargetUrl
						? this.driver.getLatestScriptResponseSummaryForUrl(importTargetUrl)
						: undefined;
					const importTargetLatestRequestFailure = importTargetUrl
						? this.driver.getLatestRequestFailureSummaryForUrl(importTargetUrl)
						: undefined;
					const importTargetLatestCdpScriptLoad = importTargetUrl
						? this.driver.getLatestCdpScriptLoadSummaryForUrl(importTargetUrl)
						: undefined;
					const importTargetScriptResponseStatus = importTargetUrl
						? `\nImport target latest script response: ${importTargetLatestScriptResponse ?? 'unseen'}`
						: '';
					const importTargetRequestFailureStatus = importTargetUrl
						? `\nImport target latest request failure: ${importTargetLatestRequestFailure ?? 'unseen'}`
						: '';
					const importTargetCdpScriptLoadStatus = importTargetUrl
						? `\nImport target latest CDP script load: ${importTargetLatestCdpScriptLoad ?? 'unseen'}`
						: '';

					throw new Error(`Workbench startup failed due to renderer module import error: ${pageError}${importTargetStatus}${importTargetScriptResponseStatus}${importTargetRequestFailureStatus}${importTargetCdpScriptLoadStatus}${failureSummary}${scriptResponseSummary}${cdpScriptLoadSummary}`);
				}
			}

			if (trial > retryCount) {
				this.logger.log('Timeout!');
				this.logger.log(lastError);
				this.logger.log(`Timeout: ${timeoutMessage} after ${(retryCount * retryInterval) / 1000} seconds.`);

				throw new Error(`Timeout: ${timeoutMessage} after ${(retryCount * retryInterval) / 1000} seconds.`);
			}

			let result;
			try {
				result = await fn();
				if (acceptFn(result)) {
					return result;
				} else {
					lastError = 'Did not pass accept function';
				}
			} catch (e: any) {
				lastError = Array.isArray(e.stack) ? e.stack.join(os.EOL) : e.stack;
			}

			await this.wait(retryInterval);
			trial++;
		}
	}

	private summarizeRecentRequestFailures(failures: readonly string[]): { formattedFailures: string; totalCount: number; uniqueCount: number; sourceSummary: string; signature: string } {
		const recentEntrySummary = this.summarizeRecentEntries(failures);
		const counts = new Map<string, number>();
		const sourceCounts = new Map<string, number>();
		for (const failure of failures) {
			counts.set(failure, (counts.get(failure) ?? 0) + 1);
			const source = failure.startsWith('[cdp] ') ? 'cdp' : 'requestfailed';
			sourceCounts.set(source, (sourceCounts.get(source) ?? 0) + 1);
		}

		const sourceSummary = [...sourceCounts.entries()]
			.sort(([leftSource], [rightSource]) => leftSource.localeCompare(rightSource))
			.map(([source, count]) => `${source}=${count}`)
			.join(', ');

		return {
			formattedFailures: recentEntrySummary.formattedEntries,
			totalCount: recentEntrySummary.totalCount,
			uniqueCount: recentEntrySummary.uniqueCount,
			sourceSummary,
			signature: recentEntrySummary.signature
		};
	}

	private summarizeRecentEntries(entries: readonly string[]): { formattedEntries: string; totalCount: number; uniqueCount: number; signature: string } {
		const counts = new Map<string, number>();
		for (const entry of entries) {
			counts.set(entry, (counts.get(entry) ?? 0) + 1);
		}

		const formattedEntries = [...counts.entries()]
			.sort(([leftEntry, leftCount], [rightEntry, rightCount]) => {
				if (rightCount !== leftCount) {
					return rightCount - leftCount;
				}

				return leftEntry.localeCompare(rightEntry);
			})
			.map(([entry, count]) => count > 1 ? `[x${count}] ${entry}` : entry)
			.join('\n');
		const signaturePayload = [...counts.entries()]
			.sort(([leftEntry], [rightEntry]) => leftEntry.localeCompare(rightEntry))
			.map(([entry, count]) => `${entry}::${count}`)
			.join('|');
		const signature = this.computeStableSignature(signaturePayload);

		return {
			formattedEntries,
			totalCount: entries.length,
			uniqueCount: counts.size,
			signature
		};
	}

	private computeStableSignature(value: string): string {
		let hash = 2166136261;
		for (let index = 0; index < value.length; index++) {
			hash ^= value.charCodeAt(index);
			hash = Math.imul(hash, 16777619);
		}

		return (hash >>> 0).toString(16).padStart(8, '0');
	}

	private extractImportTargetPathFromError(errorText: string): string | undefined {
		const importTargetUrl = this.extractImportTargetUrlFromError(errorText);
		if (!importTargetUrl) {
			return undefined;
		}

		try {
			const parsed = new URL(importTargetUrl);
			let pathname = decodeURIComponent(parsed.pathname);
			if (/^\/[a-zA-Z]:\//.test(pathname)) {
				pathname = pathname.slice(1);
			}

			return pathname;
		} catch {
			return undefined;
		}
	}

	private extractImportTargetUrlFromError(errorText: string): string | undefined {
		const match = /Failed to fetch dynamically imported module: ([^\s]+)/.exec(errorText);
		const importTargetUrl = match?.[1];
		if (!importTargetUrl) {
			return undefined;
		}

		try {
			const parsed = new URL(importTargetUrl);
			if (parsed.protocol !== 'vscode-file:' && parsed.protocol !== 'file:') {
				return undefined;
			}

			return importTargetUrl;
		} catch {
			return undefined;
		}
	}
}

export function findElement(element: IElement, fn: (element: IElement) => boolean): IElement | null {
	const queue = [element];

	while (queue.length > 0) {
		const element = queue.shift()!;

		if (fn(element)) {
			return element;
		}

		queue.push(...element.children);
	}

	return null;
}

export function findElements(element: IElement, fn: (element: IElement) => boolean): IElement[] {
	const result: IElement[] = [];
	const queue = [element];

	while (queue.length > 0) {
		const element = queue.shift()!;

		if (fn(element)) {
			result.push(element);
		}

		queue.push(...element.children);
	}

	return result;
}
