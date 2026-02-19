# Upstream Security External Fix Tracking (M8-08)

Tag: `upstream-vscode-security-fix`

## Scope

Task: Update Electron/Chromium/dependency stack to reduce active vulnerabilities.

## Status

This task is flagged as an **upstream VS Code external fix** because Pointer inherits the Electron/Chromium runtime stack from Code - OSS.

### What was done in this milestone

1. Marked this item as an upstream-tracked security dependency task with explicit tag:
   - `upstream-vscode-security-fix`
2. Added this tracking document to keep the requirement visible in Pointer planning.
3. Kept implementation changes local to Pointer-owned layers while deferring runtime stack bumps to upstream syncs.

## Why upstream

- Electron/Chromium runtime version changes have broad blast radius in Code - OSS.
- Pointer follows upstream cadence for core runtime updates to remain merge-compatible.
- Runtime security updates should land via upstream merge/sync playbook already defined in repository docs.

## Follow-up

- Apply upstream runtime security updates when syncing from upstream/main.
- Re-run smoke launch + perf regression workflows after each upstream runtime bump.
