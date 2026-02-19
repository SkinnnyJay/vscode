# Clean-Room Contribution Rules

Pointer is implemented as a clean-room project. Every contribution must follow these rules.

## Absolute prohibitions

Contributors must **not**:

- copy, paste, or translate proprietary Cursor source code
- decompile or reverse engineer proprietary binaries/assets
- reuse proprietary Cursor branding, screenshots, icons, or marketing copy
- import code from repositories with incompatible licenses

## Required contribution practices

- Build features from public documentation, open standards, and independently authored implementations.
- Document major design decisions in repository Markdown docs.
- Prefer additive Pointer-owned modules (`pointer/`, `extensions/pointer-ai/`) over invasive core modifications.
- Keep changes reviewable and traceable with descriptive commit messages.

## Review checklist

Before opening a PR, confirm:

1. The implementation was authored from scratch in this repository.
2. Any borrowed ideas are from license-compatible, publicly documented sources.
3. No proprietary assets or code snippets are present in changed files.
4. New tooling/scripts do not embed credentials or private data.

## Escalation

If uncertain whether a source or asset is permissible, stop and request maintainer/legal review before merging.
