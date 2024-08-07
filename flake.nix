{
  description = "My darwin system";

  inputs = {
    # pin nixpkgs and home-manager version
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    # manages config and links stuff into homedir
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # control system level config for macOS
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-darwin, ... }:{
    # nix-darwin expects a darwinConfigurations key
    darwinConfigurations = {
      # my macbook air machine
      air = 
        # darwinSystem is a function inherited from the nix-darwin lib namespace
        inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # alternatively "x86_64-darwin"
          pkgs = import inputs.nixpkgs {system = "aarch64-darwin"; };
        modules = [
          # include the nix-darwin module
          ./modules/darwin
          # setup home-manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {              
              # include the home-manager module
              users.marcalph = import ./modules/home;
            };
            users.users.marcalph.home = "/Users/marcalph";
          }
        ];
      };
      pro = 
        # darwinSystem is a function inherited from the nix-darwin lib namespace
        inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # alternatively "x86_64-darwin"
          pkgs = import inputs.nixpkgs {system = "aarch64-darwin"; };
        modules = [
          # include the nix-darwin module
          ./modules/darwin
          # setup home-manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {             
              # include the home-manager module
              users.marcalph = import ./modules/home;
            };
            users.users.marcalph.home = "/Users/marcalph";
          }
        ];
      };
      
    };
  };
}
