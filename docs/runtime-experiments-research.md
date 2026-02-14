# Runtime Experiments Research (M9-09)

Date: 2026-02-14

## Candidate experiments

### 1) Web-first Pointer shell
- **Idea:** move AI surfaces to a browser-first shell that can run with reduced desktop dependencies.
- **Potential win:** lower install friction and faster updates.
- **Risks:** extension compatibility gaps, local tool execution trust model complexity.

### 2) Light desktop shell
- **Idea:** keep Electron host but trim startup path with optional AI-only mode.
- **Potential win:** quicker startup and lower idle memory on constrained machines.
- **Risks:** split feature surface and increased maintenance for mode parity.

### 3) Headless+remote hybrid
- **Idea:** local thin client + remote sidecar runtime for heavy AI tasks.
- **Potential win:** stronger enterprise control and scalable CI/automation reuse.
- **Risks:** latency/network dependency and offline degradation.

## Experiment recommendation order
1. Light desktop shell (lowest migration risk)
2. Headless+remote hybrid (enterprise payoff)
3. Web-first shell (largest ecosystem shift)

## Success criteria for experiments
- No regressions to core patch/tab/chat workflows.
- Measurable startup and memory improvements (or clear enterprise governance gains).
- Migration path for existing extension/setting surfaces.
