{ inputs }:
let
  inherit (inputs) nixpkgs home-manager;
in {
  mkDarwin = hostname:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [
          inputs.nix-vscode-extensions.overlays.default
          inputs.nur.overlays.default
        ];
      };
      specialArgs = { inherit inputs hostname; };
      modules = [
        ../modules/darwin
        ../modules/hosts/${hostname}.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.marcalph = import ../modules/home;
          };
          users.users.marcalph.home = "/Users/marcalph";
        }
      ];
    };

  mkNixos = { hostname, system ? "x86_64-linux" }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostname; };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.nix-vscode-extensions.overlays.default
            inputs.nur.overlays.default
          ];
        }
        ../modules/nixos
        ../modules/hosts/${hostname}
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.marcalph = import ../modules/home;
          };
        }
      ];
    };
}
