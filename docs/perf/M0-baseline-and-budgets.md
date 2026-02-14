# M0 Performance Baseline and Budgets

Date: 2026-02-14  
Environment: Linux CI-like VM, Node v22.22.0, desktop runtime under `xvfb`

## Baseline measurements

### 1) Startup time

- Source: `docs/perf/startup-markers.txt`
- Command: `xvfb-run -a node scripts/code-perf.js --runtime desktop --runs 3 --duration-markers-file ...`
- Observed `ellapsed` startup times:
  - 2814 ms
  - 2919 ms
  - 4215 ms
- Baseline median: **2919 ms**

### 2) Idle memory

- Sources:
  - `docs/perf/perf-heap.txt` (heap stats from perf trace run)
  - `docs/perf/idle-memory-snapshot.txt` (RSS snapshot of running Pointer processes)
- Heap baseline (`perf-heap.txt`):
  - used: **206 MB**
  - garbage: **176 MB**
  - GC duration: **120 ms**
- RSS snapshot baseline (max process): **367276 KB (~359 MB)**

### 3) Typing latency (synthetic model edit baseline)

- Source: `docs/perf/typing-latency-baseline.txt`
- Method: 1000 single-character insertions into the piece-tree text buffer.
- Results:
  - average: 0.0050 ms
  - median: 0.0025 ms
  - p95: 0.0050 ms
  - p99: 0.0366 ms

> Note: this is a model-level synthetic baseline, not full end-to-end UI keypress latency.

## M0 performance budgets

| Metric | Baseline | Budget |
|---|---:|---:|
| Startup (`ellapsed` median) | 2919 ms | **<= 3500 ms** |
| Startup (`ellapsed` worst run) | 4215 ms | **<= 5000 ms** |
| Idle RSS (max process) | 359 MB | **<= 550 MB** |
| Heap used (perf trace) | 206 MB | **<= 300 MB** |
| Synthetic typing p95 (model edit) | 0.0050 ms | **<= 1.0 ms** |
| End-to-end typing latency target | N/A (M0 synthetic only) | **<= 50 ms p95** |

## Follow-up

- M3/M7 should add end-to-end typing latency instrumentation to replace synthetic-only typing baseline.
- CI perf gates should enforce startup + memory budgets and alert on regressions.
