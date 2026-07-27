# Synthesis

## Recommendation

Do not add `x86_64-darwin` to the normal `cursor-flake` systems list.
Keep macOS support scoped to Apple Silicon.

## What to copy

- Nixpkgs 26.05's explicit deprecation and EOL language.
- Its separate `nixpkgs-26.05-darwin` migration path if legacy support is
  ever required.

## What to reject

- `allowDeprecatedx86_64Darwin = "force"` on unstable: direct evaluation
  proves the package set is already internally unsupported.
- Relying on the current lock's pre-removal behavior.
- Calling Intel supported merely because Cursor still publishes a DMG.

## What to adapt

- Document the current platform as `macOS Apple Silicon`, not generic macOS.
- Keep release metadata extensible by system, so a separate legacy Intel
  output remains reversible without contaminating the primary matrix.

## Golden synthesis

One altitude up, the relevant contract is sustained package-manager support,
not artifact availability. Keeping a single supported Darwin target preserves
a simple interface and avoids leaking an EOL Nixpkgs fork into every update.
The existing per-system source seam is sufficient if a real legacy user later
justifies that complexity.

## Recommended tracer if legacy Intel is requested

Add a separate 26.05-pinned legacy flake output, build it on an Intel Mac,
verify Cursor's signature and CLI, label its 2026-12-31 support sunset, then
stop for user feedback before wiring it into automatic updates.
