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
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix User Repository (for firefox extensions)
    nur.url = "github:nix-community/NUR";
    helix.url = "github:helix-editor/helix/master";
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-darwin, ... }:{
    darwinConfigurations = {
      air =
        inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; 
          pkgs = import inputs.nixpkgs {
            config.allowUnfree = true;
            overlays = [
              inputs.nix-vscode-extensions.overlays.default
              inputs.nur.overlays.default
            ];
          };
          # Set all inputs parameters as special arguments for all submodules
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "backup";
                # include the home-manager module
                users.marcalph = import ./modules/home;
              };
              users.users.marcalph.home = "/Users/marcalph";
            }
          ];
        };
      rizoapro =
        # darwinSystem is a function inherited from the nix-darwin lib namespace
        inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # alternatively "x86_64-darwin"
          pkgs = import inputs.nixpkgs {
            config.allowUnfree = true;
            overlays = [
              inputs.nix-vscode-extensions.overlays.default
              inputs.nur.overlays.default
            ];
          };
        modules = [
          # include the nix-darwin module
          ./modules/darwin
          # setup home-manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              backupFileExtension = "backup";
              # include the home-manager module
              users.marcalph = import ./modules/home;
            };
            users.users.marcalph.home = "/Users/marcalph";
          }
        ];
      };
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
