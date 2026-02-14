# Pointer Workspace Trust Model

Pointer uses VS Code workspace trust as the primary safety gate for workspace-scoped automation config.

## Trust rules

### Untrusted workspace

- Do **not** load workspace `.pointer/` files (`rules`, `prompts`, `commands`, `hooks`, `mcp`, excludes).
- Do **not** execute workspace-declared tools, hooks, or command templates.
- Use only user-level defaults and built-in safe settings.
- Show explicit warning that Pointer workspace automation is disabled until trust is granted.

### Trusted workspace

- Load workspace `.pointer/` files with standard precedence rules.
- Allow workspace-configured prompt/rules/hooks pipelines subject to policy gates.
- Keep dangerous tools (terminal/network/filesystem) behind confirm/allowlist controls even in trusted mode.

## Configuration precedence

1. Session overrides
2. Trusted workspace `.pointer/` config
3. User settings defaults
4. Built-in defaults

## Security posture

- Trust controls **whether workspace policy is loaded**, not whether safety gates are bypassed.
- Confirmation policies and allowlists remain active regardless of trust.
- Workspace trust state should be visible in Pointer UI context and logs.
