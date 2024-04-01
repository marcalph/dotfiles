{
  description = "My darwin system";

  inputs = {
    # I pinned darwin to a particular release
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    # I then pinned home-manager so that it would not issue the mismatch error
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }: {
    darwinConfigurations = {
      "air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # alternatively "aarch64-darwin"
        modules = [
          # include the darwin module
          ./darwin.nix
          # setup home-manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              # include the home-manager module
              users.marcalph = import ./home.nix;
            };
            users.users.marcalph.home = "/Users/marcalph";
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
