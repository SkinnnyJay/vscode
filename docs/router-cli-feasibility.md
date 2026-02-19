# M2 CLI Feasibility Spike

Date: 2026-02-14  
Scope: `codex`, `claude`, `opencode` CLI adapter viability (stdin/stdout, streaming, JSON output, cancellation)

## Environment probe results

| CLI | Binary found in PATH | `--help` probe | Feasibility status |
|---|---|---|---|
| codex | No | `command not found` | **Non-viable in current env** |
| claude | No | `command not found` | **Non-viable in current env** |
| opencode | No | `command not found` | **Non-viable in current env** |

## Example probe transcripts

### Codex CLI

```text
$ codex --help
--: line 1: codex: command not found
```

### Claude CLI

```text
$ claude --help
--: line 1: claude: command not found
```

### OpenCode CLI

```text
$ opencode --help
--: line 1: opencode: command not found
```

## Capability assessment

Because binaries are unavailable in this environment, the following checks are currently blocked:

- stdin/stdout prompt exchange behavior
- streaming token output behavior
- JSON output mode behavior
- cancellation signal handling latency

## Early viability decision

All three adapters are marked **temporarily non-viable** in local development until installation/auth bootstrap is defined.

## Next enablement steps

1. Define installation/bootstrap scripts for provider CLIs.
2. Add deterministic smoke probes per CLI (`--help`, version, one-shot prompt, cancel test).
3. Record capability matrix after binaries are available and authenticated.
