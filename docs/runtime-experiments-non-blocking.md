# Why Runtime Experiments Do Not Block Core Delivery (M9-10)

Runtime experiments are intentionally **parallel tracks** and must not block the core Pointer roadmap.

## Core delivery remains first-class

Core milestones already ship:
- tab completion flows
- chat + patch review flows
- policy/rules/hooks safety rails
- CI/headless and enterprise governance primitives

These capabilities provide direct product value independent of runtime experiments.

## Non-blocking principles

1. **Feature parity before shell migration**
   - experiments must consume stable internal APIs instead of rewriting core behavior.
2. **Reversible prototypes**
   - each experiment should be removable without affecting core sidecar/extension contracts.
3. **Separate acceptance gates**
   - experiment success criteria are measured independently from parity milestones.
4. **No critical-path dependencies**
   - release commits cannot depend on unfinished experimental runtime branches.

## Practical execution model

- keep runtime experiments behind explicit flags/prototype branches;
- continue shipping improvements to existing runtime in parallel;
- only promote an experiment when it demonstrates net improvement without parity regressions.
