{pkgs, config, ... }: {
  environment.systemPackages =
    [
      pkgs.home-manager
    ];
  # Auto upgrade nix package and the daemon 
  services.nix-daemon.enable = true;
  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };
  # allow spotlight indexing
  environment.pathsToLink = ["/Applications"];
  # set some OSX preferences 
  system.defaults = {
    # minimal dock
    dock = {
      autohide = true;
      orientation = "bottom";
      show-process-indicators = false;
      show-recents = false;
      static-only = true;
      persistent-apps = [
        "/Applications/Slack.app/"
        "/Applications/Firefox.app/"
        "/Applications/Visual Studio Code.app"
        "/Applications/Notion.app"
        "/Applications/Notes.app"
        "/Applications/utilities/Terminal.app"
      ];
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    # a finder that tells me what I want to know and lets me work
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
    };
  };
  security.pam.enableSudoTouchIdAuth = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

}