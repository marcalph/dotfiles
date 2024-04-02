{ config, pkgs, lib, ... }:

{
  # imports = [
  #   ./nvim.nix
  #   ./tmux.nix
  #   ./git.nix
  #   ./wezterm.nix
  # ];

  home = {
    stateVersion = "23.11"; # Please read the comment before changing.
    # home.packages option allows install of nix packages user profile
    packages = with pkgs; [
      tree
      less
      (pkgs.nerdfonts.override { fonts = ["Hack"]; })
    ];
  # # Required to get the fonts installed by home-manager to be picked up by OS.
  # fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];
  # fonts.fontconfig.enable = true;
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };
  };
  fonts.fontconfig.enable = true;
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.eza.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  # programs.zsh.autosuggestion.enable =  true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellAliases = {
    ll = "ls -hailF --color=auto";
    ls = "ls --color=auto -F";
    nixswitch = "darwin-rebuild switch --flake flake.nix";
  };
  programs.alacritty = {
    enable = true;
    settings.font.normal.family = "Hack Nerd Font Mono";
    settings.font.size = 16;
  };
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
    # home.file.".inputrc".source = ./dotfiles/inputrc;

}