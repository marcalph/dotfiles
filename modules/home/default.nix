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

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.bat
      pkgs.vim
      pkgs.tree 
    ];

    sessionVariables = {
    };
  };

  programs = {

    # starship = {
    #   enable = true;

    #   settings = {
    #     command_timeout = 100;
    #     format = "[$all](dimmed white)";

    #     character = {
    #       success_symbol = "[❯](dimmed green)";
    #       error_symbol = "[❯](dimmed red)";
    #     };

    #     git_status = {
    #       style = "bold yellow";
    #       format = "([$all_status$ahead_behind]($style) )";
    #     };

    #     jobs.disabled = true;
    #   };
    # };

  };
}