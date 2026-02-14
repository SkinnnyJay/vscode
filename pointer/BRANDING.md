# Pointer Branding Rules

This document defines what branding assets may be used in Pointer and what must never be shipped.

## Allowed assets

- Pointer-owned name and marks:
  - Product name: **Pointer**
  - Long name: **Pointer IDE**
- Pointer-owned icon files under:
  - `resources/linux/pointer.png`
  - `resources/win32/pointer*.png`
  - `resources/win32/pointer.ico`
  - `resources/darwin/pointer.icns`
- Neutral fallback assets used only as temporary placeholders while Pointer-owned replacements are prepared.
- Documentation screenshots or examples that are explicitly created for this repository.

## Forbidden assets and marks

- Any proprietary Cursor logo, icon, screenshot, or marketing asset.
- Any Microsoft Visual Studio Code trademarked names/logos in shipped product identity.
- Marketplace branding that implies official Microsoft distribution unless explicitly licensed for use.
- Decompiled, reverse-engineered, or copied proprietary binaries/resources from third-party apps.

## Naming and metadata constraints

- `product.json` must keep Pointer identity values (`nameShort`, `nameLong`, `applicationName`, URL protocol, issue/update URLs) aligned with this repository.
- Linux/Windows/macOS package metadata must use Pointer naming, not Visual Studio Code or Cursor naming.
- New assets must be committed in-source; do not fetch runtime branding from third-party servers.

## Review checklist for branding changes

1. Confirm no new `Cursor` or `Visual Studio Code` marks are introduced in product identity paths.
2. Confirm icons used for launcher/installers are Pointer-owned or approved placeholders.
3. Confirm issue, update, and homepage URLs point to Pointer-controlled locations.
4. Confirm legal docs (`SECURITY.md`, `CODE_OF_CONDUCT.md`, contribution policy) stay consistent with clean-room constraints.
