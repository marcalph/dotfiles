{pkgs, config, lib, inputs, hostname, ... }: {
  nixpkgs.config.allowUnfree = true;

  networking.hostName      = lib.mkDefault hostname;
  networking.localHostName = lib.mkDefault hostname;
  networking.computerName  = lib.mkDefault hostname;
  system.defaults.smb.NetBIOSName = lib.mkDefault (lib.toUpper hostname);
  
  environment.systemPackages = [
    pkgs.home-manager
    pkgs.nixos-rebuild # for remote hosts builds
    pkgs.rectangle
    pkgs.firefox  # System-level for Spotlight registration
    pkgs.obsidian
    pkgs.slack
    pkgs.discord
    pkgs.bitwarden-desktop
    pkgs.vscode
    pkgs.kitty
    pkgs.anki-bin
    pkgs.qmk
    pkgs.gcc-arm-embedded  # arm-none-eabi-gcc; required to build RP2040 (Sea-Picro) firmware
    pkgs.dos2unix  # required by qmk doctor
    inputs.helix.packages."${pkgs.stdenv.hostPlatform.system}".helix
  ];
  
  nix-homebrew = {
    enable = true;
    user = "marcalph";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # Both are ad-hoc signed (not notarized). Homebrew removed the
    # --no-quarantine flag, so quarantine is stripped manually after install
    # (see postActivation below) to satisfy Gatekeeper.
    casks = [
      "qmk-toolbox"
      "vial"
    ];
  };

  system.activationScripts.postActivation.text = ''
    for app in "QMK Toolbox" "Vial"; do
      if [ -d "/Applications/$app.app" ]; then
        /usr/bin/xattr -dr com.apple.quarantine "/Applications/$app.app" 2>/dev/null || true
      fi
    done
  '';

  programs.zsh.enable = true;

  # fix builtins.toFile store-reference warning during builds.
  documentation.enable = false;
  system.stateVersion = 4;
  
  # Disabled because using Determinate                        installer
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