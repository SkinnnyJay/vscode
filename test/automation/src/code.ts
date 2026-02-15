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
	private static readonly importTargetDiagnosticsSchemaVersion = 1;
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
					const importTargetCdpScriptLifecycle = importTargetUrl
						? this.driver.getCdpScriptLifecycleSummaryForUrl(importTargetUrl)
						: undefined;
					const importTargetTotalEventCounts = importTargetUrl
						? this.driver.getImportTargetEventCounts(importTargetUrl)
						: undefined;
					const importTargetDisplayWindowRequestFailureEventCount = importTargetUrl ? this.countEntriesContainingUrl(recentFailures, importTargetUrl) : 0;
					const importTargetDisplayWindowScriptResponseEventCount = importTargetUrl ? this.countEntriesContainingUrl(recentScriptResponses, importTargetUrl) : 0;
					const importTargetDisplayWindowCdpScriptLoadEventCount = importTargetUrl ? this.countEntriesContainingUrl(recentCdpScriptLoads, importTargetUrl) : 0;
					const importTargetRequestFailureEventCount = importTargetUrl ? this.countEntriesContainingUrl(allRecentFailures, importTargetUrl) : 0;
					const importTargetScriptResponseEventCount = importTargetUrl ? this.countEntriesContainingUrl(allRecentScriptResponses, importTargetUrl) : 0;
					const importTargetCdpScriptLoadEventCount = importTargetUrl ? this.countEntriesContainingUrl(allRecentCdpScriptLoads, importTargetUrl) : 0;
					const importTargetScriptResponseStatus = importTargetUrl
						? `\nImport target latest script response: ${importTargetLatestScriptResponse ?? 'unseen'}`
						: '';
					const importTargetRequestFailureStatus = importTargetUrl
						? `\nImport target latest request failure: ${importTargetLatestRequestFailure ?? 'unseen'}`
						: '';
					const importTargetCdpScriptLoadStatus = importTargetUrl
						? `\nImport target latest CDP script load: ${importTargetLatestCdpScriptLoad ?? 'unseen'}`
						: '';
					const importTargetCdpScriptLifecycleStatus = importTargetUrl
						? `\nImport target CDP script lifecycle: ${importTargetCdpScriptLifecycle ?? 'unseen'}`
						: '';
					const importTargetDisplayWindowChannelEventCounts = importTargetUrl
						? `\nImport target display-window event counts: requestFailures=${importTargetDisplayWindowRequestFailureEventCount}, scriptResponses=${importTargetDisplayWindowScriptResponseEventCount}, cdpScriptLoads=${importTargetDisplayWindowCdpScriptLoadEventCount}`
						: '';
					const importTargetChannelEventCounts = importTargetUrl
						? `\nImport target retained-window event counts: requestFailures=${importTargetRequestFailureEventCount}, scriptResponses=${importTargetScriptResponseEventCount}, cdpScriptLoads=${importTargetCdpScriptLoadEventCount}`
						: '';
					const importTargetTotalChannelEventCounts = importTargetUrl
						? `\nImport target total event counts: requestFailures=${importTargetTotalEventCounts?.requestFailures ?? 0}, scriptResponses=${importTargetTotalEventCounts?.scriptResponses ?? 0}, cdpScriptLoads=${importTargetTotalEventCounts?.cdpScriptLoads ?? 0}`
						: '';
					const importTargetSignalClass = importTargetUrl && importTargetTotalEventCounts
						? this.classifyImportTargetSignal(importTargetTotalEventCounts)
						: 'no-import-target-url';
					const importTargetSignalClassStatus = importTargetUrl
						? `\nImport target signal class: ${importTargetSignalClass}`
						: '';
					const importTargetVisibilityClass = importTargetUrl
						? this.classifyImportTargetVisibility(
							{
								requestFailures: importTargetRequestFailureEventCount,
								scriptResponses: importTargetScriptResponseEventCount,
								cdpScriptLoads: importTargetCdpScriptLoadEventCount
							},
							importTargetTotalEventCounts
						)
						: 'no-import-target-url';
					const importTargetVisibilityClassStatus = importTargetUrl
						? `\nImport target visibility class: ${importTargetVisibilityClass}`
						: '';
					const importTargetChannelStates = {
						requestFailures: this.classifyChannelVisibilityState(importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0),
						scriptResponses: this.classifyChannelVisibilityState(importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0),
						cdpScriptLoads: this.classifyChannelVisibilityState(importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)
					};
					const importTargetChannelStatesStatus = importTargetUrl
						? `\nImport target channel states: requestFailures=${importTargetChannelStates.requestFailures}, scriptResponses=${importTargetChannelStates.scriptResponses}, cdpScriptLoads=${importTargetChannelStates.cdpScriptLoads}`
						: '';
					const importTargetChannelWindowStates = {
						requestFailures: this.classifyChannelWindowState(importTargetDisplayWindowRequestFailureEventCount, importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0),
						scriptResponses: this.classifyChannelWindowState(importTargetDisplayWindowScriptResponseEventCount, importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0),
						cdpScriptLoads: this.classifyChannelWindowState(importTargetDisplayWindowCdpScriptLoadEventCount, importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)
					};
					const importTargetChannelWindowStatesStatus = importTargetUrl
						? `\nImport target channel window states: requestFailures=${importTargetChannelWindowStates.requestFailures}, scriptResponses=${importTargetChannelWindowStates.scriptResponses}, cdpScriptLoads=${importTargetChannelWindowStates.cdpScriptLoads}`
						: '';
					const importTargetChannelWindowCoverage = {
						requestFailures: this.buildChannelWindowCoverageStats(importTargetDisplayWindowRequestFailureEventCount, importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0),
						scriptResponses: this.buildChannelWindowCoverageStats(importTargetDisplayWindowScriptResponseEventCount, importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0),
						cdpScriptLoads: this.buildChannelWindowCoverageStats(importTargetDisplayWindowCdpScriptLoadEventCount, importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)
					};
					const importTargetChannelWindowCoverageStatus = importTargetUrl
						? `\nImport target channel window coverage: requestFailures=${this.formatChannelWindowCoverage(importTargetChannelWindowCoverage.requestFailures)}, scriptResponses=${this.formatChannelWindowCoverage(importTargetChannelWindowCoverage.scriptResponses)}, cdpScriptLoads=${this.formatChannelWindowCoverage(importTargetChannelWindowCoverage.cdpScriptLoads)}`
						: '';
					const importTargetDroppedEventEstimates = importTargetTotalEventCounts
						? {
							requestFailures: Math.max(0, importTargetTotalEventCounts.requestFailures - importTargetRequestFailureEventCount),
							scriptResponses: Math.max(0, importTargetTotalEventCounts.scriptResponses - importTargetScriptResponseEventCount),
							cdpScriptLoads: Math.max(0, importTargetTotalEventCounts.cdpScriptLoads - importTargetCdpScriptLoadEventCount)
						}
						: undefined;
					const importTargetDroppedEventEstimatesStatus = importTargetUrl
						? `\nImport target dropped event estimates: requestFailures=${importTargetDroppedEventEstimates?.requestFailures ?? 0}, scriptResponses=${importTargetDroppedEventEstimates?.scriptResponses ?? 0}, cdpScriptLoads=${importTargetDroppedEventEstimates?.cdpScriptLoads ?? 0}`
						: '';
					const importTargetCoverageStatus = importTargetUrl
						? `\nImport target channel coverage: requestFailures=${this.formatCoverage(importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0)}, scriptResponses=${this.formatCoverage(importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0)}, cdpScriptLoads=${this.formatCoverage(importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)}`
						: '';
					const importTargetChannelCoverage = {
						requestFailures: this.buildChannelCoverageStats(importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0),
						scriptResponses: this.buildChannelCoverageStats(importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0),
						cdpScriptLoads: this.buildChannelCoverageStats(importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)
					};
					const importTargetChannelCoverageClasses = {
						requestFailures: this.classifyCoverageVisibility(importTargetRequestFailureEventCount, importTargetTotalEventCounts?.requestFailures ?? 0),
						scriptResponses: this.classifyCoverageVisibility(importTargetScriptResponseEventCount, importTargetTotalEventCounts?.scriptResponses ?? 0),
						cdpScriptLoads: this.classifyCoverageVisibility(importTargetCdpScriptLoadEventCount, importTargetTotalEventCounts?.cdpScriptLoads ?? 0)
					};
					const importTargetChannelCoverageClassesStatus = importTargetUrl
						? `\nImport target channel coverage classes: requestFailures=${importTargetChannelCoverageClasses.requestFailures}, scriptResponses=${importTargetChannelCoverageClasses.scriptResponses}, cdpScriptLoads=${importTargetChannelCoverageClasses.cdpScriptLoads}`
						: '';
					const importTargetDiagnosticsSchemaStatus = importTargetUrl
						? `\nImport target diagnostics schemaVersion: ${Code.importTargetDiagnosticsSchemaVersion}`
						: '';
					const importTargetDiagnosticsSignature = importTargetUrl
						? this.computeImportTargetDiagnosticsSignature(
							importTargetUrl,
							importTargetSignalClass,
							importTargetRequestFailureEventCount,
							importTargetScriptResponseEventCount,
							importTargetCdpScriptLoadEventCount,
							importTargetTotalEventCounts,
							importTargetDroppedEventEstimates
						)
						: 'no-import-target-url';
					const importTargetDiagnosticsSignatureStatus = importTargetUrl
						? `\nImport target diagnostics signature: ${importTargetDiagnosticsSignature}`
						: '';
					const importTargetDiagnosticsConsistency = this.buildImportTargetDiagnosticsConsistency(
						importTargetSignalClass,
						importTargetVisibilityClass,
						{
							requestFailures: importTargetDisplayWindowRequestFailureEventCount,
							scriptResponses: importTargetDisplayWindowScriptResponseEventCount,
							cdpScriptLoads: importTargetDisplayWindowCdpScriptLoadEventCount
						},
						{
							requestFailures: importTargetRequestFailureEventCount,
							scriptResponses: importTargetScriptResponseEventCount,
							cdpScriptLoads: importTargetCdpScriptLoadEventCount
						},
						importTargetTotalEventCounts,
						importTargetDroppedEventEstimates,
						importTargetChannelCoverage,
						importTargetChannelWindowCoverage
					);
					const importTargetDiagnosticsConsistencyStatus = importTargetUrl
						? `\nImport target diagnostics consistency: ${importTargetDiagnosticsConsistency.isConsistent ? 'pass' : 'fail'} (signal=${importTargetDiagnosticsConsistency.signalMatchesTotals}, visibility=${importTargetDiagnosticsConsistency.visibilityMatchesCounts}, deltas=${importTargetDiagnosticsConsistency.droppedMatchesDelta}, coverage=${importTargetDiagnosticsConsistency.coverageMatchesCounts}, windowCoverage=${importTargetDiagnosticsConsistency.windowCoverageMatchesCounts}, windows=${importTargetDiagnosticsConsistency.windowHierarchyMatchesCounts})`
						: '';
					const globalChannelBufferStats = {
						requestFailures: {
							displayed: recentFailures.length,
							retained: allRecentFailures.length,
							capacity: recentFailureCapacity,
							observed: totalObservedRequestFailures,
							dropped: droppedRecentRequestFailures
						},
						scriptResponses: {
							displayed: recentScriptResponses.length,
							retained: allRecentScriptResponses.length,
							capacity: recentScriptResponseCapacity,
							observed: totalObservedScriptResponses,
							dropped: droppedRecentScriptResponses
						},
						cdpScriptLoads: {
							displayed: recentCdpScriptLoads.length,
							retained: allRecentCdpScriptLoads.length,
							capacity: recentCdpScriptLoadCapacity,
							observed: totalObservedCdpScriptLoads,
							dropped: droppedRecentCdpScriptLoads
						}
					};
					const globalChannelBufferStatsStatus = importTargetUrl
						? `\nImport target global channel buffers: requestFailures=${globalChannelBufferStats.requestFailures.displayed}/${globalChannelBufferStats.requestFailures.retained} (capacity=${globalChannelBufferStats.requestFailures.capacity}, observed=${globalChannelBufferStats.requestFailures.observed}, dropped=${globalChannelBufferStats.requestFailures.dropped}), scriptResponses=${globalChannelBufferStats.scriptResponses.displayed}/${globalChannelBufferStats.scriptResponses.retained} (capacity=${globalChannelBufferStats.scriptResponses.capacity}, observed=${globalChannelBufferStats.scriptResponses.observed}, dropped=${globalChannelBufferStats.scriptResponses.dropped}), cdpScriptLoads=${globalChannelBufferStats.cdpScriptLoads.displayed}/${globalChannelBufferStats.cdpScriptLoads.retained} (capacity=${globalChannelBufferStats.cdpScriptLoads.capacity}, observed=${globalChannelBufferStats.cdpScriptLoads.observed}, dropped=${globalChannelBufferStats.cdpScriptLoads.dropped})`
						: '';
					const importTargetGlobalBufferSignature = this.computeGlobalBufferSignature(globalChannelBufferStats);
					const importTargetGlobalBufferSignatureStatus = importTargetUrl
						? `\nImport target global buffer signature: ${importTargetGlobalBufferSignature}`
						: '';
					const importTargetCompositeSignature = this.computeImportTargetCompositeSignature(
						importTargetDiagnosticsSignature,
						importTargetGlobalBufferSignature,
						importTargetDiagnosticsConsistency
					);
					const importTargetCompositeSignatureStatus = importTargetUrl
						? `\nImport target composite signature: ${importTargetCompositeSignature}`
						: '';
					const importTargetDiagnosticsRecord = this.buildImportTargetDiagnosticsRecord(
						importTargetUrl,
						importTargetTotalEventCounts,
						{
							requestFailures: importTargetDisplayWindowRequestFailureEventCount,
							scriptResponses: importTargetDisplayWindowScriptResponseEventCount,
							cdpScriptLoads: importTargetDisplayWindowCdpScriptLoadEventCount
						},
						{
							requestFailures: importTargetRequestFailureEventCount,
							scriptResponses: importTargetScriptResponseEventCount,
							cdpScriptLoads: importTargetCdpScriptLoadEventCount
						},
						importTargetDroppedEventEstimates,
						importTargetSignalClass,
						importTargetVisibilityClass,
						importTargetChannelStates,
						importTargetChannelWindowStates,
						importTargetChannelWindowCoverage,
						importTargetChannelCoverage,
						importTargetChannelCoverageClasses,
						importTargetDiagnosticsConsistency,
						importTargetDiagnosticsSignature,
						importTargetGlobalBufferSignature,
						importTargetCompositeSignature,
						trial,
						retryInterval,
						globalChannelBufferStats
					);
					const importTargetDiagnosticsRecordStatus = importTargetDiagnosticsRecord
						? `\nImport target diagnostics record: ${JSON.stringify(importTargetDiagnosticsRecord)}`
						: '';
					const importTargetDetectionTimingStatus = importTargetUrl
						? `\nImport target detection timing: trial=${trial}, elapsedMs=${(trial - 1) * retryInterval}`
						: '';

					throw new Error(`Workbench startup failed due to renderer module import error: ${pageError}${importTargetStatus}${importTargetScriptResponseStatus}${importTargetRequestFailureStatus}${importTargetCdpScriptLoadStatus}${importTargetCdpScriptLifecycleStatus}${importTargetDisplayWindowChannelEventCounts}${importTargetChannelEventCounts}${importTargetTotalChannelEventCounts}${importTargetSignalClassStatus}${importTargetVisibilityClassStatus}${importTargetChannelStatesStatus}${importTargetChannelWindowStatesStatus}${importTargetChannelWindowCoverageStatus}${importTargetDroppedEventEstimatesStatus}${importTargetCoverageStatus}${importTargetChannelCoverageClassesStatus}${importTargetDiagnosticsSchemaStatus}${importTargetDiagnosticsSignatureStatus}${importTargetGlobalBufferSignatureStatus}${importTargetCompositeSignatureStatus}${importTargetDiagnosticsConsistencyStatus}${importTargetDetectionTimingStatus}${globalChannelBufferStatsStatus}${importTargetDiagnosticsRecordStatus}${failureSummary}${scriptResponseSummary}${cdpScriptLoadSummary}`);
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

	private countEntriesContainingUrl(entries: readonly string[], url: string): number {
		const targetUrlKey = this.toNormalizedUrlKey(url);
		let count = 0;
		for (const entry of entries) {
			const entryUrl = this.extractFirstFileLikeUrl(entry);
			if (entryUrl && this.toNormalizedUrlKey(entryUrl) === targetUrlKey) {
				count++;
				continue;
			}

			if (entry.includes(url)) {
				count++;
			}
		}

		return count;
	}

	private classifyImportTargetSignal(eventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number }): string {
		const { requestFailures, scriptResponses, cdpScriptLoads } = eventCounts;

		if (requestFailures === 0 && scriptResponses === 0 && cdpScriptLoads === 0) {
			return 'no-channel-signals';
		}

		if (requestFailures > 0 && scriptResponses === 0 && cdpScriptLoads === 0) {
			return 'request-failure-only';
		}

		if (requestFailures === 0 && scriptResponses > 0 && cdpScriptLoads === 0) {
			return 'response-only-no-cdp-finish';
		}

		if (requestFailures === 0 && scriptResponses === 0 && cdpScriptLoads > 0) {
			return 'cdp-finish-only';
		}

		if (requestFailures > 0 && scriptResponses > 0 && cdpScriptLoads === 0) {
			return 'response-and-request-failure';
		}

		if (requestFailures === 0 && scriptResponses > 0 && cdpScriptLoads > 0) {
			return 'response-and-cdp-finish';
		}

		if (requestFailures > 0 && scriptResponses === 0 && cdpScriptLoads > 0) {
			return 'request-failure-and-cdp-finish';
		}

		return 'mixed-all-channels';
	}

	private classifyImportTargetVisibility(
		recentEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number },
		totalEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined
	): string {
		const hasRecentSignals = recentEventCounts.requestFailures > 0 || recentEventCounts.scriptResponses > 0 || recentEventCounts.cdpScriptLoads > 0;
		const hasTotalSignals = (totalEventCounts?.requestFailures ?? 0) > 0 || (totalEventCounts?.scriptResponses ?? 0) > 0 || (totalEventCounts?.cdpScriptLoads ?? 0) > 0;

		if (hasRecentSignals) {
			return 'visible-in-recent-window';
		}

		if (hasTotalSignals) {
			return 'historical-only-truncated-from-window';
		}

		return 'unseen-across-all-channels';
	}

	private classifyChannelVisibilityState(recentCount: number, totalCount: number): 'visible' | 'truncated' | 'unseen' {
		if (recentCount > 0) {
			return 'visible';
		}

		if (totalCount > 0) {
			return 'truncated';
		}

		return 'unseen';
	}

	private classifyChannelWindowState(displayCount: number, retainedCount: number, totalCount: number): 'displayed' | 'retained-only' | 'historical-only' | 'unseen' {
		if (displayCount > 0) {
			return 'displayed';
		}

		if (retainedCount > 0) {
			return 'retained-only';
		}

		if (totalCount > 0) {
			return 'historical-only';
		}

		return 'unseen';
	}

	private computeImportTargetDiagnosticsSignature(
		importTargetUrl: string,
		importTargetSignalClass: string,
		recentRequestFailures: number,
		recentScriptResponses: number,
		recentCdpScriptLoads: number,
		totalEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined,
		droppedEventEstimates: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined
	): string {
		const payload = [
			`url=${importTargetUrl}`,
			`signalClass=${importTargetSignalClass}`,
			`recent.requestFailures=${recentRequestFailures}`,
			`recent.scriptResponses=${recentScriptResponses}`,
			`recent.cdpScriptLoads=${recentCdpScriptLoads}`,
			`total.requestFailures=${totalEventCounts?.requestFailures ?? 0}`,
			`total.scriptResponses=${totalEventCounts?.scriptResponses ?? 0}`,
			`total.cdpScriptLoads=${totalEventCounts?.cdpScriptLoads ?? 0}`,
			`dropped.requestFailures=${droppedEventEstimates?.requestFailures ?? 0}`,
			`dropped.scriptResponses=${droppedEventEstimates?.scriptResponses ?? 0}`,
			`dropped.cdpScriptLoads=${droppedEventEstimates?.cdpScriptLoads ?? 0}`
		].join('|');

		return this.computeStableSignature(payload);
	}

	private buildImportTargetDiagnosticsRecord(
		importTargetUrl: string | undefined,
		totalEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined,
		displayWindowEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number },
		recentEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number },
		droppedEventEstimates: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined,
		signalClass: string,
		visibilityClass: string,
		channelStates: { requestFailures: 'visible' | 'truncated' | 'unseen'; scriptResponses: 'visible' | 'truncated' | 'unseen'; cdpScriptLoads: 'visible' | 'truncated' | 'unseen' },
		channelWindowStates: { requestFailures: 'displayed' | 'retained-only' | 'historical-only' | 'unseen'; scriptResponses: 'displayed' | 'retained-only' | 'historical-only' | 'unseen'; cdpScriptLoads: 'displayed' | 'retained-only' | 'historical-only' | 'unseen' },
		channelWindowCoverage: {
			requestFailures: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			scriptResponses: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			cdpScriptLoads: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
		},
		channelCoverage: {
			requestFailures: { recent: number; total: number; percent: number | null };
			scriptResponses: { recent: number; total: number; percent: number | null };
			cdpScriptLoads: { recent: number; total: number; percent: number | null };
		},
		channelCoverageClasses: {
			requestFailures: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
			scriptResponses: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
			cdpScriptLoads: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
		},
		consistencyChecks: {
			signalMatchesTotals: boolean;
			visibilityMatchesCounts: boolean;
			droppedMatchesDelta: boolean;
			coverageMatchesCounts: boolean;
			windowCoverageMatchesCounts: boolean;
			windowHierarchyMatchesCounts: boolean;
			isConsistent: boolean;
		},
		signature: string,
		globalBufferSignature: string,
		compositeSignature: string,
		detectedAtTrial: number,
		retryIntervalMs: number,
		globalChannelBufferStats: {
			requestFailures: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
			scriptResponses: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
			cdpScriptLoads: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
		}
	): {
		schemaVersion: number;
		url: string;
		signalClass: string;
		visibilityClass: string;
		channelStates: { requestFailures: 'visible' | 'truncated' | 'unseen'; scriptResponses: 'visible' | 'truncated' | 'unseen'; cdpScriptLoads: 'visible' | 'truncated' | 'unseen' };
		channelWindowStates: { requestFailures: 'displayed' | 'retained-only' | 'historical-only' | 'unseen'; scriptResponses: 'displayed' | 'retained-only' | 'historical-only' | 'unseen'; cdpScriptLoads: 'displayed' | 'retained-only' | 'historical-only' | 'unseen' };
		channelWindowCoverage: {
			requestFailures: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			scriptResponses: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			cdpScriptLoads: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
		};
		channelCoverage: {
			requestFailures: { recent: number; total: number; percent: number | null };
			scriptResponses: { recent: number; total: number; percent: number | null };
			cdpScriptLoads: { recent: number; total: number; percent: number | null };
		};
		channelCoverageClasses: {
			requestFailures: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
			scriptResponses: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
			cdpScriptLoads: 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible';
		};
		consistencyChecks: {
			signalMatchesTotals: boolean;
			visibilityMatchesCounts: boolean;
			droppedMatchesDelta: boolean;
			coverageMatchesCounts: boolean;
			windowCoverageMatchesCounts: boolean;
			windowHierarchyMatchesCounts: boolean;
			isConsistent: boolean;
		};
		detectedAtTrial: number;
		detectedAtElapsedMs: number;
		globalBufferSignature: string;
		compositeSignature: string;
		displayWindowEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number };
		recentEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number };
		totalEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number };
		droppedEventEstimates: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number };
		globalChannelBufferStats: {
			requestFailures: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
			scriptResponses: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
			cdpScriptLoads: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
		};
		signature: string;
	} | undefined {
		if (!importTargetUrl) {
			return undefined;
		}

		return {
			schemaVersion: Code.importTargetDiagnosticsSchemaVersion,
			url: importTargetUrl,
			signalClass,
			visibilityClass,
			channelStates,
			channelWindowStates,
			channelWindowCoverage,
			channelCoverage,
			channelCoverageClasses,
			consistencyChecks,
			globalBufferSignature,
			compositeSignature,
			detectedAtTrial,
			detectedAtElapsedMs: (detectedAtTrial - 1) * retryIntervalMs,
			displayWindowEventCounts,
			recentEventCounts,
			totalEventCounts: totalEventCounts ?? { requestFailures: 0, scriptResponses: 0, cdpScriptLoads: 0 },
			droppedEventEstimates: droppedEventEstimates ?? { requestFailures: 0, scriptResponses: 0, cdpScriptLoads: 0 },
			globalChannelBufferStats,
			signature
		};
	}

	private formatCoverage(recentCount: number, totalCount: number): string {
		if (totalCount <= 0) {
			return `n/a (${recentCount}/${totalCount})`;
		}

		const percent = Math.round((recentCount / totalCount) * 1000) / 10;
		return `${percent}% (${recentCount}/${totalCount})`;
	}

	private buildChannelCoverageStats(recentCount: number, totalCount: number): { recent: number; total: number; percent: number | null } {
		if (totalCount <= 0) {
			return { recent: recentCount, total: totalCount, percent: null };
		}

		const percent = Math.round((recentCount / totalCount) * 1000) / 10;
		return { recent: recentCount, total: totalCount, percent };
	}

	private buildChannelWindowCoverageStats(displayCount: number, retainedCount: number, totalCount: number): {
		displayInRetained: { recent: number; total: number; percent: number | null };
		retainedInTotal: { recent: number; total: number; percent: number | null };
	} {
		return {
			displayInRetained: this.buildChannelCoverageStats(displayCount, retainedCount),
			retainedInTotal: this.buildChannelCoverageStats(retainedCount, totalCount)
		};
	}

	private formatChannelWindowCoverage(channelWindowCoverage: {
		displayInRetained: { recent: number; total: number; percent: number | null };
		retainedInTotal: { recent: number; total: number; percent: number | null };
	}): string {
		return `display=${this.formatCoverage(channelWindowCoverage.displayInRetained.recent, channelWindowCoverage.displayInRetained.total)}, retained=${this.formatCoverage(channelWindowCoverage.retainedInTotal.recent, channelWindowCoverage.retainedInTotal.total)}`;
	}

	private classifyCoverageVisibility(recentCount: number, totalCount: number): 'n-a' | 'none-visible' | 'partial-visible' | 'fully-visible' {
		if (totalCount <= 0) {
			return 'n-a';
		}

		if (recentCount <= 0) {
			return 'none-visible';
		}

		if (recentCount >= totalCount) {
			return 'fully-visible';
		}

		return 'partial-visible';
	}

	private buildImportTargetDiagnosticsConsistency(
		signalClass: string,
		visibilityClass: string,
		displayWindowEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number },
		recentEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number },
		totalEventCounts: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined,
		droppedEventEstimates: { requestFailures: number; scriptResponses: number; cdpScriptLoads: number } | undefined,
		channelCoverage: {
			requestFailures: { recent: number; total: number; percent: number | null };
			scriptResponses: { recent: number; total: number; percent: number | null };
			cdpScriptLoads: { recent: number; total: number; percent: number | null };
		},
		channelWindowCoverage: {
			requestFailures: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			scriptResponses: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
			cdpScriptLoads: {
				displayInRetained: { recent: number; total: number; percent: number | null };
				retainedInTotal: { recent: number; total: number; percent: number | null };
			};
		}
	): {
		signalMatchesTotals: boolean;
		visibilityMatchesCounts: boolean;
		droppedMatchesDelta: boolean;
		coverageMatchesCounts: boolean;
		windowCoverageMatchesCounts: boolean;
		windowHierarchyMatchesCounts: boolean;
		isConsistent: boolean;
	} {
		const normalizedTotals = totalEventCounts ?? { requestFailures: 0, scriptResponses: 0, cdpScriptLoads: 0 };
		const normalizedDropped = droppedEventEstimates ?? { requestFailures: 0, scriptResponses: 0, cdpScriptLoads: 0 };
		const expectedSignalClass = this.classifyImportTargetSignal(normalizedTotals);
		const expectedVisibilityClass = this.classifyImportTargetVisibility(recentEventCounts, normalizedTotals);
		const expectedDropped = {
			requestFailures: Math.max(0, normalizedTotals.requestFailures - recentEventCounts.requestFailures),
			scriptResponses: Math.max(0, normalizedTotals.scriptResponses - recentEventCounts.scriptResponses),
			cdpScriptLoads: Math.max(0, normalizedTotals.cdpScriptLoads - recentEventCounts.cdpScriptLoads)
		};
		const signalMatchesTotals = signalClass === expectedSignalClass;
		const visibilityMatchesCounts = visibilityClass === expectedVisibilityClass;
		const droppedMatchesDelta = normalizedDropped.requestFailures === expectedDropped.requestFailures
			&& normalizedDropped.scriptResponses === expectedDropped.scriptResponses
			&& normalizedDropped.cdpScriptLoads === expectedDropped.cdpScriptLoads;
		const coverageMatchesCounts = channelCoverage.requestFailures.recent === recentEventCounts.requestFailures
			&& channelCoverage.scriptResponses.recent === recentEventCounts.scriptResponses
			&& channelCoverage.cdpScriptLoads.recent === recentEventCounts.cdpScriptLoads
			&& channelCoverage.requestFailures.total === normalizedTotals.requestFailures
			&& channelCoverage.scriptResponses.total === normalizedTotals.scriptResponses
			&& channelCoverage.cdpScriptLoads.total === normalizedTotals.cdpScriptLoads;
		const windowCoverageMatchesCounts = channelWindowCoverage.requestFailures.displayInRetained.recent === displayWindowEventCounts.requestFailures
			&& channelWindowCoverage.requestFailures.displayInRetained.total === recentEventCounts.requestFailures
			&& channelWindowCoverage.requestFailures.retainedInTotal.recent === recentEventCounts.requestFailures
			&& channelWindowCoverage.requestFailures.retainedInTotal.total === normalizedTotals.requestFailures
			&& channelWindowCoverage.scriptResponses.displayInRetained.recent === displayWindowEventCounts.scriptResponses
			&& channelWindowCoverage.scriptResponses.displayInRetained.total === recentEventCounts.scriptResponses
			&& channelWindowCoverage.scriptResponses.retainedInTotal.recent === recentEventCounts.scriptResponses
			&& channelWindowCoverage.scriptResponses.retainedInTotal.total === normalizedTotals.scriptResponses
			&& channelWindowCoverage.cdpScriptLoads.displayInRetained.recent === displayWindowEventCounts.cdpScriptLoads
			&& channelWindowCoverage.cdpScriptLoads.displayInRetained.total === recentEventCounts.cdpScriptLoads
			&& channelWindowCoverage.cdpScriptLoads.retainedInTotal.recent === recentEventCounts.cdpScriptLoads
			&& channelWindowCoverage.cdpScriptLoads.retainedInTotal.total === normalizedTotals.cdpScriptLoads;
		const windowHierarchyMatchesCounts = displayWindowEventCounts.requestFailures <= recentEventCounts.requestFailures
			&& displayWindowEventCounts.scriptResponses <= recentEventCounts.scriptResponses
			&& displayWindowEventCounts.cdpScriptLoads <= recentEventCounts.cdpScriptLoads
			&& recentEventCounts.requestFailures <= normalizedTotals.requestFailures
			&& recentEventCounts.scriptResponses <= normalizedTotals.scriptResponses
			&& recentEventCounts.cdpScriptLoads <= normalizedTotals.cdpScriptLoads;
		const isConsistent = signalMatchesTotals && visibilityMatchesCounts && droppedMatchesDelta && coverageMatchesCounts && windowCoverageMatchesCounts && windowHierarchyMatchesCounts;

		return {
			signalMatchesTotals,
			visibilityMatchesCounts,
			droppedMatchesDelta,
			coverageMatchesCounts,
			windowCoverageMatchesCounts,
			windowHierarchyMatchesCounts,
			isConsistent
		};
	}

	private computeGlobalBufferSignature(globalChannelBufferStats: {
		requestFailures: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
		scriptResponses: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
		cdpScriptLoads: { displayed: number; retained: number; capacity: number; observed: number; dropped: number };
	}): string {
		const payload = [
			`requestFailures.displayed=${globalChannelBufferStats.requestFailures.displayed}`,
			`requestFailures.retained=${globalChannelBufferStats.requestFailures.retained}`,
			`requestFailures.capacity=${globalChannelBufferStats.requestFailures.capacity}`,
			`requestFailures.observed=${globalChannelBufferStats.requestFailures.observed}`,
			`requestFailures.dropped=${globalChannelBufferStats.requestFailures.dropped}`,
			`scriptResponses.displayed=${globalChannelBufferStats.scriptResponses.displayed}`,
			`scriptResponses.retained=${globalChannelBufferStats.scriptResponses.retained}`,
			`scriptResponses.capacity=${globalChannelBufferStats.scriptResponses.capacity}`,
			`scriptResponses.observed=${globalChannelBufferStats.scriptResponses.observed}`,
			`scriptResponses.dropped=${globalChannelBufferStats.scriptResponses.dropped}`,
			`cdpScriptLoads.displayed=${globalChannelBufferStats.cdpScriptLoads.displayed}`,
			`cdpScriptLoads.retained=${globalChannelBufferStats.cdpScriptLoads.retained}`,
			`cdpScriptLoads.capacity=${globalChannelBufferStats.cdpScriptLoads.capacity}`,
			`cdpScriptLoads.observed=${globalChannelBufferStats.cdpScriptLoads.observed}`,
			`cdpScriptLoads.dropped=${globalChannelBufferStats.cdpScriptLoads.dropped}`
		].join('|');

		return this.computeStableSignature(payload);
	}

	private computeImportTargetCompositeSignature(
		diagnosticsSignature: string,
		globalBufferSignature: string,
		consistencyChecks: {
			signalMatchesTotals: boolean;
			visibilityMatchesCounts: boolean;
			droppedMatchesDelta: boolean;
			coverageMatchesCounts: boolean;
			windowCoverageMatchesCounts: boolean;
			windowHierarchyMatchesCounts: boolean;
			isConsistent: boolean;
		}
	): string {
		const payload = [
			`diagnostics=${diagnosticsSignature}`,
			`globalBuffer=${globalBufferSignature}`,
			`signalMatchesTotals=${consistencyChecks.signalMatchesTotals}`,
			`visibilityMatchesCounts=${consistencyChecks.visibilityMatchesCounts}`,
			`droppedMatchesDelta=${consistencyChecks.droppedMatchesDelta}`,
			`coverageMatchesCounts=${consistencyChecks.coverageMatchesCounts}`,
			`windowCoverageMatchesCounts=${consistencyChecks.windowCoverageMatchesCounts}`,
			`windowHierarchyMatchesCounts=${consistencyChecks.windowHierarchyMatchesCounts}`,
			`isConsistent=${consistencyChecks.isConsistent}`
		].join('|');

		return this.computeStableSignature(payload);
	}

	private extractFirstFileLikeUrl(value: string): string | undefined {
		const match = /(vscode-file:\/\/\S+|file:\/\/\S+)/.exec(value);
		return match?.[1];
	}

	private toNormalizedUrlKey(url: string): string {
		try {
			const parsed = new URL(url);
			return `${parsed.protocol}//${parsed.host}${parsed.pathname}`;
		} catch {
			return url;
		}
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
