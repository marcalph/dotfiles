{ inputs }:
let
  inherit (inputs) nixpkgs home-manager;
  overlays = [
    inputs.nix-vscode-extensions.overlays.default
    inputs.nur.overlays.default
    # nixpkgs 4df1b88 ships highlight's shellscript-crash-fix.patch already applied
    # upstream, so it fails to apply ("reversed or previously applied"). Drop the
    # now-redundant patch (the fix is in the source). Remove once nixpkgs fixes it.
    (final: prev: {
      highlight = prev.highlight.overrideAttrs (old: {
        patches = builtins.filter
          (p: !(prev.lib.hasInfix "shellscript-crash-fix" (baseNameOf (toString p))))
          (old.patches or [ ]);
      });
    })
  ];
in {
  mkDarwin = hostname:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        # bitwarden-desktop pins electron 39 (same as upstream Bitwarden); nixpkgs
        # flags it once that electron major hits EOL. Clears when bitwarden bumps.
        config.permittedInsecurePackages = [ "electron-39.8.10" ];
        inherit overlays;
      };
      specialArgs = { inherit inputs hostname; };
      modules = [
        ../modules/darwin
        ../modules/hosts/${hostname}.nix
        inputs.nix-homebrew.darwinModules.nix-homebrew
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

  # Standalone home-manager to handle only user env
  mkHome = { hostname, system ? "x86_64-linux" }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-39.8.10" ];
        inherit overlays;
      };
      extraSpecialArgs = { inherit inputs hostname; };
      modules = [
        ../modules/home
        ../modules/hosts/${hostname}.nix
        {
          home.username = "marc.alphonsus";
          home.homeDirectory = "/home/marc.alphonsus";
        }
      ];
    };

  mkNixos = { hostname, system ? "x86_64-linux" }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostname; };
      modules = [
        {
          nixpkgs.overlays = overlays;
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
