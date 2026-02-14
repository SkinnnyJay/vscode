# Prompt Injection Defense Strategy (M4-17)

Pointer applies a defense-in-depth strategy for tool use and patch proposals:

1. **Instruction hierarchy preservation**
   - Detect prompt patterns that attempt to override system/rules instructions.
   - Escalate suspicious requests for explicit confirmation rather than automatic execution.

2. **Tool-gated execution**
   - Terminal/network/filesystem tools are evaluated by policy gates before execution.
   - Confirm/deny behavior is surfaced in UI; no silent privileged actions.

3. **Patch path sanitization**
   - Reject absolute and traversal (`..`) paths in patch payloads.
   - Keep edits constrained to workspace-relative, reviewable targets.

4. **Diff-first enforcement**
   - Agent edits are reviewed as diffs before apply.
   - Apply/reject/conflict states are tracked and surfaced to users.

5. **Traceability**
   - Chat plans and patch flows emit trace IDs and plan metadata for audit/debug.
