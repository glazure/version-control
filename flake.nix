{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    formatter.${system} = pkgs.alejandra;

    packages.${system}.default = let
      manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
    in
      pkgs.rustPlatform.buildRustPackage {
        pname = manifest.name;
        inherit (manifest) version;
        cargoLock.lockFile = ./Cargo.lock;
        src = pkgs.lib.cleanSource ./.;
      };

    devShells = pkgs.mkShell {
      buildInputs = with pkgs; [
        cargo
        rust-analyzer
        rustfmt
        clippy
      ];
    };
  };
}
