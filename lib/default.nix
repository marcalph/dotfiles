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
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "backup";
            users.marcalph = import ../modules/home;
          };
          users.users.marcalph.home = "/Users/marcalph";
        }
      ];
    };
}
