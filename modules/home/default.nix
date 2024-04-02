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
      tldr
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
  programs.eza.enable = true;
  # programs.eza.enableZshIntegration = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  # programs.zsh.autosuggestion.enable = true;
  programs.zsh.envExtra = "";
  programs.zsh.history.ignoreDups = true;
  # programs.zsh.autosuggestion.enable =  true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellAliases = {
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -iv";
    ll = "eza -hailF --icons";
    ls = "eza --grid --icons";
    tree = "eza --tree --icons"; 
    ga = "git add";
    gc = "git commit";
    gs = "git status | head -n 2; exa --git -l";
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