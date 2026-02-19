# ACP Compatibility Layer Decision (M2-22)

Date: 2026-02-14

## Decision

For M2, Pointer will **not** implement an ACP compatibility layer.

## Rationale

1. Current M2 scope is focused on direct CLI adapters (Codex/Claude/OpenCode).
2. CLI availability/auth setup is still maturing; adding ACP abstraction now would increase complexity without immediate execution value.
3. Router/provider contracts are now explicit in `pointer/agent`, which allows a future ACP bridge to map onto stable internal interfaces later.

## Consequences

- Provider integration continues through direct adapter implementations.
- ACP support is deferred to a later milestone when:
  - provider bootstrap is stable,
  - cancellation/stream semantics are proven in production-like scenarios,
  - interoperability requirements are concrete.

## Revisit trigger

Re-evaluate ACP layer implementation when at least two of the following are true:

1. Multiple non-CLI providers require a shared protocol bridge.
2. Enterprise integrations demand ACP-specific tooling compatibility.
3. Router/plugin ecosystem requires ACP protocol interoperability.
