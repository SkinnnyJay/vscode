# Upstream Tracking Record

Last verified: 2026-02-14

## Remotes

- `origin`: Pointer fork (`SkinnnyJay/vscode`)
- `upstream`: canonical source (`microsoft/vscode`)

## Branch tracking

- Active Pointer working branch: `cursor/project-plan-intake-a339`
- Remote tracking branch: `origin/cursor/project-plan-intake-a339`
- Upstream default branch: `upstream/main`

## Verification commands

```bash
git remote -v
git branch -vv
git ls-remote --symref upstream HEAD
```

Expected upstream HEAD result:

```text
ref: refs/heads/main	HEAD
```
