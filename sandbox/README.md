# Sandbox

Experimentation area for trying out code, tooling, and dependencies with a real environment—without affecting the main codebase.

## What this folder is for

- **Experiments that need to run** — Code, small apps, or configs you want to execute, build, or test (e.g. a mini React app, a CLI prototype).
- **Dependency and tool tryouts** — Testing new libraries, frameworks, or build tools in isolation before adopting them in the project.
- **Spikes and prototypes** — Short-lived proofs of concept that may later be discarded or folded into the main repo.
- **Learning or demos** — Small projects used for exploration or documentation examples.

## What this folder is not for

- **Production or committed application code** — Code that becomes part of Pointer IDE should live in the proper source tree and be moved out of sandbox.
- **Long-term storage** — Don’t rely on sandbox for anything permanent; it can be cleaned or reset.
- **Secrets or credentials** — No API keys, passwords, or sensitive config; use env vars or placeholders.
- **Plain notes or drafts** — Text-only or non-runnable stuff belongs in `scratchpad/`.

## Required formats

- **Structure:** Use one subfolder per experiment (e.g. `sandbox/react-spike/`, `sandbox/cli-demo/`). Each subfolder can have its own `package.json`, `requirements.txt`, or build config as needed.
- **Naming:** Use clear, kebab-case folder names that describe the experiment (e.g. `auth-flow-test`, `vite-migration-poc`).
- **Isolation:** Keep experiments self-contained. Prefer local dependencies (e.g. a local `package.json`) rather than relying on the repo root’s tooling unless that’s the point of the experiment.
- **Lifecycle:** Treat contents as disposable. When an experiment is done, either delete it, move useful code into the main project, or document it in a short README inside the subfolder; the top-level sandbox can be pruned without affecting the rest of the repo.
