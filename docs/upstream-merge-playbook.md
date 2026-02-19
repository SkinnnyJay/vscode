# Upstream Merge Playbook

This playbook is the standard procedure for syncing Pointer with `microsoft/vscode`.

## 1) Prepare local repository

```bash
git fetch origin cursor/project-plan-intake-a339
git fetch upstream main
git checkout cursor/project-plan-intake-a339
git pull origin cursor/project-plan-intake-a339
```

## 2) Create an integration branch

```bash
git checkout -b chore/upstream-sync-$(date +%Y%m%d)
```

## 3) Merge upstream

```bash
git merge --no-ff upstream/main
```

## 4) Conflict policy

When conflicts occur:

1. **Keep Pointer branding/security policy changes** in Pointer-owned docs/scripts/product configuration.
2. **Prefer upstream behavior** for untouched core/editor/workbench logic unless Pointer has an intentional override.
3. **If uncertain, fail safe**: keep conflict unresolved until owner review; do not guess in security-, update-, or trust-related files.
4. Add a short rationale in commit message for each non-trivial manual resolution.

## 5) Validate and publish

```bash
make lint
make typecheck
make test-unit
git push -u origin chore/upstream-sync-$(date +%Y%m%d)
```

Open a PR titled:

`chore: upstream sync from microsoft/vscode main (YYYY-MM-DD)`
