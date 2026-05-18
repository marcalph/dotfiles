{pkgs, config, lib, inputs,... }: {
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.rectangle
    pkgs.firefox  # System-level for Spotlight registration
    pkgs.obsidian
    pkgs.slack
    pkgs.discord
    pkgs.bitwarden-desktop
    pkgs.vscode
    pkgs.kitty
    pkgs.anki-bin
    inputs.helix.packages."${pkgs.stdenv.hostPlatform.system}".helix
  ];
  
  programs.zsh.enable = true;
  system.stateVersion = 4;
  
  # Disabled because using Determinate Systems Nix installer
  nix.enable = false;
  
  # Required for newer nix-darwin (system defaults need a primary user)
  system.primaryUser = "marcalph";

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      show-process-indicators = false;
      show-recents = false;
      static-only = true;
      persistent-apps = lib.mkDefault [
        "/Applications/Nix Apps/Firefox.app"
        "/Applications/Nix Apps/Visual Studio Code.app"
        "/Applications/Nix Apps/Obsidian.app"
        "/Applications/Nix Apps/Bitwarden.app"
        "/Applications/Nix Apps/kitty.app"
        "/Applications/Nix Apps/Anki.app"
        "/Applications/Nix Apps/Rectangle.app"
      ];
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

}