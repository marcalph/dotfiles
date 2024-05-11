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
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
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
  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;
    # casks = [
    #   "1password"
    #   "bartender"
    #   "fantastical"
    #   "firefox"
    #   "hammerspoon"
    #   "karabiner-elements"
    #   "obsidian"
    #   "raycast"
    #   "soundsource"
    #   "wezterm"
    # ];

    masApps = {
      "reMarkable desktop" = 1276493162;
      # "Drafts" = 1435957248;
      # "Reeder" = 1529448980;
      # "Things" = 904280696;
      # "Timery" = 1425368544;
    };
  };

}