{pkgs, config, ... }: {
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = [ 
    pkgs.home-manager
    pkgs.anki-bin
    pkgs.vscode
  ];
  
  programs.zsh.enable = true;
  system.stateVersion = 4;
  
  # Disabled because using Determinate Systems Nix installer
  nix.enable = false;
  
  # Required for newer nix-darwin (system defaults need a primary user)
  system.primaryUser = "marcalph";
  
  environment.pathsToLink = ["/Applications"];
  
  # Create proper app links for Spotlight indexing
  system.activationScripts.applications.text = pkgs.lib.mkForce ''
    echo "Setting up /Applications..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while IFS= read -r app; do
      src="$(/usr/bin/stat -f%Y "$app")"
      appname="$(basename "$app")"
      echo "Copying $appname..."
      /usr/bin/ditto "$src" "/Applications/Nix Apps/$appname" 2>/dev/null || true
    done
  ''; 
  system.defaults = {
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
        "/Applications/Nix Apps/Anki.app"
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