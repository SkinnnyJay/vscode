# M8 Decision: AI Settings Sync Scope

Date: 2026-02-14

## Decision

AI settings sync is **V2 scope** (not required for M8 parity exit criteria).

## Reasoning

1. Current parity work is focused on local UX completeness and safe edit flows.
2. Syncing provider/model/policy settings across machines introduces additional security and data-boundary requirements.
3. M9 already includes an explicit task for AI settings sync if approved, making it the correct phase gate.

## Implications

- M8 ships with local/workspace AI settings only.
- Users can export/import sessions/config manually where implemented.
- M9 will own final sync design and rollout if approved.
