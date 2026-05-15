{ ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./vscode.nix
    ./kitty.nix
    ./firefox.nix
  ];

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "24.11";
  fonts.fontconfig.enable = true;
  programs.neovim.enable = true;
}
