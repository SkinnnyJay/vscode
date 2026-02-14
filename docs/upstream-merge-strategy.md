# Upstream Merge Strategy

Last updated: 2026-02-14

## Objectives

1. Keep Pointer close to `microsoft/vscode` to reduce long-lived fork drift.
2. Isolate Pointer-owned functionality in extension/sidecar areas to minimize core conflicts.
3. Preserve a predictable, reviewable upstream sync rhythm.

## Cadence

- **Continuous:** CI runs a lightweight upstream conflict check on every PR.
- **Weekly:** perform an upstream sync pass from `upstream/main` into the fork.
- **Milestone boundary (or monthly, whichever comes first):** run full lint/typecheck/tests and smoke launch validation after upstream sync.

## Rebase and merge policy

- **Upstream sync into fork default branch:** use a **merge commit** from `upstream/main` into the fork branch so sync points remain explicit and easy to audit.
- **Feature branches:** rebase onto the latest fork default branch before merge to keep Pointer changes linear and reduce conflict amplification.
- **No force pushes on shared branches:** avoid history rewrites on collaborative branches; only clean local branch history before opening PRs.

## Patch placement policy

- Prefer built-in extension and sidecar changes over deep core patches.
- When core changes are unavoidable, keep them minimal and documented with rationale near code and in PR description.
