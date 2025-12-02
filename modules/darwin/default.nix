{pkgs, config, ... }: {
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = [
    pkgs.home-manager
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
      persistent-apps = [
        "/Applications/Slack.app"
        "/Applications/Firefox.app"
        "/Users/marcalph/Applications/Home Manager Apps/Visual Studio Code.app"
        "/Applications/Notion.app"
        "/Applications/Notes.app"
        "/System/Applications/Utilities/Terminal.app"
        "/Users/marcalph/Applications/Home Manager Apps/Anki.app"
        "/Users/marcalph/Applications/Home Manager Apps/Rectangle.app"
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