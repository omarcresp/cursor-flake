{
  description = "Flake for Cursor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./default.nix {};
        packages.legacy = pkgs.callPackage ./legacy.nix {};

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };
        apps.legacy = flake-utils.lib.mkApp {
          drv = self.packages.${system}.legacy;
        };
      }
    );
}
