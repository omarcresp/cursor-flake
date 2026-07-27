# Cursor Flake

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Auto Update](https://github.com/omarcresp/cursor-flake/actions/workflows/update.yml/badge.svg)](https://github.com/omarcresp/cursor-flake/actions/workflows/update.yml)

Nix flake for [Cursor](https://cursor.com), the AI-first code editor. Automatically updated three times daily.

## Quick Start

```sh
# Try it without installing
nix run github:omarcresp/cursor-flake

# Or add to your shell temporarily
nix shell github:omarcresp/cursor-flake
```

## Installation

### NixOS (flake)

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cursor.url = "github:omarcresp/cursor-flake";
  };

  outputs = { nixpkgs, cursor, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            cursor.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

### Home Manager

```nix
# home.nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.cursor.packages.${pkgs.system}.default
  ];
}
```

Then rebuild:

```sh
sudo nixos-rebuild switch --flake .
# or for home-manager
home-manager switch --flake .
```

## Version Management

This flake disables Cursor's built-in auto-update (`--no-update` flag) to let Nix handle versioning. To update:

```sh
nix flake update cursor
sudo nixos-rebuild switch --flake .
```

### Auto-Updates

This repository automatically checks for new Cursor releases **three times daily** via GitHub Actions. When a new version is detected, it:

1. Fetches the latest version from Cursor's API
2. Computes the new package hash
3. Commits and pushes the update

You'll always have access to the latest version by simply updating your flake inputs.

## Platform Support

| Platform | Status |
|----------|--------|
| Linux x86_64 | Supported |
| macOS Apple Silicon | Supported |

## Contributing

1. Fork the repository
2. Create your feature branch
3. Submit a pull request

For version updates, the automated CI handles this. Manual updates can be done by running:

```sh
node update.js
```

## License

MIT License. See [LICENSE](LICENSE) for details.

Cursor itself has its own [licensing terms](https://cursor.com).
