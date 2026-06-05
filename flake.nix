{
  description = "My darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix User Repository (for firefox extensions)
    nur.url = "github:nix-community/NUR";
    helix.url = "github:helix-editor/helix/master";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # macOS-style key remapping on pro (GNOME/Wayland); see modules/hosts/pro.nix
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-darwin, ... }:
    let
      helpers = import ./lib { inherit inputs; };
    in {
    darwinConfigurations = {
      air = helpers.mkDarwin "air";
    };
    nixosConfigurations = {
      tower = helpers.mkNixos { hostname = "tower"; };
    };
    homeConfigurations = {
      pro = helpers.mkHome { hostname = "pro"; }; #hm doesnt own hostname, here it is just a build flag
    };
    # Add devShell for development
    # Correct devShell using pkgs.mkShell
    devShells = {
      aarch64-darwin = {
        default = let
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
        in pkgs.mkShell {
          packages = with pkgs; [
            xz
            zlib
            pkg-config
            ncurses
            readline
            gcc
            gnumake
            zlib
            libffi
            readline
            bzip2
            ncurses
            # Add other dependencies you need for your dev shell
          ];
          shellHook = '' 
          export LDFLAGS="-L${pkgs.libffi.out}/lib -L${pkgs.bzip2.out}/lib -L${pkgs.xz.out}/lib -L${pkgs.zlib.out}/lib -L${pkgs.ncurses.out}/lib -L${pkgs.readline.out}/lib -L${pkgs.openssl.out}/lib"
          export CFLAGS="-I${pkgs.xz.dev}/include -I${pkgs.zlib.dev}/include -I${pkgs.bzip2.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.ncurses.dev}/include -I${pkgs.readline}/include -I${pkgs.openssl.dev}/include"
          export CXXFLAGS="-I${pkgs.xz.dev}/include -I${pkgs.zlib.dev}/include  -I${pkgs.bzip2.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.ncurses.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.openssl.dev}/include"
          export CPPFLAGS="-I${pkgs.xz.dev}/include -I${pkgs.zlib.dev}/include  -I${pkgs.bzip2.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.ncurses.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.openssl.dev}/include"
          export PKG_CONFIG_PATH="${pkgs.xz.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig:${pkgs.bzip2.dev}/lib/pkgconfig:${pkgs.libffi.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.readline.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig"
          '';
        };
      };
    };
  };
}
