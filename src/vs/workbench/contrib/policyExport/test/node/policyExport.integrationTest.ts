/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import * as assert from 'assert';
import * as cp from 'child_process';
import { promises as fs } from 'fs';
import * as os from 'os';
import { ensureNoDisposablesAreLeakedInTestSuite } from '../../../../../base/test/common/utils.js';
import { isWindows } from '../../../../../base/common/platform.js';
import { dirname, join } from '../../../../../base/common/path.js';
import { FileAccess } from '../../../../../base/common/network.js';
import * as util from 'util';

const execFile = util.promisify(cp.execFile);
const policyExportRetries = 3;
const policyExportRetryDelayMs = 500;
const policyExportAttemptTimeoutMs = 90000;
const policyExportTestTimeoutMs = 300000;
const policyExportFileWaitTimeoutMs = 5000;
const policyExportFileWaitIntervalMs = 200;

suite('PolicyExport Integration Tests', () => {
	ensureNoDisposablesAreLeakedInTestSuite();

	test('exported policy data matches checked-in file', async function () {
		// Skip this test in ADO pipelines
		if (process.env['TF_BUILD']) {
			this.skip();
		}

		// This test launches VS Code with --export-policy-data flag, so it takes longer
		this.timeout(policyExportTestTimeoutMs);

		// Get the repository root (FileAccess.asFileUri('') points to the 'out' directory)
		const rootPath = dirname(FileAccess.asFileUri('').fsPath);
		const checkedInFile = join(rootPath, 'build/lib/policies/policyData.jsonc');
		const tempFile = join(os.tmpdir(), `policyData-test-${Date.now()}.jsonc`);

		try {
			// Launch VS Code with --export-policy-data flag
			const scriptPath = isWindows
				? join(rootPath, 'scripts', 'code.bat')
				: join(rootPath, 'scripts', 'code.sh');

			await runPolicyExportWithRetry(scriptPath, tempFile, rootPath);

			// Read both files
			const [exportedContent, checkedInContent] = await Promise.all([
				fs.readFile(tempFile, 'utf-8'),
				fs.readFile(checkedInFile, 'utf-8')
			]);

			// Compare contents
			assert.strictEqual(
				exportedContent,
				checkedInContent,
				'Exported policy data should match the checked-in file. If this fails, run: ./scripts/code.sh --export-policy-data'
			);
		} finally {
			// Clean up temp file
			try {
				await fs.unlink(tempFile);
			} catch {
				// Ignore cleanup errors
			}
		}
	});
});

async function runPolicyExportWithRetry(scriptPath: string, targetPath: string, cwd: string): Promise<void> {
	let lastError: Error | undefined;

	for (let attempt = 1; attempt <= policyExportRetries; attempt++) {
		try {
			await fs.unlink(targetPath).catch(() => undefined);
			const execResult = await execFile(scriptPath, [
				`--export-policy-data=${targetPath}`,
				'--disable-extensions',
				'--disable-gpu',
				'--skip-welcome'
			], {
				cwd,
				env: { ...process.env, VSCODE_SKIP_PRELAUNCH: '1' },
				timeout: policyExportAttemptTimeoutMs
			});

			const fileCreated = await waitForFile(targetPath, policyExportFileWaitTimeoutMs, policyExportFileWaitIntervalMs);
			if (fileCreated) {
				return;
			}

			lastError = new Error(`Policy export command completed but did not produce output file '${targetPath}' (attempt ${attempt}/${policyExportRetries}). stdout='${execResult.stdout.trim()}' stderr='${execResult.stderr.trim()}'`);
		} catch (error) {
			lastError = error instanceof Error ? error : new Error(String(error));
		}

		if (attempt < policyExportRetries) {
			await new Promise<void>(resolve => setTimeout(resolve, policyExportRetryDelayMs));
		}
	}

	throw lastError ?? new Error(`Policy export failed after ${policyExportRetries} attempts.`);
}

async function waitForFile(path: string, timeoutMs: number, intervalMs: number): Promise<boolean> {
	const startedAt = Date.now();

	while ((Date.now() - startedAt) < timeoutMs) {
		try {
			await fs.access(path);
			return true;
		} catch {
			await new Promise<void>(resolve => setTimeout(resolve, intervalMs));
		}
	}

	return false;
}
