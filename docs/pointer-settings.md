# Pointer Settings Reference (M1)

This document describes the initial Pointer settings categories and defaults exposed by `extensions/pointer-ai`.

## Providers

- `pointer.providers.primary` (default: `auto`)
- `pointer.defaults.chat.provider` (default: `auto`)
- `pointer.defaults.tab.provider` (default: `auto`)
- `pointer.defaults.agent.provider` (default: `auto`)

## Models

- `pointer.models.default` (default: `auto`)
- `pointer.defaults.chat.model` (default: `auto`)
- `pointer.defaults.tab.model` (default: `auto`)
- `pointer.defaults.agent.model` (default: `auto`)

## Context

- `pointer.context.maxFiles` (default: `8`, minimum: `1`)

## Tools and Safety

- `pointer.tools.terminalPolicy` (default: `confirm`; enum: `disabled`, `confirm`, `allow`)
- `pointer.compatibility.enableCopilotVisibility` (default: `false`)

## Prompts and Rules

- `pointer.prompts.rulesProfile` (default: `workspace`)

## Notes

- Status bar routing summary reflects `pointer.defaults.*` values.
- In untrusted workspaces, Pointer warns users that workspace `.pointer/` automation files are disabled.
