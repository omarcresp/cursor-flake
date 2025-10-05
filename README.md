# Cursor for NixOS

This repository contains a Nix flake for packaging Cursor, an AI-first code editor, for use on NixOS systems.

## Table of Contents

1. [About Cursor](#about-cursor)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Version Management](#version-management)
5. [Contributing](#contributing)
6. [License](#license)

## About Cursor

Cursor is an AI-first code editor designed to enhance productivity through AI-assisted coding. It offers features like code completion, refactoring suggestions, and natural language command processing.

For more information about Cursor, visit the [official website](https://cursor.sh/).

## Installation

To install Cursor using this flake, follow these steps:

1. Ensure you have flakes enabled in your NixOS configuration.

2. Add this flake to your `flake.nix`:

   ```nix
   {
     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Note that nixos unstable channel is required
       cursor.url = "github:omarcresp/cursor-flake/main";
     };

     outputs = { self, nixpkgs, cursor }: {
       # Your existing configuration...
       
       nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
         # ...
         modules = [
           # ...
           ({ pkgs, ... }: {
             environment.systemPackages = [ cursor.packages.${pkgs.system}.default ];
           })
         ];
       };
     };
   }
   ```

3. Run `sudo nixos-rebuild switch` to apply the changes. It can also be registered with home manager

## Usage

After installation, you can launch Cursor from your application menu or by running `cursor` in your terminal.

## Version Management

To ensure proper version management and take full advantage of Nix's reproducibility features, we recommend the following:

1. **Disable auto-updates in Cursor**: 
   - Open Cursor
   - Go to Settings (gear icon) > Updates
   - Disable "Automatically download and install updates"

2. **Update using Nix**:
   To update Cursor, update the flake input in your `flake.nix` and rebuild your system:

   ```sh
   nix flake update
   sudo nixos-rebuild switch
   ```

This approach ensures that your Cursor version is managed atomically with the rest of your system, providing better stability and reproducibility.

## Contributing

We welcome contributions to improve this Nix package for Cursor! Here are some ways you can contribute:

1. **Testing**: Try the package on different NixOS configurations and report any issues.
2. **Documentation**: Help improve this README or add wiki pages with tips and tricks.
3. **Code Improvements**: Suggest improvements to the Nix expression or flake configuration.
4. **Version Updates**: Help keep the package up-to-date with the latest Cursor releases.

To contribute:

1. Fork this repository
2. Create a new branch for your changes
3. Make your changes and commit them
4. Push to your fork and submit a pull request

## License

This Nix package is distributed under the MIT License. See the `LICENSE` file for more information.

Note: While this package is MIT licensed, Cursor itself may have its own licensing terms. Please refer to the [Cursor website](https://cursor.sh/) for details on Cursor's license.

---

For any questions or issues, please open an issue on the GitHub repository.
