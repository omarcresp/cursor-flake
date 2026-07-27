# Adversarial brief

## Strongest case for adding Intel support anyway

- Cursor still ships a native x64 DMG.
- The package is mostly an unpack-and-copy derivation, so it needs less of
  Nixpkgs than a source-built application.
- The repository's current lock evaluates `x86_64-darwin`.
- A dedicated 26.05 input could keep it operational through 2026 and perhaps
  longer for users willing to accept frozen dependencies.

## Failure modes

- The current lock's compatibility disappears on the next normal
  `nix flake update`.
- The 26.11 `"force"` escape hatch already fails in core Darwin stdenv
  evaluation; it is not a credible compatibility strategy.
- A frozen 26.05 package set stops receiving security fixes after
  2026-12-31.
- Intel behavior cannot be honestly claimed without building and launching
  on Intel macOS (or a carefully configured Rosetta builder).
- One release updater would need to manage a live platform and an EOL
  platform with different Nixpkgs lifecycles.

## Adversarial conclusion

Technically possible is not the same as sustainably supported. Adding Intel
to the main matrix would create a broken-window support promise. A separate,
explicitly legacy output is defensible only if an actual user needs it and
accepts the sunset.
