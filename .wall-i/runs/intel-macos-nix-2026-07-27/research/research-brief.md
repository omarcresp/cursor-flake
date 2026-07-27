# Intel macOS in Nix — research brief

Date: 2026-07-27

## Question

Has Intel macOS (`x86_64-darwin`) been dropped from Nix, and should
`cursor-flake` expose an Intel macOS package?

## Findings

1. **Nixpkgs 26.05 is the final supported Intel macOS release.** Platform
   support and binary builds continue only until 26.05 reaches end of life on
   2026-12-31. Nixpkgs 26.11 does not build packages or support source builds
   for `x86_64-darwin`.
   Tier: canonical web sources (NixOS 26.05 announcement and release notes).

2. **Current `nixos-unstable` has already crossed the removal boundary.**
   A normal `x86_64-darwin` import throws:
   `Nixpkgs 26.11 has dropped support for x86_64-darwin.` The documented
   migration is to `nixpkgs-26.05-darwin`.
   Tier: direct local evaluation of current upstream commit
   `624af665418d3c65d544145b4d34ad696439570e`.

3. **The unsupported escape hatch is not viable for this package.** Setting
   `allowDeprecatedx86_64Darwin = "force"` gets past the top-level error, but
   evaluation then fails because Darwin `libiconv` supports only
   `aarch64-darwin`. Hydra does not build Intel packages on this line.
   Tier: direct local evaluation plus current upstream `config.nix`.

4. **This repository is temporarily insulated by its lock.** Its Nixpkgs
   revision `567a49d1913ce81ac6e9582e3553dd90a955875f` is dated 2026-06-15,
   before the hard-error PR merged on 2026-06-23. Intel evaluation still works
   there with a deprecation warning. A routine flake update would remove that
   accidental compatibility.
   Tier: repository inspection, local evaluation, GitHub PR metadata.

5. **The Nix package manager itself has not dropped Intel macOS.** Upstream
   Nix still includes `x86_64-darwin` in its build matrix, and the Nix 2.35.1
   Intel Darwin binary tarball is available. The removal is in current
   Nixpkgs platform/package support, not the evaluator or daemon.
   Tier: upstream Nix source and direct release-artifact check.

6. **Cursor still publishes an Intel DMG.** Cursor's stable API returned an
   x64 DMG for version 3.13.10. Upstream application availability therefore
   is not the blocker.
   Tier: direct Cursor API response.

## Practical implication for cursor-flake

`cursor-flake` follows `nixos-unstable`. Adding `x86_64-darwin` to the primary
platform matrix would promise support that breaks on the next input update.
Apple Silicon Darwin is the only sustainable macOS target on that input.

If legacy Intel support becomes an explicit requirement, isolate it behind a
second `nixpkgs-26.05-darwin` input, label it legacy/EOL, and do not mix it
into the main platform matrix. That path receives security fixes only through
2026-12-31.
