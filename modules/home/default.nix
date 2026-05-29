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

  home.stateVersion = "24.11";
  fonts.fontconfig.enable = true;
  programs.neovim.enable = true;
}
