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
  # manpage generation builds the options doc (builtins.toFile options.json),
  # which emits an unreliable store-reference warning; we don't use these docs.
  manual.manpages.enable = false;
  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
  programs.neovim.enable = true;
}
