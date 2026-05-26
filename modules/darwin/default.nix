{pkgs, config, lib, inputs, hostname, ... }: {
  nixpkgs.config.allowUnfree = true;

  networking.hostName      = lib.mkDefault hostname;
  networking.localHostName = lib.mkDefault hostname;
  networking.computerName  = lib.mkDefault hostname;
  system.defaults.smb.NetBIOSName = lib.mkDefault (lib.toUpper hostname);
  
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.nixos-rebuild # for remote builds
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
      autohide = lib.mkDefault true;
      orientation = lib.mkDefault "bottom";
      show-process-indicators = lib.mkDefault true;
      show-recents = lib.mkDefault true;
      static-only = lib.mkDefault true;
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
      AppleShowAllExtensions = lib.mkDefault true;
      AppleShowAllFiles = lib.mkDefault true;
      InitialKeyRepeat = lib.mkDefault 14;
      KeyRepeat = lib.mkDefault 1;
    };
    finder = {
      AppleShowAllExtensions = lib.mkDefault true;
      ShowPathbar = lib.mkDefault true;
      _FXShowPosixPathInTitle = lib.mkDefault true;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;
  system.keyboard.enableKeyMapping = lib.mkDefault true;
  system.keyboard.remapCapsLockToEscape = lib.mkDefault true;

}