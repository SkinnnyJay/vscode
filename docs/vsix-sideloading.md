# VSIX Sideloading Fallback

When an extension is unavailable in Open VSX (or a private gallery is offline), Pointer supports direct VSIX installation.

## Install from UI

1. Open **Extensions** view.
2. Select the `...` menu in the top-right.
3. Choose **Install from VSIX...**
4. Select the `.vsix` file and reload if prompted.

## Install from CLI

```bash
./scripts/code.sh --install-extension path/to/extension.vsix
```

Windows:

```powershell
.\scripts\code.bat --install-extension path\to\extension.vsix
```

## Verify installation

```bash
./scripts/code.sh --list-extensions
```

## Policy notes

- Prefer Open VSX by default; use VSIX only when registry distribution is unavailable or intentionally restricted.
- Only install VSIX packages from trusted publishers or internal artifact pipelines.
- For enterprise use, publish signed VSIX assets alongside each release to guarantee offline recoverability.
