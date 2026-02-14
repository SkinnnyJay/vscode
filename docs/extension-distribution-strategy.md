# Extension Distribution Strategy

Last updated: 2026-02-14

## Decision

Pointer will use a **hybrid distribution strategy**:

1. **Primary registry:** Open VSX
2. **Secondary channel:** signed VSIX artifacts for direct sideload/install
3. **Optional enterprise channel:** private extension registry (self-hosted or managed)

## Why this strategy

- Avoids dependency on Visual Studio Marketplace licensing restrictions for forks.
- Preserves broad compatibility with existing open-source extension publishing flows.
- Provides a controlled fallback path when an extension is unavailable in Open VSX.

## Policy

- Pointer does **not** claim compatibility with Microsoft Marketplace terms by default.
- Pointer-owned extensions should be published to Open VSX and also attached as versioned VSIX artifacts in releases.
- Enterprise/private installations may override gallery settings to an internal endpoint.

## Operational rollout

1. Configure `product.json` to use Open VSX endpoints by default.
2. Document VSIX sideload workflow for offline and private deployments.
3. Add CI checks to ensure Pointer-owned extension bundles are produced and attached to release artifacts.
